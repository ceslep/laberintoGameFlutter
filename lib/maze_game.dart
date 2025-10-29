import 'dart:math';
import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/events.dart';

enum GameState {
  ready,
  playing,
  finished,
}

class MazeGame extends FlameGame with KeyboardEvents {
  static const int cellSize = 48;
  late int mazeWidth;
  late int mazeHeight;

  late List<List<Cell>> maze;
  late Player player;
  late Cell startCell;
  late Cell endCell;
  bool _isInitialized = false;
  final List<PositionComponent> _solutionPathComponents = [];
  late Stopwatch _stopwatch;
  late TextComponent _winMessageComponent;
  Function(String elapsedTime)? onPlayerWin;

  void playerReachedGoal() {
    _stopwatch.stop();
    final String elapsedTime = _formatDuration(_stopwatch.elapsed);
    _winMessageComponent.text = '¡Ganaste! Tiempo: $elapsedTime';
    add(_winMessageComponent);

    if (onPlayerWin != null) {
      onPlayerWin!(elapsedTime);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  // Exposed methods for Flutter widget
  void startGame() {
    _stopwatch.start();
    _winMessageComponent.removeFromParent();
  }

  void endGame() {
    // Game state and timer managed by Flutter
  }

  void resetGame() {
    _stopwatch.stop();
    _stopwatch.reset();
    _winMessageComponent.removeFromParent();
    _resetGame();
  }

  void drawSolution() {
    // Clear existing solution path components
    for (final component in _solutionPathComponents) {
      component.removeFromParent();
    }
    _solutionPathComponents.clear();

    final solution = _solveMaze();
    if (solution.isNotEmpty) {
      for (int i = 0; i < solution.length - 1; i++) {
        final currentCell = solution[i];
        final nextCell = solution[i + 1];

        Direction arrowDirection;
        if (nextCell.x > currentCell.x) {
          arrowDirection = Direction.east;
        } else if (nextCell.x < currentCell.x) {
          arrowDirection = Direction.west;
        } else if (nextCell.y > currentCell.y) {
          arrowDirection = Direction.south;
        } else {
          arrowDirection = Direction.north;
        }

        const arrowSize = cellSize / 2;
        final arrowPosition = Vector2(
          currentCell.x * cellSize + cellSize / 2,
          currentCell.y * cellSize + cellSize / 2,
        );

        final arrow = ArrowComponent(
          arrowPosition,
          arrowDirection,
          arrowSize,
          Colors.blue.withAlpha(150),
        );
        add(arrow);
        _solutionPathComponents.add(arrow);
      }
    }
  }

  MazeGame() {
    // No-op constructor, initialization moved to onLoad
  }

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    mazeWidth = (size.x / cellSize).floor();
    mazeHeight = (size.y / cellSize).floor();

    // Ensure maze dimensions are at least 1
    if (mazeWidth == 0) mazeWidth = 1;
    if (mazeHeight == 0) mazeHeight = 1;

    camera = CameraComponent.withFixedResolution(
      width: mazeWidth * cellSize.toDouble(),
      height: mazeHeight * cellSize.toDouble(),
    );
    camera.viewfinder.anchor = Anchor.topLeft;

    generateMaze();
    _initializePlayerAndGoals();

    for (int y = 0; y < mazeHeight; y++) {
      for (int x = 0; x < mazeWidth; x++) {
        final cell = maze[y][x];

        // Draw walls
        if (cell.walls['north']!) {
          add(RectangleComponent.fromRect(
            Rect.fromLTWH(
              x * cellSize.toDouble(),
              y * cellSize.toDouble(),
              cellSize.toDouble(),
              2,
            ),
            paint: Paint()..color = Colors.black,
          ));
        }
        if (cell.walls['south']!) {
          add(RectangleComponent.fromRect(
            Rect.fromLTWH(
              x * cellSize.toDouble(),
              (y + 1) * cellSize.toDouble() - 2,
              cellSize.toDouble(),
              2,
            ),
            paint: Paint()..color = Colors.black,
          ));
        }
        if (cell.walls['west']!) {
          add(RectangleComponent.fromRect(
            Rect.fromLTWH(
              x * cellSize.toDouble(),
              y * cellSize.toDouble(),
              2,
              cellSize.toDouble(),
            ),
            paint: Paint()..color = Colors.black,
          ));
        }
        if (cell.walls['east']!) {
          add(RectangleComponent.fromRect(
            Rect.fromLTWH(
              (x + 1) * cellSize.toDouble() - 2,
              y * cellSize.toDouble(),
              2,
              cellSize.toDouble(),
            ),
            paint: Paint()..color = Colors.black,
          ));
        }
      }
    }
    _stopwatch = Stopwatch();
    _winMessageComponent = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48.0,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      priority: 10, // Ensure it's on top
    );
    add(_winMessageComponent);
    _winMessageComponent.removeFromParent(); // Initially hidden

    _isInitialized = true;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (!_isInitialized) {
      return KeyEventResult.skipRemainingHandlers;
    }

    if (event is KeyDownEvent) {
      final LogicalKeyboardKey key = event.logicalKey;

      if (key == LogicalKeyboardKey.arrowUp) {
        player.move(Direction.north, maze);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowDown) {
        player.move(Direction.south, maze);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        player.move(Direction.west, maze);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowRight) {
        player.move(Direction.east, maze);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.skipRemainingHandlers;
  }

  void _resetGame() {
    // Timer management handled by Flutter

    // Remove all existing maze components (walls, player, goals, solution path)
    removeAll(children
        .where((component) =>
            component is RectangleComponent ||
            component is Player ||
            component is SpriteComponent ||
            _solutionPathComponents.contains(component))
        .toList());
    _solutionPathComponents.clear();
    _solutionPathComponents.clear();

    // Generate new maze
    generateMaze();

    // Add new maze components (walls)
    for (int y = 0; y < mazeHeight; y++) {
      for (int x = 0; x < mazeWidth; x++) {
        final cell = maze[y][x];

        // Draw walls
        if (cell.walls['north']!) {
          add(RectangleComponent.fromRect(
            Rect.fromLTWH(
              x * cellSize.toDouble(),
              y * cellSize.toDouble(),
              cellSize.toDouble(),
              2,
            ),
            paint: Paint()..color = Colors.black,
          ));
        }
        if (cell.walls['south']!) {
          add(RectangleComponent.fromRect(
            Rect.fromLTWH(
              x * cellSize.toDouble(),
              (y + 1) * cellSize.toDouble() - 2,
              cellSize.toDouble(),
              2,
            ),
            paint: Paint()..color = Colors.black,
          ));
        }
        if (cell.walls['west']!) {
          add(RectangleComponent.fromRect(
            Rect.fromLTWH(
              x * cellSize.toDouble(),
              y * cellSize.toDouble(),
              2,
              cellSize.toDouble(),
            ),
            paint: Paint()..color = Colors.black,
          ));
        }
        if (cell.walls['east']!) {
          add(RectangleComponent.fromRect(
            Rect.fromLTWH(
              (x + 1) * cellSize.toDouble() - 2,
              y * cellSize.toDouble(),
              2,
              cellSize.toDouble(),
            ),
            paint: Paint()..color = Colors.black,
          ));
        }
      }
    }
    _initializePlayerAndGoals();
  }

  List<Cell> _solveMaze() {
    final Queue<List<Cell>> queue = Queue();
    final Set<Cell> visited = {};
    final Map<Cell, Cell> parentMap = {};

    queue.add([startCell]);
    visited.add(startCell);

    while (queue.isNotEmpty) {
      final List<Cell> path = queue.removeFirst();
      final Cell current = path.last;

      if (current == endCell) {
        return path;
      }

      for (final neighbor in _getPassableNeighbors(current)) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          parentMap[neighbor] = current;
          queue.add(List.from(path)..add(neighbor));
        }
      }
    }
    return []; // No solution found
  }

