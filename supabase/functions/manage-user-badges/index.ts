import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { ethers } from "npm:ethers@6";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("WAYLO_SERVICE_ROLE_KEY")!;
const sessionSecret = Deno.env.get("WAYLO_SESSION_SECRET");

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false,
  },
});


const BADGE_CONTRACT_ABI = [
  "function recordBadge(bytes32 userHash, bytes32 badgeHash) external",
  "function hasBadge(bytes32 userHash, bytes32 badgeHash) external view returns (bool)",
];

async function recordBadgeOnBlockchain(
  userId: number,
  badgeId: string,
): Promise<string | null> {
  const privateKey = Deno.env.get("WAYLO_BADGE_PRIVATE_KEY");
  const contractAddress = Deno.env.get("WAYLO_BADGE_CONTRACT_ADDRESS");
  const rpcUrl = Deno.env.get("WAYLO_SEPOLIA_RPC_URL");

  if (!privateKey || !contractAddress || !rpcUrl) {
    throw new Error("Konfigurasi blockchain belum lengkap");
  }

  const provider = new ethers.JsonRpcProvider(rpcUrl);
  const wallet = new ethers.Wallet(privateKey, provider);

  const contract = new ethers.Contract(
    contractAddress,
    BADGE_CONTRACT_ABI,
    wallet,
  );

  // Hash ID pengguna dan ID badge agar tidak mengirim identitas asli
  // ke blockchain.
  const userHash = ethers.keccak256(
    ethers.toUtf8Bytes(`waylo-user:${userId}`),
  );
  const badgeHash = ethers.keccak256(
    ethers.toUtf8Bytes(`waylo-badge:${badgeId}`),
  );

  // Jangan kirim transaksi jika badge sudah tercatat.
  const alreadyRecorded = await contract.hasBadge(userHash, badgeHash);

  if (alreadyRecorded) {
    return null;
  }

  const tx = await contract.recordBadge(userHash, badgeHash);
  const receipt = await tx.wait();

  if (!receipt || receipt.status !== 1) {
    throw new Error("Transaksi pencatatan badge gagal");
  }

  return tx.hash;
}


const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, content-type, apikey, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
) {
  return Response.json(body, { status, headers: corsHeaders });
}

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

type BadgeProgress = {
  badgeId: string;
  progress: number;
  targetCount: number;
};


async function saveCalculatedProgress(
  userId: number,
  badgeId: string,
  progress: number,
) {
  const { data: badge, error: badgeError } = await supabase
    .from("travel_badges")
    .select("id, target_count")
    .eq("id", badgeId)
    .maybeSingle();

  if (badgeError) throw badgeError;
  if (!badge) return;

  const { data: previous, error: previousError } = await supabase
    .from("user_badges")
    .select("progress, is_unlocked, unlocked_at")
    .eq("user_id", userId)
    .eq("badge_id", badgeId)
    .maybeSingle();

  if (previousError) throw previousError;

  const finalProgress = Math.min(
    badge.target_count,
    Math.max(progress, previous?.progress ?? 0),
  );

  const isUnlocked =
    previous?.is_unlocked === true ||
    finalProgress >= badge.target_count;

  const newlyUnlocked =
    isUnlocked && previous?.is_unlocked !== true;

  const unlockedAt = isUnlocked
    ? previous?.unlocked_at ?? new Date().toISOString()
    : null;

  const { error } = await supabase
    .from("user_badges")
    .upsert(
      {
        user_id: userId,
        badge_id: badgeId,
        progress: finalProgress,
        is_unlocked: isUnlocked,
        unlocked_at: unlockedAt,
      },
      { onConflict: "user_id,badge_id" },
    );

  if (error) throw error;

  // Catat ke blockchain hanya ketika badge baru terbuka.
  if (newlyUnlocked) {
    try {
      const txHash = await recordBadgeOnBlockchain(userId, badgeId);

      if (txHash) {
        const { error: recordError } = await supabase
          .from("user_badge_blockchain_records")
          .upsert(
            {
              user_id: userId,
              badge_id: badgeId,
              tx_hash: txHash,
              chain_id: 11155111,
            },
            { onConflict: "user_id,badge_id" },
          );

        if (recordError) {
          console.error(
            "Gagal menyimpan hash transaksi badge:",
            recordError,
          );
        }
      }
    } catch (blockchainError) {
      // Kegagalan blockchain tidak menghapus progres badge di Supabase.
      console.error(
        `Gagal mencatat badge ${badgeId} ke blockchain:`,
        blockchainError,
      );
    }
  }
}

