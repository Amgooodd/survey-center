import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstImageScreen extends StatefulWidget {
  const FirstImageScreen({super.key});

  @override
  _FirstImageScreenState createState() => _FirstImageScreenState();
}

class _FirstImageScreenState extends State<FirstImageScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  
final List<Map<String, String>> _onboardingPages = [
  {
    "image": "assets/mainpic2.jpg",
    "title": "Welcome to Survey Center",
    "description": "Join us to begin your survey journey today!",
  },
  {
    "image": "assets/welcome2.png",
    "title": "Explore Available Surveys",
    "description": "Discover and participate in surveys tailored to your group and interests.",
  },
  {
    "image": "assets/welcome3.png",
    "title": "Track Your Survey History",
    "description": "View your completed surveys and track your progress over time.",
  },
  {
    "image": "assets/studentmain.jpg",
    "title": "Ready to Dive In?",
    "description": "Let’s get started with your first survey!",
  },
];

  @override
  void initState() {
    super.initState();
    _checkOnboardingPreference();
  }

  
  Future<void> _checkOnboardingPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? dontShowAgain = prefs.getBool('dont_show_onboarding');
    if (dontShowAgain == true) {
      Navigator.pushReplacementNamed(context, '/complog');
    }
  }

  
  Future<void> _saveOnboardingPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dont_show_onboarding', value);
  }

  
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/complog');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingPages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final page = _onboardingPages[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: AssetImage(page["image"]!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    page["title"]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 28, 51, 95),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      page["description"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 28, 51, 95),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingPages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.blue
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    Row(
                      children: [
                        Checkbox(
                          value: _dontShowAgain,
                          onChanged: (value) {
                            setState(() {
                              _dontShowAgain = value!;
                            });
                            _saveOnboardingPreference(value!);
                          },
                        ),
                        const Text("Don't show again"),
                      ],
                    ),

                    
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _onboardingPages.length - 1) {
                          _navigateToLogin();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 28, 51, 95),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: Text(
                        _currentPage == _onboardingPages.length - 1
                            ? "Skip"
                            : "Next",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}