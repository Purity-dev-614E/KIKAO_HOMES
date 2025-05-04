import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // Allow all origins
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
};

// Define the notification type
interface Notification {
  id: string;
  user_id: string;
  message: string;
  type: string;
  status: string;
  created_at?: string;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders, status: 204 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { user_id, message, type } = await req.json();

  if (!user_id || !message || !type) {
    return new Response(
      JSON.stringify({ error: "Missing required fields" }),
      { status: 400, headers: corsHeaders }
    );
  }

  // Insert the notification into the table
  const { data: insertedNotification, error: insertError } = await supabase
    .from("notifications")
    .insert({
      user_id,
      message,
      type,
      status: "unread", // Initially the notification is unread
    })
    .select()
    .single(); // Use single to get the inserted row
    
  // Type assertion for insertedNotification
  const typedNotification = insertedNotification as Notification;

  if (insertError) {
    console.error("Insert error:", insertError);
    return new Response(
      JSON.stringify({ error: "Failed to insert notification" }),
      { status: 500, headers: corsHeaders }
    );
  }

  // Get the user's device token
  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("device_token")
    .eq("id", user_id)
    .single();

  if (profileError || !profile?.device_token) {
    return new Response(
      JSON.stringify({ warning: "Notification saved, but no device token found." }),
      { status: 200, headers: corsHeaders }
    );
  }

  // Send the push notification using FCM
  const pushRes = await fetch("https://fcm.googleapis.com/fcm/send", {
    method: "POST",
    headers: {
      "Authorization": `key=${Deno.env.get("FCM_SERVER_KEY")}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      to: profile.device_token,
      notification: {
        title: "Kikao Homes",  // Notification title
        body: message,  // The message content
      },
      data: { type },  // Additional data
    }),
  });

  // Handle FCM push response
  if (!pushRes.ok) {
    const errorText = await pushRes.text();
    console.error("Push notification error:", errorText);

    // Update the notification status to "failed"
    const { error: updateError } = await supabase
      .from("notifications")
      .update({ status: "failed" })
      .eq("id", typedNotification.id);

    if (updateError) {
      console.error("Failed to update notification status to failed:", updateError);
    }

    return new Response(
      JSON.stringify({ error: "Failed to send push notification" }),
      { status: 500, headers: corsHeaders }
    );
  }

  // Successfully sent push notification
  return new Response(
    JSON.stringify({ message: "Notification created and sent successfully." }),
    { status: 200, headers: corsHeaders }
  );
});
