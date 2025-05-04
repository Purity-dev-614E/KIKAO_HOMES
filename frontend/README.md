# Kikao Homes

A modern property management system built with Flutter, designed to streamline residential community management and security operations.

## Features

### User Roles
- **Admin**: Comprehensive management dashboard with user management, settings, and analytics
- **Security**: Real-time visitor management, QR code scanning, and security patrol tracking
- **Resident**: Visitor registration and management capabilities

### Key Features

- **Visitor Management**
  - Visitor registration with ID verification
  - Real-time visitor tracking
  - Visitor history and analytics
  - QR code-based access control

- **Security Operations**
  - Real-time security dashboard
  - Active visit monitoring
  - Security patrol tracking
  - Quick visitor checkout

- **Admin Controls**
  - User management
  - System settings
  - Resident management
  - Visitor analytics

### Technical Stack
- **Framework**: Flutter
- **Backend**: Supabase
- **Authentication**: Firebase
- **Notifications**: Push notifications
- **QR Code**: Custom QR code generation

## Getting Started

To run the application locally:

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/           # Core application logic and services
├── models/         # Data models
├── screens/        # Screen implementations
├── utils/          # Utility functions
└── widgets/        # Reusable widgets
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
