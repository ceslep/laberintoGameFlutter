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
  GameState _gameState = GameState.ready;

  @override
  void initState() {
    super.initState();
    _game = MazeGame();
    _game.onPlayerWin = (elapsedTime) {
      setState(() {
        _gameState = GameState.finished;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Juego del Laberinto'),
          actions: [
            if (_gameState == GameState.ready || _gameState == GameState.finished)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _game.resetGame();
                    _game.startGame();
                    _gameState = GameState.playing;
                  });
                },
                child: const Text('Iniciar Juego'),
              ),
            if (_gameState == GameState.ready || _gameState == GameState.finished)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _game.drawSolution();
                  });
                },
                child: const Text('Resolver'),
              ),
            if (_gameState == GameState.playing)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _game.endGame();
                    _gameState = GameState.finished;
                  });
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
