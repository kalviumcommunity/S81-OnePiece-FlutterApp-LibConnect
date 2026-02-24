import 'package:flutter/material.dart';

class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final orientation = MediaQuery.of(context).orientation;

    final bool isTabletByWidth = screenWidth >= 600;
    final bool isLandscape = orientation == Orientation.landscape;
    final double sectionSpacing = screenHeight * 0.02;
    final double horizontalPadding = screenWidth * 0.06;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Design Demo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding.clamp(16, 40),
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Screen: ${screenWidth.toStringAsFixed(0)} x ${screenHeight.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Orientation: ${isLandscape ? 'Landscape' : 'Portrait'}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sectionSpacing),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isTabletLayout = constraints.maxWidth >= 600 || isTabletByWidth;
                  if (!isTabletLayout) {
                    return _buildMobileLayout(context, screenWidth, screenHeight);
                  }
                  return _buildTabletLayout(context, screenWidth, screenHeight);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, double screenWidth, double screenHeight) {
    final double assetCardWidth = (screenWidth * 0.9).clamp(240, 420);
    final double assetCardHeight = (screenHeight * 0.25).clamp(180, 240);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAssetShowcaseCard(
          width: assetCardWidth,
          height: assetCardHeight,
        ),
        SizedBox(height: screenHeight * 0.03),
        _responsivePanel(
          width: screenWidth * 0.8,
          height: screenHeight * 0.14,
          color: Colors.tealAccent,
          icon: Icons.phone_android,
          text: 'Mobile Layout',
        ),
        SizedBox(height: screenHeight * 0.025),
        _responsivePanel(
          width: screenWidth * 0.8,
          height: screenHeight * 0.14,
          color: Colors.orangeAccent,
          icon: Icons.aspect_ratio,
          text: 'Adaptive Size: 80% width',
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, double screenWidth, double screenHeight) {
    final double panelWidth = (screenWidth * 0.36).clamp(220, 340);
    final double panelHeight = (screenHeight * 0.2).clamp(140, 220);
    final double assetCardWidth = (screenWidth * 0.8).clamp(320, 700);
    final double assetCardHeight = (screenHeight * 0.26).clamp(180, 260);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAssetShowcaseCard(
          width: assetCardWidth,
          height: assetCardHeight,
        ),
        SizedBox(height: screenHeight * 0.04),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _responsivePanel(
              width: panelWidth,
              height: panelHeight,
              color: Colors.orangeAccent,
              icon: Icons.tablet,
              text: 'Tablet Left Panel',
            ),
            _responsivePanel(
              width: panelWidth,
              height: panelHeight,
              color: Colors.tealAccent,
              icon: Icons.dashboard_customize,
              text: 'Tablet Right Panel',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssetShowcaseCard({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: const DecorationImage(
          image: AssetImage('assets/images/banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.black.withOpacity(0.4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: height * 0.32,
              height: height * 0.32,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            const Text(
              'Assets + Icons',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flutter_dash, color: Colors.lightBlueAccent, size: 24),
                const SizedBox(width: 10),
                Image.asset(
                  'assets/icons/star.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 10),
                const Icon(Icons.android, color: Colors.greenAccent, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _responsivePanel({
    required double width,
    required double height,
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: height * 0.28),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
