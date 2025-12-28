# Implementation Plan - Premium Theme Upgrade

The goal of this session was to upgrade the `referral_earning_app` to a "Premium Obsidian & Gold" aesthetic, utilizing glassmorphism, rich gradients, and animations to enhance the user experience without altering the backend logic.

## User Review Required

> [!IMPORTANT]
> The entire UI has been shifted to a dark/gold theme. Please verify that:
> 1.  **Text Legibility**: All text, especially on the dark/gradient backgrounds, is readable.
> 2.  **Navigation**: The flow from Splash -> Login -> Home -> various screens feels seamless.
> 3.  **Animations**: The new entry animations are smooth and not distracting.

## Proposed Changes

### Theme Overhaul (`app_theme.dart`)

-   **New Palette**: Introduced `obsidian` (background), `vividGold` (primary/accent), and `luxuryPurple` (secondary).
-   **Gradients**: Added `premiumDarkGradient` (background), `goldGradient` (buttons/icons), `glassGradient` (cards).
-   **Typography**: Switched to `GoogleFonts.outfit` and `plusJakartaSans` for a modern look.
-   **Components**: Updated `ThemeData` to use these new colors globally (Buttons, Cards, TextFields).

### Critical Screen Updates

#### 1. Splash Screen (`splash_screen.dart`)
-   Replaced the basic gradient with the `premiumDarkGradient`.
-   Animated the logo with a scale/shimmer effect.
-   Updated the "REFER • EARN • GROW" tagline with gold accents.

#### 2. Login Screen (`login_screen.dart`)
-   Applied the dark gradient background.
-   Styled inputs with transparency and gold borders on focus.
-   Updated the "Login" button to use the `vividGold` color.
-   Added entry animations for all elements.

#### 3. Home Screen (`home_screen.dart`)
-   Implemented a `premiumDarkGradient` scaffold.
-   Redesigned the "Current Status" card with glassmorphism.
-   Updated the "Roadmap" items to features `vividGold` indicators and glow effects.
-   Added animations for listing items.

#### 4. Tasks Screen ("Game Arena") (`tasks_screen.dart`)
-   Updated game cards to use `AppTheme.surface` with borders and glows.
-   Used `flutter_animate` for card entry.
-   Ensured lock/unlock states are visually distinct using the new palette.

#### 5. Wallet Screen (`wallet_screen.dart`)
-   Redesigned the "Balance Card" to be a standout feature with `violetGradient`.
-   Styled transaction history with glassmorphism.
-   Updated "Deposit/Withdraw" dialogs to match the dark theme.

#### 6. Referral Screen ("My Team") (`referral_screen.dart`)
-   Added a glassmorphic summary header.
-   Styled the team list with distinct "Active" (Green) vs "Pending" (Grey) indicators.
-   Added animations to the list.

#### 7. Profile Screen (`profile_screen.dart`)
-   Redesigned the header to show the user avatar and stats prominently.
-   Styled the "Referral Code" box as a key action area.
-   Updated menu items to be consistent glass cards.

#### 8. Games (`scratch_card_game.dart`)
-   Updated the game UI to match the dark aesthetic.
-   Added "Winner" dialogs with gold/confetti styling (simulated via colors).

## Verification Plan

### Automated Tests
-   Run `flutter test` (if available) to ensure no regressions in logic (though logic wasn't touched).
-   Check `flutter analyze` for any missing consts or unused imports.

### Manual Verification
-   **Launch App**: Verify Splash -> Login flow.
-   **Login**: Use credentials to enter Home.
-   **Home**: Check the "Roadmap" rendering and animations.
-   **Wallet**: Go to Wallet, check balance card visuals.
-   **Tasks**: Go to Game Arena, open "Scratch Card". Play a round.
-   **Referral**: Go to "My Team" and check the list.
-   **Profile**: Check "My Profile" and logout flow.
