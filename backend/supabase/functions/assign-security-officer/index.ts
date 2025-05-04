import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // Allow all origins
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
};

// Initialize the Supabase client
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_ANON_KEY")!
);

export default async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders, status: 204 });
  }

  const { visitorId, unitNumber, authUid } = await req.json();

  if (!authUid) {
    return new Response(
      JSON.stringify({ message: "Security officer UID is required." }), 
      { status: 400, headers: corsHeaders }
    );
  }

  // Get the active shift for the security officer
  const { data: activeShift, error: shiftError } = await supabase
    .from("active_shifts")
    .select("security_id")
    .eq("security_id", authUid)
    .single();

  if (shiftError || !activeShift) {
    return new Response(
      JSON.stringify({ message: "No active security officer found." }), 
      { status: 400, headers: corsHeaders }
    );
  }

  // Fetch resident based on unit number
  const { data: resident, error: residentError } = await supabase
    .from("profiles")
    .select("id")
    .eq("unit_number", unitNumber)
    .single();

  if (residentError || !resident) {
    return new Response(
      JSON.stringify({ message: "Resident not found." }), 
      { status: 400, headers: corsHeaders }
    );
  }

  // Create visit session and assign security officer
  const { data: _data, error } = await supabase
    .from("visit_sessions")
    .insert([
      {
        visitor_id: visitorId,
        unit_number: unitNumber,
        status: "approved", // Set status to approved
        security_id: activeShift.security_id, // Assign security officer
        check_in_at: new Date(),
        created_at: new Date()
      }
    ]);

  if (error) {
    return new Response(
      JSON.stringify({ message: "Error assigning security officer." }), 
      { status: 500, headers: corsHeaders }
    );
  }

  return new Response(
    JSON.stringify({ message: "Visit session created and security officer assigned." }),
    { status: 200, headers: corsHeaders }
  );
};
