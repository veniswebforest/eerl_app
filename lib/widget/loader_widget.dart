import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import '../core/constants/app_constants.dart';

class LoadingWidget extends StatelessWidget {
  final bool isLoading;
  const LoadingWidget({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Visibility(
        visible: isLoading,
        child: Lottie.asset(
          "${AppConstants.assetLottie}ic_loader.json",
          decoder: customDecoder,
          // repeat: false,
          // height: double.infinity,
          // width: double.infinity,
          // fit: BoxFit.cover,

          onLoaded: (composition) {
            debugPrint("lottie start ===>");

          },
          // height: 100,
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
