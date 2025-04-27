import 'package:banking4students/services/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:banking4students/providers/navigation_provider.dart';
import 'package:banking4students/pages/login_page.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 3;
              });
            },
            children: [
              Container(
                padding: EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("lib/assets/icon/app_icon_anim.gif", height: 400, width: 400),
                    SizedBox(height: 20),
                    Text(
                      "Welcome to UniFinance",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "An easy way to manage your finances.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              buildPage(
                animation: 'lib/assets/onboarding/animation3.json',
                title: 'Track Your Expenses',
                subtitle: 'Get insights on where your money goes.',
              ),
              buildPage(
                animation: 'lib/assets/onboarding/animation1.json',
                title: 'Save and Invest',
                subtitle: 'Plan your future with smart saving strategies.',
              ),
              buildPage(
                animation: 'lib/assets/onboarding/animation2.json',
                title: 'Start Now!',
                subtitle: 'Join and take control of your financial life.',
              ),
            ],
          ),

          // Page Indicator & Button
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 4,
                  effect: WormEffect(
                    activeDotColor: Colors.blue,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
                SizedBox(height: 20),
                isLastPage
                    ? ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('seenOnboarding', true);
                        // Navigate to the LoginPage using Navigator.pushReplacement
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AuthGate()),
                        );
                      },
                      child: Text('Get Started'),
                    )
                    : TextButton(
                      onPressed: () {
                        _controller.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text('Next'),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String animation,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            animation,
            height: 250,
            repeat: false,
            reverse: false,
            animate: true,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, size: 150, color: Colors.red);
            },
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
