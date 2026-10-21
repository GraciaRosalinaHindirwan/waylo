import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("WAYLO_SERVICE_ROLE_KEY")!,
  {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  },
);

const sessionSecret = Deno.env.get("WAYLO_SESSION_SECRET")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, content-type, apikey, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function base64UrlToBytes(value: string): Uint8Array {
  const base64 = value.replace(/-/g, "+").replace(/_/g, "/");
  const padded = base64 + "=".repeat((4 - base64.length % 4) % 4);
  return Uint8Array.from(atob(padded), (c) => c.charCodeAt(0));
}

async function verifyToken(token: string): Promise<number | null> {
  const parts = token.split(".");
  if (parts.length !== 3) return null;

  const [headerPart, payloadPart, signaturePart] = parts;

  try {
    const header = JSON.parse(
      new TextDecoder().decode(base64UrlToBytes(headerPart)),
    );
    const payload = JSON.parse(
      new TextDecoder().decode(base64UrlToBytes(payloadPart)),
    );

    if (header.alg !== "HS256") return null;
    if (typeof payload.sub !== "string") return null;
    if (typeof payload.exp !== "number" || payload.exp <= Date.now() / 1000) {
      return null;
    }

    const key = await crypto.subtle.importKey(
      "raw",
      new TextEncoder().encode(sessionSecret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["verify"],
    );

    const valid = await crypto.subtle.verify(
      "HMAC",
      key,
      base64UrlToBytes(signaturePart),
      new TextEncoder().encode(`${headerPart}.${payloadPart}`),
    );

    if (!valid) return null;

    const userId = Number(payload.sub);
    return Number.isSafeInteger(userId) && userId > 0 ? userId : null;
  } catch {
    return null;
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return Response.json(
      { error: "Method not allowed" },
      { status: 405, headers: corsHeaders },
    );
  }

  try {
    const authorization = req.headers.get("Authorization") ?? "";
    const token = authorization.startsWith("Bearer ")
      ? authorization.slice(7)
      : "";

    if (!token || !sessionSecret) {
      return Response.json(
        { error: "Token sesi tidak tersedia" },
        { status: 401, headers: corsHeaders },
      );
    }

    const userId = await verifyToken(token);

    if (!userId) {
      return Response.json(
        { error: "Token sesi tidak valid atau kedaluwarsa" },
        { status: 401, headers: corsHeaders },
      );
    }

    const body = await req.json();
    const districtIds = body.districtIds;
    const categoryIds = body.categoryIds;

    if (
      !Array.isArray(districtIds) ||
      !Array.isArray(categoryIds) ||
      !districtIds.every(
        (id: unknown) => Number.isSafeInteger(id) && Number(id) > 0,
      ) ||
      !categoryIds.every(
        (id: unknown) => Number.isSafeInteger(id) && Number(id) > 0,
      ) ||
      districtIds.length === 0 ||
      categoryIds.length === 0
    ) {
      return Response.json(
        { error: "Pilih minimal satu district dan satu category" },
        { status: 400, headers: corsHeaders },
      );
    }

    // Pastikan ID yang dikirim memang tersedia di tabel master.
    const { data: districts, error: districtCheckError } = await supabase
      .from("district")
      .select("id")
      .in("id", districtIds);

    if (districtCheckError) throw districtCheckError;

    if (new Set(districts.map((d) => d.id)).size !== new Set(districtIds).size) {
      return Response.json(
        { error: "Ada district yang tidak valid" },
        { status: 400, headers: corsHeaders },
      );
    }

    const { data: categories, error: categoryCheckError } = await supabase
      .from("category")
      .select("id")
      .in("id", categoryIds);

    if (categoryCheckError) throw categoryCheckError;

    if (
      new Set(categories.map((c) => c.id)).size !==
      new Set(categoryIds).size
    ) {
      return Response.json(
        { error: "Ada category yang tidak valid" },
        { status: 400, headers: corsHeaders },
      );
    }

    // Hapus pilihan sebelumnya milik user yang tokennya sudah diverifikasi.
    const { error: deleteDistrictError } = await supabase
      .from("user_destination_preferance")
      .delete()
      .eq("id_user", userId);

    if (deleteDistrictError) throw deleteDistrictError;

    const { error: deleteCategoryError } = await supabase
      .from("user_category_preference")
      .delete()
      .eq("id_user", userId);

    if (deleteCategoryError) throw deleteCategoryError;

    const { error: insertDistrictError } = await supabase
      .from("user_destination_preferance")
      .insert(
        districtIds.map((id: number) => ({
          id_user: userId,
          id_district: id,
        })),
      );

    if (insertDistrictError) throw insertDistrictError;

    const { error: insertCategoryError } = await supabase
      .from("user_category_preference")
      .insert(
        categoryIds.map((id: number) => ({
          id_user: userId,
          id_category: id,
        })),
      );

    if (insertCategoryError) throw insertCategoryError;

    const { error: updateUserError } = await supabase
      .from("users")
      .update({ has_completed_preference: true })
      .eq("id", userId);

    if (updateUserError) throw updateUserError;


    return Response.json(
      { success: true },
      { status: 200, headers: corsHeaders },
    );
  } catch (error) {
    console.error("save-preference:", error);
    return Response.json(
      { error: "Gagal menyimpan preferensi" },
      { status: 500, headers: corsHeaders },
    );
  }
});