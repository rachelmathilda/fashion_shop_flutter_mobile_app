import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingData {
  final String imageAsset;
  final String title;
  final String subtitle;
  final String buttonLabel;

  const _OnboardingData({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      imageAsset: 'assets/images/onboarding1.png',
      title: '100+ Clothes Option',
      subtitle: 'Various clothes Option',
      buttonLabel: 'Next',
    ),
    _OnboardingData(
      imageAsset: 'assets/images/onboarding2.png',
      title: 'Try-On Before Buy',
      subtitle: 'You can try it using our AI based AR tech',
      buttonLabel: 'Next',
    ),
    _OnboardingData(
      imageAsset: 'assets/images/onboarding3.png',
      title: 'Find Outfit That Suit You',
      subtitle:
          'Our algorithm able to make recommendation of based on your style',
      buttonLabel: 'Get Started',
    ),
  ];

  void _onButton() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _pages.length,
              itemBuilder: (context, index) =>
                  _OnboardingPage(data: _pages[index]),
            ),
          ),
          SmoothPageIndicator(
            controller: _controller,
            count: _pages.length,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.primary,
              dotColor: AppColors.greyLight,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ElevatedButton(
              onPressed: _onButton,
              child: Text(_pages[_currentPage].buttonLabel),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top illustration area — full width with blob behind image
        Expanded(
          flex: 6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Organic blob background
              Positioned.fill(child: CustomPaint(painter: _BlobPainter())),
              // Illustration centered in the blob area
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Image.asset(data.imageAsset, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
        // Text area
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints the organic light-purple blob that fills the upper portion
/// of each onboarding page, matching the design's freeform shape.
class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEEEEF8)
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Organic blob: covers roughly the top-left two-thirds of the area,
    // with a smooth curve bottom-right — matches design.
    path.moveTo(0, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h * 0.55);
    path.cubicTo(w * 0.75, h * 0.75, w * 0.55, h * 0.85, w * 0.25, h * 0.92);
    path.cubicTo(w * 0.1, h * 0.95, 0, h * 0.88, 0, h * 0.75);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
