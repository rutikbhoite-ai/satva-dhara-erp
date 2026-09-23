import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';
import '../../../../shared/widgets/desktop_app_shell.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

import '../../../../app/app_colors.dart';
import '../../data/expense_repository.dart';
import '../../data/models/expense_model.dart';

class ExpenseEntryScreen extends StatefulWidget {
  const ExpenseEntryScreen({super.key});

  @override
  State<ExpenseEntryScreen> createState() =>
      _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState
    extends State<ExpenseEntryScreen> {
  final ExpenseRepository _repository =
      ExpenseRepository();

  final _formKey =
      GlobalKey<FormState>();

  final _amountController =
      TextEditingController();

  final _descController =
      TextEditingController();

  DateTime _selectedDate =
      DateTime.now();

  String _category =
      'चारा / पशुखाद्य';

  bool _isSaving = false;
  bool _isLoadingExpenses = true;

  ExpenseModel? _editingExpense;

  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> _filteredExpenses = [];

  final TextEditingController _desktopSearchController =
      TextEditingController();

  String _desktopCategoryFilter = 'सर्व';
  String _desktopDateFilter = 'सर्व';

  final List<String> _desktopDateFilters = [
    'सर्व',
    'आज',
    'हा महिना',
    'मागील 30 दिवस',
  ];

  final List<String> _desktopCategories = [
    'सर्व',
    'चारा / पशुखाद्य',
    'औषध / डॉक्टर',
    'मजुरी / पगार',
    'मेंटेनन्स / दुरुस्ती',
    'वीज / पाणी',
    'इंधन / वाहन',
    'इतर',
  ];

  final List<String> _categories = [
    'चारा / पशुखाद्य',
    'औषध / डॉक्टर',
    'मजुरी / पगार',
    'मेंटेनन्स / दुरुस्ती',
    'वीज / पाणी',
    'इंधन / वाहन',
    'इतर',
  ];

  @override
  void initState() {
    super.initState();
    _desktopSearchController.addListener(_applyDesktopFilters);
    _loadExpenses();
  }

  @override
  void dispose() {
    _desktopSearchController.removeListener(_applyDesktopFilters);
    _desktopSearchController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadExpenses() async {
    try {
      final data =
          await _repository.getAllExpenses();

      if (!mounted) return;

      setState(() {
        _expenses = data;
        _filteredExpenses = data;
        _isLoadingExpenses = false;
      });

      _applyDesktopFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingExpenses = false;
      });

      _showMessage(
        'खर्चाच्या नोंदी मिळवताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _selectDate() async {
    final selected =
        await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'खर्चाची तारीख',
      cancelText: 'रद्द',
      confirmText: 'निवडा',
    );

    if (selected == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _selectedDate = selected;
    });
  }

  // ============================================================
  // DUPLICATE GUARD
  // ============================================================

  bool _isDuplicateExpense({
    required DateTime date,
    required String category,
    required double amount,
    required String description,
  }) {
    final normalizedDescription =
        description.trim().toLowerCase();

    return _expenses.any((expense) {
      if (_editingExpense != null &&
          expense.id == _editingExpense!.id) {
        return false;
      }

      final sameDate =
          expense.date.year == date.year &&
          expense.date.month == date.month &&
          expense.date.day == date.day;

      final sameCategory =
          expense.category.trim() == category.trim();

      final sameAmount =
          (expense.amount - amount).abs() < 0.0001;

      final sameDescription =
          expense.description.trim().toLowerCase() ==
              normalizedDescription;

      return sameDate &&
          sameCategory &&
          sameAmount &&
          sameDescription;
    });
  }

  // ============================================================
  // SAVE / UPDATE
  // ============================================================

