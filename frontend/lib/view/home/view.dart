import 'package:ai_math_helper/data/main/model/model.dart';
import 'package:ai_math_helper/data/user/model/auth_model.dart';
import 'package:ai_math_helper/view/math_input/view.dart';
import 'package:ai_math_helper/view/profile/profile_modal.dart';
import 'package:ai_math_helper/view/notebook/notebooks_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _selectedIndex = 0;
  bool _isExtended = false;

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
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.book_outlined),
                    selectedIcon: Icon(Icons.book),
                    label: 'Notebooks',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.assignment_outlined),
                    selectedIcon: Icon(Icons.assignment),
                    label: 'Practice',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: 'Analytics',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
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
    return NavigationRail(
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
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: Text('Notebooks'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: Text('Practice'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: Text('Analytics'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
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
          if (_isExtended) ...[
            const SizedBox(height: 12),
            Text(
              'AI Math Helper',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Learn & Practice',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Menu toggle button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _isExtended ? Icons.menu_open : Icons.menu,
                  key: ValueKey(_isExtended),
                ),
              ),
              tooltip: _isExtended ? 'Collapse menu' : 'Expand menu',
              onPressed: () {
                setState(() {
                  _isExtended = !_isExtended;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          // Add new problem FAB
          SizedBox(
            width: _isExtended ? 200 : 56,
            child:
                _isExtended
                    ? FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MathInputScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Problem'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )
                    : FloatingActionButton(
                      heroTag: 'rail_fab',
                      mini: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MathInputScreen(),
                          ),
                        );
                      },
                      child: const Icon(Icons.add),
                    ),
          ),
          // Additional options when expanded
          if (_isExtended) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            // Settings option
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Settings action
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Help option
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Help action
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Help',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
              'AI Math Helper',
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
            title: const Text('Home'),
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
            title: const Text('Notebooks'),
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
            title: const Text('Practice'),
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
            title: const Text('Analytics'),
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
            title: const Text('Profile'),
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
            'Welcome back!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to solve some math problems?',
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
                            'Problems Solved',
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
                    label: const Text('Start New Problem'),
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
            'JWT Token',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is a test JWT token for authentication purposes.',
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
                    'Learning content coming soon!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      ref.read(authModelProvider.notifier).getJwtToken();
                    },
                    child: const Text("Test JWT Token"),
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
            'Practice',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Practice problems to improve your skills',
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
                    'Practice exercises coming soon!',
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
            'Analytics',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your progress and performance',
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
                    'Analytics dashboard coming soon!',
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
            'Profile',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your account and preferences',
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
                    'Tap the profile icon in the top bar to access your profile',
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
                    label: const Text('Open Profile'),
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
