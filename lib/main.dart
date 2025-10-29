import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:laberinto/maze_game.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MazeGame _game;

  @override
  void initState() {
    super.initState();
    _game = MazeGame();
    _game.onPlayerWin = (elapsedTime) {
      setState(() {
        // No need to update _gameState here, MazeGame handles its own state
      });
    };
    _game.gameState.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _game.gameState.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    setState(() {
      // Rebuild UI when game state changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Instituto Guatica'),
          actions: [
            if (_game.gameState.value == GameState.ready || _game.gameState.value == GameState.finished)
              ElevatedButton(
                onPressed: () {
                  _game.resetGame();
                  _game.startGame();
                },
                child: const Text('Iniciar Juego'),
              ),
            if (_game.gameState.value == GameState.ready || _game.gameState.value == GameState.finished)
              ElevatedButton(
                onPressed: () {
                  _game.drawSolution();
                },
                child: const Text('Resolver'),
              ),
            if (_game.gameState.value == GameState.playing)
              ElevatedButton(
                onPressed: () {
                  _game.endGame();
                },
                child: const Text('Terminar Juego'),
              ),
          ],
        ),
        body: GameWidget(game: _game),
      ),
    );
  }
}
