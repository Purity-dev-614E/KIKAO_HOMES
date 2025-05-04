import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

// Resend API key (should be set in your environment variables)
const resendApiKey = Deno.env.get("RESEND_API_KEY");

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // Allow all origins
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
};

const sendApprovalNotificationEmail = async (residentEmail: string, visitor_name: string, action: "approved" | "rejected") => {
  const emailBody = `
    <p>Hi,</p>
    <p>The visit with ID ${visitor_name} has been ${action} by the resident. Please follow up accordingly.</p>
    <p>If you did not expect this notification, please ignore this email.</p>
  `;

  const emailPayload = {
    from: "Kikao Homes <onboarding@resend.dev>", // Replace with your verified email
    to: residentEmail,
    subject: `Your visit has ${action} ${visitor_name}`,
    html: emailBody,
  };

  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${resendApiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(emailPayload),
  });

  const data = await response.json();
  return data;
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders, status: 204 });
  }

  // Get data from request body
  const { residentEmail, visitId, action } = await req.json();

  if (!residentEmail || !visitId || !action) {
    return new Response(
      JSON.stringify({ error: "Missing required parameters" }), 
      { status: 400, headers: corsHeaders }
    );
  }

  try {
    const result = await sendApprovalNotificationEmail(residentEmail, visitId, action);
    return new Response(
      JSON.stringify({ message: "Email sent successfully", result }), 
      { status: 200, headers: corsHeaders }
    );
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "An unknown error occurred";
    return new Response(
      JSON.stringify({ error: errorMessage }), 
      { status: 500, headers: corsHeaders }
    );
  }
});
