import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:individual_asg/bgm.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'local_storage.dart';

class CompareNumbersPage extends StatefulWidget {
  const CompareNumbersPage({super.key});

  @override
  State<CompareNumbersPage> createState() => _CompareNumbersPageState();
}

class _CompareNumbersPageState extends State<CompareNumbersPage> {
  int number1 = 0;
  int number2 = 0;

  int? leftDroppedNumber;
  int? rightDroppedNumber;

  //int score = 0;

  String resultText = "";

  @override
  void initState() {
    super.initState();
    _generateTwoNumbers();
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted && !helpAppearCompare) {
        helpAppearCompare = true;
        showHelpDialog(context);
      }
    });
  }

  // Function to generate two random values
  void _generateTwoNumbers() {
    final random = Random();
    number1 = random.nextInt(1000);
    do {
      number2 = random.nextInt(1000);
    } while (number2 == number1);
  }

  // Check whether correct or wrong
  void _checkComparison() async {
    if (leftDroppedNumber != null && rightDroppedNumber != null) {
      HapticFeedback.mediumImpact();
      bool isCorrect = leftDroppedNumber! > rightDroppedNumber!;
      resultText =
          isCorrect
              ? "🎉 Congratulation, this is correct. $leftDroppedNumber is bigger than $rightDroppedNumber."
              : "❌ Wrong answer, $leftDroppedNumber is smaller than $rightDroppedNumber. Please try again.";

      if (isCorrect) {
        compareScore++;
      }

      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // small delay before showing

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false, // force user to press OK
        builder:
            (_) => AlertDialog(
              title: const Text(
                'Result',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              content: Text(resultText, style: TextStyle(fontSize: 18)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    _resetGame(); // refresh game
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  // Reset the game
  void _resetGame() {
    setState(() {
      leftDroppedNumber = null;
      rightDroppedNumber = null;
      resultText = "";
      _generateTwoNumbers();
    });
  }

  // Help button dialog
  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('How to Play'),
            content: const Text(
              'Welcome to Compare Number Stage.\n\n'
              'Drag and drop the bigger number on the left scale and smaller number on the right scale!\n\n'
              'If you get it right, you score a point!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: Brightness.light, // Light icons (white)
      ),

      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/background/compare_numbers_background.svg',
                fit: BoxFit.cover,
                placeholderBuilder:
                    (BuildContext context) => Container(color: Colors.grey),
              ),
            ),

            // Custom AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((255 * 0.35).toInt()),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha((255 * 0.1).toInt()),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((255 * 0.3).toInt()),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Title and Score
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Compare Numbers',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Score: $compareScore',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Help Button
                      InkWell(
                        onTap: () => showHelpDialog(context),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((255 * 0.3).toInt()),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Audio button
            Positioned(
              top: 135,
              right: 0,
              left: 300,
              child: Consumer<BgmProvider>(
                builder: (context, bgm, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        bgm.isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        bgm.toggleMute();
                      },
                    ),
                  );
                },
              ),
            ),

            // Random number boxes
            Positioned(
              top: 200,
              left: 50,
              right: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left box
                  if (leftDroppedNumber != number1 &&
                      rightDroppedNumber != number1)
                    Draggable<int>(
                      data: number1,
                      feedback: Material(
                        color: Colors.transparent,
                        child: NumberBox(number: number1),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: NumberBox(number: number1),
                      ),
                      child: NumberBox(number: number1),
                    )
                  else
                    const SizedBox(width: 100),

                  // Right box
                  if (leftDroppedNumber != number2 &&
                      rightDroppedNumber != number2)
                    Draggable<int>(
                      data: number2,
                      feedback: Material(
                        color: Colors.transparent,
                        child: NumberBox(number: number2),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: NumberBox(number: number2),
                      ),
                      child: NumberBox(number: number2),
                    )
                  else
                    const SizedBox(width: 100),
                ],
              ),
            ),

            // Left box on weight scale
            Positioned(
              bottom: 280,
              left: 20,
              child: DragTarget<int>(
                onAcceptWithDetails: (details) {
                  setState(() {
                    leftDroppedNumber = details.data;
                    if (rightDroppedNumber == details.data) {
                      rightDroppedNumber = null; // prevent duplicate
                    }
                  });
                  _checkComparison();
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((255 * 0.3).toInt()),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        leftDroppedNumber != null
                            ? Draggable<int>(
                              data: leftDroppedNumber!,
                              feedback: Material(
                                color: Colors.transparent,
                                child: NumberBox(number: leftDroppedNumber!),
                              ),
                              childWhenDragging:
                                  const SizedBox(), // hide during drag
                              child: NumberBox(number: leftDroppedNumber!),
                            )
                            : const Text(
                              "?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  );
                },
              ),
            ),

            // Right box on weight scale
            Positioned(
              bottom: 345,
              right: 9,
              child: DragTarget<int>(
                onAcceptWithDetails: (details) {
                  setState(() {
                    rightDroppedNumber = details.data;
                    if (leftDroppedNumber == details.data) {
                      leftDroppedNumber = null; // prevent duplicate
                    }
                  });
                  _checkComparison();
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((255 * 0.3).toInt()),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        rightDroppedNumber != null
                            ? Draggable<int>(
                              data: rightDroppedNumber!,
                              feedback: Material(
                                color: Colors.transparent,
                                child: NumberBox(number: rightDroppedNumber!),
                              ),
                              childWhenDragging:
                                  const SizedBox(), // hide during drag
                              child: NumberBox(number: rightDroppedNumber!),
                            )
                            : const Text(
                              "?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberBox extends StatelessWidget {
  final int number;

  const NumberBox({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.3).toInt()),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        number.toString(),
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
