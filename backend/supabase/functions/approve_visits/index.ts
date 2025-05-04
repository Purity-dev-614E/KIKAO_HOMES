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

  const { visit_id } = await req.json();

  if (!visit_id) return new Response(
    JSON.stringify({ error: "Missing visit_id" }), 
    { status: 400, headers: corsHeaders }
  );

  const { data: visit } = await supabase
    .from("visit_sessions")
    .select("unit_number")
    .eq("id", visit_id)
    .single();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: resident } = await supabase
    .from("profiles")
    .select("unit_number")
    .eq("id", user?.id || "")
    .single();

  if (!resident || resident.unit_number !== visit?.unit_number) {
    return new Response(
      JSON.stringify({ error: "Unauthorized" }), 
      { status: 403, headers: corsHeaders }
    );
  }

  const { error } = await supabase
    .from("visit_sessions")
    .update({ status: "approved", check_in_at: new Date().toISOString() })
    .eq("id", visit_id);

  if (error) return new Response(
    JSON.stringify({ error: "Error accepting visit" }), 
    { status: 500, headers: corsHeaders }
  );

  return new Response(
    JSON.stringify({ message: "Visit Accepted" }), 
    { status: 200, headers: corsHeaders }
  );
});