  List<Cell> _getPassableNeighbors(Cell cell) {
    final List<Cell> neighbors = [];

    // Check north
    if (cell.y > 0 && !cell.walls['north']!) {
      neighbors.add(maze[cell.y - 1][cell.x]);
    }
    // Check south
    if (cell.y < mazeHeight - 1 && !cell.walls['south']!) {
      neighbors.add(maze[cell.y + 1][cell.x]);
    }
    // Check east
    if (cell.x < mazeWidth - 1 && !cell.walls['east']!) {
      neighbors.add(maze[cell.y][cell.x + 1]);
    }
    // Check west
    if (cell.x > 0 && !cell.walls['west']!) {
      neighbors.add(maze[cell.y][cell.x - 1]);
    }

    return neighbors;
  }

  void _initializePlayerAndGoals() {
    final Random random = Random();

    // Random start cell
    int startX = random.nextInt(mazeWidth);
    int startY = random.nextInt(mazeHeight);
    startCell = maze[startY][startX];

    // Random end cell, ensuring it's not the same as the start cell
    int endX, endY;
    do {
      endX = random.nextInt(mazeWidth);
      endY = random.nextInt(mazeHeight);
    } while (startX == endX && startY == endY);
    endCell = maze[endY][endX];

    // Add player
    player = Player(Vector2(
      startCell.x * cellSize + cellSize / 2,
      startCell.y * cellSize + cellSize / 2,
    ));
    add(player);

    // Draw start and end cells
    add(RectangleComponent.fromRect(
      Rect.fromLTWH(
        startCell.x * cellSize.toDouble(),
        startCell.y * cellSize.toDouble(),
        cellSize.toDouble(),
        cellSize.toDouble(),
      ),
      paint: Paint()..color = Colors.green.withAlpha((255 * 0.5).toInt()),
    ));

    add(RectangleComponent.fromRect(
      Rect.fromLTWH(
        endCell.x * cellSize.toDouble(),
        endCell.y * cellSize.toDouble(),
        cellSize.toDouble(),
        cellSize.toDouble(),
      ),
      paint: Paint()..color = Colors.red.withAlpha((255 * 0.5).toInt()),
    ));
  }

