# KIKAO HOMES Backend

This directory contains the backend services for the KIKAO HOMES application, built using Supabase Edge Functions. The backend handles visitor management, security operations, user authentication, and administrative functions.

## Architecture

The backend is built on Supabase, utilizing:

- **Supabase Auth**: For user authentication and authorization
- **Supabase Database**: PostgreSQL database for storing application data
- **Supabase Edge Functions**: Serverless functions written in TypeScript running on Deno

## Technology Stack

- **Deno**: Runtime environment for Edge Functions (version 1.x)
- **TypeScript**: Programming language for all backend code
- **Supabase JS Client**: Version 2.49.4
- **Deno Standard Library**: Version 0.114.0 and 0.224.0

## Directory Structure

```
backend/
├── supabase/
│   ├── config.toml         # Supabase configuration file
│   ├── functions/          # Edge Functions
│   │   ├── add-user/       # Function to add new users
│   │   ├── admin-signup/   # Admin registration function
│   │   ├── approve_visits/ # Function to approve visit requests
│   │   ├── login/          # User authentication function
│   │   ├── send-set-password-email/ # Email function for password setup
│   │   ├── sendApprovalNotificationEmail/ # Email notifications for approvals
│   │   └── ...            # Other function directories
```

## Edge Functions

The backend implements the following Edge Functions:

### User Management
- **add-user**: Creates new resident users
- **admin-signup**: Registers new admin users
- **set-user-password**: Updates user password
- **send-set-password-email**: Sends email with password setup instructions
- **login**: Authenticates users with email and password

### Security Operations
- **security-login**: Authenticates security personnel
- **security-logout**: Logs out security personnel
- **assign-security-officer**: Assigns security officers to specific duties

### Visit Management
- **submit_visit_requests**: Allows residents to submit visitor requests
- **approve_visits**: Approves pending visit requests
- **reject_visits**: Rejects visit requests
- **get-my-visits**: Retrieves a resident's visit history
- **get-active-visits**: Lists all currently active visits
- **checkout-visit**: Records when a visitor leaves the premises
- **sendApprovalNotificationEmail**: Sends email notifications when visits are approved

### System Functions
- **createVisitSession**: Creates a new visit session when a visitor arrives
- **updateSessionStatus**: Updates the status of a visit session
- **requestVisitAccess**: Processes requests for visit access
- **approveVisitRequest**: Approves a visit request
- **exitVisitSession**: Records when a visitor exits
- **getApprovedSessions**: Retrieves all approved visit sessions
- **getMyVisitHistory**: Gets visit history for a specific resident
- **expireOldRequests**: Automatically expires old visit requests
- **exportVisitLogs**: Exports visit logs for reporting

## Setup and Deployment

