import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // Allow all origins
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
};

// Initialize the Supabase client (you can get these from environment variables)
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_ANON_KEY")!
);

export default async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders, status: 204 });
  }

  const { authUid } = await req.json(); // Extracting the UID from the body

  if (!authUid) {
    return new Response(
      JSON.stringify({ message: "Security officer UID is required." }), 
      { status: 400, headers: corsHeaders }
    );
  }

  // Upsert security officer login data into active_shifts table
  const { data: _data, error } = await supabase
    .from("active_shifts")
    .upsert(
      { security_id: authUid, login_time: new Date() },
      { onConflict: "security_id" }
    );

  if (error) {
    return new Response(
      JSON.stringify({ message: "Error logging in security officer." }), 
      { status: 500, headers: corsHeaders }
    );
  }

  return new Response(
    JSON.stringify({ message: "Security officer logged in successfully." }),
    { status: 200, headers: corsHeaders }
  );
};
