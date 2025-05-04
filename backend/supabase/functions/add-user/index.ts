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

  const { email, role, unit_number, full_name } = await req.json();

  if (!email || !role || !full_name || (role === "resident" && !unit_number)) {
    return new Response(
      JSON.stringify({ error: "Missing fields" }), 
      { status: 400, headers: corsHeaders }
    );
  }

  const supabaseAdmin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { data: user, error } = await supabaseAdmin.auth.admin.createUser({
    email,
    email_confirm: true,
    user_metadata: { role },
  });

  if (error) {
    console.error("Error creating user:", error);
    return new Response(
      JSON.stringify({ error: "Error creating user" }), 
      { status: 500, headers: corsHeaders }
    );
  }
  const { error: profileError } = await supabaseAdmin.from("profiles").insert([
    {
      id: user.user?.id,
      role,
      unit_number: role === "resident" && unit_number ? unit_number : null,
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
    JSON.stringify({ message: "User created successfully" }), 
    { status: 200, headers: corsHeaders }
  );
});
