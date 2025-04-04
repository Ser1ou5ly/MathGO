import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:individual_asg/bgm.dart';
import 'dart:math';
import 'package:individual_asg/local_storage.dart';
import 'package:provider/provider.dart';


class OrderingNumbersPage extends StatefulWidget {
  const OrderingNumbersPage({super.key});

  @override
  State<OrderingNumbersPage> createState() => _OrderingNumbersPageState();
}

class _OrderingNumbersPageState extends State<OrderingNumbersPage> {
  List<int> numbers = [];
  List<int> availableNumbers = [];
  List<int?> droppedValues = List.generate(5, (_) => null);
  late String arrowImage;
  late bool isAscending;

  @override
  void initState() {
    super.initState();
    _generateFiveNumbers();
    _chooseArrowImage();
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted && !helpAppearOrder) {
        helpAppearOrder = true;
        showHelpDialog(context);
      }
    });
  }

  // Decide ascending or descending
  void _chooseArrowImage() {
    final random = Random();
    isAscending = random.nextBool(); // true = ascending, false = descending
    arrowImage =
        isAscending
            ? 'assets/images/upArrow.png'
            : 'assets/images/downArrow.png';
  }

  // Generate 5 random numbers
  void _generateFiveNumbers() {
    final random = Random();
    final Set<int> generated = {};
    while (generated.length < 5) {
      generated.add(random.nextInt(1000));
    }
    numbers = generated.toList();
    availableNumbers = List.from(numbers);
  }

  Widget buildDropBox(
    int index,
    double bottom,
    double leftOrRight, {
    bool isRight = false,
  }) {
    return Positioned(
      bottom: bottom,
      left: isRight ? null : leftOrRight,
      right: isRight ? leftOrRight : null,
      child: DragTarget<int>(
        onAcceptWithDetails: (details) {
          setState(() {
            int newValue = details.data;
            int? replacedValue = droppedValues[index];

            // Return replaced value to the top
            if (replacedValue != null) {
              availableNumbers.add(replacedValue);
            }

            droppedValues[index] = newValue;

            for (var i = 0; i < droppedValues.length; i++) {
              if (i != index && droppedValues[i] == newValue) {
                droppedValues[i] = null;
              }
            }

            availableNumbers.remove(
              newValue,
            ); // Remove the value box on top after being dragged into minecart

            if (!droppedValues.contains(null)) {
              _checkOrderCorrectness();
            } // Check the results if 5 minecarts are filled
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            width: 50,
            height: 50,
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
                droppedValues[index] != null
                    ? Draggable<int>(
                      data: droppedValues[index]!,
                      feedback: Material(
                        color: Colors.transparent,
                        child: NumberBox(number: droppedValues[index]!),
                      ),
                      childWhenDragging: const SizedBox(),
                      child: NumberBox(number: droppedValues[index]!),
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
    );
  }

  // Check whether the answer is correct or not
  void _checkOrderCorrectness() async {
    if (droppedValues.contains(null)) return; // not all filled

    List<int> values = droppedValues.whereType<int>().toList();
    HapticFeedback.mediumImpact();
    bool correct = true;

    for (int i = 0; i < values.length - 1; i++) {
      if (isAscending) {
        if (values[i] > values[i + 1]) {
          correct = false;
          break;
        }
      } else {
        if (values[i] < values[i + 1]) {
          correct = false;
          break;
        }
      }
    }

    if (correct) {
      orderScore++;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Result'),
            content: Text(
              correct
                  ? "🎉 Congratulations! You arranged them correctly."
                  : "❌ Oops! The order is incorrect. Try again.",
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _generateFiveNumbers();
                    _chooseArrowImage();
                    droppedValues = List.generate(5, (_) => null);
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // Help button dialog
  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('How to Play'),
            content: const Text(
              'Welcome to Ordering Number Stage.\n\n'
              'Drag and drop the 5 numbers on the minecarts following the red arrows on the wall.\n\n'
              'The red up arrow represents to put from smaller to bigger numbers\n\n'
              'The red down arrow represents to put from bigger to smaller numbers\n\n'
              'Put the biggest or smallest number on the cart with a tag with "start"\n\n'
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
                'assets/background/ordering_numbers_page_background.svg',
                fit: BoxFit.cover,
                placeholderBuilder:
                    (BuildContext context) => Container(
                      color: Colors.grey, // or any theme-friendly color
                    ),
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
                              'Ordering Numbers',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Score: $orderScore',
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

            // Draggable Boxes
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // First row (3 draggable boxes)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (i) {
                      if (!availableNumbers.contains(numbers[i])) {
                        return const SizedBox(width: 50, height: 50);
                      }
                      return Draggable<int>(
                        data: numbers[i],
                        feedback: Material(
                          color: Colors.transparent,
                          child: NumberBox(number: numbers[i]),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: NumberBox(number: numbers[i]),
                        ),
                        child: NumberBox(number: numbers[i]),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),

                  // Second row (2 draggable boxes)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(2, (i) {
                      int index = i + 3;
                      if (!availableNumbers.contains(numbers[index])) {
                        return const SizedBox(width: 50, height: 50);
                      }
                      return Draggable<int>(
                        data: numbers[index],
                        feedback: Material(
                          color: Colors.transparent,
                          child: NumberBox(number: numbers[index]),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: NumberBox(number: numbers[index]),
                        ),
                        child: NumberBox(number: numbers[index]),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Arrow image on the wall
            Positioned(
              bottom: 270,
              child: Center(
                child: Image.asset(arrowImage, width: 200, height: 200),
              ),
            ),

            // Target Boxes on Minecarts
            buildDropBox(0, 102, 10), // First Target Box
            buildDropBox(1, 153, 83), // Second Target Box
            buildDropBox(2, 205, 155), // Third Target Box
            buildDropBox(3, 258, 96, isRight: true), // Forth Target Box
            buildDropBox(4, 308, 22, isRight: true), // Fifth Target Box
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
      width: 50,
      height: 50,
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
