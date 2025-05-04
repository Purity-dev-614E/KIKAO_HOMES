import { createClient as createSupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.49.4'

export const createClient = (req: Request) => {
  const supabaseClient = createSupabaseClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    {
      global: {
        headers: { Authorization: req.headers.get('Authorization')! },
      },
    }
  )
  return supabaseClient
}