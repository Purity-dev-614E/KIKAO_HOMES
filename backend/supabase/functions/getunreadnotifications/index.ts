import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.4';

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // Allow all origins
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
};

const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!);

async function getUnreadNotifications(userId: string) {
  const { data, error } = await supabase
    .from('notifications')
    .select('*')
    .eq('user_id', userId)
    .eq('status', 'unread'); // This ensures you only get unread notifications

  if (error) {
    return new Response(
      JSON.stringify({ status: 'error', message: error.message }), 
      { status: 500, headers: corsHeaders }
    );
  }

  return new Response(
    JSON.stringify({ status: 'success', data }), 
    { status: 200, headers: corsHeaders }
  );
}

export default async function handler(req: Request) {
    // Handle CORS preflight requests
    if (req.method === "OPTIONS") {
        return new Response(null, { headers: corsHeaders, status: 204 });
    }
    
    const { userId } = await req.json();
    return getUnreadNotifications(userId);
}
