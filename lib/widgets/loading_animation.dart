import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingAnimation extends StatelessWidget {
  final String lottieAsset;
  final double height;

  const LoadingAnimation({
    super.key,
    this.lottieAsset = 'assets/animations/loading.json',
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        lottieAsset,
        height: height,
        fit: BoxFit.contain,
        repeat: true,
      ),
    );
  }
}
