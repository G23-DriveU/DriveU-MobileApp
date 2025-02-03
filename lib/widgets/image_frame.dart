import 'package:driveu_mobile_app/constants/api_path.dart';
import 'package:flutter/material.dart';

class ImageFrame extends StatelessWidget {
  String firebaseUid;
  ImageFrame({super.key, required this.firebaseUid});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      "$BASE_URL/uploads/$firebaseUid.jpeg",
      height: 150,
      width: 150,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/knightro.bmp',
        height: 150,
        width: 150,
      ),
    );
  }
}