  void generateMaze() {
    maze = List.generate(
      mazeHeight,
      (y) => List.generate(
        mazeWidth,
        (x) => Cell(x, y),
      ),
    );

    final Random random = Random();
    final List<Cell> stack = [];
    Cell current = maze[0][0];
    current.visited = true;
    stack.add(current);

    while (stack.isNotEmpty) {
      final List<Cell> unvisitedNeighbors = getUnvisitedNeighbors(current);

      if (unvisitedNeighbors.isNotEmpty) {
        final Cell next =
            unvisitedNeighbors[random.nextInt(unvisitedNeighbors.length)];
        stack.add(next);
        removeWall(current, next);
        current = next;
        current.visited = true;
      } else {
        current = stack.removeLast();
      }
    }
  }

  List<Cell> getUnvisitedNeighbors(Cell cell) {
    final List<Cell> neighbors = [];

    // North
    if (cell.y > 0 && !maze[cell.y - 1][cell.x].visited) {
      neighbors.add(maze[cell.y - 1][cell.x]);
    }
    // South
    if (cell.y < mazeHeight - 1 && !maze[cell.y + 1][cell.x].visited) {
      neighbors.add(maze[cell.y + 1][cell.x]);
    }
    // East
    if (cell.x < mazeWidth - 1 && !maze[cell.y][cell.x + 1].visited) {
      neighbors.add(maze[cell.y][cell.x + 1]);
    }
    // West
    if (cell.x > 0 && !maze[cell.y][cell.x - 1].visited) {
      neighbors.add(maze[cell.y][cell.x - 1]);
    }

    return neighbors;
  }

  void removeWall(Cell current, Cell next) {
    if (current.x == next.x) {
      // Vertical movement
      if (current.y > next.y) {
        current.walls['north'] = false;
        next.walls['south'] = false;
      } else {
        current.walls['south'] = false;
        next.walls['north'] = false;
      }
    } else {
      // Horizontal movement
      if (current.x > next.x) {
        current.walls['west'] = false;
        next.walls['east'] = false;
      } else {
        current.walls['east'] = false;
        next.walls['west'] = false;
      }
    }
  }
}

