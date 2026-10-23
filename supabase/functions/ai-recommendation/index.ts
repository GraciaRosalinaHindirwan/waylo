import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const GEMINI_MODEL = "gemini-3.8-flash";

function response(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function buildPrompt(userMessage: string, destinations: unknown[]): string {
  return [
    "You are a travel recommendation assistant for the WAYLO app. ",
    "Here is the list of destinations available in the WAYLO database (JSON):",
    JSON.stringify(destinations),
    "",
    `The user said: "${userMessage}"`,
    "From that message, understand if there is a preference for a destination/country/area, " +
      "travel category (e.g. beach, mountain, culture), budget, or minimum rating. " +
      "Reply in a friendly and concise way (max 4 sentences) in English, " +
      "and recommend destinations from the list above that fit best. " +
      "If none of the destinations truly match the requested area, " +
      "be honest about the destinations currently available and offer the closest " +
      "alternative based on the requested category/budget/rating. " +
      "Do not reply in JSON format, reply like a normal chat message.",
  ].join("\n");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return response({ error: "Method tidak diizinkan" }, 405);
  }

  const apiKey = Deno.env.get("GEMINI_API_KEY");

  if (!apiKey) {
    return response({ error: "Konfigurasi server belum lengkap" }, 500);
  }

  try {
    const body = await req.json();
    const userMessage =
      typeof body.message === "string" ? body.message.trim() : "";
    const destinations = Array.isArray(body.destinations)
      ? body.destinations
      : [];

    if (!userMessage) {
      return response({ error: "Pesan tidak boleh kosong" }, 400);
    }

    const prompt = buildPrompt(userMessage, destinations);

    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${apiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
        }),
      },
    );

    const data = await geminiResponse.json();

    if (!geminiResponse.ok) {
      console.error("Gemini error:", data);
      return response({ error: "Gagal menghubungi AI" }, 502);
    }

    const text = data?.candidates?.[0]?.content?.parts?.[0]?.text as
      | string
      | undefined;

    return response({
      reply: text?.trim() || "Sorry, I don't have a recommendation for that yet.",
    });
  } catch (e) {
    console.error(e);
    return response({ error: "Request tidak valid" }, 400);
  }
});