  Future<void> _saveExpense() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount =
        double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _showMessage(
        'कृपया योग्य खर्चाची रक्कम टाका.',
        isError: true,
      );
      return;
    }

    final description =
        _descController.text.trim();

    if (_isDuplicateExpense(
      date: _selectedDate,
      category: _category,
      amount: amount,
      description: description,
    )) {
      _showMessage(
        'हीच खर्च नोंद आधीच उपलब्ध आहे. Duplicate entry टाळली.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final expense =
          ExpenseModel(
        date: _selectedDate,
        category: _category,
        amount: amount,
        description: description,
      );

      // EDIT असल्यास existing IDs preserve करा.
      if (_editingExpense != null) {
        expense.id =
            _editingExpense!.id;

        expense.firebaseId =
            _editingExpense!.firebaseId;

        expense.lastSyncAt =
            _editingExpense!.lastSyncAt;
      }

      await _repository.addExpense(
        expense,
      );

      if (!mounted) return;

      final wasEditing =
          _editingExpense != null;

      setState(() {
        _isSaving = false;
        _editingExpense = null;
      });

      _resetForm();

      await _loadExpenses();

      if (!mounted) return;

      _showMessage(
        wasEditing
            ? 'खर्चाची नोंद अपडेट झाली.'
            : 'खर्चाची नोंद यशस्वीरीत्या सेव्ह झाली.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'खर्च सेव्ह करताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // EDIT
  // ============================================================

  void _editExpense(
    ExpenseModel expense,
  ) {
    setState(() {
      _editingExpense = expense;

      _selectedDate =
          expense.date;

      _category =
          expense.category;

      _amountController.text =
          expense.amount.toString();

      _descController.text =
          expense.description;
    });

    _showMessage(
      'नोंद Edit करण्यासाठी form मध्ये भरली आहे.',
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteExpense(
    ExpenseModel expense,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'खर्चाची नोंद हटवायची?',
          ),
          content: Text(
            '${expense.category}\n'
            '₹${expense.amount.toStringAsFixed(2)}\n'
            '${_formatDate(expense.date)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('रद्द'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('हटवा'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final success =
          await _repository.deleteExpense(
        expense,
      );

      if (!mounted) return;

      if (success) {
        if (_editingExpense?.id ==
            expense.id) {
          _resetForm();
        }

        await _loadExpenses();

        if (!mounted) return;

        _showMessage(
          'खर्चाची नोंद हटवली.',
        );
      } else {
        _showMessage(
          'Firebase मधून नोंद हटवता आली नाही. '
          'स्थानिक नोंद सुरक्षित ठेवली आहे.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'खर्चाची नोंद हटवताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;

    if (isDesktop) {
      return DesktopAppShell(
        currentIndex: 3,
        title: 'खर्च',
        subtitle: 'Expense Management',
        actions: [
          IconButton(
            tooltip: 'Refresh expenses',
            onPressed: _isLoadingExpenses ? null : _loadExpenses,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: _isSaving ? null : _resetForm,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('नवीन खर्च'),
          ),
          const SizedBox(width: 8),
        ],
        onDestinationSelected: _handleDesktopNavigation,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadExpenses,
          child: _isLoadingExpenses
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _buildDesktopContent(),
        ),
      );
    }

    // Existing mobile UI is intentionally preserved.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _editingExpense == null
              ? 'नवीन खर्च नोंदवा'
              : 'खर्च नोंद Edit',
        ),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: _isSaving ? null : _resetForm,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildCategorySection(),
              const SizedBox(height: 14),
              _buildDateSection(),
              const SizedBox(height: 14),
              _buildAmountSection(),
              const SizedBox(height: 14),
              _buildDescriptionSection(),
              const SizedBox(height: 20),
              _buildSaveButton(),
              if (_editingExpense != null) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _isSaving ? null : _resetForm,
                  child: const Text('Edit रद्द करा'),
                ),
              ],
              const SizedBox(height: 30),
              _buildExpensesSection(),
              const SizedBox(height: 25),
            ],
          ),
        ),
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

  void _applyDesktopFilters() {
    final search =
        _desktopSearchController.text.trim().toLowerCase();

    final filtered = _expenses.where((expense) {
      final matchesSearch =
          search.isEmpty ||
          expense.category.toLowerCase().contains(search) ||
          expense.description.toLowerCase().contains(search);

      final matchesCategory =
          _desktopCategoryFilter == 'सर्व' ||
          expense.category == _desktopCategoryFilter;

      final now = DateTime.now();
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final matchesDate = switch (_desktopDateFilter) {
        'आज' => expenseDate == today,
        'हा महिना' =>
          expense.date.year == now.year &&
          expense.date.month == now.month,
        'मागील 30 दिवस' =>
          !expenseDate.isBefore(
            today.subtract(const Duration(days: 29)),
          ) &&
          !expenseDate.isAfter(today),
        _ => true,
      };

      return matchesSearch &&
          matchesCategory &&
          matchesDate;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredExpenses = filtered;
    });
  }

  Widget _buildDesktopContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const maxWidth = 1600.0;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDesktopIntro(),
                    const SizedBox(height: 18),
                    _buildDesktopSummary(),
                    const SizedBox(height: 18),
                    _buildDesktopWorkspace(),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'खर्चाच्या नोंदी',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${_filteredExpenses.length} नोंदी',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildDesktopExpenseList(
                      constraints.maxWidth > 1350 ? 3 : 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopIntro() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'खर्च व्यवस्थापन',
                style: TextStyle(
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'दैनंदिन खर्च, category आणि एकूण आर्थिक नोंदी एका ठिकाणी व्यवस्थापित करा.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _desktopCountPill(
          icon: Icons.receipt_long_outlined,
          label: 'एकूण नोंदी',
          value: '${_expenses.length}',
          color: AppColors.error,
        ),
      ],
    );
  }

  Widget _desktopCountPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Text(
            '$label  $value',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSummary() {
    final total = _expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    final today = DateTime.now();
    final todayTotal = _expenses
        .where(
          (expense) =>
              expense.date.year == today.year &&
              expense.date.month == today.month &&
              expense.date.day == today.day,
        )
        .fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        );

    final monthTotal = _expenses
        .where(
          (expense) =>
              expense.date.year == today.year &&
              expense.date.month == today.month,
        )
        .fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        );

    final categoryTotals = <String, double>{};
    for (final expense in _expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    String topCategory = '—';
    double topAmount = 0;
    for (final entry in categoryTotals.entries) {
      if (entry.value > topAmount) {
        topCategory = entry.key;
        topAmount = entry.value;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _desktopMetric(
            icon: Icons.account_balance_wallet_outlined,
            title: 'एकूण खर्च',
            value: '₹${total.toStringAsFixed(0)}',
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.today_outlined,
            title: 'आजचा खर्च',
            value: '₹${todayTotal.toStringAsFixed(0)}',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.calendar_month_outlined,
            title: 'या महिन्यात',
            value: '₹${monthTotal.toStringAsFixed(0)}',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.category_outlined,
            title: 'सर्वाधिक category',
            value: topCategory,
            color: AppColors.secondary,
            subtitle: topAmount > 0
                ? '₹${topAmount.toStringAsFixed(0)}'
                : null,
          ),
        ),
      ],
    );
  }

  Widget _desktopMetric({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: value.length > 15 ? 12 : 20,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopWorkspace() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildDesktopFormPanel(),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 2,
          child: _buildDesktopQuickInfo(),
        ),
      ],
    );
  }

  Widget _buildDesktopFormPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.add_card_outlined,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _editingExpense == null
                        ? 'नवीन खर्च नोंद'
                        : 'खर्च नोंद Edit',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_editingExpense != null)
                  TextButton(
                    onPressed: _isSaving ? null : _resetForm,
                    child: const Text('Edit रद्द करा'),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _buildDesktopFormFields(),
            const SizedBox(height: 18),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFormFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'खर्चाची category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _category = value;
                        });
                      },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'रक्कम',
                  prefixText: '₹ ',
                  prefixIcon: Icon(Icons.currency_rupee_outlined),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount <= 0) {
                    return 'योग्य रक्कम टाका';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _isSaving ? null : _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'खर्चाची तारीख',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(_formatDate(_selectedDate)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextFormField(
                controller: _descController,
                minLines: 1,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'खर्चाचा तपशील',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'खर्चाचा तपशील टाका';
                  }
                  if (value.trim().length < 3) {
                    return 'कृपया अधिक तपशील द्या';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopQuickInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Overview',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Search, category आणि date filter वापरून खर्च पटकन शोधा.',
            style: TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _desktopSearchController,
            decoration: InputDecoration(
              hintText: 'Category किंवा तपशील शोधा...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _desktopSearchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _desktopSearchController.clear();
                      },
                      icon: const Icon(Icons.clear_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _desktopCategoryFilter,
            decoration: const InputDecoration(
              labelText: 'Category filter',
              prefixIcon: Icon(Icons.filter_alt_outlined),
            ),
            items: _desktopCategories
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _desktopCategoryFilter = value;
              });
              _applyDesktopFilters();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _desktopDateFilter,
            decoration: const InputDecoration(
              labelText: 'Date filter',
              prefixIcon: Icon(Icons.date_range_outlined),
            ),
            items: _desktopDateFilters
                .map(
                  (filter) => DropdownMenuItem<String>(
                    value: filter,
                    child: Text(filter),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _desktopDateFilter = value;
              });
              _applyDesktopFilters();
            },
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'नोंदणीमध्ये समाविष्ट',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _desktopInfoRow(Icons.category_outlined, 'Category'),
          _desktopInfoRow(Icons.currency_rupee_outlined, 'Amount'),
          _desktopInfoRow(Icons.calendar_today_outlined, 'Date'),
          _desktopInfoRow(Icons.description_outlined, 'Description'),
          const SizedBox(height: 10),
          Text(
            _editingExpense == null
                ? 'नवीन नोंद सेव्ह केल्यावर ती local database मध्ये सुरक्षित राहते आणि उपलब्ध असल्यास Firebase ला sync होते.'
                : 'Edit केल्यावर existing record ची ID आणि sync माहिती preserve केली जाते.',
            style: const TextStyle(
              fontSize: 9.5,
              height: 1.45,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopInfoRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopExpenseList(int columns) {
    if (_filteredExpenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 10),
            Text(
              'या filter साठी कोणतीही खर्च नोंद नाही.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    const gap = 14.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * gap)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _filteredExpenses
              .map(
                (expense) => SizedBox(
                  width: cardWidth,
                  child: _buildDesktopExpenseCard(expense),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildDesktopExpenseCard(ExpenseModel expense) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(expense.date),
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            expense.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => _editExpense(expense),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 2),
              TextButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => _deleteExpense(expense),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                ),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error,
            Color(0xFF9E2020),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withValues(
                alpha: 0.15,
              ),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child: const Icon(
              Icons
                  .account_balance_wallet_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(
            width: 13,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _editingExpense == null
                      ? 'फार्म खर्च'
                      : 'फार्म खर्च Edit',
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                const Text(
                  'Farm Expense Entry',
                  style:
                      TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
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
  // CATEGORY
  // ============================================================

  Widget _buildCategorySection() {
    return _sectionCard(
      title: 'खर्चाचा प्रकार',
      icon:
          Icons.category_outlined,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _category,
          isExpanded: true,
          items: _categories
              .map(
                (category) =>
                    DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _category = value;
            });
          },
          decoration:
              const InputDecoration(
            labelText: 'कॅटेगरी',
            prefixIcon: Icon(
              Icons.category_outlined,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  Widget _buildDateSection() {
    return _sectionCard(
      title: 'खर्चाची तारीख',
      icon:
          Icons.calendar_today_outlined,
      children: [
        InkWell(
          onTap: _selectDate,
          borderRadius:
              BorderRadius.circular(12),
          child: InputDecorator(
            decoration:
                const InputDecoration(
              labelText: 'तारीख निवडा',
              prefixIcon: Icon(
                Icons.calendar_month_outlined,
              ),
            ),
            child: Text(
              _formatDate(
                _selectedDate,
              ),
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  Widget _buildAmountSection() {
    return _sectionCard(
      title: 'खर्चाची रक्कम',
      icon:
          Icons.currency_rupee_rounded,
      children: [
        TextFormField(
          controller:
              _amountController,
          keyboardType:
              const TextInputType
                  .numberWithOptions(
            decimal: true,
          ),
          decoration:
              const InputDecoration(
            labelText: 'रक्कम (₹)',
            hintText: 'उदा. 2500',
            prefixIcon: Icon(
              Icons.currency_rupee_rounded,
              color: AppColors.error,
            ),
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'रक्कम टाका';
            }

            final amount =
                double.tryParse(
              value.trim(),
            );

            if (amount == null ||
                amount <= 0) {
              return 'योग्य रक्कम टाका';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescriptionSection() {
    return _sectionCard(
      title: 'खर्चाचा तपशील',
      icon:
          Icons.description_outlined,
      children: [
        TextFormField(
          controller:
              _descController,
          maxLines: 4,
          textCapitalization:
              TextCapitalization.sentences,
          decoration:
              const InputDecoration(
            labelText: 'तपशील',
            hintText:
                'उदा. 5 गोणी सरकी पेंड खरेदी',
            alignLabelWithHint: true,
            prefixIcon: Padding(
              padding:
                  EdgeInsets.only(
                bottom: 52,
              ),
              child: Icon(
                Icons.description_outlined,
              ),
            ),
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'खर्चाचा तपशील टाका';
            }

            if (value.trim().length <
                3) {
              return 'कृपया थोडा अधिक तपशील द्या';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    final isEditing =
        _editingExpense != null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isSaving
            ? null
            : _saveExpense,
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                isEditing
                    ? Icons.update_rounded
                    : Icons.save_rounded,
              ),
        label: Text(
          _isSaving
              ? 'सेव्ह होत आहे...'
              : isEditing
                  ? 'खर्च अपडेट करा'
                  : 'खर्च सेव्ह करा',
          style:
              const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EXPENSE LIST
  // ============================================================

  Widget _buildExpensesSection() {
    return _sectionCard(
      title:
          'खर्चाच्या नोंदी (${_expenses.length})',
      icon:
          Icons.receipt_long_outlined,
      children: [
        if (_isLoadingExpenses)
          const Padding(
            padding:
                EdgeInsets.all(20),
            child: Center(
              child:
                  CircularProgressIndicator(),
            ),
          )
        else if (_expenses.isEmpty)
          const Padding(
            padding:
                EdgeInsets.all(20),
            child: Center(
              child: Text(
                'अजून कोणतीही खर्च नोंद नाही.',
                style:
                    TextStyle(
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ..._expenses.map(
            _buildExpenseCard,
          ),
      ],
    );
  }

  // ============================================================
  // EXPENSE CARD
  // ============================================================

  Widget _buildExpenseCard(
    ExpenseModel expense,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(13),
      decoration:
          BoxDecoration(
        color:
            AppColors.background,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color:
              AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.error
                          .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons
                      .account_balance_wallet_outlined,
                  color:
                      AppColors.error,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.category,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      _formatDate(
                        expense.date,
                      ),
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${expense.amount.toStringAsFixed(2)}',
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w900,
                  color:
                      AppColors.error,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              expense.description,
              style:
                  const TextStyle(
                fontSize: 12,
                color:
                    AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Divider(
            height: 1,
          ),

          const SizedBox(
            height: 4,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _isSaving
                    ? null
                    : () {
                        _editExpense(
                          expense,
                        );
                      },
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                ),
                label:
                    const Text('Edit'),
              ),
              const SizedBox(
                width: 4,
              ),
              TextButton.icon(
                onPressed: _isSaving
                    ? null
                    : () {
                        _deleteExpense(
                          expense,
                        );
                      },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                ),
                label:
                    const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.error
                          .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      AppColors.error,
                  size: 18,
                ),
              ),
              const SizedBox(
                width: 9,
              ),
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 13,
          ),
          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  void _resetForm() {
    _amountController.clear();
    _descController.clear();

    setState(() {
      _category = 'चारा / पशुखाद्य';
      _selectedDate = DateTime.now();
      _editingExpense = null;
      _desktopCategoryFilter = 'सर्व';
      _desktopDateFilter = 'सर्व';
    });

    _applyDesktopFilters();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              isError
                  ? AppColors.error
                  : AppColors.primary,
          content:
              Text(message),
        ),
      );
  }
}