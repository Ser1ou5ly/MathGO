import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'compare_numbers_page.dart';
import 'composing_numbers_page.dart';
import 'ordering_numbers_page.dart';
import 'bgm.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget buildStyledButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          elevation: WidgetStateProperty.all(8),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.deepPurple.shade200;
            }
            return Colors.white;
          }),
          shadowColor: WidgetStateProperty.all(
            const Color(0xFF6750A4).withAlpha((0.5 * 255).toInt()),
          ),
        ),
        onPressed: onPressed,

        child: Text(
          text,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6750A4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Black status bar
        statusBarIconBrightness: Brightness.light, // Light icons (white)
      ),

      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/background/homepage_background.svg',
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
                      // Custom back button with background
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

                      Expanded(
                        child: Center(
                          child: Text(
                            'Main Menu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
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
              top: 120,
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

            // Menu selection
            Positioned(
              top: 350,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildStyledButton('Compare Numbers', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompareNumbersPage(),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  buildStyledButton('Ordering Numbers', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderingNumbersPage(),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  buildStyledButton('Composing Numbers', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComposingNumbersPage(),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: 260,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        elevation: WidgetStateProperty.all(8),
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.deepPurple.shade200;
                            }
                            return Colors.white;
                          },
                        ),
                        shadowColor: WidgetStateProperty.all(
                          const Color(
                            0xFF6750A4,
                          ).withAlpha((0.5 * 255).toInt()),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Exit App'),
                                content: const Text(
                                  'Are you sure you want to exit?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => SystemNavigator.pop(),
                                    child: const Text('Exit'),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
