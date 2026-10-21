  
import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("WAYLO_SERVICE_ROLE_KEY")!;
const sessionSecret = Deno.env.get("WAYLO_SESSION_SECRET");

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false,
  },
});

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
  if (!sessionSecret) return null;

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

    if (
      typeof payload.exp !== "number" ||
      payload.exp <= Date.now() / 1000
    ) {
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

    return Number.isSafeInteger(userId) && userId > 0
      ? userId
      : null;
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

    const userId = token ? await verifyToken(token) : null;

    if (!userId) {
      return Response.json(
        { error: "Token sesi tidak valid atau kedaluwarsa" },
        { status: 401, headers: corsHeaders },
      );
    }

    const { data: categories, error: categoryError } = await supabase
      .from("user_category_preference")
      .select("id_category")
      .eq("id_user", userId);

    if (categoryError) throw categoryError;

    const { data: districts, error: districtError } = await supabase
      .from("user_destination_preferance")
      .select("id_district")
      .eq("id_user", userId);

    if (districtError) throw districtError;
    const { data: favorites, error: favoritesError } = await supabase
      .from("favorites")
      .select("destination_id")
      .eq("user_id", userId);

    if (favoritesError) throw favoritesError;

    return Response.json(
      {
        success: true,
        categoryIds: (categories ?? []).map(
          (row) => Number(row.id_category),
        ),
        districtIds: (districts ?? []).map(
          (row) => Number(row.id_district),
        ),
        favoriteDestinationIds: (favorites ?? []).map(
          (row) => Number(row.destination_id),
        ),
      },
      { status: 200, headers: corsHeaders },
    );
  } catch (error) {
    console.error("get-user-preferences:", error);

    return Response.json(
      { error: "Gagal mengambil preferensi pengguna" },
      { status: 500, headers: corsHeaders },
    );
  }
});
