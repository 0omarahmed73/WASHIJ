import 'package:flutter/material.dart';

import '../theme/tokens.dart';

Widget paintingImageLoadingBuilder(
  BuildContext context,
  Widget child,
  ImageChunkEvent? loadingProgress,
) {
  if (loadingProgress == null) return child;

  return const Center(
    child: SizedBox.square(
      dimension: 28,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: WashijColors.starYellow,
      ),
    ),
  );
}
