# AhamAI - Modern Flutter Android App

A beautiful and modern AI chat application built with Flutter, featuring character interactions, real-time news discovery with TikTok-style UI, and personalized conversations.

## ✨ Features

- 🤖 **AI Chat**: Engage in conversations with multiple AI models
- 👥 **AI Characters**: Create and chat with custom AI personalities  
- 📰 **News Discovery**: Browse real-time news with TikTok-style vertical scrolling
- 💾 **Save & History**: Bookmark conversations and maintain chat history
- 🎨 **Modern UI**: Clean, minimalistic design with neutral color palette
- 📱 **Mobile-First**: Optimized for Android with responsive design

## 🆕 Recent Improvements

### News & Discovery Page
- **Real News Integration**: Multiple news APIs (NewsAPI, NewsData.io, GNews)
- **TikTok-Style UI**: Vertical scrolling with full-screen news cards
- **Enhanced UX**: Swipe gestures, share functionality, and bookmark options
- **Real-Time Updates**: Live news feeds from Indian and international sources

### Chat Interface
- **Cleaner Input Bar**: Light white design with improved styling
- **Better UX**: Rounded corners, subtle shadows, and responsive animations
- **Enhanced Buttons**: Minimalistic send/stop buttons with proper feedback

### Characters Page
- **List Layout**: Removed card-based design for cleaner appearance
- **Neutral Colors**: Grey-based color scheme with minimal accents
- **Compact Design**: Smaller, better-positioned action buttons
- **Improved Navigation**: Streamlined character management

### Authentication
- **Minimalistic Design**: Cleaner sign-in/sign-up forms
- **Smaller Buttons**: Compact, well-styled authentication buttons
- **Better Typography**: Improved font weights and spacing

### Saved & Profile Pages
- **Enhanced Layout**: Better organization and visual hierarchy
- **Improved Tabs**: Cleaner tab switching with smooth animations
- **Better Content Display**: Optimized for readability and usability

## 📋 Dependencies Required

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Core Dependencies
  http: ^1.1.0
  shared_preferences: ^2.2.2
  
  # UI & Design
  google_fonts: ^6.1.0
  flutter_markdown: ^0.6.18
  cached_network_image: ^3.3.0
  
  # Utilities
  url_launcher: ^6.2.1
  timeago: ^3.6.0
  
  # Development
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## 📱 Android Configuration

### AndroidManifest.xml

Add these permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Internet permissions for API calls -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Optional: For better network performance -->
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    
    <application
        android:label="AhamAI"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
              
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### build.gradle (app-level)

Update your `android/app/build.gradle`:

```gradle
android {
    namespace "com.ahamai.app"
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId "com.ahamai.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            shrinkResources false
            minifyEnabled false
        }
    }
}
```

## 🚀 Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ahamai-flutter-app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys**
   - Replace placeholder API keys in `discover_page.dart`
   - Get free API keys from:
     - [NewsAPI](https://newsapi.org/) - 1000 requests/day
     - [NewsData.io](https://newsdata.io/) - 200 requests/day
     - [GNews](https://gnews.io/) - 100 requests/day

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 API Configuration

### News APIs Integration

The app uses multiple news APIs for comprehensive coverage:

```dart
// NewsAPI Configuration
final response = await http.get(
  Uri.parse('https://newsapi.org/v2/top-headlines?country=in&pageSize=30&apiKey=YOUR_API_KEY'),
  headers: {'User-Agent': 'AhamAI/1.0'},
);

// NewsData.io Configuration  
final response = await http.get(
  Uri.parse('https://newsdata.io/api/1/news?apikey=YOUR_API_KEY&country=in&language=en&size=20'),
  headers: {'User-Agent': 'AhamAI/1.0'},
);

// GNews Configuration
final response = await http.get(
  Uri.parse('https://gnews.io/api/v4/top-headlines?token=YOUR_API_KEY&country=in&lang=en&max=25'),
  headers: {'User-Agent': 'AhamAI/1.0'},
);
```

### AI Chat Configuration

- **Base URL**: `https://api-aham-ai.officialprakashkrsingh.workers.dev`
- **Authentication**: Bearer token authentication
- **Supported Models**: Multiple AI models for different conversation styles

## 📰 News Sources

### Indian Sources
- Times of India
- Hindustan Times  
- The Hindu
- Indian Express
- NDTV

### International Sources
- BBC News
- Reuters
- AP News
- The Guardian
- CNN

## 🎨 Design Philosophy

- **Minimalistic UI**: Clean, flat design with subtle shadows
- **Neutral Colors**: White backgrounds, grey accents, black highlights
- **TikTok-Style News**: Vertical scrolling with immersive full-screen cards
- **Responsive Design**: Optimized for various Android screen sizes
- **Accessibility**: High contrast, readable fonts, intuitive navigation

## 📁 File Structure

```
lib/
├── main.dart                    # App entry point
├── main_shell.dart             # Main navigation shell
├── discover_page.dart          # TikTok-style news discovery
├── chat_page.dart              # AI chat interface
├── characters_page.dart        # Character management (list view)
├── auth_and_profile_pages.dart # Authentication & profile
├── saved_page.dart             # Bookmarks and chat history
├── models.dart                 # Core data models
├── character_models.dart       # Character-specific models
├── character_service.dart      # Character management service
├── auth_service.dart           # Authentication service
├── file_upload_service.dart    # File handling
└── character_*.dart            # Additional character features
```

## 🛠️ Development Features

- **Hot Reload**: Instant development feedback
- **State Management**: Efficient state handling with ChangeNotifier
- **Error Handling**: Graceful error handling with fallback content
- **Caching**: Network image caching for better performance
- **Offline Support**: Basic offline functionality with cached data

## 🔄 Build & Deploy

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

### Generate App Bundle
```bash
flutter build appbundle --release
```

## 📊 Performance Optimizations

- **Lazy Loading**: Efficient content loading
- **Image Caching**: Reduced network calls
- **Memory Management**: Proper disposal of controllers
- **Network Optimization**: Request deduplication and caching

## 🐛 Troubleshooting

### Common Issues

1. **API Rate Limits**: Switch to alternative news APIs or implement caching
2. **Network Errors**: Check internet connectivity and API endpoints
3. **Build Errors**: Run `flutter clean && flutter pub get`
4. **Permission Issues**: Verify AndroidManifest.xml permissions

### Debug Commands
```bash
flutter doctor              # Check Flutter installation
flutter clean               # Clean build cache
flutter pub deps            # Check dependencies
flutter logs                # View device logs
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- News API providers for real-time data
- Open source contributors and community

---

**AhamAI** - Modern AI Chat Experience with Real-Time News Discovery