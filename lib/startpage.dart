import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:individual_asg/bgm.dart';
import 'package:individual_asg/homepage.dart';
import 'package:provider/provider.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  Widget buildStyledButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 230,
      height: 60,
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
              return Colors.yellowAccent.shade200;
            }
            return Colors.amber;
          }),
          shadowColor: WidgetStateProperty.all(
            const Color(0xFF6750A4).withAlpha((0.5 * 255).toInt()),
          ),
        ),
        onPressed: onPressed,

        child: Text(
          text,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
                'assets/background/start_background.svg',            
                fit: BoxFit.cover,
                placeholderBuilder:
                    (BuildContext context) => Container(
                      color: Colors.grey, // or any theme-friendly color
                    ),
              ),
            ),            

            // Audio button
            Positioned(
              top: 200,
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

            // Start game button
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildStyledButton('Start Game', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
