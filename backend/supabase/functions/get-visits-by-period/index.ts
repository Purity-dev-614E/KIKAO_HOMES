import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // Allow all origins
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
};

function getDateRange(period: string): { start: string; end: string } {
  const now = new Date();
  let start: Date;
  const end = new Date(now); // today

  switch (period) {
    case "weekly":
      start = new Date(now);
      start.setDate(now.getDate() - 7);
      break;
    case "monthly":
      start = new Date(now.getFullYear(), now.getMonth(), 1);
      break;
    case "yearly":
      start = new Date(now.getFullYear(), 0, 1);
      break;
    default:
      throw new Error("Invalid period");
  }

  // return ISO format
  return {
    start: start.toISOString(),
    end: end.toISOString(),
  };
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders, status: 204 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
  );

  const { searchParams } = new URL(req.url);
  const period = searchParams.get("period") || "monthly";

  let range;
  try {
    range = getDateRange(period);
  } catch (e: unknown) {
    const errorMessage = e instanceof Error ? e.message : 'An unknown error occurred';
    return new Response(JSON.stringify({ error: errorMessage }), { status: 400, headers: corsHeaders });
  }

  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
  }

  const { data, error } = await supabase
    .from("visit_sessions")
    .select("*")
    .gte("check_in_at", range.start)
    .lte("check_in_at", range.end)
    .eq("user_id", user.id); // optional filter

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: corsHeaders });
  }

  return new Response(JSON.stringify(data), {
    headers: corsHeaders,
    status: 200
  });
});
