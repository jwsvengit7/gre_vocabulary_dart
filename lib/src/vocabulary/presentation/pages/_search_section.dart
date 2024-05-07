part of 'homepage.dart';

class DashboardSearchSection extends ConsumerStatefulWidget {
  const DashboardSearchSection({Key? key}) : super(key: key);

  @override
  DashboardSearchSectionState createState() => DashboardSearchSectionState();
}

class DashboardSearchSectionState
    extends ConsumerState<DashboardSearchSection> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();

    _debouncer = Debouncer(const Duration(milliseconds: 300));

    _searchController.addListener(_doWordSearch);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 5),
      decoration: BoxDecoration(
        color: context.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Let's Learn",
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.onPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                IconButton(
                  onPressed: _navigateToSettings,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                  color: context.colorScheme.onPrimary,
                  icon: const Icon(
                    Icons.settings,
                  ),
                ),
              ],
            ),
            const Gap(size: 20),
            SizedBox(
              height: 65,
              child: TextField(
                controller: _searchController,
                clipBehavior: Clip.antiAlias,
                focusNode: _focusNode,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: context.colorScheme.onPrimary,
                onTapOutside: (val) {
                  _focusNode.unfocus();
                },
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onPrimary,
                ),
                decoration: InputDecoration(
                  hintText: "Search for a word",
                  hintStyle: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onPrimary.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.colorScheme.onPrimary.withOpacity(0.5),
                  ),
                  suffixIcon: ValueListenableBuilder(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      if (_searchController.text.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                        color: context.colorScheme.onPrimary,
                        icon: const Icon(
                          Icons.close,
                        ),
                      );
                    },
                  ),
                  filled: true,
                  fillColor: context.colorScheme.onPrimary.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SearchResultSection(),
          ],
        ),
      ),
    );
  }

  void _navigateToSettings() {
    print("Navigate to settings");
  }

  void _doWordSearch() {
    if (_searchController.text.isEmpty) {
      _debouncer.reset();
      ref.read(vocabularyControllerProvider.notifier).clearSearch();

      return;
    }
    _debouncer.call(
      () {
        ref.read(vocabularyControllerProvider.notifier).searchWord(
              _searchController.text,
            );
      },
    );
  }
}

class SearchResultSection extends ConsumerWidget {
  const SearchResultSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(
      vocabularyControllerProvider.select(
        (vocabularyState) => vocabularyState.maybeWhen(
          orElse: () => <Word>[],
          searchSuccess: (results) => results,
        ),
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: searchResults.isEmpty ? 0 : 200,
      child: Scrollbar(
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 10),
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final word = searchResults[index];
            if (!word.value.isValid()) return const SizedBox();

            return ListTile(
              title: Text(
                word.value.getOrElse(""),
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onPrimary,
                ),
              ),
              subtitle: Text(
                word.definition,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onPrimary.withOpacity(0.5),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              height: 1,
              thickness: 1,
            );
          },
        ),
      ),
    );
  }
}
