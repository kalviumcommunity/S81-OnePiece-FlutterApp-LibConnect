import 'package:flutter/material.dart';

class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final bool isTablet = screenWidth > 600;

    final double padding = isTablet ? 24 : 16;
    final double titleSize = isTablet ? 28 : 22;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Responsive Home",
          style: TextStyle(fontSize: titleSize),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isTablet) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return _buildCard(index, isTablet);
                      },
                    );
                  } else {
                    return ListView.builder(
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCard(index, isTablet),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.07,
              child: ElevatedButton(
                onPressed: () {},
                child: FittedBox(
                  child: Text(
                    "Continue",
                    style: TextStyle(fontSize: isTablet ? 20 : 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index, bool isTablet) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Icon(
                  Icons.dashboard,
                  size: isTablet ? 60 : 40,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  "Item ${index + 1}",
                  style: TextStyle(fontSize: isTablet ? 18 : 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
