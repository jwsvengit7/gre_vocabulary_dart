import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gre_vocabulary/gen/assets.gen.dart';
import 'package:gre_vocabulary/src/core/configs/router.dart';
import 'package:gre_vocabulary/src/core/extensions.dart';

import '../../vocabulary/vocabulary_di.dart';
import '../_onboarding.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const _SplashPage();
  }
}

class _SplashPage extends ConsumerStatefulWidget {
  const _SplashPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => __SplashPageState();
}

class __SplashPageState extends ConsumerState<_SplashPage> {
  @override
  void initState() {
    super.initState();
    _initOnboardingCheck();
  }

  Future<void> _initOnboardingCheck() async {
    final onboardingController =
        ref.read(onboardingControllerProvider.notifier);
    final vocabularyController =
        ref.read(vocabularyControllerProvider.notifier);

    await Future.delayed(const Duration(seconds: 2));
    await vocabularyController.init();

    onboardingController.checkOnboardingStatus();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      onboardingControllerProvider,
      (previous, next) {
        next.maybeWhen(
          orElse: () {
            log("onboardingControllerProvider: orElse");
          },
          onboardingNotCompleted: () async {
            log("onboardingNotCompleted");
            // precache onboarding images
            for (final image in getOnboardingScreenData()) {
              await precacheImage(AssetImage(image.iconPath), context);
            }
            _navigateToOnboarding();
          },
          onboardingCompleted: () {
            log("onboardingCompleted");
            context.go(AppRoutePaths.home);
          },
        );
      },
    );
    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.images.logo.path,
              height: 50,
              width: 50,
            ),
            const SizedBox(width: 10),
            Text(
              "GRE Vocabulary",
              style: TextStyle(
                fontSize: 30,
                color: context.colorScheme.inversePrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOnboarding() {
    context.go(AppRoutePaths.onboarding);
  }
}
