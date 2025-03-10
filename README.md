# Graph My Token

## AI-Powered Development

This project was developed entirely using artificial intelligence, without writing a single line of code manually. It was built using Trae, an innovative AI development tool from ByteDance that enables seamless code generation and project development through natural language interactions.

## Project Overview

Graph My Token is a modern, responsive cryptocurrency tracking application that provides real-time price data and visual analytics for top cryptocurrencies. The application features a sleek dark theme with neon accents, making it both visually appealing and easy to read.

## Key Features

- **Real-time Data**: Automatically updates cryptocurrency data every 15 seconds
- **Responsive Grid Layout**: Adapts to different screen sizes:
  - Mobile: 1-2 columns
  - Tablet: 3 columns
  - Desktop: 5-6 columns
- **Visual Analytics**: Interactive price charts showing 7-day price history
- **Modern UI**: Dark theme with neon accents and smooth animations
- **Error Handling**: Graceful error management with retry functionality
- **Pull-to-Refresh**: Manual refresh capability for instant updates

## Technology Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Charts**: fl_chart
- **HTTP Client**: http package
- **Number Formatting**: intl package
- **Data Persistence**: shared_preferences

## Getting Started

### Prerequisites

- Flutter SDK (^3.6.2)
- Dart SDK (^3.6.2)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/graph_my_token.git
```

2. Navigate to the project directory:
```bash
cd graph_my_token
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the application:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart           # Application entry point and theme configuration
├── models/
│   └── token.dart      # Token data model
├── screens/
│   └── grid_home_screen.dart  # Main grid view screen
└── services/
    └── token_service.dart     # API service for token data
```

## Theme and Design

The application uses a carefully crafted dark theme with neon accents:
- Primary Color: #00FF9C (Neon Green)
- Secondary Color: #00E5FF (Neon Blue)
- Tertiary Color: #FF00E5 (Neon Pink)
- Background: #121212 (Dark Gray)
- Surface: #1E1E1E (Lighter Dark Gray)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with Trae AI by ByteDance
- Cryptocurrency data provided by CoinGecko API
- Flutter and Dart teams for the amazing framework