### Prerequisites
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Deno](https://deno.land/) (for local development)
- Node.js and npm

### Local Development

1. Install the Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Start the local Supabase development environment:
   ```bash
   supabase start
   ```

3. Deploy functions to your local Supabase instance:
   ```bash
   supabase functions deploy <function-name>
   ```

4. Test a function locally:
   ```bash
   supabase functions serve <function-name> --env-file .env.local
   ```

### Production Deployment

1. Link your project:
   ```bash
   supabase link --project-ref <project-id>
   ```

2. Deploy all functions:
   ```bash
   supabase functions deploy
   ```

3. Deploy a specific function:
   ```bash
   supabase functions deploy <function-name>
   ```

## Environment Variables

The following environment variables are required:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Anonymous key for client-side operations
- `SUPABASE_SERVICE_ROLE_KEY`: Service role key for admin operations

## Function Development

Each Edge Function follows a similar pattern:

1. Import required dependencies
2. Define the request handler
3. Process the request payload
4. Interact with Supabase services
5. Return an appropriate response

Example:
```typescript
import { serve } from "https://deno.land/std@0.114.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

serve(async (req) => {
  // Process request
  const { data } = await req.json();
  
  // Initialize Supabase client
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    {
      global: {
        headers: { Authorization: req.headers.get('Authorization')! },
      },
    }
  );
  
  // Perform operations
  const { data: result, error } = await supabase
    .from("your_table")
    .select()
    .eq("some_column", data.value);
  
  // Return response
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { 
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
  
  return new Response(JSON.stringify({ data: result }), { 
    status: 200,
    headers: { "Content-Type": "application/json" }
  });
});
```

## Security Considerations

- All functions use JWT verification (`verify_jwt = true`)
- Service role keys are used only when necessary
- Input validation is performed on all request data
- Error handling prevents leaking sensitive information

## Database Schema

The application uses the following main tables:

- `profiles`: User profiles with roles and unit information
- `visits`: Records of all visits
- `visit_sessions`: Active visit sessions
- `visit_requests`: Pending and processed visit requests
- `security_officers`: Information about security personnel

## API Documentation

### Authentication

#### `login`
- **Method**: POST
- **Description**: Authenticates a user with email and password
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "securepassword"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "User authenticated successfully",
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```

#### `security-login`
- **Method**: POST
- **Description**: Authenticates security personnel
- **Request Body**:
  ```json
  {
    "email": "security@example.com",
    "password": "securepassword"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "Security officer authenticated successfully",
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```

#### `security-logout`
- **Method**: POST
- **Description**: Logs out security personnel
- **Request Body**:
  ```json
  {
    "session_id": "session-uuid"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "Logged out successfully"
  }
  ```

### User Management

#### `admin-signup`
- **Method**: POST
- **Description**: Creates a new admin user
- **Request Body**:
  ```json
  {
    "email": "admin@example.com",
    "password": "securepassword"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "Admin created successfully"
  }
  ```

#### `add-user`
- **Method**: POST
- **Description**: Creates a new resident user
- **Request Body**:
  ```json
  {
    "email": "resident@example.com",
    "unit_number": "A101",
    "full_name": "John Resident"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "User created successfully",
    "user_id": "user-uuid"
  }
  ```

#### `set-user-password`
- **Method**: POST
- **Description**: Updates a user's password
- **Request Body**:
  ```json
  {
    "token": "password-reset-token",
    "new_password": "newSecurePassword"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "Password updated successfully"
  }
  ```

#### `send-set-password-email`
- **Method**: POST
- **Description**: Sends email with password setup instructions
- **Request Body**:
  ```json
  {
    "email": "resident@example.com"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "Password setup email sent successfully"
  }
  ```

### Visit Management

#### `submit_visit_requests`
- **Method**: POST
- **Description**: Submit a new visit request
- **Request Body**:
  ```json
  {
    "visitor_name": "John Doe",
    "visitor_phone": "+1234567890",
    "national_id": "12345678",
    "unit_number": "A101"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "Visit request created",
    "data": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "status": "pending"
    }
  }
  ```

#### `approve_visits`
- **Method**: POST
- **Description**: Approve a pending visit request
- **Request Body**:
  ```json
  {
    "visit_id": "123e4567-e89b-12d3-a456-426614174000"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "Visit request approved",
    "data": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "status": "approved"
    }
  }
  ```

#### `reject_visits`
- **Method**: POST
- **Description**: Reject a pending visit request
- **Request Body**:
  ```json
  {
    "visit_id": "123e4567-e89b-12d3-a456-426614174000",
    "reason": "Scheduling conflict"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "Visit request rejected",
    "data": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "status": "rejected"
    }
  }
  ```

#### `get-active-visits`
- **Method**: GET
- **Description**: Retrieves all currently active visits
- **Response**: 
  ```json
  {
    "visits": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "visitor_name": "John Doe",
        "status": "approved",
        "unit_number": "A101",
        "created_at": "2023-06-15T14:00:00Z"
      }
    ]
  }
  ```

#### `get-my-visits`
- **Method**: GET
- **Description**: Retrieves visit history for the authenticated resident
- **Response**: 
  ```json
  {
    "visits": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "visitor_name": "John Doe",
        "status": "completed",
        "created_at": "2023-06-15T14:00:00Z",
        "exit_time": "2023-06-15T16:30:00Z"
      }
    ]
  }
  ```

#### `checkout-visit`
- **Method**: POST
- **Description**: Records when a visitor leaves the premises
- **Request Body**:
  ```json
  {
    "visit_id": "123e4567-e89b-12d3-a456-426614174000"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "Visit checked out successfully",
    "data": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "status": "completed",
      "exit_time": "2023-06-15T16:30:00Z"
    }
  }
  ```

#### `sendApprovalNotificationEmail`
- **Method**: POST
- **Description**: Sends email notification when a visit is approved
- **Request Body**:
  ```json
  {
    "visit_id": "123e4567-e89b-12d3-a456-426614174000",
    "recipient_email": "resident@example.com"
  }
  ```
- **Response**: 
  ```json
  {
    "message": "Approval notification email sent successfully"
  }
  ```

## Troubleshooting

### Common Issues

1. **Function Deployment Failures**
   - Ensure Deno is installed correctly
   - Check for syntax errors in your TypeScript files
   - Verify that all dependencies are correctly imported
   - Make sure the function is properly registered in `config.toml`

2. **Authentication Errors**
   - Verify that JWT verification is properly configured
   - Check that the correct Supabase keys are being used
   - Ensure the Authorization header is being passed correctly

3. **Database Connection Issues**
   - Confirm that environment variables are correctly set
   - Check database permissions for the service role
   - Verify that table schemas match the expected structure

4. **Email Sending Issues**
   - Check that email service credentials are correctly configured
   - Verify that email templates are properly formatted
   - Ensure recipient email addresses are valid

### Logs

Access function logs through the Supabase dashboard:
1. Go to your project in the Supabase dashboard
2. Navigate to Edge Functions
3. Select the function to view its logs

For local development, logs are output to the console when using:
```bash
supabase functions serve <function-name> --env-file .env.local
```

## Contributing

When adding new functions:

1. Create a new directory under `functions/`
2. Add the function implementation in `index.ts`
3. Create a `deno.json` file for import maps
4. Add a `.npmrc` file with `{ "allow-import-from-external-modules": true }`
5. Update the `config.toml` file to register the function
6. Create a helper file for common functionality if needed (like `supabase-functions.ts`)
7. Test locally before deploying
8. Update this README with documentation for the new function

### Function Structure Template

```
functions/
└── your-function-name/
    ├── .npmrc
    ├── deno.json
    ├── index.ts
    └── supabase-functions.ts (optional)
```

## License

This project is proprietary and confidential. Unauthorized copying, distribution, or use is strictly prohibited.