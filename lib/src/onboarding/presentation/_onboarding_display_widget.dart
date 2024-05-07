part of 'onboarding_screen.dart';

class OnboardingDisplay extends StatelessWidget {
  final OnboardingScreenData data;
  final bool isCurrentScreen;
  final bool isLastScreen;

  const OnboardingDisplay({
    Key? key,
    required this.data,
    required this.isCurrentScreen,
    required this.isLastScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: Image.asset(
              data.iconPath,
              fit: BoxFit.cover,
            ),
          ),
          const Gap(size: 50),
          Text(
            data.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: 22,
              color: context.colorScheme.secondary,
            ),
          ),
          const Gap(size: 10),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
