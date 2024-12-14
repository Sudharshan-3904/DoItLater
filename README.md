# DoItLater: Your Personal To-Do List Manager

## Overview

DoItLater is a simple yet powerful to-do list manager built with Flutter. It allows you to keep track of your tasks, categorize them, prioritize them, and set deadlines. This project demonstrates how to use state management in Flutter, interact with JSON files for data persistence, and handle user inputs effectively.

## Features

- **Task Management**: Easily add, edit, and delete tasks.
- **Categorization**: Organize tasks into different categories (e.g., work, personal).
- **Priority Levels**: Set priorities for tasks (e.g., High, Medium, Low).
- **Deadlines**: Assign deadlines to tasks with a built-in date picker.
- **Dark Mode**: Switch between light and dark themes.

## Getting Started

### Prerequisites

- Flutter SDK: Ensure you have the Flutter SDK installed on your machine. You can download it from [flutter.dev](https://flutter.dev/docs/get-started/install).
- IDE/Code Editor: Use Android Studio, VS Code, or any other Flutter-supported IDE.

### Installation

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/yourusername/do-it-later.git
   cd do-it-later
   ```

2. **Install Dependencies**:
   Run the following command to install all required packages:
   ```sh
   flutter pub get
   ```

### Running the Project

1. **Connect Your Device or Emulator**:
   Make sure your Android device is connected via USB, or start an emulator.

2. **Run the App**:
   Use the following command to run the app on your connected device or emulator:
   ```sh
   flutter run
   ```

### Project Structure

- `lib/main.dart`: The main entry point of the application.
- `lib/models/to_do_list_item.dart`: A model class representing a to-do list item.
- `lib/screens/add_task_screen.dart`: A screen for adding new tasks.
- `lib/screens/home_screen.dart`: The home screen displaying all tasks.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

1. **Fork the Repository**:
   ```sh
   git fork https://github.com/yourusername/do-it-later.git
   ```

2. **Create Your Branch**:
   ```sh
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes and Commit**:
   Make your changes, then commit them with a descriptive message.
   ```sh
   git add .
   git commit -m "Add new feature"
   ```

4. **Push to Your Branch**:
   ```sh
   git push origin feature/your-feature-name
   ```

5. **Open a Pull Request**:
   Go to the repository and open a pull request against the `main` branch.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---