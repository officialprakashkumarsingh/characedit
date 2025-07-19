# AhamAI - Flutter Android App

A beautiful and modern AI chat application built with Flutter, featuring character interactions, RSS news discovery, and personalized conversations.

## Features

- 🤖 **AI Chat**: Engage in conversations with multiple AI models
- 👥 **AI Characters**: Create and chat with custom AI personalities  
- 📰 **News Discovery**: Browse curated news articles from Indian and international RSS feeds
- 💾 **Save & History**: Bookmark conversations and maintain chat history
- 🎨 **Modern UI**: Clean, neutral design with white, grey, and silver color scheme

## Dependencies Required

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  google_fonts: ^6.1.0
  flutter_markdown: ^0.6.18
  shared_preferences: ^2.2.2
  url_launcher: ^6.2.1
  cached_network_image: ^3.3.0
  timeago: ^3.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## Android Manifest Permissions

Add these permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## Setup Instructions

1. **Clone the repository**
2. **Install dependencies**: `flutter pub get`
3. **Run the app**: `flutter run`

## API Configuration

The app uses a custom AI API endpoint. Update the base URL in the code if needed:
- Base URL: `https://api-aham-ai.officialprakashkrsingh.workers.dev`
- Authorization: Uses bearer token authentication

## News Sources (RSS Feeds)

The discover page aggregates news from:
- **Indian Sources**: Times of India, Hindustan Times, The Hindu, Indian Express
- **International**: BBC, Reuters, AP News, Guardian

## Design Philosophy

- **Neutral Color Palette**: White backgrounds, grey accents, silver highlights
- **No Gradients**: Clean, flat design approach
- **Modern UI**: Rounded corners, subtle shadows, smooth animations
- **Accessibility**: High contrast, readable fonts, intuitive navigation

## File Structure

- `main.dart` - App entry point
- `main_shell.dart` - Main navigation shell
- `chat_page.dart` - AI chat interface
- `characters_page.dart` - Character management
- `discover_page.dart` - News and articles discovery
- `saved_page.dart` - Bookmarks and chat history
- `models.dart` - Data models
- `character_models.dart` - Character-specific models
- Authentication pages and services

## Contributing

Feel free to submit issues and pull requests to improve the app!

## License

This project is licensed under the MIT License.