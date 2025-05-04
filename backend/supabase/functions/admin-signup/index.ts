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

  const { email, password, full_name } = await req.json();

  if (!email || !password ||!full_name) {
    return new Response(
      JSON.stringify({ error: "Missing fields" }), 
      { status: 400, headers: corsHeaders }
    );
  }

  const supabaseAdmin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // Step 1: Create the user using the signup function
  const { data: { user }, error: signUpError } = await supabaseAdmin.auth.signUp({
    email,
    password,
  });

  if (signUpError) {
    return new Response(
      JSON.stringify({ error: signUpError.message }), 
      { status: 500, headers: corsHeaders }
    );
  }

  // Step 2: Insert user profile into the profiles table
  const { error: profileError } = await supabaseAdmin.from("profiles").insert([
    {
      id: user?.id,
      role: "admin", // Set role as admin by default
      unit_number: null, // Admins don't need unit numbers
      full_name
    },
  ]);

  if (profileError) {
    console.error("Error inserting profile:", profileError);
    return new Response(
      JSON.stringify({ error: "Error inserting profile" }), 
      { status: 500, headers: corsHeaders }
    );
  }

  return new Response(
    JSON.stringify({ message: "Admin created successfully" }), 
    { status: 200, headers: corsHeaders }
  );
});