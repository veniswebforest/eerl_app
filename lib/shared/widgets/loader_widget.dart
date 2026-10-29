import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import 'package:eerl_app/core/constants/app_constants.dart';

class LoadingWidget extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final String? subtitle;

  const LoadingWidget({
    super.key,
    required this.isLoading,
    this.message,
    this.subtitle,
  });

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  message!,
                  key: const Key('loading-widget-message'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            if (subtitle?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    subtitle!,
                    key: const Key('loading-widget-subtitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,                    fontWeight: FontWeight.w500,

                      // color: AppColors.cool900,
                    ),
                  ),
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
