import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gre_vocabulary/src/onboarding/domain/services/onboarding_services.dart';
import 'package:gre_vocabulary/src/vocabulary/_vocabulary.dart';

import 'onboarding/_onboarding.dart';

class Services {
  final VocabularyServiceFacade vocabularyServiceFacade;
  final OnboardingService onboardingService;

  Services({
    required this.vocabularyServiceFacade,
    required this.onboardingService,
  });
}

final initializer = FutureProvider.autoDispose((ref) async {
  final vocabularyService =
      await ref.watch(vocabularyServiceFacadeProvider.future);
  final onboardingService = await ref.watch(onboardingServiceProvider.future);

  return Services(
    vocabularyServiceFacade: vocabularyService,
    onboardingService: onboardingService,
  );
});
