import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  final PageController _pageController = PageController();
  final List<String> MAIN_ROUTES = [
    
    '/wallet',
    '/qrScanner',
    '/home',
    '/profile',
    '/info',

  ];

  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    // inizializza _currentIndex in base alla route attuale se vuoi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });

          final newRoute = MAIN_ROUTES[index];
          if (ModalRoute.of(context)?.settings.name != newRoute) {
            Navigator.pushNamed(context, 'test');

          }
        },
        children: MAIN_PAGES,
      ),
      
    );
  }
}
