import { serve } from 'https://deno.land/std@0.114.0/http/server.ts'
import { createClient } from './supabase-functions.ts'

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

  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ message: 'Method Not Allowed' }), 
      { status: 405, headers: corsHeaders }
    )
  }

  const body = await req.json()
  const { visitor_name, national_id, visitor_phone, unit_number } = body

  if (!visitor_name || !national_id || !visitor_phone || !unit_number) {
    return new Response(
      JSON.stringify({ message: 'Missing required fields' }), 
      { status: 400, headers: corsHeaders }
    )
  }

  const supabase = createClient(req)

  // Check resident
  const { data: resident, error: residentError } = await supabase
    .from('profiles')
    .select('id')
    .eq('unit_number', unit_number)
    .single()

  if (residentError || !resident) {
    return new Response(
      JSON.stringify({ message: 'Resident not found for this unit' }), 
      { status: 404, headers: corsHeaders }
    )
  }

  const { data, error } = await supabase.from('visit_sessions').insert([
    {
      visitor_name,
      visitor_phone,
      national_id,
      unit_number,
      status: 'pending',
      security_id: null,
    },
  ])

  if (error) {
    return new Response(
      JSON.stringify({ message: 'Error creating visit request', error }), 
      { status: 500, headers: corsHeaders }
    )
  }

  return new Response(
    JSON.stringify({ message: 'Visit request created', data: data ?? {} }), 
    { status: 201, headers: corsHeaders }
  )
})
