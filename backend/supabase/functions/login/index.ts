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

  const { email, password } = await req.json();

  // Check if email and password are provided
  if (!email || !password) {
    return new Response(
      JSON.stringify({ error: "Missing fields" }), 
      { status: 400, headers: corsHeaders }
    );
  }

  const supabaseAdmin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // Step 1: Authenticate user with email and password
  const { data, error } = await supabaseAdmin.auth.signInWithPassword({
    email,
    password,
  });

  // Handle error if authentication fails
  if (error) {
    console.error("Error authenticating user:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 401, headers: corsHeaders }
    );
  }

  // Step 2: Return authentication token if successful
  return new Response(
    JSON.stringify({
      message: "User authenticated successfully",
      access_token: data?.session?.access_token,
    }),
    { status: 200, headers: corsHeaders }
  );
});

