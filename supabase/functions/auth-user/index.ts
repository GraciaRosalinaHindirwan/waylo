
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const ITERATIONS = 100000;
const encoder = new TextEncoder();

function response(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function toBase64(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary);
}

function fromBase64(value: string): Uint8Array {
  return Uint8Array.from(atob(value), (char) => char.charCodeAt(0));
}

async function deriveHash(password: string, salt: Uint8Array) {
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(password),
    "PBKDF2",
    false,
    ["deriveBits"],
  );

  const bits = await crypto.subtle.deriveBits(
    {
      name: "PBKDF2",
      salt,
      iterations: ITERATIONS,
      hash: "SHA-256",
    },
    key,
    256,
  );

  return new Uint8Array(bits);
}

async function hashPassword(password: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const hash = await deriveHash(password, salt);

  return `pbkdf2-sha256$${ITERATIONS}$${toBase64(salt)}$${toBase64(hash)}`;
}

async function verifyPassword(
  password: string,
  stored: string,
): Promise<boolean> {
  try {
    const parts = stored.split("$");
    if (parts.length !== 4 || parts[0] !== "pbkdf2-sha256") return false;

    const iterations = Number(parts[1]);
    if (!Number.isInteger(iterations) || iterations < 100000 ||
        iterations > 1000000) return false;

    const salt = fromBase64(parts[2]);
    const expected = fromBase64(parts[3]);

    if (salt.length !== 16 || expected.length !== 32) return false;

    const key = await crypto.subtle.importKey(
      "raw",
      encoder.encode(password),
      "PBKDF2",
      false,
      ["deriveBits"],
    );

    const bits = await crypto.subtle.deriveBits(
      {
        name: "PBKDF2",
        salt,
        iterations,
        hash: "SHA-256",
      },
      key,
      256,
    );

    const actual = new Uint8Array(bits);
    return actual.every((byte, i) => byte === expected[i]);
  } catch {
    return false;
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return response({ error: "Method tidak diizinkan" }, 405);
  }

  const url = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("WAYLO_SERVICE_ROLE_KEY");

  if (!url || !serviceKey) {
    return response({ error: "Konfigurasi server belum lengkap" }, 500);
  }

  const supabase = createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  try {
    const body = await req.json();
    const action = body.action;
    const username =
      typeof body.username === "string" ? body.username.trim() : "";
    const password = body.password;
    const fullname =
      typeof body.fullname === "string" ? body.fullname.trim() : "";

    if (
      !["register", "login"].includes(action) ||
      !/^[a-zA-Z0-9_]{3,20}$/.test(username) ||
      typeof password !== "string" ||
      password.length < 8 ||
      password.length > 128
    ) {
      return response({ error: "Username atau password tidak valid" }, 400);
    }

    if (action === "register") {
      if (!fullname || fullname.length > 50) {
        return response({ error: "Nama lengkap wajib diisi" }, 400);
      }

      const { data: existing, error: lookupError } = await supabase
        .from("users")
        .select("id")
        .eq("username", username)
        .maybeSingle();

      if (lookupError) {
        console.error("Lookup error:", lookupError);
        return response(
          {
            error: "Gagal memeriksa username",
            code: lookupError.code,
            details: lookupError.message,
          },
          500,
        );
      }

      if (existing) {
        return response({ error: "Username sudah digunakan" }, 409);
      }

      const passwordHash = await hashPassword(password);

      const { data: user, error } = await supabase
        .from("users")
        .insert({
          fullname,
          username,
          password: passwordHash,
        })
        .select("id, fullname, username, created_at, updated_at")
        .single();

      if (error) {
        if (error.code === "23505") {
          return response({ error: "Username sudah digunakan" }, 409);
        }
        return response({ error: "Registrasi gagal" }, 500);
      }

      return response({ user }, 201);
    }

    const { data: user, error } = await supabase
      .from("users")
      .select("id, fullname, username, password, created_at, updated_at")
      .eq("username", username)
      .maybeSingle();

    if (error) {
      return response({ error: "Login gagal" }, 500);
    }

    if (!user || !(await verifyPassword(password, user.password))) {
      return response({ error: "Username atau password salah" }, 401);
    }

    const { password: _passwordHash, ...safeUser } = user;
    return response({ user: safeUser });
  } catch {
    return response({ error: "Request tidak valid" }, 400);
  }
});
