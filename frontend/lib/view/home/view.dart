import 'package:ai_math_helper/data/main/model/model.dart';
import 'package:ai_math_helper/data/user/model/auth_model.dart';
import 'package:ai_math_helper/view/math_input/view.dart';
import 'package:ai_math_helper/view/profile/profile_modal.dart';
import 'package:ai_math_helper/view/notebook/notebooks_view.dart';
import 'package:ai_math_helper/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isExtended = false;
  late AnimationController _railAnimationController;

  @override
  void initState() {
    super.initState();
    _railAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _railAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're on a tablet-sized screen
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                enableDrag: true,
                showDragHandle: true,
                useSafeArea: true,
                builder:
                    (context) => DraggableScrollableSheet(
                      initialChildSize: 0.9,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      expand: false,
                      builder:
                          (context, scrollController) => const ProfileScreen(),
                    ),
              );
            },
          ),
        ],
      ),
      drawer: isTablet ? null : _buildDrawer(),
      body: Row(
        children: [
          // Show Navigation Rail on tablet screens
          if (isTablet) _buildNavigationRail(),

          // Main content area
          Expanded(child: _buildBody()),
        ],
      ),
      // Show bottom navigation on small screens only
      bottomNavigationBar:
          isTablet
              ? null
              : NavigationBar(
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                selectedIndex: _selectedIndex,
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: L10n.get('home'),
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.book_outlined),
                    selectedIcon: Icon(Icons.book),
                    label: L10n.get('notebooks'),
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.assignment_outlined),
                    selectedIcon: Icon(Icons.assignment),
                    label: L10n.get('practice'),
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: L10n.get('analytics'),
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: L10n.get('profile'),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.large(
        heroTag: 'home_fab', // Unique tag for the main FAB
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MathInputScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNavigationRail() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubicEmphasized,
      width: _isExtended ? 280 : 80,
      child: NavigationRail(
        extended: _isExtended,
        labelType:
            _isExtended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.selected,
        useIndicator: true,
        minExtendedWidth: 280,
        minWidth: 80,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text(L10n.get('home')),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: Text(L10n.get('notebooks')),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: Text(L10n.get('practice')),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: Text(L10n.get('analytics')),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text(L10n.get('profile')),
        ),
        NavigationRailDestination(icon: Icon(Icons.key), label: Text("JWT")),
      ],
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      leading: _buildNavigationRailHeader(),
      // trailing: _isExtended ? _buildNavigationRailTrailing() : null,
      ),
    );
  }

  Widget _buildNavigationRailHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // App logo/icon section
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.calculate,
              size: 32,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubicEmphasized,
            height: _isExtended ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubicEmphasized,
              opacity: _isExtended ? 1.0 : 0.0,
              child: _isExtended
                  ? Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          L10n.get('appName'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          L10n.get('learnAndPractice'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 16),
          // Menu toggle button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOutCubicEmphasized,
                switchOutCurve: Curves.easeInOutCubicEmphasized,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  _isExtended ? Icons.menu_open : Icons.menu,
                  key: ValueKey(_isExtended),
                ),
              ),
              tooltip: _isExtended ? L10n.get('collapseMenu') : L10n.get('expandMenu'),
              onPressed: () {
                setState(() {
                  _isExtended = !_isExtended;
                });
                if (_isExtended) {
                  _railAnimationController.forward();
                } else {
                  _railAnimationController.reverse();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              L10n.get('appName'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
              color:
                  _selectedIndex == 0
                      ? Theme.of(context).colorScheme.primary
                      : null,
            ),
            title: Text(L10n.get('home')),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              _selectedIndex == 1 ? Icons.book : Icons.book_outlined,
              color:
                  _selectedIndex == 1
                      ? Theme.of(context).colorScheme.primary
                      : null,
            ),
            title: Text(L10n.get('notebooks')),
            selected: _selectedIndex == 1,
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              _selectedIndex == 2
                  ? Icons.assignment
                  : Icons.assignment_outlined,
              color:
                  _selectedIndex == 2
                      ? Theme.of(context).colorScheme.primary
                      : null,
            ),
            title: Text(L10n.get('practice')),
            selected: _selectedIndex == 2,
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              _selectedIndex == 3 ? Icons.bar_chart : Icons.bar_chart_outlined,
              color:
                  _selectedIndex == 3
                      ? Theme.of(context).colorScheme.primary
                      : null,
            ),
            title: Text(L10n.get('analytics')),
            selected: _selectedIndex == 3,
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              _selectedIndex == 4 ? Icons.person : Icons.person_outline,
              color:
                  _selectedIndex == 4
                      ? Theme.of(context).colorScheme.primary
                      : null,
            ),
            title: Text(L10n.get('profile')),
            selected: _selectedIndex == 4,
            onTap: () {
              setState(() {
                _selectedIndex = 4;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    Widget content;

    switch (_selectedIndex) {
      case 0:
        content = _buildHomeContent();
        break;
      case 1:
        content = const NotebooksView();
        break;
      case 2:
        content = _buildPracticeContent();
        break;
      case 3:
        content = _buildAnalyticsContent();
        break;
      case 4:
        content = _buildProfileContent();
        break;
      case 5:
        content = _buildJWTContent();
      default:
        content = _buildHomeContent();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      child: content,
    );
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10n.get('welcomeBack'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            L10n.get('readyToSolve'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calculate,
                            size: 64,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            L10n.get('problemsSolved'),
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${ref.watch(mainModelProvider).count}',
                            style: Theme.of(
                              context,
                            ).textTheme.displayMedium?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MathInputScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(L10n.get('startNewProblem')),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJWTContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10n.get('jwtToken'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            L10n.get('testJwtDescription'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    L10n.get('learningContentSoon'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      ref.read(authModelProvider.notifier).getJwtToken();
                    },
                    child: Text(L10n.get('testJwtToken')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10n.get('practice'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            L10n.get('practiceDescription'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    L10n.get('practiceExercisesSoon'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10n.get('analytics'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            L10n.get('trackProgress'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    L10n.get('analyticsDashboardSoon'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10n.get('profile'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            L10n.get('manageAccount'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    L10n.get('tapProfileIcon'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        enableDrag: true,
                        showDragHandle: true,
                        useSafeArea: true,
                        builder:
                            (context) => DraggableScrollableSheet(
                              initialChildSize: 0.9,
                              minChildSize: 0.5,
                              maxChildSize: 0.95,
                              expand: false,
                              builder:
                                  (context, scrollController) =>
                                      const ProfileScreen(),
                            ),
                      );
                    },
                    icon: const Icon(Icons.person),
                    label: Text(L10n.get('openProfile')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
