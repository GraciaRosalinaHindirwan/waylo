
import { createClient } from "npm:@supabase/supabase-js@2";
import { jwtVerify } from "npm:jose";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function response(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return response({ error: "Method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    const token = authHeader?.startsWith("Bearer ")
      ? authHeader.slice(7)
      : null;

    if (!token) {
      return response({ error: "Token tidak ditemukan" }, 401);
    }

    const secret = Deno.env.get("WAYLO_SESSION_SECRET");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!secret || !supabaseUrl || !serviceRoleKey) {
      console.error("Konfigurasi secret belum lengkap");
      return response({ error: "Konfigurasi server belum lengkap" }, 500);
    }

    const key = new TextEncoder().encode(secret);
    const { payload } = await jwtVerify(token, key, {
      algorithms: ["HS256"],
    });

    // Token WAYLO harus menyimpan ID pengguna pada claim "sub".
    const userId = Number(payload.sub);

    if (!Number.isSafeInteger(userId) || userId <= 0) {
      return response({ error: "Token tidak valid" }, 401);
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    const { data: user, error } = await supabase
      .from("users")
      .select(
        "id, fullname, username, created_at, updated_at, profile_image_url, has_completed_preference",
      )
      .eq("id", userId)
      .maybeSingle();

    if (error) {
      console.error("Gagal mengambil profil:", error.message);
      return response({ error: "Gagal mengambil profil" }, 500);
    }

    if (!user) {
      return response({ error: "Akun tidak ditemukan" }, 404);
    }

    return response({ user });
  } catch (error) {
    console.error("restore-session:", error);
    return response({ error: "Token tidak valid atau kedaluwarsa" }, 401);
  }
});
