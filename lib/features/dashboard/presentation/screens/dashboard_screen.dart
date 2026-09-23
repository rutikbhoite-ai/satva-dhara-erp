import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_colors.dart';
import '../../../../config/app_constants.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/desktop_app_shell.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

import '../../../animals/data/animal_repository.dart';
import '../../../expenses/data/expense_repository.dart';
import '../../../health/data/health_repository.dart';
import '../../../inventory/data/inventory_repository.dart';
import '../../../milk/data/milk_repository.dart';
import '../../../pregnancy/data/pregnancy_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ============================================================
  // REPOSITORIES
  // ============================================================

  final AnimalRepository _animalRepository = AnimalRepository();
  final MilkRepository _milkRepository = MilkRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final InventoryRepository _inventoryRepository = InventoryRepository();
  final HealthRepository _healthRepository = HealthRepository();
  final PregnancyRepository _pregnancyRepository = PregnancyRepository();

  // ============================================================
  // DASHBOARD DATA
  // ============================================================

  int _totalAnimals = 0;
  int _milkingAnimals = 0;
  int _dryAnimals = 0;

  double _todayMilkLiters = 0.0;
  double _morningMilkLiters = 0.0;
  double _eveningMilkLiters = 0.0;
  double _todayIncome = 0.0;
  double _todayExpense = 0.0;
  double _monthlyExpense = 0.0;
  String _topExpenseCategory = '—';

  // Last 7 days trend data for the dashboard analytics panel. V16 keeps this local and dependency-free.
  final List<double> _last7DayMilk = List<double>.filled(7, 0.0);
  final List<double> _last7DayExpense = List<double>.filled(7, 0.0);

  int _lowStockCount = 0;
  int _outOfStockCount = 0;
  int _healthFollowUpCount = 0;
  int _pregnancyDueCount = 0;

  bool _isLoading = true;
  bool _hasError = false;

  DateTime _lastUpdated = DateTime.now();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // ============================================================
  // DATA LOADING
  // ============================================================

  Future<void> _fetchDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      // Load all dashboard data in parallel.
      // The previous implementation waited for each Isar query one-by-one,
      // which made dashboard startup unnecessarily slow.
      final results = await Future.wait([
        _animalRepository.getAllAnimals(),
        _milkRepository.getAllMilkEntries(),
        _expenseRepository.getAllExpenses(),
        _inventoryRepository.getAllItems(),
        _healthRepository.getAllHealthRecords(),
        _pregnancyRepository.getAllPregnancyRecords(),
      ]);

      final animals = results[0] as List;
      final milkRecords = results[1] as List;
      final expenseRecords = results[2] as List;
      final inventoryItems = results[3] as List;
      final healthRecords = results[4] as List;
      final pregnancyRecords = results[5] as List;

      final now = DateTime.now();

      final milkTrend = List<double>.filled(7, 0.0);
      final expenseTrend = List<double>.filled(7, 0.0);

      double milkSum = 0.0;
      double incomeSum = 0.0;
      double expenseSum = 0.0;
      double morningMilk = 0.0;
      double eveningMilk = 0.0;
      double monthlyExpense = 0.0;
      final expenseByCategory = <String, double>{};
      int milkingAnimals = 0;
      int dryAnimals = 0;

      // ----------------------------------------------------------
      // TODAY'S MILK + INCOME
      // ----------------------------------------------------------

      for (final record in milkRecords) {
        final daysAgo = DateTime(
          now.year,
          now.month,
          now.day,
        ).difference(
          DateTime(record.date.year, record.date.month, record.date.day),
        ).inDays;

        if (daysAgo >= 0 && daysAgo < 7) {
          milkTrend[6 - daysAgo] += record.quantityInLiters;
        }

        if (_isSameDay(record.date, now)) {
          milkSum += record.quantityInLiters;
          incomeSum += record.totalPrice;
          if (record.shift.toLowerCase().contains('morning') ||
              record.shift.contains('सकाळ')) {
            morningMilk += record.quantityInLiters;
          } else if (record.shift.toLowerCase().contains('evening') ||
              record.shift.contains('संध्याकाळ')) {
            eveningMilk += record.quantityInLiters;
          }
        }
      }

      // ----------------------------------------------------------
      // TODAY'S EXPENSE
      // ----------------------------------------------------------

      for (final expense in expenseRecords) {
        final daysAgo = DateTime(
          now.year,
          now.month,
          now.day,
        ).difference(
          DateTime(expense.date.year, expense.date.month, expense.date.day),
        ).inDays;

        if (daysAgo >= 0 && daysAgo < 7) {
          expenseTrend[6 - daysAgo] += expense.amount;
        }

        if (_isSameDay(expense.date, now)) {
          expenseSum += expense.amount;
        }
        if (expense.date.year == now.year &&
            expense.date.month == now.month) {
          monthlyExpense += expense.amount;
          expenseByCategory[expense.category] =
              (expenseByCategory[expense.category] ?? 0) + expense.amount;
        }
      }

      for (final animal in animals) {
        if (animal.isMilking) {
          milkingAnimals++;
        } else {
          dryAnimals++;
        }
      }

      if (expenseByCategory.isNotEmpty) {
        _topExpenseCategory = expenseByCategory.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;
      } else {
        _topExpenseCategory = '—';
      }

      // ----------------------------------------------------------
      // LOW STOCK
      // ----------------------------------------------------------

      int lowStock = 0;
      int outOfStock = 0;

      for (final item in inventoryItems) {
        if (item.quantity <= 0) {
          outOfStock++;
        }
        if (item.quantity <= item.minThreshold) {
          lowStock++;
        }
      }

      // ----------------------------------------------------------
      // HEALTH FOLLOW-UP
      // ----------------------------------------------------------

      int healthFollowUps = 0;

      for (final record in healthRecords) {
        final followUpDate = record.nextFollowUpDate;

        if (followUpDate != null &&
            _isDueWithinDays(followUpDate, now, 7)) {
          healthFollowUps++;
        }
      }

      // ----------------------------------------------------------
      // PREGNANCY / DELIVERY ALERT
      // ----------------------------------------------------------

      int pregnancyDue = 0;

      for (final record in pregnancyRecords) {
        final deliveryDate = record.expectedDeliveryDate;

        if (deliveryDate != null &&
            _isDueWithinDays(deliveryDate, now, 30)) {
          pregnancyDue++;
        }
      }

      if (!mounted) return;

      setState(() {
        _totalAnimals = animals.length;
        _milkingAnimals = milkingAnimals;
        _dryAnimals = dryAnimals;
        _todayMilkLiters = milkSum;
        _morningMilkLiters = morningMilk;
        _eveningMilkLiters = eveningMilk;
        _todayIncome = incomeSum;
        _todayExpense = expenseSum;
        _monthlyExpense = monthlyExpense;
        for (var i = 0; i < 7; i++) {
          _last7DayMilk[i] = milkTrend[i];
          _last7DayExpense[i] = expenseTrend[i];
        }
        _lowStockCount = lowStock;
        _outOfStockCount = outOfStock;
        _healthFollowUpCount = healthFollowUps;
        _pregnancyDueCount = pregnancyDue;

        _lastUpdated = DateTime.now();
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  bool _isDueWithinDays(
    DateTime date,
    DateTime now,
    int days,
  ) {
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final target = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference = target.difference(today).inDays;

    return difference >= 0 && difference <= days;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 850;
    final isDesktop = width >= 900;

    // Desktop gets the new persistent navigation shell.
    // Mobile/tablet keeps the existing dashboard UI unchanged.
    if (isDesktop) {
      return DesktopAppShell(
        currentIndex: 0,
        title: 'आजचा आढावा',
        subtitle: 'Today at a glance',
        actions: [
          _buildDesktopSyncIndicator(),
          _buildDesktopHeaderDate(),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: _isLoading ? null : _fetchDashboardData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        onDestinationSelected: _handleDesktopNavigation,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetchDashboardData,
          child: _buildBody(isWide),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchDashboardData,
        child: _buildBody(isWide),
      ),
    );
  }

  Widget _buildDesktopHeaderDate() {
    final now = DateTime.now();

    const weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 7),
          Text(
            '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleDesktopNavigation(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.animalList);
        break;
      case 2:
        context.go(AppRoutes.milkEntry);
        break;
      case 3:
        context.go(AppRoutes.expenseEntry);
        break;
      case 4:
        context.go(AppRoutes.inventory);
        break;
      case 5:
        context.go(AppRoutes.health);
        break;
      case 6:
        context.go(AppRoutes.pregnancy);
        break;
      case 7:
        context.go(AppRoutes.reports);
        break;
      case 8:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const SettingsScreen(),
          ),
        );
        break;
      case 9:
        context.go(AppRoutes.auditLog,);
        break;
    }
  }

  Widget _buildDesktopSyncIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_done_outlined,
            size: 15,
            color: AppColors.success,
          ),
          SizedBox(width: 5),
          Text(
            'Local',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 16,

      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
                    Icons.agriculture,
                    color: AppColors.primary,
                    size: 25,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.farmName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Farm Management ERP',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      actions: [
        _buildSyncIndicator(),

        IconButton(
          tooltip: 'Refresh',
          onPressed: _isLoading ? null : _fetchDashboardData,
          icon: const Icon(Icons.refresh_rounded),
        ),

        IconButton(
          tooltip: 'Settings',
          onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const SettingsScreen(),
            ),
          );
        },
          icon: const Icon(Icons.settings_outlined),
        ),

        const SizedBox(width: 4),
      ],
    );
  }

  // ============================================================
  // SYNC INDICATOR
  // ============================================================

  Widget _buildSyncIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_done_outlined,
            size: 15,
            color: Colors.white,
          ),
          SizedBox(width: 5),
          Text(
            'Local',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(bool isWide) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: _buildErrorState(),
          ),
        ],
      );
    }

    final width = MediaQuery.sizeOf(context).width;

    if (width >= 1200) {
      return _buildDesktopBody();
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 28 : 16,
        vertical: isWide ? 24 : 20,
      ),
      children: [
        _buildWelcomeCard(),
        const SizedBox(height: 24),
        _buildSectionTitle(
          title: 'आजचा आढावा',
          subtitle: 'Today at a glance',
        ),
        const SizedBox(height: 12),
        _buildMetricsGrid(isWide),
        const SizedBox(height: 20),
        _buildTrendAnalytics(isDesktop: false),
        const SizedBox(height: 20),
        _buildMilkSummary(),
        const SizedBox(height: 20),
        _buildAnimalOverview(),
        const SizedBox(height: 20),
        _buildExpenseSnapshot(),
        const SizedBox(height: 20),
        _buildInventorySummaryCard(),
        const SizedBox(height: 24),
        _buildSectionTitle(
          title: 'लक्ष देण्यासारख्या गोष्टी',
          subtitle: 'Important farm alerts',
        ),
        const SizedBox(height: 12),
        _buildAlertsSection(),
        const SizedBox(height: 24),
        _buildSectionTitle(
          title: 'जलद सेवा',
          subtitle: 'Quick actions',
        ),
        const SizedBox(height: 12),
        _buildQuickActions(isWide),
        const SizedBox(height: 24),
        _buildFinancialSummary(),
        const SizedBox(height: 20),
        _buildLastUpdated(),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDesktopBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const maxContentWidth = 1600.0;
        final contentWidth = constraints.maxWidth > maxContentWidth
            ? maxContentWidth
            : constraints.maxWidth;
        final gap = 18.0;
        final columnWidth = (contentWidth - gap) / 2;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDesktopWelcomeHeader(),
                    const SizedBox(height: 22),

                    _buildSectionTitle(
                      title: 'आजचा आढावा',
                      subtitle: 'Today at a glance',
                    ),
                    const SizedBox(height: 12),

                    _buildMetricsGrid(true),
                    const SizedBox(height: 22),
                    _buildTrendAnalytics(isDesktop: true),
                    const SizedBox(height: 22),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: columnWidth,
                          child: Column(
                            children: [
                              _buildDesktopPanelSlot(
                                child: _buildMilkSummary(),
                              ),
                              SizedBox(height: gap),
                              _buildDesktopPanelSlot(
                                child: _buildAnimalOverview(),
                              ),
                              SizedBox(height: gap),
                              _buildDesktopPanelSlot(
                                child: _buildInventorySummaryCard(),
                                minHeight: 174,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: gap),
                        SizedBox(
                          width: columnWidth,
                          child: Column(
                            children: [
                              _buildDesktopPanelSlot(
                                child: _buildExpenseSnapshot(),
                              ),
                              SizedBox(height: gap),
                              _buildDesktopPanelSlot(
                                child: _buildFinancialSummary(),
                                minHeight: 174,
                              ),
                              SizedBox(height: gap),
                              _buildDesktopPanelSlot(
                                child: _buildAlertsSection(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    _buildSectionTitle(
                      title: 'जलद सेवा',
                      subtitle: 'Quick actions',
                    ),
                    const SizedBox(height: 12),
                    _buildDesktopQuickActions(),

                    const SizedBox(height: 20),
                    _buildLastUpdated(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopPanelSlot({
    required Widget child,
    double minHeight = 142,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: minHeight,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.divider,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  Widget _buildDesktopWelcomeHeader() {
    final firstName = AppConstants.farmOwner.split(' ').first;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.agriculture_rounded,
                    color: AppColors.primary,
                    size: 25,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'नमस्कार, $firstName 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'आजच्या फार्मची महत्त्वाची माहिती एका नजरेत.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildDesktopDateBadge(),
        ],
      ),
    );
  }

  Widget _buildDesktopDateBadge() {
    final now = DateTime.now();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '${now.day} ${months[now.month - 1]} ${now.year}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WELCOME CARD
  // ============================================================

  Widget _buildWelcomeCard() {
    final firstName = AppConstants.farmOwner.split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(
                    'assets/logo/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(
                      Icons.agriculture_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'नमस्कार, $firstName👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'आजच्या आपल्या फार्मची स्थिती पहा.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 15,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Farm Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Colors.white70,
                size: 15,
              ),
              const SizedBox(width: 7),
              Text(
                _formatDate(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1200;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 2 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 17,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.2,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METRICS
  // ============================================================

  Widget _buildMetricsGrid(bool isWide) {
    // V16: business-critical numbers come first. Desktop uses four
    // compact columns so the dashboard reads like an ERP command centre.
    final crossAxisCount = isWide ? 4 : 2;

    final todayNet = _todayIncome - _todayExpense;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: isWide ? 14 : 12,
      mainAxisSpacing: isWide ? 14 : 12,
      childAspectRatio: isWide ? 2.15 : 1.72,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard(
          title: 'एकूण जनावरे',
          value: '$_totalAnimals',
          subtitle: 'Total Animals',
          icon: Icons.pets_rounded,
          color: AppColors.animal,
        ),
        _buildMetricCard(
          title: 'आजचे दूध',
          value: '${_todayMilkLiters.toStringAsFixed(1)} L',
          subtitle: 'Milk Collection',
          icon: Icons.water_drop_rounded,
          color: AppColors.milk,
        ),
        _buildMetricCard(
          title: 'आजचे उत्पन्न',
          value: '₹ ${_todayIncome.toStringAsFixed(0)}',
          subtitle: 'Milk Income',
          icon: Icons.trending_up_rounded,
          color: AppColors.success,
        ),
        _buildMetricCard(
          title: 'आजची शिल्लक',
          value: '₹ ${todayNet.abs().toStringAsFixed(0)}',
          subtitle: todayNet >= 0 ? 'Net Positive' : 'Net Deficit',
          icon: todayNet >= 0
              ? Icons.account_balance_wallet_outlined
              : Icons.warning_amber_rounded,
          color: todayNet >= 0 ? AppColors.primary : AppColors.error,
        ),
        _buildMetricCard(
          title: 'आजचा खर्च',
          value: '₹ ${_todayExpense.toStringAsFixed(0)}',
          subtitle: 'Total Expense',
          icon: Icons.trending_down_rounded,
          color: AppColors.error,
        ),
        _buildMetricCard(
          title: 'या महिन्याचा खर्च',
          value: '₹ ${_monthlyExpense.toStringAsFixed(0)}',
          subtitle: _topExpenseCategory == '—'
              ? 'Monthly Expense'
              : 'Top: $_topExpenseCategory',
          icon: Icons.calendar_month_outlined,
          color: AppColors.expense,
        ),
        _buildMetricCard(
          title: 'Low Stock',
          value: '$_lowStockCount',
          subtitle: _outOfStockCount > 0
              ? '$_outOfStockCount Out of Stock'
              : 'Inventory Alerts',
          icon: Icons.inventory_2_outlined,
          color: _outOfStockCount > 0
              ? AppColors.error
              : AppColors.inventory,
        ),
        _buildMetricCard(
          title: 'लक्ष देणे आवश्यक',
          value: '${_healthFollowUpCount + _pregnancyDueCount}',
          subtitle: 'Health + Pregnancy',
          icon: Icons.notifications_active_outlined,
          color: (_healthFollowUpCount + _pregnancyDueCount) > 0
              ? AppColors.warning
              : AppColors.success,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1200;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 18 : 15,
        isDesktop ? 15 : 13,
        isDesktop ? 18 : 15,
        isDesktop ? 16 : 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: isDesktop ? -18 : -15,
            top: 10,
            bottom: 10,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isDesktop ? 12.5 : 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: isDesktop ? 36 : 34,
                    height: isDesktop ? 36 : 34,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: isDesktop ? 20 : 19,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isDesktop ? 14 : 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isDesktop ? 26 : 24,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: isDesktop ? 9.5 : 9,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TREND ANALYTICS
  // ============================================================

  Widget _buildTrendAnalytics({required bool isDesktop}) {
    final milkMax = _last7DayMilk.fold<double>(
          0.0,
          (max, value) => value > max ? value : max,
        ) *
        1.15;
    final expenseMax = _last7DayExpense.fold<double>(
          0.0,
          (max, value) => value > max ? value : max,
        ) *
        1.15;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 18 : 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'गेल्या 7 दिवसांचा ट्रेंड',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Milk collection आणि खर्चाचा तुलनात्मक आढावा',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              _trendLegendDot(
                color: AppColors.milk,
                label: 'दूध',
              ),
              const SizedBox(width: 12),
              _trendLegendDot(
                color: AppColors.expense,
                label: 'खर्च',
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: isDesktop ? 190 : 175,
            child: CustomPaint(
              painter: _DashboardTrendPainter(
                milk: List<double>.from(_last7DayMilk),
                expense: List<double>.from(_last7DayExpense),
                milkMax: milkMax,
                expenseMax: expenseMax,
                milkColor: AppColors.milk,
                expenseColor: AppColors.expense,
                gridColor: AppColors.divider,
                labelColor: AppColors.textTertiary,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'आजपासून मागील 7 दिवस',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              Text(
                'तारीखेनुसार डेटा',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trendLegendDot({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MILK SUMMARY
  // ============================================================

  Widget _buildMilkSummary() {
    return _buildDashboardPanel(
      title: 'आजचे दूध संकलन',
      subtitle: 'Morning & Evening Collection',
      icon: Icons.water_drop_rounded,
      color: AppColors.milk,
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
              'सकाळ',
              '${_morningMilkLiters.toStringAsFixed(1)} L',
              Icons.wb_sunny_outlined,
              AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMiniStat(
              'संध्याकाळ',
              '${_eveningMilkLiters.toStringAsFixed(1)} L',
              Icons.nights_stay_outlined,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMiniStat(
              'एकूण',
              '${_todayMilkLiters.toStringAsFixed(1)} L',
              Icons.local_drink_outlined,
              AppColors.milk,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalOverview() {
    return _buildDashboardPanel(
      title: 'जनावरांचा आढावा',
      subtitle: 'Animal Overview',
      icon: Icons.pets_rounded,
      color: AppColors.animal,
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
              'एकूण',
              '$_totalAnimals',
              Icons.pets_rounded,
              AppColors.animal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMiniStat(
              'दूध देणारे',
              '$_milkingAnimals',
              Icons.water_drop_outlined,
              AppColors.milk,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMiniStat(
              'Dry',
              '$_dryAnimals',
              Icons.hotel_outlined,
              AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseSnapshot() {
    return _buildDashboardPanel(
      title: 'खर्चाचा आढावा',
      subtitle: 'Current Month Snapshot',
      icon: Icons.account_balance_wallet_outlined,
      color: AppColors.expense,
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
              'आज',
              '₹ ${_todayExpense.toStringAsFixed(0)}',
              Icons.today_outlined,
              AppColors.error,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMiniStat(
              'या महिन्यात',
              '₹ ${_monthlyExpense.toStringAsFixed(0)}',
              Icons.calendar_month_outlined,
              AppColors.expense,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMiniStat(
              'Top Category',
              _topExpenseCategory,
              Icons.category_outlined,
              AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardPanel({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ALERTS
  // ============================================================


  Widget _buildInventorySummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Inventory',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _inventoryMetric(
                    'Low Stock',
                    _lowStockCount,
                    Icons.warning_amber_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _inventoryMetric(
                    'Out of Stock',
                    _outOfStockCount,
                    Icons.remove_shopping_cart_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inventoryMetric(
    String label,
    int value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    final hasAlerts =
        _lowStockCount > 0 ||
        _healthFollowUpCount > 0 ||
        _pregnancyDueCount > 0;

    final totalAlerts =
        _lowStockCount + _healthFollowUpCount + _pregnancyDueCount;

    if (!hasAlerts) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.18),
          ),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: AppColors.success,
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'सध्या कोणतीही महत्त्वाची सूचना नाही',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'फार्मची नोंदणी व्यवस्थित आहे.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                size: 19,
                color: AppColors.warning,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '$totalAlerts लक्ष देण्यासारख्या नोंदी',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Text(
                'आता तपासा',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
        if (_lowStockCount > 0)
          _buildAlertCard(
            title: 'साठा कमी आहे',
            subtitle:
                '$_lowStockCount वस्तू किमान साठा मर्यादेपेक्षा खाली आहेत.',
            icon: Icons.inventory_2_outlined,
            color: AppColors.error,
            onTap: () => context.push(AppRoutes.inventory),
          ),

        if (_healthFollowUpCount > 0)
          _buildAlertCard(
            title: 'आरोग्य Follow-up',
            subtitle:
                '$_healthFollowUpCount आरोग्य नोंदींचा follow-up पुढील 7 दिवसांत आहे.',
            icon: Icons.medical_services_outlined,
            color: AppColors.warning,
            onTap: () => context.push(AppRoutes.health),
          ),

        if (_pregnancyDueCount > 0)
          _buildAlertCard(
            title: 'प्रसूती / गाभण सूचना',
            subtitle:
                '$_pregnancyDueCount जनावरांची अंदाजित प्रसूती पुढील 30 दिवसांत आहे.',
            icon: Icons.child_care_outlined,
            color: AppColors.pregnancy,
            onTap: () => context.push(AppRoutes.pregnancy),
          ),
      ],
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildDesktopQuickActions() {
    final actions = [
      _QuickActionData(
        title: 'जनावरे',
        subtitle: 'List & Add',
        icon: Icons.pets_rounded,
        color: AppColors.animal,
        route: AppRoutes.animalList,
      ),
      _QuickActionData(
        title: 'दूध संकलन',
        subtitle: 'Milk Entry',
        icon: Icons.water_drop_rounded,
        color: AppColors.milk,
        route: AppRoutes.milkEntry,
      ),
      _QuickActionData(
        title: 'खर्च',
        subtitle: 'Expenses',
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.expense,
        route: AppRoutes.expenseEntry,
      ),
      _QuickActionData(
        title: 'साठा',
        subtitle: 'Inventory',
        icon: Icons.inventory_2_outlined,
        color: AppColors.inventory,
        route: AppRoutes.inventory,
      ),
      _QuickActionData(
        title: 'आरोग्य',
        subtitle: 'Health',
        icon: Icons.medical_services_outlined,
        color: AppColors.health,
        route: AppRoutes.health,
      ),
      _QuickActionData(
        title: 'गाभण / प्रसूती',
        subtitle: 'Breeding',
        icon: Icons.child_care_outlined,
        color: AppColors.pregnancy,
        route: AppRoutes.pregnancy,
      ),
      _QuickActionData(
        title: 'अहवाल',
        subtitle: 'Reports',
        icon: Icons.analytics_outlined,
        color: AppColors.reports,
        route: AppRoutes.reports,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: actions.map((action) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                onTap: () => context.push(action.route),
                borderRadius: BorderRadius.circular(11),
                hoverColor: action.color.withValues(alpha: 0.06),
                splashColor: action.color.withValues(alpha: 0.10),
                highlightColor: action.color.withValues(alpha: 0.04),
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 132,
                    minHeight: 46,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: AppColors.divider,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 31,
                        height: 31,
                        decoration: BoxDecoration(
                          color: action.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          action.icon,
                          color: action.color,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            action.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 8.5,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickActions(bool isWide) {
    final actions = [
      _QuickActionData(
        title: 'जनावरे',
        subtitle: 'List & Add',
        icon: Icons.pets_rounded,
        color: AppColors.animal,
        route: AppRoutes.animalList,
      ),
      _QuickActionData(
        title: 'दूध संकलन',
        subtitle: 'Milk Entry',
        icon: Icons.water_drop_rounded,
        color: AppColors.milk,
        route: AppRoutes.milkEntry,
      ),
      _QuickActionData(
        title: 'खर्च',
        subtitle: 'Expenses',
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.expense,
        route: AppRoutes.expenseEntry,
      ),
      _QuickActionData(
        title: 'साठा',
        subtitle: 'Inventory',
        icon: Icons.inventory_2_outlined,
        color: AppColors.inventory,
        route: AppRoutes.inventory,
      ),
      _QuickActionData(
        title: 'आरोग्य',
        subtitle: 'Health',
        icon: Icons.medical_services_outlined,
        color: AppColors.health,
        route: AppRoutes.health,
      ),
      _QuickActionData(
        title: 'गाभण / प्रसूती',
        subtitle: 'Breeding',
        icon: Icons.child_care_outlined,
        color: AppColors.pregnancy,
        route: AppRoutes.pregnancy,
      ),
      _QuickActionData(
        title: 'अहवाल',
        subtitle: 'Reports',
        icon: Icons.analytics_outlined,
        color: AppColors.reports,
        route: AppRoutes.reports,
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: isWide ? 2.5 : 1.65,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return _buildQuickActionCard(action);
      },
    );
  }

  Widget _buildQuickActionCard(_QuickActionData action) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () => context.push(action.route),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 21,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FINANCIAL SUMMARY
  // ============================================================

  Widget _buildFinancialSummary() {
    final net = _todayIncome - _todayExpense;

    final isProfit = net >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'आजचा आर्थिक सारांश',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'Today\'s financial snapshot',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: (isProfit ? AppColors.primary : AppColors.error)
                  .withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Icon(
                  isProfit
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: isProfit ? AppColors.primary : AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isProfit ? 'आजची निव्वळ शिल्लक' : 'आजची निव्वळ तूट',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹ ${net.abs().toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: isProfit
                              ? AppColors.primary
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildFinancialItem(
                  label: 'उत्पन्न',
                  value: '₹ ${_todayIncome.toStringAsFixed(0)}',
                  color: AppColors.success,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildFinancialItem(
                  label: 'खर्च',
                  value: '₹ ${_todayExpense.toStringAsFixed(0)}',
                  color: AppColors.error,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildFinancialItem(
                  label: isProfit ? 'शिल्लक' : 'तूट',
                  value: '₹ ${net.abs().toStringAsFixed(0)}',
                  color: isProfit
                      ? AppColors.primary
                      : AppColors.error,
                  icon: isProfit
                      ? Icons.account_balance_wallet_outlined
                      : Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),

          const SizedBox(height: 9),

          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAST UPDATED
  // ============================================================

  Widget _buildLastUpdated() {
    return Center(
      child: Text(
        'Last updated: ${_formatTime(_lastUpdated)}',
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Dashboard data load करता आले नाही',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'कृपया पुन्हा प्रयत्न करा.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _fetchDashboardData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('पुन्हा प्रयत्न करा'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FORMATTING
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}

// ================================================================
// QUICK ACTION MODEL
// ================================================================

class _DashboardTrendPainter extends CustomPainter {
  final List<double> milk;
  final List<double> expense;
  final double milkMax;
  final double expenseMax;
  final Color milkColor;
  final Color expenseColor;
  final Color gridColor;
  final Color labelColor;

  const _DashboardTrendPainter({
    required this.milk,
    required this.expense,
    required this.milkMax,
    required this.expenseMax,
    required this.milkColor,
    required this.expenseColor,
    required this.gridColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 8.0;
    const top = 8.0;
    const bottom = 28.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final milkPaint = Paint()
      ..color = milkColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final expensePaint = Paint()
      ..color = expenseColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillMilkPaint = Paint()
      ..color = milkColor.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    final fillExpensePaint = Paint()
      ..color = expenseColor.withValues(alpha: 0.055)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var row = 0; row <= 3; row++) {
      final y = top + chartHeight * row / 3;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    final maxCount = milk.length < expense.length ? milk.length : expense.length;
    if (maxCount == 0) return;

    Offset pointFor(List<double> values, int index, double maxValue) {
      final x = maxCount == 1
          ? left + chartWidth / 2
          : left + chartWidth * index / (maxCount - 1);
      final safeMax = maxValue <= 0 ? 1.0 : maxValue;
      final ratio = (values[index] / safeMax).clamp(0.0, 1.0);
      final y = top + chartHeight * (1 - ratio);
      return Offset(x, y);
    }

    Path makePath(List<double> values, double maxValue) {
      final path = Path();
      for (var i = 0; i < maxCount; i++) {
        final point = pointFor(values, i, maxValue);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          final previous = pointFor(values, i - 1, maxValue);
          final controlX = (previous.dx + point.dx) / 2;
          path.cubicTo(
            controlX,
            previous.dy,
            controlX,
            point.dy,
            point.dx,
            point.dy,
          );
        }
      }
      return path;
    }

    Path makeArea(List<double> values, double maxValue) {
      final path = makePath(values, maxValue);
      final last = pointFor(values, maxCount - 1, maxValue);
      final first = pointFor(values, 0, maxValue);
      path.lineTo(last.dx, top + chartHeight);
      path.lineTo(first.dx, top + chartHeight);
      path.close();
      return path;
    }

    canvas.drawPath(makeArea(milk, milkMax), fillMilkPaint);
    canvas.drawPath(makeArea(expense, expenseMax), fillExpensePaint);
    canvas.drawPath(makePath(milk, milkMax), milkPaint);
    canvas.drawPath(makePath(expense, expenseMax), expensePaint);

    for (var i = 0; i < maxCount; i++) {
      final milkPoint = pointFor(milk, i, milkMax);
      final expensePoint = pointFor(expense, i, expenseMax);

      canvas.drawCircle(milkPoint, 3.5, Paint()..color = milkColor);
      canvas.drawCircle(expensePoint, 3.5, Paint()..color = expenseColor);

      final date = DateTime.now().subtract(Duration(days: maxCount - 1 - i));
      final label = '${date.day}/${date.month}';
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 8,
          color: labelColor,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          milkPoint.dx - textPainter.width / 2,
          top + chartHeight + 8,
        ),
      );
    }

    textPainter.text = TextSpan(
      text: milkMax <= 0 ? '0 L' : '${milkMax.toStringAsFixed(0)} L',
      style: TextStyle(fontSize: 8, color: labelColor),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, top - 2));

    textPainter.text = TextSpan(
      text: expenseMax <= 0 ? '₹0' : '₹${expenseMax.toStringAsFixed(0)}',
      style: TextStyle(fontSize: 8, color: labelColor),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - textPainter.width, top - 2));
  }

  @override
  bool shouldRepaint(covariant _DashboardTrendPainter oldDelegate) {
    return oldDelegate.milk != milk ||
        oldDelegate.expense != expense ||
        oldDelegate.milkMax != milkMax ||
        oldDelegate.expenseMax != expenseMax ||
        oldDelegate.milkColor != milkColor ||
        oldDelegate.expenseColor != expenseColor;
  }
}

class _QuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}