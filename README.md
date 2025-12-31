# 🔐 Password Manager

A **Flutter** app for managing and generating strong passwords with cloud storage using **Firebase**.

This project helps users securely store, view, generate, and organize passwords. Built with Flutter, it works across Android, iOS, Web, and Desktop platforms.

---

## 🚀 Features

- 🔑 **Secure Password Storage** – Save and retrieve passwords
- 🎯 **Password Generator** – Create random strong passwords
- ☁️ **Cloud Sync with Firebase** – All passwords stored in Firestore
- 🔒 **User Authentication** – Secure login/signup with Firebase Auth
- 📱 Responsive UI for mobile and web
- 🛠️ Cross-platform support (Android, iOS, Web, Windows, macOS, Linux)

---

## 📦 Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | UI + App Framework |
| Dart | Programming Language |
| Firebase Authentication | User Login/Signup |
| Firebase Cloud Firestore | Password Storage |
| Provider / State Management | App State |
| Flutter Secure Storage | Local secure storage (optional) |

---

## 🛠️ Prerequisites

Before running the app, make sure you have:

- Flutter SDK ≥ **3.0.0**
- Dart ≥ **2.18.0**
- Firebase account
- Supported IDE: VS Code, Android Studio

---

## ⚡ Installation

1. **Clone the repo**

   ```bash
   git clone https://github.com/MayurVadhadiya360/password-manager.git
   cd password-manager
   ```

   
2. **Install dependencies**

   ```bash
   flutter pub get
   ```


3. **Connect Firebase**

    Create a Firebase project and make sure you add:
    - Android App (`google-services.json`)
    - iOS App (`GoogleService-Info.plist`)
    - Web App (add config to `index.html`)

    Follow the official Firebase setup:
    - Android: https://firebase.google.com/docs/android/setup
    - iOS: https://firebase.google.com/docs/ios/setup
    - Web: https://firebase.google.com/docs/web/setup

4. **Add Config Files**

    - Place `google-services.json` under `android/app/`
    - Place `GoogleService-Info.plist` under `ios/Runner/`
    - Add Firebase config keys to `web/index.html` (if targeting web)

5. **Run the app**

   ```bash
    flutter run
   ```

---

## 🧠 App Flow

1. **User Authentication**
    - Users can sign up or log in using email/password

2. **Main Dashboard**
    - List of saved passwords

3. **Add New Password**
    - Generate or enter your own
    - Save with a title & description

4. **View / Edit Password**
    - Modify or delete saved entry

5. **Security**
    - You can optionally add a **master password** or local encryption logic

---

## 🔐 Password Generation Example

You can implement a generator like:
```dart
String generatePassword(int length) {
  const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()";
  return List.generate(length, (index) => chars[Random().nextInt(chars.length)]).join();
}
```

---

## 📌 Tips for Firebase
- Enable **Email/Password** under Authentication > Sign-in method
- Use **Firestore rules** like:

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/passwords/{doc} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

This ensures each user can only read/write their own passwords.

---

## 🖼️ Screenshots

<img width="420" alt="image" src="https://github.com/user-attachments/assets/3e2ba9c6-61e9-45c5-a893-d92d6106eafb" />

<img width="420" alt="image" src="https://github.com/user-attachments/assets/d783c1f2-366e-4e36-b75f-b5c8cff6704f" />

<img width="420" alt="image" src="https://github.com/user-attachments/assets/fe20d551-de20-46b5-952a-4e1dea44ab01" />

<img width="420" alt="image" src="https://github.com/user-attachments/assets/4e45d707-2a9a-4416-8769-1b083702a56f" />

---

## ⭐ Contribution

Feel free to open issues or submit pull requests to improve:
- Biometric login (Face/Touch ID)
- Local encryption with flutter_secure_storage
- Themes (dark/light)

---

## 🧪 Testing

Run unit/widget tests:
```bash
flutter test
```

## 📄 License

This project is **MIT Licensed**.
See the `LICENSE` file for details.

