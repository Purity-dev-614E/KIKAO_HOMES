import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // Allow all origins
  "Access-Control-Allow-Methods": "POST, OPTIONS",
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

  const { national_id } = await req.json();

  if (!national_id) {
    return new Response(
      JSON.stringify({ error: "Missing national_id" }), 
      { status: 400, headers: corsHeaders }
    );
  }

  const { data: visit, error } = await supabase
    .from("visit_sessions")
    .select("*")
    .eq("national_id", national_id)
    .eq("status", "approved")
    .order("created_at", { ascending: false })
    .limit(1)
    .single();

  if (error || !visit) return new Response(
    JSON.stringify({ error: "Visit not found" }), 
    { status: 404, headers: corsHeaders }
  );

  const { error: updateError } = await supabase
    .from("visit_sessions")
    .update({ status: "checked_out", check_out_at: new Date().toISOString() })
    .eq("id", visit.id);

  if (updateError) return new Response(
    JSON.stringify({ error: "Failed to check out" }), 
    { status: 500, headers: corsHeaders }
  );

  return new Response(
    JSON.stringify({ message: "Visitor checked out" }), 
    { status: 200, headers: corsHeaders }
  );
});
