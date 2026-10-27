import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import 'package:eerl_app/core/constants/app_constants.dart';

class LoadingWidget extends StatelessWidget {
  final bool isLoading;
  final String? message;
  const LoadingWidget({super.key, required this.isLoading, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Visibility(
        visible: isLoading,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Lottie.asset(
                "${AppConstants.assetLottie}ic_loader.json",
                decoder: customDecoder,
              ),
            ),
            if (message?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                key: const Key('loading-widget-message'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<LottieComposition?> customDecoder(List<int> bytes) {
  return LottieComposition.decodeZip(
    bytes,
    filePicker: (files) {
      return files.firstWhere(
        (f) => f.name.startsWith('animations/') && f.name.endsWith('.json'),
      );
    },
  );
}
