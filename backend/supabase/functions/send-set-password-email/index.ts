import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { Resend } from "npm:resend";

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

  try {
    const { email } = await req.json();

    if (!email) {
      return new Response(
        JSON.stringify({ error: "Missing email" }), 
        { status: 400, headers: corsHeaders }
      );
    }

    const resend = new Resend(Deno.env.get("RESEND_API_KEY")!);

    const magicLink = `https://kikaohomes.com/set-password?email=${encodeURIComponent(email)}`;

    const { data, error } = await resend.emails.send({
      from: "Kikao Homes <onboarding@resend.dev>",
      to: email,
      subject: "Set your Kikao Homes password",
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f4f4f9; color: #333;">
          <table width="100%" style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 8px; overflow: hidden;">
            <tr>
              <td style="padding: 20px; text-align: center; background-color: #2563eb; color: #ffffff;">
                <h1 style="margin: 0;">Kikao Homes</h1>
              </td>
            </tr>
            <tr>
              <td style="padding: 20px;">
                <h2 style="color: #2563eb;">👋 Welcome to Kikao Homes!</h2>
                <p>You're almost ready to start using your account. Click the button below to set your password:</p>
                <div style="text-align: center; margin: 20px 0;">
                  <a href="${magicLink}" 
                     style="display: inline-block; background-color: #2563eb; color: #ffffff; padding: 12px 24px; text-decoration: none; border-radius: 5px; font-weight: bold;">
                    Set My Password
                  </a>
                </div>
                <p style="font-size: 0.9em; color: #666;">If you didn't request this, you can safely ignore this email.</p>
              </td>
            </tr>
            <tr>
              <td style="padding: 20px; text-align: center; font-size: 0.8em; color: #999;">
                © 2023 Kikao Homes. All rights reserved.
              </td>
            </tr>
          </table>
        </div>
      `
    });

    if (error) {
      console.error("Resend error:", error);
      return new Response(
        JSON.stringify({ error: error.message }), 
        { status: 500, headers: corsHeaders }
      );
    }

    return new Response(
      JSON.stringify({ message: "Email sent", id: data?.id }), 
      { status: 200, headers: corsHeaders }
    );

  } catch (err) {
    console.error("Unhandled error:", err);
    return new Response(
      JSON.stringify({ error: "Internal Server Error" }), 
      { status: 500, headers: corsHeaders }
    );
  }
});