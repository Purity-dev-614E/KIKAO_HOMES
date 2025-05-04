import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // Allow all origins
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
};

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

  const { data: visits, error } = await supabase
    .from("visit_sessions")
    .select("*")
    .in("status", ["approved"])
    .order("created_at", { ascending: false });

  if (error) return new Response(
    JSON.stringify({ error: "Error fetching active visits" }), 
    { status: 500, headers: corsHeaders }
  );

  return new Response(
    JSON.stringify({ visits }), 
    { status: 200, headers: corsHeaders }
  );
});
