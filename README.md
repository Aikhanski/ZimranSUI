# ZimranSUI - GitHub Client App

A modern iOS application built with SwiftUI and MVVM architecture for browsing GitHub repositories and users.

## Features

- 🔐 **Authentication**: GitHub OAuth 2.0 with PKCE and Personal Access Token support
- 🔍 **Search**: Search repositories and users with advanced filtering
- 📊 **Sorting**: Sort repositories by stars, forks, update date
- 📱 **Responsive UI**: Optimized for iPhone SE to iPhone 15 Pro Max
- 📚 **History**: Track viewed repositories and users (offline storage)
- 🌐 **Web Integration**: Open repositories in SafariView
- 🏗️ **MVVM Architecture**: Clean separation of concerns
- 🧪 **Testing**: Unit tests with XCTest framework

## Architecture

- **MVVM Pattern**: Model-View-ViewModel architecture
- **Custom Networking**: URLSession-based networking layer with generics
- **Dependency Injection**: ViewModels initialized with dependencies
- **Combine Framework**: Reactive programming with @Published properties
- **Keychain Storage**: Secure token storage
- **UserDefaults**: Local history storage

## Project Structure

```
ZimranSUI/
├── Models/           # Data models (Repository, User, etc.)
├── Views/            # SwiftUI views
├── ViewModels/       # MVVM view models
├── Networking/       # Custom networking layer
├── Services/         # Business logic services
├── Storage/          # Local storage management
└── Tests/            # Unit tests
```

## Authentication Methods

### OAuth 2.0 with PKCE (Recommended)
- Secure authentication flow
- No client secret required
- Automatic token refresh

### Personal Access Token
- Direct API access
- Simple setup
- Manual token management

## Getting Started

1. Clone the repository
2. Open `ZimranSUI.xcodeproj` in Xcode
3. Configure GitHub OAuth App (optional)
4. Build and run on iOS Simulator or device

## Requirements

- iOS 18.1+
- Xcode 16.1+
- Swift 5.9+

## Technologies Used

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming
- **URLSession**: Networking
- **CryptoKit**: PKCE implementation
- **AuthenticationServices**: OAuth flow
- **XCTest**: Unit testing

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is for educational purposes.