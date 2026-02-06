import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/presentation/home/home_screen.dart';
import 'package:potion_focus/presentation/cabinet/cabinet_screen.dart';
import 'package:potion_focus/presentation/grimoire/grimoire_book_screen.dart';
import 'package:potion_focus/presentation/quests/quests_screen.dart';
import 'package:potion_focus/presentation/shop/shop_screen.dart';
import 'package:potion_focus/services/timer_service.dart';

class AppNavigation extends ConsumerStatefulWidget {
  const AppNavigation({super.key});

  @override
  ConsumerState<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends ConsumerState<AppNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CabinetScreen(),
    GrimoireBookScreen(),
    QuestsScreen(),
    ShopScreen(),
  ];

  static const _navItems = [
    _PixelNavItem(icon: Icons.science_outlined, selectedIcon: Icons.science, label: 'Brew'),
    _PixelNavItem(icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, label: 'Cabinet'),
    _PixelNavItem(icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: 'Grimoire'),
    _PixelNavItem(icon: Icons.flag_outlined, selectedIcon: Icons.flag, label: 'Threads'),
    _PixelNavItem(icon: Icons.store_outlined, selectedIcon: Icons.store, label: 'Shop'),
  ];

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerServiceProvider);
    final isSessionActive = timerState.isRunning;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: isSessionActive
          ? _buildLockedNavBar(context)
          : _buildPixelNavBar(context),
    );
  }

  Widget _buildPixelNavBar(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: const Border(
          top: BorderSide(color: Colors.black87, width: 3),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: isSelected
                        ? primaryColor.withOpacity(0.12)
                        : Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          color: isSelected ? primaryColor : Colors.grey.shade500,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected ? primaryColor : Colors.grey.shade500,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 10,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 16,
                            height: 2,
                            color: primaryColor,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedNavBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(
          top: BorderSide(color: Colors.black54, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 8),
          Text(
            'Focus Session Active',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PixelNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _PixelNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
