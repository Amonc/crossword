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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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

    int r = random.nextInt(200) + 128; // Red component between 128 and 255
    int g = random.nextInt(200) + 128; // Green component between 128 and 255
    int b = random.nextInt(200) + 128; // Blue component between 128 and 255

    return Color.fromARGB(255, r, g, b);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lineColors = List.generate(100, (index) => generateRandomColor()).toList();
    letters = generateRandomLetters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Crossword(
          acceptReversedDirection: false,
          drawCrossLine: false,
          drawVerticalLine: false,
          letters: letters,
          spacing: const Offset(30, 30),
          onLineDrawn: (List<String> words) {},
          textStyle: const TextStyle(color: Colors.white, fontSize: 20),
          lineDecoration:
              LineDecoration(lineColors: lineColors, strokeWidth: 20),
          hints: [letters.first.join('')],
        ));
  }

}
