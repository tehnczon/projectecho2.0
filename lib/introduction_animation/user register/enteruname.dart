import 'package:flutter/material.dart';
import 'package:projecho/introduction_animation/user register/usertype.dart';


class Usernamescreen extends StatefulWidget {
  final String phoneNumber;

  const Usernamescreen({super.key, required this.phoneNumber});

  @override
  State<Usernamescreen> createState() => _UsernamescreenState();
}

class _UsernamescreenState extends State<Usernamescreen> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  
  bool _isVisible = false; // Control visibility for animations

  @override
  void initState() {
    super.initState();
    _animatePage(); // Start animation when page is loaded
  }

  void _animatePage() {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fade-in Animation for Text
            AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: const Duration(seconds: 1),
              child: const Text(
                "What should we call you?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: const Duration(seconds: 1),
              child: const Text(
                "Enter username/alias.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Slide and Fade Animation for TextField
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              transform: _isVisible ? Matrix4.identity() : Matrix4.translationValues(0, 30, 0),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: "username",
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.4), // 40% opacity
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Slide and Fade Animation for Button
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              transform: _isVisible ? Matrix4.identity() : Matrix4.translationValues(0, 30, 0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final username = _usernameController.text.trim();
                    if (username.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a username')),
                      );
                    } else {
                      debugPrint("Entered username: $username");
                       Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserTypeScreen()),
      );// Navigate only when valid username is entered
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}