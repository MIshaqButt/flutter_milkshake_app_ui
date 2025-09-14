import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milkshake_app_ui/shakes_data.dart';

/// Home Page
class MilkshakePage extends StatefulWidget {
  const MilkshakePage({super.key});

  @override
  State<MilkshakePage> createState() => _MilkshakePageState();
}

class _MilkshakePageState extends State<MilkshakePage> {
  /// Page controller for main slider
  final PageController _pageController = PageController(
    viewportFraction: 0.5,
    initialPage: 1000, // <- set higher so user can scroll both ways infinitely
  );

  /// Page controller for price slider
  final PageController _priceSlideController = PageController();

  int _currentPage = 0;

  /// Handle when milkshake changes
  void _onChangePage(int page) {
    setState(() => _currentPage = page % milkshakes.length);

    // Animate the price widget to match the milkshake
    _priceSlideController.animateToPage(
      page % milkshakes.length,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    // inital jump for demo purpose
    Future.delayed(const Duration(milliseconds: 100), () {
      _pageController.animateToPage(
        1001,
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _priceSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background gradient
          MilkshakeBackground(color: milkshakes[_currentPage].color),

          /// Main content
          ListView(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 700,
                child: Stack(
                  children: [
                    /// Promo card (half circle)
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: PromoCard(color: milkshakes[_currentPage].color),
                    ),

                    /// Milkshake slider
                    Positioned(
                      top: 200,
                      child: MilkshakeSlider(
                        pageController: _pageController,
                        currentPage: _currentPage,
                        onPageChanged: _onChangePage,
                      ),
                    ),
                  ],
                ),
              ),

              /// Price widget
              PriceWidget(
                color: milkshakes[_currentPage].color,
                priceSlideController: _priceSlideController,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Background with gradient animation
class MilkshakeBackground extends StatelessWidget {
  final Color color;
  const MilkshakeBackground({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white, // top
            color.withOpacity(0.4), // middle
            Colors.white, // bottom
          ],
        ),
      ),
    );
  }
}

/// Promo card with custom clipped half-circle shape
class PromoCard extends StatelessWidget {
  final Color color;

  const PromoCard({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipPath(
        clipper: TopHalfCircleClipper(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: MediaQuery.of(context).size.width / 1.4,
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.3), color],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// Small star svg
              SvgPicture.asset(
                "assets/images/star.svg",
                width: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),

              const SizedBox(height: 8),

              /// Promo text
              Text(
                "Only This",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Weekend",
                style: GoogleFonts.greatVibes(
                  fontSize: 60,
                  color: Colors.white,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Milkshake slider with looping support
class MilkshakeSlider extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const MilkshakeSlider({
    super.key,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      width: MediaQuery.of(context).size.width,
      child: AnimatedBuilder(
        animation: pageController,
        builder: (context, child) {
          return PageView.builder(
            padEnds: false,
            controller: pageController,
            onPageChanged: onPageChanged,
            // Infinite loop effect using modulo
            itemBuilder: (context, index) {
              final actualIndex = index % milkshakes.length;

              double value = 0.0;
              if (pageController.position.haveDimensions) {
                value = index.toDouble() - (pageController.page ?? 0);
                value = (value * 0.7).clamp(-1, 1);
              }

              return GestureDetector(
                onTap: () {
                  pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: currentPage == actualIndex ? 0 : 3,
                    sigmaY: currentPage == actualIndex ? 0 : 3,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(0, (value.abs() * -100)),
                      child: Transform.scale(
                        scale: 1 - (value.abs() * 0.6),
                        child: Column(
                          children: [
                            Image.asset(
                              milkshakes[actualIndex].image,
                              width: MediaQuery.of(context).size.width,
                              height: 400,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              milkshakes[actualIndex].name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: milkshakes[actualIndex].color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Price widget with vertical page view
class PriceWidget extends StatelessWidget {
  final Color color;
  final PageController priceSlideController;

  const PriceWidget({
    super.key,
    required this.color,
    required this.priceSlideController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Price divider with stars
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Expanded(child: Divider(color: color)),
              SvgPicture.asset(
                "assets/images/star.svg",
                width: 18,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              Expanded(child: Divider(color: color)),

              /// Price container with vertical sliding
              Container(
                height: 40,
                width: 170,
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 1.0),
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                ),
                child: PageView.builder(
                  itemCount: milkshakes.length,
                  controller: priceSlideController,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        "\$${milkshakes[index].price} EACH",
                        style: GoogleFonts.montserrat(
                          fontSize: 21,
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(child: Divider(color: color)),
              SvgPicture.asset(
                "assets/images/star.svg",
                width: 18,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              Expanded(child: Divider(color: color)),
            ],
          ),
        ),

        const SizedBox(height: 8),

        /// Offer text
        Center(
          child: Text(
            "BUY 1 GET 1 FREE",
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom clipper for half circle top
class TopHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // start from bottom-left
    path.moveTo(0, size.height);

    // go up left side
    path.lineTo(0, size.height / 2);

    // draw half circle arc across top
    path.arcToPoint(
      Offset(size.width, size.height / 2),
      radius: Radius.circular(size.width / 2),
    );

    // go down right side
    path.lineTo(size.width, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
