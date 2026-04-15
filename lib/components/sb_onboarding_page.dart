import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller    = PageController();
  int _currentIndex                   = 0;
  final List<String> images           = [
    "assets/images/slide1-sballando.jpg",
    "assets/images/slide2-sballando.jpg",
    "assets/images/slide3-sballando.jpg",
    "assets/images/slide4-sballando.jpg",
    "assets/images/slide5-sballando.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return Image.asset(
                images[index],
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ...List.generate(images.length, (index) {
                  return CustomDot(isActive: index == _currentIndex);
                }),
                SizedBox(width: 50,),
                if(_currentIndex + 1 != images.length )
                GestureDetector(
                  onTap: () {
                    if (_currentIndex == images.length - 1) {
                      // onboarding finito
                      saveShared('bool', true, 'onboarding_seen');

                      Navigator.of(context).pushReplacementNamed('/home');
                    } else {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(500),
                    ),
                    child: Icon(Icons.arrow_right_alt, color: Color(0xFFA02854), size: 40),
                  ),
                ),
                if(_currentIndex + 1 == images.length )
                GestureDetector(
                  onTap: () {
                    if (_currentIndex == images.length - 1) {
                      // onboarding finito
                      saveShared('bool', true, 'onboarding_seen');

                      Navigator.of(context).pushReplacementNamed('/home');
                    } else {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(500),
                    ),
                    child: Text(
                      'Inizia',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: textMid,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
              ]
              
            ),
          ),

        ],
      ),
    );
  }
}

class CustomDot extends StatelessWidget {
  final bool isActive;

  const CustomDot({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 80 : 30,
      height: 15,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}
