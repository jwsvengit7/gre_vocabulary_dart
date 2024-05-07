import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:gre_vocabulary/gen/assets.gen.dart';
import 'package:gre_vocabulary/src/core/configs/router.dart';
import 'package:gre_vocabulary/src/core/extensions.dart';
import 'package:gre_vocabulary/src/core/presentation/common_presentation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../onboarding_di.dart';

part '_onboarding_display_widget.dart';
part 'onboarding_screen_data.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({
    Key? key,
  }) : super(key: key);

  List<OnboardingScreenData> get onboardingDataList =>
      getOnboardingScreenData();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingControllerProvider);
    ref.listen(onboardingControllerProvider, (prev, next) {
      next.maybeWhen(
        orElse: () {},
        onboardingCompleted: () {
          log("onboarding done: go home");

          context.go(AppRoutePaths.home);
        },
      );
    });

    final currentIndex = onboardingState.maybeWhen(
      orElse: () => 0,
      onboardingInProgress: (index) => index,
    );

    final pageController = usePageController(initialPage: 0);

    final currentIndexNotifier = useValueNotifier(currentIndex);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _markOnboardingDone(ref),
                  child: const Text("Skip"),
                ),
              ),
              const Spacer(
                flex: 1,
              ),
              Expanded(
                flex: 6,
                child: PageView(
                  controller: pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    currentIndexNotifier.value = index;
                  },
                  children: onboardingDataList
                      .map(
                        (onboardingData) => OnboardingDisplay(
                          data: onboardingData,
                          isCurrentScreen: onboardingDataList[currentIndex] ==
                              onboardingData,
                          isLastScreen:
                              onboardingDataList.last == onboardingData,
                        ),
                      )
                      .toList(),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    AppButton(
                      text: "Continue",
                      onPressed: () => _handleOnNavigateNext(
                          pageController, ref, currentIndexNotifier),
                    ),
                    const Gap(size: 10),
                    DotPainter(
                      currentIndexNotifier: currentIndexNotifier,
                      count: onboardingDataList.length,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markOnboardingDone(WidgetRef ref) async {
    final onboardingController =
        ref.read(onboardingControllerProvider.notifier);
    await onboardingController.markOnboardingCompleted();
  }

  void _handleOnNavigateNext(PageController pageController, WidgetRef ref,
      ValueNotifier<int> currentIndexNotifier) {
    final nextPageIndex = pageController.page!.toInt() + 1;

    if (nextPageIndex == 3) {
      _markOnboardingDone(ref);

      return;
    }
    pageController.animateToPage(
      nextPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class DotPainter extends StatelessWidget {
  final ValueNotifier<int> currentIndexNotifier;
  final int count;
  const DotPainter(
      {Key? key, required this.currentIndexNotifier, required this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentIndexNotifier,
      builder: (context, currentIndex, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            count,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: currentIndex == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: currentIndex == index
                    ? context.colorScheme.primary.withOpacity(0.8)
                    : Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }
}
