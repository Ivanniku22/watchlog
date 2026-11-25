# 🎬 Watchlog

**Your personal space to track, discover, and manage the movies and TV shows you watch.**

Watchlog is a Flutter-based movie and TV show tracking application inspired by apps like TV Time. It allows users to explore movies and television shows, maintain personal watchlists, track watched episodes, and keep their viewing history organized in one place.

Built as a personal project to strengthen my Flutter development skills and explore real-world application architecture, API integration, authentication, and cloud database management.

---

## ✨ Features

### 🔐 Authentication
- User registration and login using Firebase Authentication.
- Individual user accounts with separate viewing data.

### 🔎 Explore
- Discover popular movies and TV shows.
- Search for movies and television shows.
- View detailed information about movies and shows.
- Browse posters, backdrops, descriptions, ratings, and release information.
- Add movies and shows directly to your watchlist.

### 📺 TV Show Tracking
- Maintain a personal TV show watchlist.
- Track watched episodes.
- Keep track of episode progress.
- View upcoming episodes and releases.
- Organize shows based on their watching status.

### 🎥 Movie Tracking
- Maintain a personal movie watchlist.
- Separate upcoming movies from released movies.
- Mark movies as watched.
- Keep track of watched movie history.

### 👤 Profile
- View personal watch statistics.
- Track the total number of watched episodes.
- Import viewing history from a TV Time export.
- View your added movies and TV shows.

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI development |
| Dart | Application programming language |
| GetX | State management, dependency injection, and navigation |
| Firebase Authentication | User authentication |
| Cloud Firestore | Cloud database and user-specific data storage |
| TMDB API | Movie and TV show information |
| Dio | HTTP requests and API communication |
| flutter_dotenv | Environment variable management |

---

## 🏗️ Architecture

Watchlog follows an **MVVM-inspired architecture** to separate UI, application logic, and data operations.

```text
lib/
├── app/
│   ├── bindings/
│   ├── routes/
│   └── ...
│
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── presentation/
│   ├── explore/
│   ├── shows/
│   ├── movies/
│   ├── movie_details/
│   ├── show_details/
│   └── profile/
│
└── main.dart
```

**Architecture responsibilities:**

- **Views:** Display the application UI.
- **Controllers:** Handle state management and application logic using GetX.
- **Repositories:** Manage data operations and communicate with data sources.
- **Services:** Handle external API communication.
- **Models:** Represent and parse application data.

---

## 🌐 APIs and Services

### The Movie Database (TMDB)

Watchlog uses the [TMDB API](https://developer.themoviedb.org/docs) to retrieve movie and television data, including:

- Popular movies and TV shows.
- Search results.
- Movie and TV show details.
- Season and episode information.
- Posters and backdrop images.

### Firebase

Firebase provides:
- Authentication.
- Cloud Firestore for storing individual users' watchlists and viewing history.

---

## ⚙️ Getting Started

### Prerequisites

Make sure you have installed:

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- A Firebase project
- A TMDB API access token

### 1. Clone the repository

```bash
git clone https://github.com/Ivanniku22/watchlog.git
```

### 2. Navigate to the project

```bash
cd watchlog
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Configure environment variables

Create a `.env` file in the project root:

```env
TMDB_ACCESS_TOKEN=your_tmdb_access_token
```

Never commit your actual API token or other private credentials.

### 5. Configure Firebase

Set up Firebase for your Flutter project using the official [FlutterFire documentation](https://firebase.google.com/docs/flutter/setup).

Make sure Firebase Authentication and Cloud Firestore are enabled.

### 6. Run the application

```bash
flutter run
```

---

## 🔒 Security

- API credentials are managed through environment variables.
- Firebase Authentication identifies individual users.
- User-specific viewing data is stored separately in Firestore.
- Firebase security rules should restrict access to each user's own data.

**Important:** Never upload your `.env` file, Firebase service account credentials, or other private secrets to GitHub.

---

## 🎯 Project Goals

This project was developed to gain practical experience with:

- Building real-world Flutter applications.
- Implementing MVVM-inspired architecture.
- State management and dependency injection with GetX.
- Integrating REST APIs using Dio.
- Parsing JSON responses into Dart models.
- Firebase Authentication and Cloud Firestore.
- Managing asynchronous operations and application state.
- Handling large datasets and optimizing application performance.

---

## 🚀 Future Improvements

Potential areas for future development:

- Notifications for upcoming episodes.
- More detailed viewing statistics.
- Improved recommendations.
- Additional filtering and sorting options.
- UI and performance refinements.

---

## 🙌 Acknowledgements

- [TMDB](https://www.themoviedb.org/) for providing movie and television data.
- [Flutter](https://flutter.dev/) for the application framework.
- [Firebase](https://firebase.google.com/) for authentication and cloud storage.

---

## 📌 Disclaimer

Watchlog is an independent personal project developed for learning and portfolio purposes. It is not affiliated with, endorsed by, or officially connected to TV Time or TMDB.

This product uses the TMDB API but is not endorsed or certified by TMDB.

---

**Built with ❤️ using Flutter.**