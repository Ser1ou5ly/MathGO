import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:individual_asg/bgm.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'local_storage.dart';

class ComposingNumbersPage extends StatefulWidget {
  const ComposingNumbersPage({super.key});

  @override
  State<ComposingNumbersPage> createState() => _ComposingNumbersPage();
}

class _ComposingNumbersPage extends State<ComposingNumbersPage> {
  int generatedNumber = 0;
  int? leftNumber;
  int? rightNumber;
  List<int> options = [];
  List<int> availableOptions = [];

  @override
  void initState() {
    super.initState();
    _generateKeyNumber();
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted && !helpAppearCompose) {
        helpAppearCompose = true;
        showHelpDialog(context);
      }
    });
  }

  // Generate the needed number in this mode
  void _generateKeyNumber() {
    final random = Random();
    leftNumber = null;
    rightNumber = null;
    options.clear();
    availableOptions.clear();
    int first, second, randomNumber;

    // Ensure the number to be composed is not 0
    do {
      generatedNumber = random.nextInt(1000);
    } while (generatedNumber == 0);

    // Ensure one number always smaller than the generated number so compose to generatedNumber
    first = random.nextInt(generatedNumber);
    second = generatedNumber - first;

    // Add the correct answer into list
    options.addAll([first, second]);

    // Add random number into list
    while (options.length < 4) {
      randomNumber = random.nextInt(1000);
      if (!options.contains(randomNumber)) {
        options.add(randomNumber);
      }
    }

    options
        .shuffle(); // Shuffle the list so that the answer will not be at fixed position
    availableOptions = List.from(options);

    setState(() {}); // Ensure the lists are updated
  }

  void _checkComposedNumber() {
    if (leftNumber != null && rightNumber != null) {
      HapticFeedback.mediumImpact();
      final composed = leftNumber! + rightNumber!;
      if (composed == generatedNumber) {
        composeScore++;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => AlertDialog(
                title: const Text(
                  '🎉 Congratulations!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'You are correct. $generatedNumber is composed with $leftNumber and $rightNumber!',
                  style: const TextStyle(fontSize: 18),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        leftNumber = null;
                        rightNumber = null;
                        _generateKeyNumber();
                      });
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => AlertDialog(
                title: const Text(
                  '❌ Incorrect',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'Oops! $generatedNumber is not compose with $leftNumber and $rightNumber. Try again!',
                  style: const TextStyle(fontSize: 18),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        leftNumber = null;
                        rightNumber = null;
                        _generateKeyNumber();
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
        );
      }
    }
  }

  // Help button dialog
  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('How to Play'),
            content: const Text(
              'Welcome to Composing Number Stage.\n\n'
              'Drag and drop the numbers to compose the shown number on the top in a amber box!\n\n'
              'For example: 23 is composed with 20 and 3!\n\n'
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
                'assets/background/composing_numbers_background.svg',
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
                    color: Colors.grey.withAlpha((255 * 0.25).toInt()),
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
                              'Composing Numbers',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Score: $composeScore',
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

            // Generated number to be formed
            Positioned(
              top: 160,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepOrange, Colors.amber],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withAlpha(
                            (0.8 * 255).toInt(),
                          ),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withAlpha((0.6 * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      generatedNumber.toString(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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

            // Draggable boxes in 2 rows
            Positioned(
              top: 300,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // First row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(2, (i) {
                      final num = options[i];
                      if (!availableOptions.contains(num)) {
                        return const SizedBox(width: 80, height: 80);
                      }
                      return Draggable<int>(
                        data: num,
                        feedback: Material(
                          color: Colors.transparent,
                          child: NumberBox(number: num),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: NumberBox(number: num),
                        ),
                        child: NumberBox(number: num),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),

                  // Second row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(2, (i) {
                      final num = options[i + 2]; // always 2 and 3
                      if (!availableOptions.contains(num)) {
                        return const SizedBox(width: 80, height: 80);
                      }
                      return Draggable<int>(
                        data: num,
                        feedback: Material(
                          color: Colors.transparent,
                          child: NumberBox(number: num),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: NumberBox(number: num),
                        ),
                        child: NumberBox(number: num),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Left Treasure Box
            Positioned(
              bottom: 160,
              left: 35,
              child: DragTarget<int>(
                onAcceptWithDetails: (details) {
                  setState(() {
                    if (rightNumber == details.data) {
                      // If the number drag from right box to left box change the value back to ?
                      rightNumber = null;
                    }
                    if (leftNumber != null) {
                      availableOptions.add(
                        leftNumber!,
                      ); // put back previous value
                    }
                    leftNumber = details.data;
                    availableOptions.remove(details.data);
                  });
                  _checkComposedNumber();
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 80,
                    height: 80,
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
                        leftNumber != null
                            ? Draggable<int>(
                              data: leftNumber!,
                              feedback: Material(
                                color: Colors.transparent,
                                child: NumberBox(number: leftNumber!),
                              ),
                              childWhenDragging:
                                  const SizedBox(), // hide during drag
                              child: NumberBox(number: leftNumber!),
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

            // Right Treasure Box
            Positioned(
              bottom: 160,
              right: 45,
              child: DragTarget<int>(
                onAcceptWithDetails: (details) {
                  setState(() {
                    if (leftNumber == details.data) {
                      // If the number drag from left box to right box change the value back to ?
                      leftNumber = null;
                    }
                    if (rightNumber != null) {
                      availableOptions.add(
                        rightNumber!,
                      ); // put back previous value
                    }
                    rightNumber = details.data;
                    availableOptions.remove(details.data);
                  });
                  _checkComposedNumber();
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 80,
                    height: 80,
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
                        rightNumber != null
                            ? Draggable<int>(
                              data: rightNumber!,
                              feedback: Material(
                                color: Colors.transparent,
                                child: NumberBox(number: rightNumber!),
                              ),
                              childWhenDragging:
                                  const SizedBox(), // hide during drag
                              child: NumberBox(number: rightNumber!),
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

// Reusable NumberBox widget
class NumberBox extends StatelessWidget {
  final int number;

  const NumberBox({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
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
      child: Text(
        number.toString(),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
