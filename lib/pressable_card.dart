import 'package:flutter/material.dart';

class PressableCardWithImage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String backgroundImage;
  final VoidCallback onTap;

  const PressableCardWithImage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundImage,
    required this.onTap,
  });

  Image getImage(){
    Image tempImage = Image.asset(backgroundImage, fit: BoxFit.cover);
    try {
      final Uri? uri = Uri.tryParse(backgroundImage);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        tempImage = Image.network(backgroundImage, fit: BoxFit.contain);
      }
    } catch (e) {
      tempImage = Image.asset(backgroundImage, fit: BoxFit.cover);
    }
    return tempImage;
  } 

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: getImage(),
            ),
            // Optional: Dark overlay to improve text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            // Text content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}