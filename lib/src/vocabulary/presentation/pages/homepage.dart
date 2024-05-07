import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gre_vocabulary/src/core/configs/router.dart';
import 'package:gre_vocabulary/src/core/extensions.dart';
import 'package:gre_vocabulary/src/core/logic/debouncer.dart';
import 'package:gre_vocabulary/src/core/presentation/common_presentation.dart';
import 'package:gre_vocabulary/src/vocabulary/_vocabulary.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word_details.dart';
import 'package:gre_vocabulary/src/vocabulary/presentation/words_to_be_shown_queue.dart';
import 'package:string_extensions/string_extensions.dart';

part '_search_section.dart';
part '_word_showing_now_section.dart';

class VocabularyHomeScreen extends ConsumerWidget {
  const VocabularyHomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: const [
            DashboardSearchSection(),
            WordShowingNowSection(),
            DashboardCTASection(),
          ],
        ),
      ),
    );
  }
}

class DashboardCTAItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardCTAItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

List<DashboardCTAItem> getDashboardCTAItems(BuildContext context) => [
      DashboardCTAItem(
        title: "Flash Cards",
        icon: Icons.visibility_off,
        onTap: () {
          context.push(AppRoutePaths.flashCards);
        },
      ),
      DashboardCTAItem(
        title: "Quiz",
        icon: Icons.quiz,
        onTap: () {
          log("Settings");
        },
      ),
      DashboardCTAItem(
        title: "Memorized Words",
        icon: Icons.memory,
        onTap: () {
          log("Add new word");
        },
      ),
      DashboardCTAItem(
        title: "Saved Words",
        icon: Icons.book,
        onTap: () {
          log("Review words");
        },
      ),
      DashboardCTAItem(
        title: "Shown Today",
        icon: Icons.settings,
        onTap: () {
          log("Settings");
        },
      ),
      DashboardCTAItem(
        title: "All Words",
        icon: Icons.settings,
        onTap: () {
          log("Settings");
        },
      ),
    ];

class DashboardCTASection extends StatelessWidget {
  const DashboardCTASection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // arrange dashboardCTAItems in a row of 3 items each
    final rows = <List<DashboardCTAItem>>[];
    final dashboardCTAItems = getDashboardCTAItems(context);
    for (var i = 0; i < dashboardCTAItems.length; i += 3) {
      rows.add(dashboardCTAItems.sublist(
          i, math.min(i + 3, dashboardCTAItems.length)));
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: rows
            .map(
              (row) => Row(
                children: row
                    .map(
                      (item) => DashboardCTAItemDisplay(item: item),
                    )
                    .toList(),
              ),
            )
            .toList(),
      ),
    );
  }
}

class DashboardCTAItemDisplay extends StatelessWidget {
  final DashboardCTAItem item;
  const DashboardCTAItemDisplay({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 32,
                color: context.colorScheme.primary.withOpacity(0.8),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
