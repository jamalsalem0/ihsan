# Ihsan | إحسان

![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)
![Platform](https://img.shields.io/badge/Platform-Android-brightgreen.svg)
![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue)

A modern, beautifully designed Islamic companion app built with Flutter. Ihsan provides a serene and focused user experience to help you stay connected with your daily religious practices.

---

## 📸 Screenshots

Here's a glimpse of Ihsan's stunning user interface, featuring our signature glassmorphism design and animated backgrounds.

*(Note: Replace the placeholders below with links to your actual screenshots. You can upload them to your GitHub repository and link them directly.)*

| Splash & Home Screen | Quran Index | Adhkar Hub |
| :---: | :---: | :---: |
| `[Your Screenshot Here]` | `[Your Screenshot Here]` | `[Your Screenshot Here]` |
| **Adhkar Reader** | **Settings** | **Adhan Notification** |
| `[Your Screenshot Here]` | `[Your Screenshot Here]` | `[Your Screenshot Here]` |

---

## ✨ Features

Ihsan is packed with features designed for a seamless and spiritual experience:

* **Prayer Times:** A beautiful home screen displaying daily prayer times with a real-time countdown to the next prayer.
* **Full Quran:** An elegant, searchable index of all 114 Surahs, leading to a clean and readable Quran interface.
* **Adhkar Hub:** A well-organized hub for various Adhkar categories (Morning, Evening, etc.).
* **Adhkar Reader & Counter:** An immersive reader experience with a built-in counter to help you keep track of your recitations.
* **Adhan Notifications:** Reliable, scheduled notifications for every prayer time, using custom Adhan sounds.
* **Stunning UI/UX:**
    * **Glassmorphism:** A modern, glassy design used across all components for a cohesive look.
    * **Animated Backgrounds:** Subtle, animated starry backgrounds that bring the app to life.
    * **Fluid Animations:** Smooth transitions and animations powered by `flutter_animate` and `simple_animations`.
* **Consistent Theme:** A carefully selected color palette (Purple & Navy) that creates a calm and spiritual atmosphere.

---

## 🚀 Tech Stack & Tools

This project is built using a modern, scalable, and efficient tech stack:

* **Framework:** [Flutter](https://flutter.dev/)
* **State Management:** [Riverpod](https://riverpod.dev/)
* **Routing:** [GoRouter](https://pub.dev/packages/go_router)
* **Local Notifications:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
* **Animations:** [flutter_animate](https://pub.dev/packages/flutter_animate), [simple_animations](https://pub.dev/packages/simple_animations)
* **Audio:** [just_audio](https://pub.dev/packages/just_audio)
* **Local Storage:** [shared_preferences](https://pub.dev/packages/shared_preferences)
* **UI:** [google_fonts](https://pub.dev/packages/google_fonts), Custom Glassmorphism Widgets

---

## 🔧 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

* Flutter SDK installed on your machine.

### Installation

1.  Clone the repo
    ```sh
    git clone [https://github.com/jamalsalem0/ihsan.git](https://github.com/jamalsalem0/ihsan.git)
    ```
2.  Install packages
    ```sh
    flutter pub get
    ```
3.  Run the app
    ```sh
    flutter run
    ```

---

## 📦 Building for Release (APK)

To build a release-ready APK for Android, follow these steps:

1.  **Create a Keystore:** Follow the official Flutter guide to create a `upload-keystore.jks` file.
    ```sh
    keytool -genkey -v -keystore upload-keystore.jks ...
    ```
2.  **Create `key.properties`:** In the `android` directory, create a `key.properties` file with your keystore credentials.
3.  **Run the Build Command:** Use the following command to build split APKs for better size optimization.
    ```sh
    flutter build apk --split-per-abi
    ```
4.  The generated APKs will be located in `build/app/outputs/flutter-apk/`.

For more details, see the [official Flutter documentation on building and releasing for Android](https://docs.flutter.dev/deployment/android).

---

## 👨‍💻 Author

**[Your Name]** - Feel free to connect with me!

* GitHub: `[@jamalsalem0]`
* LinkedIn: `[https://www.linkedin.com/in/jamalsalem/]`

---

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.