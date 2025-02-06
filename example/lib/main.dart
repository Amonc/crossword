import 'dart:math';
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

  GlobalKey<CrosswordState> crosswordState = GlobalKey<CrosswordState>();
  String word = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text(word, style: const TextStyle(fontSize: 20)),
              ),
              Expanded(
                child: Crossword(
                  letterPopDecoration: const LetterPopDecoration(
                    onTouchPopScaleFactor: 1.5,
                    duration: Duration(milliseconds: 200),
                    onTouchLetterFontStyle: FontStyle.italic,
                  ),
                  revealLetterDecoration:
                      const RevealLetterDecoration(shakeOffset: Offset(10, 20)),
                  key: crosswordState,
                  allowOverlap: false,
                  letters: const [
                    [
                      "F",
                      "L",
                      "U",
                      "T",
                      "T",
                      "E",
                      "R",
                      "W",
                      "U",
                      "D",
                      "B",
                      "C"
                    ],
                    [
                      "R",
                      "M",
                      "I",
                      "O",
                      "P",
                      "U",
                      "I",
                      "Q",
                      "R",
                      "L",
                      "E",
                      "G"
                    ],
                    [
                      "T",
                      "V",
                      "D",
                      "I",
                      "R",
                      "I",
                      "M",
                      "U",
                      "A",
                      "H",
                      "E",
                      "A"
                    ],
                    [
                      "D",
                      "A",
                      "R",
                      "T",
                      "N",
                      "S",
                      "T",
                      "O",
                      "Y",
                      "J",
                      "R",
                      "M"
                    ],
                    [
                      "O",
                      "G",
                      "A",
                      "M",
                      "E",
                      "S",
                      "C",
                      "O",
                      "L",
                      "O",
                      "R",
                      "O"
                    ],
                    [
                      "S",
                      "R",
                      "T",
                      "I",
                      "I",
                      "I",
                      "F",
                      "X",
                      "S",
                      "P",
                      "E",
                      "D"
                    ],
                    [
                      "Y",
                      "S",
                      "N",
                      "E",
                      "T",
                      "M",
                      "M",
                      "C",
                      "E",
                      "A",
                      "T",
                      "S"
                    ],
                    [
                      "W",
                      "E",
                      "T",
                      "P",
                      "A",
                      "T",
                      "D",
                      "Y",
                      "L",
                      "M",
                      "N",
                      "U"
                    ],
                    [
                      "O",
                      "T",
                      "E",
                      "H",
                      "R",
                      "O",
                      "G",
                      "P",
                      "T",
                      "U",
                      "O",
                      "E"
                    ],
                    [
                      "K",
                      "R",
                      "R",
                      "C",
                      "G",
                      "A",
                      "M",
                      "E",
                      "S",
                      "S",
                      "T",
                      "S"
                    ],
                    ["S", "E", "S", "T", "L", "A", "O", "P", "U", "P", "E", "S"]
                  ],
                  spacing: const Offset(30, 30),
                  onLineUpdate: (String word, List<String> words, isLineDrawn) {
                    if (isLineDrawn) {

                    } else {

                    }
                  },
                  addIncorrectWord: false,
                  textStyle: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  lineDecoration: const LineDecoration(
                    lineGradientColors: [
                      [
                        Colors.blue,
                        Colors.black,
                        Colors.red,
                        Colors.orange,
                        Colors.black,
                        Colors.amber,
                        Colors.green
                      ],
                    ],
                    strokeWidth: 26,
                    lineTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  hints: const ["FLUTTER", "GAMES", "UI", "COLOR"],
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    crosswordState.currentState!
                        .animate(offset: const Offset(7, 3));
                  },
                  child: const Text('Reveal Hint')),
            ],
          ),
        ));
  }
}
