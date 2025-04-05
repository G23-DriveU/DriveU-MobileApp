import 'package:driveu_mobile_app/widgets/forgot_password_dialog.dart';
import 'package:driveu_mobile_app/widgets/login/register/login_form.dart';
import 'package:driveu_mobile_app/widgets/login/register/register_form_firebase.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from the right
      end: Offset.zero, // End at original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start the animation when the page loads
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB2DFDB),
              Color(0xFFBBDEFB),
              Color.fromARGB(255, 255, 255, 255), // Light blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Top-left decorative image
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                'assets/images/car1.png',
                height: 100,
              ),
            ),
            // Bottom-right decorative image with rotation
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.rotate(
                angle: 3.14159, // 180 degrees in radians
                child: Image.asset(
                  'assets/images/car1.png',
                  height: 100,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  // Slide the logo with animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: Image.asset(
                      'assets/images/drive.png',
                      height: 170,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Slide the text with animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: const Text(
                      "Where carpooling is pleasure 😊🚗",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlideTransition(
                    position: _slideAnimation,
                    child: const Text(
                      "Welcome to DriveU!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SlideTransition(
                    position: _slideAnimation,
                    child: const Text(
                      "Please log in or sign up to get started!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  SlideTransition(
                    position: _slideAnimation,
                    child: const LoginForm(),
                  ),
                  const SizedBox(height: 0),
                  // Slide the row with the 'Join' text
                  SlideTransition(
                    position: _slideAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't Have an Account? ",
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const RegisterFormFirebase();
                            }));
                          },
                          child: const Text(
                            "Join",
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text(
                          " DriveU-nation for FREE!",
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SlideTransition(
                    position: _slideAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Forgot Password?",
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) => ForgotPasswordDialog());
                          },
                          child: const Text(
                            " Reset ",
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text(
                          "Your Password.",
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
