part of 'onboarding_screen.dart';

class OnboardingScreenData extends Equatable {
  final String title;
  final String description;
  final String iconPath;

  const OnboardingScreenData({
    required this.title,
    required this.description,
    required this.iconPath,
  });

  @override
  List<Object?> get props => [title, description, iconPath];
}

List<OnboardingScreenData> getOnboardingScreenData() {
  debugPrint("getOnboardingScreenData");
  return [
    OnboardingScreenData(
      title: 'Complete GRE Vocabulary',
      description:
          'Access over 4000+ GRE words including hit words from verified sources guaranteed to appear on the GRE',
      iconPath: Assets.images.onboardingImage1.path,
    ),
    OnboardingScreenData(
      title: 'Practice with No distractions',
      description:
          'Every word is available offline, so you do not need any internet connection to prepare for your exam.',
      iconPath: Assets.images.onboardingImage2.path,
    ),
    OnboardingScreenData(
      title: 'Learn words at your own pace',
      description:
          'Want to see new words every 10 mins? 30 mins? 3 hours? No problem! You can set your own notification interval with ease.',
      iconPath: Assets.images.onboardingImage3.path,
    ),
  ];
}