class Cell {
  final int x;
  final int y;
  bool visited = false;
  Map<String, bool> walls = {
    'north': true,
    'south': true,
    'east': true,
    'west': true,
  };

  Cell(this.x, this.y);
}

class Player extends SpriteAnimationComponent {
  Player(Vector2 position)
      : super(position: position, size: Vector2.all(MazeGame.cellSize / 2)) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    List<Sprite> frames = [];
    frames.add(Sprite(await (findGame() as FlameGame).images.load('frame_001.png')));
    frames.add(Sprite(await (findGame() as FlameGame).images.load('frame_002.png')));
    frames.add(Sprite(await (findGame() as FlameGame).images.load('frame_003.png')));
    animation = SpriteAnimation.spriteList(frames, stepTime: 0.1);
    return super.onLoad();
  }

  void move(Direction direction, List<List<Cell>> maze) {
    final gameRef = findGame() as MazeGame;

    final int mazeWidth = gameRef.mazeWidth;

    final int mazeHeight = gameRef.mazeHeight;

    int currentCellX = (position.x / MazeGame.cellSize).floor();

    int currentCellY = (position.y / MazeGame.cellSize).floor();

    // Ensure currentCellX and currentCellY are within maze bounds

    if (currentCellX < 0) currentCellX = 0;

    if (currentCellX >= mazeWidth) currentCellX = mazeWidth - 1;

    if (currentCellY < 0) currentCellY = 0;

    if (currentCellY >= mazeHeight) currentCellY = mazeHeight - 1;

    final currentCell = maze[currentCellY][currentCellX];

    double newX = position.x;

    double newY = position.y;

    bool canMove = false;

    switch (direction) {
      case Direction.north:
        if (!currentCell.walls['north']!) {
          newY -= MazeGame.cellSize;

          canMove = true;
        }

        break;

      case Direction.south:
        if (!currentCell.walls['south']!) {
          newY += MazeGame.cellSize;

          canMove = true;
        }

        break;

      case Direction.east:
        if (!currentCell.walls['east']!) {
          newX += MazeGame.cellSize;

          canMove = true;
        }

        break;

      case Direction.west:
        if (!currentCell.walls['west']!) {
          newX -= MazeGame.cellSize;

          canMove = true;
        }

        break;
    }

    if (canMove) {
      position.x = newX;

      position.y = newY;

      final gameRef = findGame() as MazeGame;

      int newCellX = (position.x / MazeGame.cellSize).floor();

      int newCellY = (position.y / MazeGame.cellSize).floor();

      if (newCellX == gameRef.endCell.x && newCellY == gameRef.endCell.y) {
        gameRef.playerReachedGoal();
      }
    }
  }
}

class ArrowComponent extends PositionComponent {
  final Direction direction;

  final Paint _paint;

  ArrowComponent(
      Vector2 position, this.direction, double arrowSize, Color color)
      : _paint = Paint()..color = color,
        super(
          position: position,
          size: Vector2.all(arrowSize),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final Path path = Path();

    // Draw a triangle pointing in the correct direction

    switch (direction) {
      case Direction.north:
        path.moveTo(size.x / 2, 0);

        path.lineTo(0, size.y);

        path.lineTo(size.x, size.y);

        break;

      case Direction.south:
        path.moveTo(size.x / 2, size.y);

        path.lineTo(0, 0);

        path.lineTo(size.x, 0);

        break;

      case Direction.east:
        path.moveTo(size.x, size.y / 2);

        path.lineTo(0, 0);

        path.lineTo(0, size.y);

        break;

      case Direction.west:
        path.moveTo(0, size.y / 2);

        path.lineTo(size.x, 0);

        path.lineTo(size.x, size.y);

        break;
    }

    path.close();

    canvas.drawPath(path, _paint);
  }
}

enum Direction {
  north,

  south,

  east,

  west,
}
