// OntarioTechPlus - nav_tab_provider.dart

// This simply gives the current index for the selected page on the nav bar

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the selected bottom tab index.
class TabIndexNotifier extends Notifier<int> {
  @override
  int build() {
    return 0; // default tab index
  }

  void setIndex(int index) {
    state = index;
  }
}

final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(
  TabIndexNotifier.new,
);
