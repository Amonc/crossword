import 'dart:math';

import 'package:crossword/components/line_decoration.dart';
import 'package:crossword/crossword.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crossword Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<List<String>> letters = [];
  List<Color> lineColors = [];

  List<int> letterGrid = [11, 14];

  List<List<String>> generateRandomLetters() {
    final random = Random();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    List<List<String>> array = List.generate(
        letterGrid.first,
        (_) => List.generate(
            letterGrid.last, (_) => letters[random.nextInt(letters.length)]));

    return array;
  }

  Color generateRandomColor() {
    Random random = Random();

    int r = random.nextInt(200) - 128; // Red component between 128 and 255
    int g = random.nextInt(200) - 128; // Green component between 128 and 255
    int b = random.nextInt(200) - 128; // Blue component between 128 and 255

    return Color.fromARGB(255, r, g, b);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lineColors = List.generate(100, (index) => generateRandomColor()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Crossword(

          letters: const [
            ["F", "L", "U", "T", "T", "E", "R", "W", "U", "D", "B", "C"],
            ["R", "M", "I", "O", "P", "U", "I", "Q", "R", "L", "E", "G"],
            ["T", "V", "D", "I", "R", "I", "M", "U", "A", "H", "E", "A"],
            ["D", "A", "R", "T", "N", "S", "T", "O", "Y", "J", "R", "M"],
            ["O", "G", "A", "M", "E", "S", "C", "O", "L", "O", "R", "O"],
            ["S", "R", "T", "I", "I", "I", "F", "X", "S", "P", "E", "D"],
            ["Y", "S", "N", "E", "T", "M", "M", "C", "E", "A", "T", "S"],
            ["W", "E", "T", "P", "A", "T", "D", "Y", "L", "M", "N", "U"],
            ["O", "T", "E", "H", "R", "O", "G", "P", "T", "U", "O", "E"],
            ["K", "R", "R", "C", "G", "A", "M", "E", "S", "S", "T", "S"],
            ["S", "E", "S", "T", "L", "A", "O", "P", "U", "P", "E", "S"]
          ],
          spacing: const Offset(30, 30),
          onLineDrawn: (List<String> words) {},
          textStyle: const TextStyle(color: Colors.white, fontSize: 20),
          lineDecoration:
              LineDecoration(lineColors: lineColors, strokeWidth: 20),
          hints: const ["FLUTTER", "GAMES", "UI", "COLORS"],
        ));
  }
}
