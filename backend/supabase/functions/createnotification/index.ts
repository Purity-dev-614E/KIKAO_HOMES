import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";
import * as jose from "https://deno.land/x/jose@v4.11.2/index.ts";
import "https://deno.land/std@0.224.0/dotenv/load.ts";
// Function to generate Google OAuth token for FCM
async function generateGoogleOAuthToken(clientEmail: string, privateKey: string, scopes: string[]) {
  console.log("🔐 Generating Google OAuth Token...");
  if (!clientEmail) throw new Error("FCM_CLIENT_EMAIL is not set");
  if (!privateKey) throw new Error("FCM_PRIVATE_KEY is not set");
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: clientEmail,
    scope: scopes.join(" "),
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now
  };
  console.log("🧩 JWT payload constructed:", payload);
  // Replace escaped newlines
  const formattedPrivateKey = privateKey.replace(/\\n/g, '\n');
  console.log("🔑 Private key formatted");
  const jwt = await new jose.SignJWT(payload).setProtectedHeader({
    alg: "RS256"
  }).sign(await jose.importPKCS8(formattedPrivateKey, "RS256"));
  console.log("✅ JWT signed, requesting OAuth token from Google...");
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt
    })
  });
  if (!response.ok) {
    const errorText = await response.text();
    console.error("❌ Google OAuth token fetch failed:", errorText);
    throw new Error(`Failed to get OAuth token: ${errorText}`);
  }
  const data = await response.json();
  console.log("✅ OAuth token obtained successfully");
  return data.access_token;
}
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
};
serve(async (req)=>{
  console.log("📩 Incoming request:", req.method);
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: corsHeaders,
      status: 204
    });
  }
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !supabaseKey) {
      throw new Error("Missing Supabase environment variables");
    }
    const supabase = createClient(supabaseUrl, supabaseKey);
    const body = await req.json();
    console.log("📦 Request body:", body);
    const { user_id, message, type, visitorData } = body;
    if (!user_id || !message || !type) {
      console.warn("⚠️ Missing required fields in request");
      return new Response(JSON.stringify({
        error: "Missing required fields"
      }), {
        status: 400,
        headers: corsHeaders
      });
    }
    if (type === "visitor" && !visitorData) {
      console.warn("⚠️ Visitor data missing for 'visitor' type");
      return new Response(JSON.stringify({
        error: "Visitor data required for visitor notifications"
      }), {
        status: 400,
        headers: corsHeaders
      });
    }
    console.log("📨 Inserting notification into Supabase...");
    const { data: notification, error: insertError } = await supabase.from("notifications").insert({
      user_id,
      message,
      type,
      status: "unread"
    }).select().single();
    if (insertError) {
      console.error("❌ Notification insert error:", insertError.message);
      throw new Error("Notification insert failed: " + insertError.message);
    }
    console.log("🔍 Fetching user profile for device token...");
    const { data: profile, error: profileError } = await supabase.from("profiles").select("device_token").eq("id", user_id).single();
    if (profileError || !profile?.device_token) {
      console.warn("⚠️ No device token found for user, skipping FCM push");
      return new Response(JSON.stringify({
        warning: "Notification saved, but no device token found"
      }), {
        status: 200,
        headers: corsHeaders
      });
    }
    console.log("📱 Device token found, checking FCM configuration...");
    
    // Check if FCM environment variables are set
    const fcmClientEmail = Deno.env.get("FCM_CLIENT_EMAIL");
    const fcmPrivateKey = Deno.env.get("FCM_PRIVATE_KEY");
    const fcmProjectId = Deno.env.get("FCM_PROJECT_ID");
    
    if (!fcmClientEmail || !fcmPrivateKey || !fcmProjectId) {
      console.warn("⚠️ FCM configuration missing, notification saved but push not sent");
      return new Response(JSON.stringify({
        warning: "Notification saved, but FCM configuration is incomplete"
      }), {
        status: 200,
        headers: corsHeaders
      });
    }
    
    console.log("🔐 FCM configuration found, generating access token...");
    const accessToken = await generateGoogleOAuthToken(fcmClientEmail, fcmPrivateKey, [
      "https://www.googleapis.com/auth/firebase.messaging"
    ]);
    const fcmPayload = {
      message: {
        token: profile.device_token,
        notification: {
          title: "Kikao Homes",
          body: message
        },
        data: {
          type,
          ...type === "visitor" && visitorData && {
            visitor_id: visitorData.id,
            visitor_name: visitorData.name,
            visitor_phone: visitorData.phone,
          }
        }
      }
    };
    console.log("📤 Sending FCM notification...");
    const fcmResponse = await fetch(`https://fcm.googleapis.com/v1/projects/${fcmProjectId}/messages:send`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(fcmPayload)
    });
    if (!fcmResponse.ok) {
      const error = await fcmResponse.text();
      console.error("❌ FCM push failed:", error);
      await supabase.from("notifications").update({
        status: "failed"
      }).eq("id", notification.id);
      throw new Error(`FCM failed: ${error}`);
    }
    console.log("✅ FCM notification sent successfully");
    return new Response(JSON.stringify({
      message: "Notification created and sent successfully"
    }), {
      status: 200,
      headers: corsHeaders
    });
  } catch (error) {
    console.error("❌ Error processing request:", error);
    const errorMessage = error instanceof Error ? error.message : String(error);
    return new Response(JSON.stringify({
      error: "Internal server error",
      details: errorMessage
    }), {
      status: 500,
      headers: corsHeaders
    });
  }
});
