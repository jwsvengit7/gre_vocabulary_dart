/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsCsvGen {
  const $AssetsCsvGen();

  /// File path: assets/csv/barren_hit.csv
  String get barrenHit => 'assets/csv/barren_hit.csv';

  /// File path: assets/csv/economist_hit_list.csv
  String get economistHitList => 'assets/csv/economist_hit_list.csv';

  /// File path: assets/csv/gre_prep_list.csv
  String get grePrepList => 'assets/csv/gre_prep_list.csv';

  /// File path: assets/csv/manya_hit_list.csv
  String get manyaHitList => 'assets/csv/manya_hit_list.csv';

  /// File path: assets/csv/manya_princeton_list.csv
  String get manyaPrincetonList => 'assets/csv/manya_princeton_list.csv';

  /// File path: assets/csv/online_prep_list.csv
  String get onlinePrepList => 'assets/csv/online_prep_list.csv';

  /// File path: assets/csv/princeton_hit_parade.csv
  String get princetonHitParade => 'assets/csv/princeton_hit_parade.csv';

  /// File path: assets/csv/princeton_list.csv
  String get princetonList => 'assets/csv/princeton_list.csv';

  /// List of all assets
  List<String> get values => [
        barrenHit,
        economistHitList,
        grePrepList,
        manyaHitList,
        manyaPrincetonList,
        onlinePrepList,
        princetonHitParade,
        princetonList
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/gmail.png
  AssetGenImage get gmail => const AssetGenImage('assets/images/gmail.png');

  /// File path: assets/images/linkedIn.png
  AssetGenImage get linkedIn =>
      const AssetGenImage('assets/images/linkedIn.png');

  /// File path: assets/images/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');

  /// File path: assets/images/onboarding_image_1.jpg
  AssetGenImage get onboardingImage1 =>
      const AssetGenImage('assets/images/onboarding_image_1.jpg');

  /// File path: assets/images/onboarding_image_2.jpg
  AssetGenImage get onboardingImage2 =>
      const AssetGenImage('assets/images/onboarding_image_2.jpg');

  /// File path: assets/images/onboarding_image_3.jpg
  AssetGenImage get onboardingImage3 =>
      const AssetGenImage('assets/images/onboarding_image_3.jpg');

  /// File path: assets/images/twitter_icon.png
  AssetGenImage get twitterIcon =>
      const AssetGenImage('assets/images/twitter_icon.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        gmail,
        linkedIn,
        logo,
        onboardingImage1,
        onboardingImage2,
        onboardingImage3,
        twitterIcon
      ];
}

class Assets {
  Assets._();

  static const $AssetsCsvGen csv = $AssetsCsvGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider() => AssetImage(_assetName);

  String get path => _assetName;

  String get keyName => _assetName;
}