function categoryMatches(
  categoryName: string,
  type: "culture" | "food",
): boolean {
  const name = categoryName.trim().toLowerCase();

  if (type === "culture") {
    return name === "cultural" ||
      name === "culture" ||
      name === "historical" ||
      name === "history";
  }

  return name === "culinary" ||
    name === "food" ||
    name === "cuisine" ||
    name === "kuliner";
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse(
      { success: false, error: "Method not allowed" },
      405,
    );
  }

  try {
    const authorization = req.headers.get("Authorization") ?? "";
    const token = authorization.startsWith("Bearer ")
      ? authorization.slice(7)
      : "";

    const userId = token ? await verifyToken(token) : null;

    if (!userId) {
      return jsonResponse(
        {
          success: false,
          error: "Token sesi tidak valid atau kedaluwarsa",
        },
        401,
      );
    }

    const body = await req.json();
    const action = body?.action;

    // Mengambil progres hanya untuk pengguna dari token.
    if (action === "list") {
      const { data, error } = await supabase
        .from("user_badges")
        .select("user_id, badge_id, progress, is_unlocked, unlocked_at")
        .eq("user_id", userId);

      if (error) throw error;

      return jsonResponse({ success: true, badges: data ?? [] });
    }

    // Mencatat kunjungan dan menghitung progres di backend.
    if (action === "record_visit") {
      const destinationId = body?.destinationId;

      if (
        typeof destinationId !== "string" ||
        !/^\d+$/.test(destinationId) ||
        !Number.isSafeInteger(Number(destinationId)) ||
        Number(destinationId) <= 0
      ) {
        return jsonResponse(
          { success: false, error: "Destination ID tidak valid" },
          400,
        );
      }

      const numericDestinationId = Number(destinationId);

      // Pastikan destinasi memang ada di database.
      const { data: destination, error: destinationError } =
        await supabase
          .from("destinations")
          .select("id, name")
          .eq("id", numericDestinationId)
          .maybeSingle();

      if (destinationError) throw destinationError;

      if (!destination) {
        return jsonResponse(
          { success: false, error: "Destinasi tidak ditemukan" },
          404,
        );
      }

      // PRIMARY KEY user_id + destination_id mencegah kunjungan
      // destinasi yang sama dihitung berulang kali.
      const { error: visitError } = await supabase
        .from("user_destination_visits")
        .upsert(
          {
            user_id: userId,
            destination_id: numericDestinationId,
          },
          {
            onConflict: "user_id,destination_id",
            ignoreDuplicates: true,
          },
        );

      if (visitError) throw visitError;

      // Ambil semua destinasi unik yang pernah dicatat untuk user ini.
      const { data: visits, error: visitsError } = await supabase
        .from("user_destination_visits")
        .select("destination_id")
        .eq("user_id", userId);

      if (visitsError) throw visitsError;

      const destinationIds = [
        ...new Set((visits ?? []).map((visit) => visit.destination_id)),
      ];

      const totalVisited = destinationIds.length;

      const normalizedName = destination.name.toLowerCase();

      // China Starter: setidaknya satu destinasi dikunjungi.
      await saveCalculatedProgress(userId, "china_starter", totalVisited > 0 ? 1 : 0);

      // Curious Explorer: lima destinasi unik.
      await saveCalculatedProgress(
        userId,
        "curious_explorer",
        totalVisited,
      );

      // Badge khusus berdasarkan nama destinasi di database.
      const { data: greatWallDestinations, error: greatWallError } =
        await supabase
          .from("destinations")
          .select("id")
          .or("name.ilike.%great wall%,name.ilike.%mutianyu%");

      if (greatWallError) throw greatWallError;

      const visitedGreatWall = (greatWallDestinations ?? []).some(
        (item) => destinationIds.includes(item.id),
      );

      if (visitedGreatWall) {
        await saveCalculatedProgress(userId, "great_wall_dreamer", 1);
      }

      const { data: pandaDestinations, error: pandaError } =
        await supabase
          .from("destinations")
          .select("id")
          .or("name.ilike.%panda%,name.ilike.%chengdu%");

      if (pandaError) throw pandaError;

      const visitedPandaDestination = (pandaDestinations ?? []).some(
        (item) => destinationIds.includes(item.id),
      );

      if (
        normalizedName.includes("panda") ||
        normalizedName.includes("chengdu") ||
        visitedPandaDestination
      ) {
        await saveCalculatedProgress(userId, "panda_fan", 1);
      }

      
      // Ambil kategori semua destinasi yang sudah dikunjungi.
      if (destinationIds.length > 0) {
        const { data: categoryRows, error: categoryError } =
          await supabase
            .from("destination_category")
            .select(`
              id_destination,
              category:category!destination_category_id_category_fkey (
                name
              )
            `)
            .in("id_destination", destinationIds);

        if (categoryError) throw categoryError;

        // Deklarasikan sebelum digunakan.
        const cultureIds = new Set<number>();
        const foodIds = new Set<number>();

        for (const row of categoryRows ?? []) {
          const category = Array.isArray(row.category)
            ? row.category[0]
            : row.category;

          const categoryName = category?.name;

          if (typeof categoryName !== "string") continue;

          if (categoryMatches(categoryName, "culture")) {
            cultureIds.add(row.id_destination);
          }

          if (categoryMatches(categoryName, "food")) {
            foodIds.add(row.id_destination);
          }
        }

        await saveCalculatedProgress(
          userId,
          "culture_seeker",
          cultureIds.size,
        );

        await saveCalculatedProgress(
          userId,
          "food_hunter",
          foodIds.size,
        );
      }

      return jsonResponse({
        success: true,
        message: "Kunjungan berhasil dicatat",
        totalVisited,
      });
    }

    // Jangan menerima progres badge yang ditentukan Flutter.
    if (action === "save") {
      return jsonResponse(
        {
          success: false,
          error: "Progres harus dihitung oleh backend",
        },
        403,
      );
    }

    return jsonResponse(
      { success: false, error: "Action tidak dikenal" },
      400,
    );
  } catch (error) {
    console.error("manage-user-badges:", error);

    return jsonResponse(
      {
        success: false,
        error: "Gagal memproses badge pengguna",
      },
      500,
    );
  }
});
