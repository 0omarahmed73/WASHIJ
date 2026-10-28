import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'logo_symbol.dart';

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.symbolSize = 36, this.showEnglish = false});

  final double symbolSize;
  final bool showEnglish;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'وَشيج',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        LogoSymbol(size: symbolSize),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'و'),
                  TextSpan(
                    text: 'َ',
                    style: TextStyle(color: WashijColors.starYellow),
                  ),
                  const TextSpan(text: 'شيج'),
                ],
              ),
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: WashijFonts.wordmark,
                fontWeight: FontWeight.w700,
                fontSize: symbolSize * 0.52,
                color: WashijColors.ivory,
                height: 1.25,
              ),
            ),
            if (showEnglish)
              Text(
                'WASHIJ',
                textDirection: TextDirection.ltr,
                style: WashijTypography.englishDisplay.copyWith(
                  fontSize: symbolSize * 0.32,
                  color: WashijColors.mist,
                  letterSpacing: symbolSize * 0.1024,
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
