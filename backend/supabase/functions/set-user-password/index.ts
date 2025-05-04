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

  if (!email || !password) {
    return new Response(
      JSON.stringify({ error: "Missing email or password" }), 
      { status: 400, headers: corsHeaders }
    );
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // Step 1: Fetch user by email
  const { data: users, error: fetchError } = await supabase.auth.admin.listUsers();

  if (fetchError || !users?.users) {
    return new Response(
      JSON.stringify({ error: "User not found" }), 
      { status: 404, headers: corsHeaders }
    );
  }

  const user = users.users.find((u) => u.email === email);

  if (!user) {
    return new Response(
      JSON.stringify({ error: "User not found" }), 
      { status: 404, headers: corsHeaders }
    );
  }

  // Step 2: Update the user's password
  const { error: updateError } = await supabase.auth.admin.updateUserById(user.id, {
    password,
  });

  if (updateError) {
    return new Response(
      JSON.stringify({ error: updateError.message }), 
      { status: 500, headers: corsHeaders }
    );
  }

  return new Response(
    JSON.stringify({ message: "Password updated successfully" }), 
    { status: 200, headers: corsHeaders }
  );
});
