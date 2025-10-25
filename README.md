# Maze Game

A simple yet engaging maze game built with Flutter and the Flame game engine. Navigate through procedurally generated mazes, race against the clock, and even get a helping hand with an automatic solver!

## ✨ Features

*   **Procedural Maze Generation:** Each game presents a unique maze.
*   **Player Movement:** Control the player character using keyboard arrow keys.
*   **Win Condition:** Reach the end of the maze to win.
*   **Elapsed Time Tracker:** See how fast you can solve the maze.
*   **Automatic Solution Path:** Visualize the shortest path to the exit with directional arrows.
*   **Responsive Design:** Adapts to different screen sizes (though primarily designed for desktop/web).

## 🚀 Technologies Used

*   **Flutter:** UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
*   **Flame:** A minimalist 2D game engine for Flutter.

## 🎮 Getting Started

### Prerequisites

Make sure you have the Flutter SDK installed on your machine. You can find installation instructions [here](https://flutter.dev/docs/get-started/install).

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/laberinto.git
    cd laberinto
    ```
2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```

### Running the Game

To run the game on your preferred platform (e.g., desktop, web):

```bash
flutter run
```

For a specific platform, you can use:
```bash
flutter run -d windows # For Windows desktop
flutter run -d web     # For web browser
```

## 🕹️ How to Play

*   **Objective:** Guide the blue square (player) from the green starting cell to the red ending cell.
*   **Controls:** Use the **arrow keys** (Up, Down, Left, Right) to move the player.
*   **Start Game:** Click the "Start Game" button to begin a new maze and start the timer.
*   **Solve:** Click the "Solve" button to display the shortest path to the exit, indicated by blue arrows.

## 📂 Project Structure

```
laberinto/
├── lib/
│   ├── main.dart         # Main application entry point and Flutter UI
│   └── maze_game.dart    # Core game logic using Flame (maze generation, player, etc.)
├── pubspec.yaml          # Project dependencies and metadata
└── README.md             # This file
```

## 🛣️ Future Enhancements

*   **Confetti Animation:** Add a visual confetti effect upon winning.
*   **Difficulty Levels:** Implement different maze sizes or complexities.
*   **Mobile Controls:** Add on-screen joystick or swipe controls for mobile devices.
*   **Sound Effects:** Incorporate sound for movement, winning, etc.
*   **Score Tracking:** Keep track of high scores.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

*   [Flutter](https://flutter.dev/)
*   [Flame Engine](https://flame-engine.org/)