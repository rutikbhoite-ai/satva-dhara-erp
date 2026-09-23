import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../config/app_constants.dart';

/// Reusable desktop application shell for Satva Dhara ERP.
///
/// Presentation/navigation chrome only.
/// It does not touch repositories, Isar, Firebase, sync, or business logic.
class DesktopAppShell extends StatefulWidget {
  const DesktopAppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.title,
    this.subtitle,
    this.actions,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  State<DesktopAppShell> createState() => _DesktopAppShellState();
}

class _DesktopAppShellState extends State<DesktopAppShell> {
  bool _isSidebarCollapsed = false;

  static const double _expandedWidth = 248;
  static const double _collapsedWidth = 76;
  static const double _desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < _desktopBreakpoint) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final width =
        _isSidebarCollapsed ? _collapsedWidth : _expandedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildBrand(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildSectionLabel('MAIN'),

                  _buildNavItem(
                    0,
                    Icons.dashboard_outlined,
                    Icons.dashboard_rounded,
                    'Dashboard',
                  ),

                  _buildNavItem(
                    1,
                    Icons.pets_outlined,
                    Icons.pets_rounded,
                    'Animals',
                  ),

                  _buildNavItem(
                    2,
                    Icons.water_drop_outlined,
                    Icons.water_drop_rounded,
                    'Milk',
                  ),

                  _buildNavItem(
                    3,
                    Icons.account_balance_wallet_outlined,
                    Icons.account_balance_wallet_rounded,
                    'Expenses',
                  ),

                  _buildNavItem(
                    4,
                    Icons.inventory_2_outlined,
                    Icons.inventory_2_rounded,
                    'Inventory',
                  ),

                  _buildNavItem(
                    5,
                    Icons.medical_services_outlined,
                    Icons.medical_services_rounded,
                    'Health',
                  ),

                  _buildNavItem(
                    6,
                    Icons.child_care_outlined,
                    Icons.child_care_rounded,
                    'Pregnancy',
                  ),

                  _buildNavItem(
                    7,
                    Icons.analytics_outlined,
                    Icons.analytics_rounded,
                    'Reports',
                  ),

                  const SizedBox(height: 18),

                  _buildSectionLabel('SYSTEM'),

                  _buildNavItem(
                    8,
                    Icons.settings_outlined,
                    Icons.settings_rounded,
                    'Settings',
                  ),

                  // ======================================================
                  // AUDIT LOG
                  // ======================================================

                  _buildNavItem(
                    9,
                    Icons.history_outlined,
                    Icons.history_rounded,
                    'Audit Log',
                  ),
                ],
              ),
            ),
            _buildCollapseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _isSidebarCollapsed ? 14 : 18,
        18,
        _isSidebarCollapsed ? 14 : 12,
        4,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.agriculture_rounded,
                    color: AppColors.primary,
                    size: 24,
                  );
                },
              ),
            ),
          ),
          if (!_isSidebarCollapsed) ...[
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                AppConstants.farmName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    if (_isSidebarCollapsed) {
      return const SizedBox(height: 8);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 7),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    final selected = widget.currentIndex == index;

    final foregroundColor =
        selected ? AppColors.primary : AppColors.textSecondary;

    final item = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      margin: const EdgeInsets.only(bottom: 4),
      height: 44,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisAlignment: _isSidebarCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          if (selected)
            Container(
              width: 3,
              height: 22,
              margin: const EdgeInsets.only(
                left: 1,
                right: 11,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            )
          else if (!_isSidebarCollapsed)
            const SizedBox(width: 15),

          Icon(
            selected ? selectedIcon : icon,
            size: 20,
            color: foregroundColor,
          ),

          if (!_isSidebarCollapsed) ...[
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Tooltip(
      message: _isSidebarCollapsed ? label : '',
      child: InkWell(
        onTap: () => widget.onDestinationSelected(index),
        borderRadius: BorderRadius.circular(11),
        child: item,
      ),
    );
  }

  Widget _buildCollapseButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _isSidebarCollapsed = !_isSidebarCollapsed;
          });
        },
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.divider),
          ),
          child: Icon(
            _isSidebarCollapsed
                ? Icons.keyboard_double_arrow_right_rounded
                : Icons.keyboard_double_arrow_left_rounded,
            size: 19,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? 'Dashboard',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle ?? 'Today at a glance',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (widget.actions != null) ...widget.actions!,
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}