# Referral Earning App 💰

A premium Flutter-based referral earning platform with a beautiful dark theme UI, wallet management, and task-based rewards system.

![Flutter](https://img.shields.io/badge/Flutter-3.35.7-blue)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

- 🎨 **Premium UI Design** - Beautiful dark theme with gradients and animations
- 💰 **Wallet System** - Manage deposits, earnings, and withdrawals
- 🎯 **Referral Tasks** - 5 levels of referral challenges with progressive rewards
- 🎮 **Game Integration** - Earn rewards by completing games
- 📊 **Dashboard** - Track your referrals, earnings, and progress
- 🔗 **Share System** - Easy referral code sharing
- 🔐 **Authentication** - Secure login and registration

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (>=3.35.7)
- Dart SDK (>=3.9.2)
- Chrome, Edge, or any modern browser for web deployment

### Installation

```bash
# Clone the repository
git clone https://github.com/RAJRS20/Referral_based_app.git
cd Referral_based_app

# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Build for web
flutter build web --release
```

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── wallet_model.dart
│   └── referral_model.dart
├── providers/               # State management
│   ├── auth_provider.dart
│   ├── wallet_provider.dart
│   ├── referral_provider.dart
│   └── game_provider.dart
├── screens/                 # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── home/
│       ├── main_screen.dart
│       ├── home_screen.dart
│       ├── tasks_screen.dart
│       ├── wallet_screen.dart
│       └── profile_screen.dart
├── widgets/                 # Reusable widgets
│   ├── gradient_button.dart
│   └── custom_text_field.dart
└── utils/
    └── app_theme.dart       # Theme configuration
```

## 🎨 Screenshots

The app features:
- Animated splash screen
- Login/Registration with validation
- Home dashboard with wallet balance
- Referral tasks with progress tracking
- Wallet management with transaction history
- User profile with stats

## 🌐 Deploy to Vercel

### Option 1: Deploy via Vercel Dashboard

1. Go to [Vercel](https://vercel.com)
2. Click "Add New Project"
3. Import your GitHub repository: `RAJRS20/Referral_based_app`
4. Vercel will auto-detect the configuration from `vercel.json`
5. Click "Deploy"

### Option 2: Deploy via Vercel CLI

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
vercel --prod
```

The `vercel.json` configuration automatically handles:
- Building the Flutter web app
- Setting up proper routing
- Configuring CORS headers

## 🛠️ Technologies Used

- **Flutter** - UI framework
- **Provider** - State management
- **SharedPreferences** - Local storage
- **Flutter Animate** - Animations
- **Google Fonts** - Typography
- **Share Plus** - Social sharing
- **Intl** - Date formatting

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

Created with ❤️ by RAJRS20

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

---

**Note**: This app uses simulated data for demo purposes. For production use, integrate with a real backend API and payment gateway.
