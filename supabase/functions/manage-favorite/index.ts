import { createClient } from "npm:@supabase/supabase-js@2";
import { jwtVerify } from "npm:jose";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const jsonResponse = (
  body: Record<string, unknown>,
  status = 200,
) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ success: false, error: "Method not allowed" }, 405);
  }

  try {
    const authorization = req.headers.get("Authorization");
    const token = authorization?.match(/^Bearer\s+(.+)$/i)?.[1];

    if (!token) {
      return jsonResponse({ success: false, error: "Token tidak ditemukan" }, 401);
    }

    const jwtSecret = Deno.env.get("WAYLO_SESSION_SECRET");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("WAYLO_SERVICE_ROLE_KEY");

    if (!jwtSecret || !supabaseUrl || !serviceRoleKey) {
      throw new Error("Konfigurasi server belum lengkap");
    }

    // Verifikasi custom JWT WAYLO.
    const { payload } = await jwtVerify(
      token,
      new TextEncoder().encode(jwtSecret),
      { algorithms: ["HS256"] },
    );

    const userId = payload.sub;

    // users.id bertipe BIGINT, sehingga sub harus berupa angka integer.
    if (
      typeof userId !== "string" ||
      !/^\d+$/.test(userId)
    ) {
      return jsonResponse({ success: false, error: "Token user tidak valid" }, 401);
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const body = await req.json();
    const action = body.action;

    if (action === "list") {
      const { data, error } = await supabase
        .from("favorites")
        .select("destination_id")
        .eq("user_id", userId);

      if (error) throw error;

      return jsonResponse({
        success: true,
        favoriteIds: (data ?? []).map((item) => item.destination_id),
      });
    }

    const destinationId = body.destinationId;

    if (
      !["check", "add", "remove"].includes(action) ||
      !Number.isSafeInteger(destinationId) ||
      destinationId <= 0
    ) {
      return jsonResponse({
        success: false,
        error: "Aksi atau ID destinasi tidak valid",
      }, 400);
    }

    if (action === "check") {
      const { data, error } = await supabase
        .from("favorites")
        .select("id")
        .eq("user_id", userId)
        .eq("destination_id", destinationId)
        .maybeSingle();

      if (error) throw error;

      return jsonResponse({
        success: true,
        isFavorite: data != null,
      });
    }

    if (action === "add") {
      const { error } = await supabase
        .from("favorites")
        .upsert(
          {
            user_id: userId,
            destination_id: destinationId,
          },
          {
            onConflict: "user_id,destination_id",
            ignoreDuplicates: true,
          },
        );

      if (error) throw error;

      return jsonResponse({ success: true, isFavorite: true });
    }

    const { error } = await supabase
      .from("favorites")
      .delete()
      .eq("user_id", userId)
      .eq("destination_id", destinationId);

    if (error) throw error;

    return jsonResponse({ success: true, isFavorite: false });
  } catch (error) {
    console.error("manage-favorite error:", error);

    return jsonResponse({
      success: false,
      error: error instanceof Error
        ? error.message
        : "Gagal memproses favorite",
    }, 500);
  }
});