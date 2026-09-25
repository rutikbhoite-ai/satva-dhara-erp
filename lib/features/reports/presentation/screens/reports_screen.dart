import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/desktop_app_shell.dart';
import '../../../../routing/routes.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

import '../../../../app/app_colors.dart';
import '../../../../config/app_constants.dart';

import '../../../animals/data/animal_repository.dart';
import '../../../expenses/data/expense_repository.dart';
import '../../../health/data/health_repository.dart';
import '../../../inventory/data/inventory_repository.dart';
import '../../../milk/data/milk_repository.dart';
import '../../../pregnancy/data/pregnancy_repository.dart';
import '../../../animals/data/models/animal_model.dart';
import '../../../expenses/data/models/expense_model.dart';
import '../../../health/data/models/health_model.dart';
import '../../../inventory/data/models/inventory_model.dart';
import '../../../milk/data/models/milk_model.dart';
import '../../../pregnancy/data/models/pregnancy_model.dart';



class _PdfRowData {
  final String label;
  final String value;

  const _PdfRowData(
    this.label,
    this.value,
  );
}

class _DesktopOperationData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DesktopOperationData(
    this.icon,
    this.label,
    this.value,
    this.color,
  );
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() =>
      _ReportsScreenState();
}

class _ReportsScreenState
    extends State<ReportsScreen> {
  final MilkRepository _milkRepository =
      MilkRepository();

  final ExpenseRepository _expenseRepository =
      ExpenseRepository();

  final AnimalRepository _animalRepository =
      AnimalRepository();

  final HealthRepository _healthRepository =
      HealthRepository();

  final InventoryRepository _inventoryRepository =
      InventoryRepository();

  final PregnancyRepository _pregnancyRepository =
      PregnancyRepository();

  bool _isLoading = true;
  bool _isGenerating = false;

  // PDF fonts for Marathi/Devanagari Unicode support.
  late pw.Font _pdfRegularFont;
  late pw.Font _pdfBoldFont;

  DateTime _fromDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  DateTime _toDate = DateTime.now();

  double _totalMilk = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _generalExpense = 0;
  double _healthExpense = 0;

  int _animalCount = 0;
  int _activeAnimalCount = 0;
  int _milkingAnimalCount = 0;
  int _lowStockCount = 0;
  int _pregnancyCount = 0;

  // Reports V2 details
  double _morningMilk = 0;
  double _eveningMilk = 0;
  final Map<String, double> _expenseByCategory = {};
  final Map<String, double> _milkByDay = {};
  final Map<String, double> _incomeByDay = {};

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  // ============================================================
  // LOAD REPORT DATA
  // ============================================================

  Future<void> _loadReportData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Load all independent repositories in parallel.
      // This keeps the existing report calculations unchanged while
      // avoiding six sequential database waits on mobile devices.
      final results = await Future.wait([
        _milkRepository.getAllMilkEntries(),
        _expenseRepository.getAllExpenses(),
        _animalRepository.getAllAnimals(),
        _healthRepository.getAllHealthRecords(),
        _inventoryRepository.getAllItems(),
        _pregnancyRepository.getAllPregnancyRecords(),
      ]);

      final List<MilkModel> milkData =
          results[0] as List<MilkModel>;
      final List<ExpenseModel> expenseData =
          results[1] as List<ExpenseModel>;
      final List<AnimalModel> animalData =
          results[2] as List<AnimalModel>;
      final List<HealthModel> healthData =
          results[3] as List<HealthModel>;
      final List<InventoryModel> inventoryData =
          results[4] as List<InventoryModel>;
      final List<PregnancyModel> pregnancyData =
          results[5] as List<PregnancyModel>;

      final milkInRange = milkData.where(
        (item) =>
            _isDateInRange(
              item.date,
              _fromDate,
              _toDate,
            ),
      );

      final expenseInRange = expenseData.where(
        (item) =>
            _isDateInRange(
              item.date,
              _fromDate,
              _toDate,
            ),
      );

      final healthInRange = healthData.where(
        (item) =>
            _isDateInRange(
              item.date,
              _fromDate,
              _toDate,
            ),
      );

      final totalMilk =
          milkInRange.fold<double>(
        0,
        (sum, item) =>
            sum + item.quantityInLiters,
      );

      final totalIncome =
          milkInRange.fold<double>(
        0,
        (sum, item) =>
            sum + item.totalPrice,
      );

      final totalExpense =
          expenseInRange.fold<double>(
        0,
        (sum, item) =>
            sum + item.amount,
      );

      final healthExpense =
          healthInRange.fold<double>(
        0,
        (sum, item) =>
            sum + item.cost,
      );

      final activeAnimals =
          animalData.where(
        (animal) =>
            animal.status == 'Active',
      );

      final milkingAnimals =
          activeAnimals.where(
        (animal) =>
            animal.isMilking,
      );

      final lowStock =
          inventoryData.where(
        (item) =>
            item.quantity <=
            item.minThreshold,
      );

      final activePregnancies =
          pregnancyData.where(
        (record) =>
            record.status ==
                'Pregnant (गाभण)' ||
            record.status ==
                'Pending Diagnosis',
      );

      double morningMilk = 0;
      double eveningMilk = 0;
      final expenseByCategory = <String, double>{};
      final milkByDay = <String, double>{};
      final incomeByDay = <String, double>{};

      for (final item in milkInRange) {
        final shift = item.shift.toLowerCase();

        if (shift.contains('morning') ||
            shift.contains('सकाळ')) {
          morningMilk += item.quantityInLiters;
        } else if (shift.contains('evening') ||
            shift.contains('संध्याकाळ')) {
          eveningMilk += item.quantityInLiters;
        }

        final key = _shortDateKey(item.date);
        milkByDay[key] =
            (milkByDay[key] ?? 0) + item.quantityInLiters;
        incomeByDay[key] =
            (incomeByDay[key] ?? 0) + item.totalPrice;
      }

      for (final item in expenseInRange) {
        expenseByCategory[item.category] =
            (expenseByCategory[item.category] ?? 0) +
                item.amount;
      }

      if (!mounted) return;

      setState(() {
        _totalMilk = totalMilk;
        _totalIncome = totalIncome;
        _generalExpense = totalExpense;
        _healthExpense = healthExpense;
        _totalExpense = totalExpense + healthExpense;

        _animalCount =
            animalData.length;

        _activeAnimalCount =
            activeAnimals.length;

        _milkingAnimalCount =
            milkingAnimals.length;

        _lowStockCount =
            lowStock.length;

        _pregnancyCount =
            activePregnancies.length;

        _morningMilk = morningMilk;
        _eveningMilk = eveningMilk;

        _expenseByCategory
          ..clear()
          ..addAll(expenseByCategory);

        _milkByDay
          ..clear()
          ..addAll(milkByDay);

        _incomeByDay
          ..clear()
          ..addAll(incomeByDay);

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'रिपोर्ट डेटा मिळवताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // DATE PICKERS
  // ============================================================

  Future<void> _selectFromDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2000),
      lastDate: _toDate,
      helpText: 'सुरुवातीची तारीख',
      cancelText: 'रद्द',
      confirmText: 'निवडा',
    );

    if (selected == null) return;

    setState(() {
      _fromDate = selected;
    });

    await _loadReportData();
  }

  Future<void> _selectToDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime.now(),
      helpText: 'शेवटची तारीख',
      cancelText: 'रद्द',
      confirmText: 'निवडा',
    );

    if (selected == null) return;

    setState(() {
      _toDate = selected;
    });

    await _loadReportData();
  }

  // ============================================================
  // QUICK DATE FILTERS
  // ============================================================

  void _setQuickRange(String range) {
    final now = DateTime.now();

    DateTime from;
    DateTime to = DateTime(
      now.year,
      now.month,
      now.day,
    );

    switch (range) {
      case 'आज':
        from = to;
        break;

      case '7 दिवस':
        from = to.subtract(
          const Duration(days: 6),
        );
        break;

      case 'या महिन्यात':
        from = DateTime(
          now.year,
          now.month,
          1,
        );
        break;

      default:
        from = _fromDate;
        to = _toDate;
    }

    setState(() {
      _fromDate = from;
      _toDate = to;
    });

    _loadReportData();
  }

  // ============================================================
  // REPORTS V2 CARDS
  // ============================================================

  Widget _buildMilkBreakdownCard() {
    final total = _morningMilk + _eveningMilk;
    final morningPercent =
        total <= 0 ? 0.0 : _morningMilk / total;
    final eveningPercent =
        total <= 0 ? 0.0 : _eveningMilk / total;

    return _sectionCard(
      title: 'दूध संकलन आढावा',
      subtitle: 'Morning vs Evening',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _breakdownMetric(
                  icon: Icons.wb_sunny_outlined,
                  label: 'सकाळ',
                  value:
                      '${_morningMilk.toStringAsFixed(1)} L',
                  percent: morningPercent,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _breakdownMetric(
                  icon: Icons.nightlight_outlined,
                  label: 'संध्याकाळ',
                  value:
                      '${_eveningMilk.toStringAsFixed(1)} L',
                  percent: eveningPercent,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _miniSummaryRow(
            'एकूण दूध',
            '${_totalMilk.toStringAsFixed(1)} L',
            AppColors.secondary,
          ),
          _miniSummaryRow(
            'सरासरी दर / L',
            _totalMilk <= 0
                ? '₹ 0.00'
                : '₹ ${(_totalIncome / _totalMilk).toStringAsFixed(2)}',
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMilkCard() {
    if (_milkByDay.isEmpty) {
      return _sectionCard(
        title: 'दैनंदिन दूध उत्पादन',
        subtitle: 'Daily Milk Collection',
        child: _emptyReportState(
          'निवडलेल्या कालावधीत दूध नोंद उपलब्ध नाही.',
        ),
      );
    }

    final entries = _sortedEntries(
      _milkByDay,
    );

    return _sectionCard(
      title: 'दैनंदिन दूध उत्पादन',
      subtitle: 'Daily Milk Collection',
      child: _buildBars(
        entries,
        suffix: ' L',
        color: AppColors.secondary,
      ),
    );
  }

  Widget _buildIncomeExpenseCard() {
    final netProfit = _totalIncome - _totalExpense;
    final entries = <String, double>{
      'उत्पन्न': _totalIncome,
      'एकूण खर्च': _totalExpense,
      'निव्वळ': netProfit.abs(),
    };

    return _sectionCard(
      title: 'उत्पन्न vs खर्च',
      subtitle: 'Income vs Expense',
      child: Column(
        children: [
          _horizontalBar(
            label: 'उत्पन्न',
            value: _totalIncome,
            maxValue: _maxValue(entries.values),
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _horizontalBar(
            label: 'एकूण खर्च',
            value: _totalExpense,
            maxValue: _maxValue(entries.values),
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          _horizontalBar(
            label:
                netProfit >= 0
                    ? 'निव्वळ नफा'
                    : 'निव्वळ तोटा',
            value: netProfit.abs(),
            maxValue: _maxValue(entries.values),
            color:
                netProfit >= 0
                    ? AppColors.primary
                    : AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCategoryCard() {
    if (_expenseByCategory.isEmpty) {
      return _sectionCard(
        title: 'सामान्य खर्चाचे प्रकार',
        subtitle: 'General Expense Category Breakdown',
        child: _emptyReportState(
          'निवडलेल्या कालावधीत खर्च नोंद उपलब्ध नाही.',
        ),
      );
    }

    final entries = _sortedEntries(
      _expenseByCategory,
    );

    final total = entries.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    return _sectionCard(
      title: 'खर्चाचे प्रकार',
      subtitle: 'Expense Category Breakdown',
      child: Column(
        children: [
          for (final item in entries)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: _horizontalBar(
                label: item.key,
                value: item.value,
                maxValue: total,
                color: AppColors.error,
              ),
            ),
          const SizedBox(height: 2),
          _miniSummaryRow(
            'सामान्य खर्च एकूण',
            '₹ ${total.toStringAsFixed(2)}',
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildReportSummaryCard() {
    final averageMilkPerDay =
        _milkByDay.isEmpty
            ? 0.0
            : _totalMilk / _milkByDay.length;

    final profit =
        _totalIncome - _totalExpense;

    return _sectionCard(
      title: 'कालावधीचा सारांश',
      subtitle: 'Selected Period Overview',
      child: Column(
        children: [
          _miniSummaryRow(
            'निव्वळ नफा / तोटा',
            '₹ ${profit.abs().toStringAsFixed(2)}',
            profit >= 0
                ? AppColors.success
                : AppColors.error,
          ),
          _miniSummaryRow(
            'दररोज सरासरी दूध',
            '${averageMilkPerDay.toStringAsFixed(1)} L',
            AppColors.secondary,
          ),
          _miniSummaryRow(
            'सामान्य खर्च',
            '₹ ${_generalExpense.toStringAsFixed(2)}',
            AppColors.error,
          ),
          _miniSummaryRow(
            'आरोग्य / उपचार खर्च',
            '₹ ${_healthExpense.toStringAsFixed(2)}',
            AppColors.warning,
          ),
          _miniSummaryRow(
            'एकूण खर्च',
            '₹ ${_totalExpense.toStringAsFixed(2)}',
            AppColors.error,
          ),
          _miniSummaryRow(
            'Low Stock Items',
            '$_lowStockCount',
            _lowStockCount > 0
                ? AppColors.error
                : AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _breakdownMetric({
    required IconData icon,
    required String label,
    required String value,
    required double percent,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 8),
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
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor:
                  color.withValues(alpha: 0.10),
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniSummaryRow(
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _horizontalBar({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
  }) {
    final progress =
        maxValue <= 0
            ? 0.0
            : (value / maxValue)
                .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '₹ ${value.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius:
              BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor:
                color.withValues(alpha: 0.08),
            valueColor:
                AlwaysStoppedAnimation<Color>(
              color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBars(
    List<MapEntry<String, double>> entries, {
    required String suffix,
    required Color color,
  }) {
    final visible = entries.length > 14
        ? entries.sublist(entries.length - 14)
        : entries;

    final maxValue = visible.fold<double>(
      0,
      (max, item) =>
          item.value > max ? item.value : max,
    );

    return SizedBox(
      height: 190,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          for (final item in visible)
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    Text(
                      '${item.value.toStringAsFixed(0)}$suffix',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight:
                            FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Align(
                        alignment:
                            Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor:
                              maxValue <= 0
                                  ? 0
                                  : (item.value /
                                          maxValue)
                                      .clamp(
                                      0.02,
                                      1.0,
                                    ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius:
                                  const BorderRadius
                                      .vertical(
                                top: Radius.circular(
                                  6,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.key,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 7,
                        color:
                            AppColors.textTertiary,
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

  Widget _emptyReportState(
    String message,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  List<MapEntry<String, double>> _sortedEntries(
    Map<String, double> data,
  ) {
    final entries = data.entries.toList();

    entries.sort(
      (a, b) => a.key.compareTo(b.key),
    );

    return entries;
  }

  double _maxValue(
    Iterable<double> values,
  ) {
    var max = 0.0;

    for (final value in values) {
      if (value > max) {
        max = value;
      }
    }

    return max;
  }

  String _shortDateKey(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // PDF
  // ============================================================

  Future<void> _generatePdfReport() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // Load the Devanagari fonts from bundled app assets.
      // This is intentionally offline-safe: no Google Fonts/network
      // request is required when generating a PDF.
      final regularFontData = await rootBundle.load(
        'assets/fonts/NotoSansDevanagari-Regular.ttf',
      );

      final boldFontData = await rootBundle.load(
        'assets/fonts/NotoSansDevanagari-Bold.ttf',
      );

      _pdfRegularFont = pw.Font.ttf(regularFontData);
      _pdfBoldFont = pw.Font.ttf(boldFontData);

      final pdf = pw.Document(
        title: 'Satva Dhara ERP - Farm Report',
        author: AppConstants.farmName,
        subject: 'Farm Management Report',
      );

      final netProfit = _totalIncome - _totalExpense;
      final isProfit = netProfit >= 0;
      final averageMilkPerDay = _milkByDay.isEmpty
          ? 0.0
          : _totalMilk / _milkByDay.length;
      final averageRate = _totalMilk <= 0
          ? 0.0
          : _totalIncome / _totalMilk;

      final expenseEntries = _sortedEntries(_expenseByCategory);
      final milkEntries = _sortedEntries(_milkByDay);
      final incomeEntries = _sortedEntries(_incomeByDay);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(
            30,
            30,
            30,
            34,
          ),
          theme: pw.ThemeData.withFont(
            base: _pdfRegularFont,
            bold: _pdfBoldFont,
          ),
          header: (context) {
            return _pdfPageHeader(
              context,
              compact: context.pageNumber > 1,
            );
          },
          footer: (context) {
            return _pdfPageFooter(context);
          },
          build: (context) {
            return [
              _pdfHeroHeader(),

              pw.SizedBox(height: 18),

              _pdfPeriodCard(),

              pw.SizedBox(height: 18),

              _pdfSectionHeader(
                'EXECUTIVE SUMMARY',
                'निवडलेल्या कालावधीचा एकूण आर्थिक आढावा',
              ),

              pw.SizedBox(height: 10),

              pw.Row(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _pdfKpiCard(
                      'एकूण दूध',
                      '${_totalMilk.toStringAsFixed(1)} L',
                      'Milk Collection',
                      PdfColors.blue,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _pdfKpiCard(
                      'दूध उत्पन्न',
                      '₹ ${_totalIncome.toStringAsFixed(0)}',
                      'Milk Income',
                      PdfColors.green,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _pdfKpiCard(
                      'एकूण खर्च',
                      '₹ ${_totalExpense.toStringAsFixed(0)}',
                      'Total Expense',
                      PdfColors.red,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _pdfKpiCard(
                      isProfit ? 'निव्वळ नफा' : 'निव्वळ तोटा',
                      '₹ ${netProfit.abs().toStringAsFixed(0)}',
                      isProfit
                          ? 'Income − (General + Health Expense)'
                          : '(General + Health Expense) − Income',
                      isProfit
                          ? PdfColors.teal
                          : PdfColors.orange,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              pw.Row(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 6,
                    child: _pdfInfoCard(
                      title: 'MILK COLLECTION',
                      icon: '●',
                      rows: [
                        _PdfRowData(
                          'एकूण दूध',
                          '${_totalMilk.toStringAsFixed(2)} L',
                        ),
                        _PdfRowData(
                          'सकाळ',
                          '${_morningMilk.toStringAsFixed(2)} L',
                        ),
                        _PdfRowData(
                          'संध्याकाळ',
                          '${_eveningMilk.toStringAsFixed(2)} L',
                        ),
                        _PdfRowData(
                          'सरासरी / दिवस',
                          '${averageMilkPerDay.toStringAsFixed(2)} L',
                        ),
                        _PdfRowData(
                          'सरासरी दर / L',
                          '₹ ${averageRate.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: _pdfInfoCard(
                      title: 'FARM STATUS',
                      icon: '●',
                      rows: [
                        _PdfRowData(
                          'एकूण जनावरे',
                          '$_animalCount',
                        ),
                        _PdfRowData(
                          'Active जनावरे',
                          '$_activeAnimalCount',
                        ),
                        _PdfRowData(
                          'दूध देणारी',
                          '$_milkingAnimalCount',
                        ),
                        _PdfRowData(
                          'Pregnancy / Breeding',
                          '$_pregnancyCount',
                        ),
                        _PdfRowData(
                          'Low Stock',
                          '$_lowStockCount',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              _pdfSectionHeader(
                'FINANCIAL SNAPSHOT',
                'उत्पन्न, सामान्य खर्च + आरोग्य/उपचार खर्च आणि निव्वळ परिणाम',
              ),

              pw.SizedBox(height: 9),

              _pdfFinancialSummary(
                netProfit: netProfit,
                isProfit: isProfit,
              ),

              pw.NewPage(),

              _pdfSectionHeader(
                'MILK PRODUCTION ANALYTICS',
                'दैनंदिन दूध संकलन आणि shift-wise performance',
              ),

              pw.SizedBox(height: 10),

              _pdfMilkChart(
                milkEntries,
              ),

              pw.SizedBox(height: 16),

              _pdfSectionHeader(
                'DAILY MILK & INCOME',
                'निवडलेल्या कालावधीतील दैनंदिन नोंदी',
              ),

              pw.SizedBox(height: 8),

              _pdfDailyMilkTable(
                milkEntries,
                incomeEntries,
              ),

              pw.SizedBox(height: 16),

              _pdfSectionHeader(
                'SHIFT PERFORMANCE',
                'Morning vs Evening collection',
              ),

              pw.SizedBox(height: 9),

              _pdfShiftComparison(),

              pw.NewPage(),

              _pdfSectionHeader(
                'EXPENSE ANALYTICS',
                'सामान्य खर्चाचे प्रकार आणि त्यांचे प्रमाण',
              ),

              pw.SizedBox(height: 10),

              if (expenseEntries.isEmpty)
                _pdfEmptyBox(
                  'निवडलेल्या कालावधीत खर्चाची नोंद उपलब्ध नाही.',
                )
              else ...[
                _pdfExpenseBars(expenseEntries),
                pw.SizedBox(height: 14),
                _pdfExpenseTable(expenseEntries),
              ],

              pw.SizedBox(height: 18),

              _pdfSectionHeader(
                'OPERATIONS & ALERTS',
                'फार्मच्या महत्त्वाच्या operational indicators',
              ),

              pw.SizedBox(height: 9),

              pw.Row(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _pdfInfoCard(
                      title: 'ANIMAL MANAGEMENT',
                      icon: '●',
                      rows: [
                        _PdfRowData(
                          'Total Animals',
                          '$_animalCount',
                        ),
                        _PdfRowData(
                          'Active Animals',
                          '$_activeAnimalCount',
                        ),
                        _PdfRowData(
                          'Milking Animals',
                          '$_milkingAnimalCount',
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: _pdfInfoCard(
                      title: 'ALERTS',
                      icon: '●',
                      rows: [
                        _PdfRowData(
                          'Pregnancy / Breeding',
                          '$_pregnancyCount',
                        ),
                        _PdfRowData(
                          'Low Stock Items',
                          '$_lowStockCount',
                        ),
                        _PdfRowData(
                          'Health Expense',
                          '₹ ${_healthExpense.toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.NewPage(),

              _pdfClosingPage(
                netProfit: netProfit,
                isProfit: isProfit,
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          return pdf.save();
        },
      );
    } catch (e) {
      _showMessage(
        'PDF तयार करताना त्रुटी आली.\n$e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  pw.Widget _pdfHeroHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#102A43'),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 48,
            height: 48,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#19A7A0'),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Center(
              child: pw.Text(
                'SD',
                style: pw.TextStyle(
                  font: _pdfBoldFont,
                  fontSize: 16,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SATVA DHARA ERP',
                  style: pw.TextStyle(
                    font: _pdfBoldFont,
                    fontSize: 17,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  AppConstants.farmName,
                  style: pw.TextStyle(
                    font: _pdfRegularFont,
                    fontSize: 9,
                    color: PdfColor.fromHex('#D9EAF7'),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Farm Management • Performance Report',
                  style: pw.TextStyle(
                    font: _pdfRegularFont,
                    fontSize: 8,
                    color: PdfColor.fromHex('#B7C9D8'),
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'REPORT',
              style: pw.TextStyle(
                font: _pdfBoldFont,
                fontSize: 8,
                color: PdfColor.fromHex('#102A43'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfPeriodCard() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F3F7FA'),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColor.fromHex('#D9E2EC'),
          width: 0.7,
        ),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'REPORT PERIOD',
            style: pw.TextStyle(
              font: _pdfBoldFont,
              fontSize: 8,
              color: PdfColor.fromHex('#627D98'),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(
            '${_formatDate(_fromDate)}  —  ${_formatDate(_toDate)}',
            style: pw.TextStyle(
              font: _pdfBoldFont,
              fontSize: 10,
              color: PdfColor.fromHex('#102A43'),
            ),
          ),
          pw.Spacer(),
          pw.Text(
            'Generated ${_formatDate(DateTime.now())}',
            style: pw.TextStyle(
              font: _pdfRegularFont,
              fontSize: 8,
              color: PdfColor.fromHex('#829AB1'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfPageHeader(
    pw.Context context, {
    required bool compact,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 7),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColor.fromHex('#D9E2EC'),
            width: 0.7,
          ),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'SATVA DHARA ERP',
            style: pw.TextStyle(
              font: _pdfBoldFont,
              fontSize: compact ? 8 : 9,
              color: PdfColor.fromHex('#102A43'),
            ),
          ),
          pw.SizedBox(width: 7),
          pw.Text(
            '•',
            style: pw.TextStyle(
              font: _pdfBoldFont,
              fontSize: 8,
              color: PdfColor.fromHex('#19A7A0'),
            ),
          ),
          pw.SizedBox(width: 7),
          pw.Text(
            AppConstants.farmName,
            style: pw.TextStyle(
              font: _pdfRegularFont,
              fontSize: 8,
              color: PdfColor.fromHex('#627D98'),
            ),
          ),
          pw.Spacer(),
          pw.Text(
            '${_formatDate(_fromDate)} – ${_formatDate(_toDate)}',
            style: pw.TextStyle(
              font: _pdfRegularFont,
              fontSize: 7.5,
              color: PdfColor.fromHex('#627D98'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfPageFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 7),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: PdfColor.fromHex('#D9E2EC'),
            width: 0.7,
          ),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'Satva Dhara ERP • Confidential Farm Report',
            style: pw.TextStyle(
              font: _pdfRegularFont,
              fontSize: 7,
              color: PdfColor.fromHex('#829AB1'),
            ),
          ),
          pw.Spacer(),
          pw.Text(
            'Page ${context.pageNumber}',
            style: pw.TextStyle(
              font: _pdfBoldFont,
              fontSize: 7,
              color: PdfColor.fromHex('#627D98'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSectionHeader(
    String title,
    String subtitle,
  ) {
    return pw.Row(
      crossAxisAlignment:
          pw.CrossAxisAlignment.end,
      children: [
        pw.Container(
          width: 4,
          height: 28,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#19A7A0'),
            borderRadius: pw.BorderRadius.circular(3),
          ),
        ),
        pw.SizedBox(width: 9),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: _pdfBoldFont,
                  fontSize: 11,
                  color: PdfColor.fromHex('#102A43'),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                subtitle,
                style: pw.TextStyle(
                  font: _pdfRegularFont,
                  fontSize: 7.5,
                  color: PdfColor.fromHex('#829AB1'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfKpiCard(
    String title,
    String value,
    String subtitle,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColor.fromHex('#D9E2EC'),
          width: 0.7,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 7,
            height: 7,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(4),
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            title,
            style: pw.TextStyle(
              font: _pdfRegularFont,
              fontSize: 7.5,
              color: PdfColor.fromHex('#627D98'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            maxLines: 1,
            style: pw.TextStyle(
              font: _pdfBoldFont,
              fontSize: 13,
              color: color,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            subtitle,
            style: pw.TextStyle(
              font: _pdfRegularFont,
              fontSize: 6.5,
              color: PdfColor.fromHex('#829AB1'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfInfoCard({
    required String title,
    required String icon,
    required List<_PdfRowData> rows,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(11),
        border: pw.Border.all(
          color: PdfColor.fromHex('#D9E2EC'),
          width: 0.7,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 20,
                height: 20,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#E6FFFA'),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Center(
                  child: pw.Text(
                    icon,
                    style: pw.TextStyle(
                      font: _pdfBoldFont,
                      fontSize: 7,
                      color: PdfColor.fromHex('#0E918A'),
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 7),
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: _pdfBoldFont,
                  fontSize: 8.5,
                  color: PdfColor.fromHex('#102A43'),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          for (final row in rows)
            _pdfInfoRow(
              row.label,
              row.value,
            ),
        ],
      ),
    );
  }

  pw.Widget _pdfInfoRow(
    String label,
    String value,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        vertical: 5,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColor.fromHex('#EEF2F6'),
            width: 0.6,
          ),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: _pdfRegularFont,
                fontSize: 7.5,
                color: PdfColor.fromHex('#627D98'),
              ),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: _pdfBoldFont,
              fontSize: 8,
              color: PdfColor.fromHex('#102A43'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfFinancialSummary({
    required double netProfit,
    required bool isProfit,
  }) {
    final maxValue = _maxValue([
      _totalIncome,
      _totalExpense,
      netProfit.abs(),
    ]);

    return pw.Container(
      padding: const pw.EdgeInsets.all(13),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FAFC'),
        borderRadius: pw.BorderRadius.circular(11),
        border: pw.Border.all(
          color: PdfColor.fromHex('#D9E2EC'),
          width: 0.7,
        ),
      ),
      child: pw.Column(
        children: [
          _pdfFinancialBar(
            'दूध उत्पन्न',
            _totalIncome,
            maxValue,
            PdfColors.green,
          ),
          pw.SizedBox(height: 9),
          _pdfFinancialBar(
            'एकूण खर्च',
            _totalExpense,
            maxValue,
            PdfColors.red,
          ),
          pw.SizedBox(height: 9),
          _pdfFinancialBar(
            'आरोग्य / उपचार खर्च',
            _healthExpense,
            maxValue,
            PdfColors.orange,
          ),
          pw.SizedBox(height: 9),
          _pdfFinancialBar(
            isProfit ? 'निव्वळ नफा' : 'निव्वळ तोटा',
            netProfit.abs(),
            maxValue,
            isProfit ? PdfColors.teal : PdfColors.orange,
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfFinancialBar(
    String label,
    double value,
    double maxValue,
    PdfColor color,
  ) {
    final factor = maxValue <= 0
        ? 0.0
        : (value / maxValue).clamp(0.0, 1.0);

    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  font: _pdfRegularFont,
                  fontSize: 8,
                  color: PdfColor.fromHex('#486581'),
                ),
              ),
            ),
            pw.Text(
              '₹ ${value.toStringAsFixed(2)}',
              style: pw.TextStyle(
                font: _pdfBoldFont,
                fontSize: 8,
                color: color,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 8,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#E9EEF3'),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Container(
              width: 470 * factor,
              height: 8,
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfMilkChart(
    List<MapEntry<String, double>> entries,
  ) {
    final visible = entries.length > 20
        ? entries.sublist(entries.length - 20)
        : entries;

    if (visible.isEmpty) {
      return _pdfEmptyBox(
        'निवडलेल्या कालावधीत दूध संकलनाची नोंद उपलब्ध नाही.',
      );
    }

    final maxValue = _maxValue(
      visible.map((entry) => entry.value),
    );

    return pw.Container(
      height: 190,
      padding: const pw.EdgeInsets.fromLTRB(
        12,
        12,
        12,
        9,
      ),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(11),
        border: pw.Border.all(
          color: PdfColor.fromHex('#D9E2EC'),
          width: 0.7,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.end,
        children: [
          for (final entry in visible)
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                child: pw.Column(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      entry.value.toStringAsFixed(0),
                      style: pw.TextStyle(
                        font: _pdfBoldFont,
                        fontSize: 6,
                        color: PdfColor.fromHex('#0E918A'),
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Expanded(
                      child: pw.Align(
                        alignment:
                            pw.Alignment.bottomCenter,
                        child: pw.Container(
                          width: double.infinity,
                          height: maxValue <= 0
                              ? 2
                              : 118 *
                                  (entry.value / maxValue)
                                      .clamp(0.03, 1.0),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#19A7A0'),
                            borderRadius:
                                pw.BorderRadius.vertical(
                              top: pw.Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      entry.key,
                      style: pw.TextStyle(
                        font: _pdfRegularFont,
                        fontSize: 5.5,
                        color: PdfColor.fromHex('#829AB1'),
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

  pw.Widget _pdfDailyMilkTable(
    List<MapEntry<String, double>> milkEntries,
    List<MapEntry<String, double>> incomeEntries,
  ) {
    final incomeMap = Map<String, double>.fromEntries(
      incomeEntries,
    );

    final visible = milkEntries.length > 20
        ? milkEntries.sublist(milkEntries.length - 20)
        : milkEntries;

    if (visible.isEmpty) {
      return _pdfEmptyBox(
        'दैनंदिन नोंद उपलब्ध नाही.',
      );
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColor.fromHex('#D9E2EC'),
          width: 0.7,
        ),
      ),
      child: pw.Column(
        children: [
          _pdfTableRow(
            ['Date', 'Milk', 'Income', 'Rate / L'],
            header: true,
          ),
          for (final entry in visible)
            _pdfTableRow([
              entry.key,
              '${entry.value.toStringAsFixed(2)} L',
              '₹ ${(incomeMap[entry.key] ?? 0).toStringAsFixed(2)}',
              entry.value <= 0
                  ? '₹ 0.00'
                  : '₹ ${((incomeMap[entry.key] ?? 0) / entry.value).toStringAsFixed(2)}',
            ]),
        ],
      ),
    );
  }

  pw.Widget _pdfShiftComparison() {
    final total = _morningMilk + _eveningMilk;
    final morningFactor = total <= 0
        ? 0.0
        : _morningMilk / total;
    final eveningFactor = total <= 0
        ? 0.0
        : _eveningMilk / total;

    return pw.Row(
      children: [
        pw.Expanded(
          child: _pdfShiftCard(
            'सकाळ',
            _morningMilk,
            morningFactor,
            PdfColors.blue,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _pdfShiftCard(
            'संध्याकाळ',
            _eveningMilk,
            eveningFactor,
            PdfColors.indigo,
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfShiftCard(
    String title,
    double value,
    double factor,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColor.fromHex('#D9E2EC'),
          width: 0.7,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: _pdfBoldFont,
              fontSize: 9,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${value.toStringAsFixed(2)} L',
            style: pw.TextStyle(
              font: _pdfBoldFont,
              fontSize: 15,
              color: PdfColor.fromHex('#102A43'),
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Container(
            height: 7,
            width: double.infinity,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#E9EEF3'),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Container(
                width: 230 * factor,
                height: 7,
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${(factor * 100).toStringAsFixed(1)}% of total collection',
            style: pw.TextStyle(
              font: _pdfRegularFont,
              fontSize: 7,
              color: PdfColor.fromHex('#829AB1'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfExpenseBars(
    List<MapEntry<String, double>> entries,
  ) {
    final visible = entries.length > 10
        ? entries.sublist(entries.length - 10)
        : entries;

    final maxValue = _maxValue(
      visible.map((entry) => entry.value),
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(13),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(11),
        border: pw.Border.all(
          color: PdfColor.fromHex('#D9E2EC'),
          width: 0.7,
        ),
      ),
      child: pw.Column(
        children: [
          for (final entry in visible)
            pw.Padding(
              padding: const pw.EdgeInsets.only(
                bottom: 9,
              ),
              child: _pdfCategoryBar(
                entry.key,
                entry.value,
                maxValue,
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _pdfCategoryBar(
    String label,
    double value,
    double maxValue,
  ) {
    final factor = maxValue <= 0
        ? 0.0
        : (value / maxValue).clamp(0.0, 1.0);

    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  font: _pdfRegularFont,
                  fontSize: 7.5,
                  color: PdfColor.fromHex('#486581'),
                ),
              ),
            ),
            pw.Text(
              '₹ ${value.toStringAsFixed(2)}',
              style: pw.TextStyle(
                font: _pdfBoldFont,
                fontSize: 7.5,
                color: PdfColor.fromHex('#D64545'),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 7,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#FDECEC'),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Container(
              width: 470 * factor,
              height: 7,
              decoration: pw.BoxDecoration(
                color: PdfColors.red,
                borderRadius: pw.BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfExpenseTable(
    List<MapEntry<String, double>> entries,
  ) {
    final total = entries.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColor.fromHex('#D9E2EC'),
          width: 0.7,
        ),
      ),
      child: pw.Column(
        children: [
          _pdfTableRow(
            ['Category', 'Amount', 'Share'],
            header: true,
          ),
          for (final entry in entries)
            _pdfTableRow([
              entry.key,
              '₹ ${entry.value.toStringAsFixed(2)}',
              total <= 0
                  ? '0.0%'
                  : '${(entry.value / total * 100).toStringAsFixed(1)}%',
            ]),
          _pdfTableRow(
            [
              'GENERAL EXPENSE TOTAL',
              '₹ ${total.toStringAsFixed(2)}',
              '100.0%',
            ],
            header: true,
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfTableRow(
    List<String> values, {
    bool header = false,
  }) {
    final bg = header
        ? PdfColor.fromHex('#102A43')
        : PdfColors.white;
    final textColor = header
        ? PdfColors.white
        : PdfColor.fromHex('#334E68');

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: pw.BoxDecoration(
        color: bg,
        border: pw.Border(
          bottom: pw.BorderSide(
            color: header
                ? PdfColor.fromHex('#102A43')
                : PdfColor.fromHex('#EEF2F6'),
            width: 0.6,
          ),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Text(
              values[0],
              style: pw.TextStyle(
                font: header
                    ? _pdfBoldFont
                    : _pdfRegularFont,
                fontSize: 7.5,
                color: textColor,
              ),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                values.length > 1 ? values[1] : '',
                style: pw.TextStyle(
                  font: header
                      ? _pdfBoldFont
                      : _pdfRegularFont,
                  fontSize: 7.5,
                  color: textColor,
                ),
              ),
            ),
          ),
          if (values.length > 2)
            pw.Expanded(
              flex: 2,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  values[2],
                  style: pw.TextStyle(
                    font: header
                        ? _pdfBoldFont
                        : _pdfRegularFont,
                    fontSize: 7.5,
                    color: textColor,
                  ),
                ),
              ),
            ),
          if (values.length > 3)
            pw.Expanded(
              flex: 2,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  values[3],
                  style: pw.TextStyle(
                    font: header
                        ? _pdfBoldFont
                        : _pdfRegularFont,
                    fontSize: 7.5,
                    color: textColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _pdfEmptyBox(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FAFC'),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColor.fromHex('#D9E2EC'),
          width: 0.7,
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          message,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: _pdfRegularFont,
            fontSize: 8,
            color: PdfColor.fromHex('#829AB1'),
          ),
        ),
      ),
    );
  }

  pw.Widget _pdfClosingPage({
    required double netProfit,
    required bool isProfit,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#102A43'),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'REPORT SUMMARY',
            style: pw.TextStyle(
              font: _pdfBoldFont,
              fontSize: 15,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'निवडलेल्या कालावधीचा अंतिम व्यवस्थापन आढावा',
            style: pw.TextStyle(
              font: _pdfRegularFont,
              fontSize: 8.5,
              color: PdfColor.fromHex('#B7C9D8'),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#173E5C'),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        isProfit
                            ? 'निव्वळ नफा'
                            : 'निव्वळ तोटा',
                        style: pw.TextStyle(
                          font: _pdfRegularFont,
                          fontSize: 8,
                          color: PdfColor.fromHex('#B7C9D8'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '₹ ${netProfit.abs().toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          font: _pdfBoldFont,
                          fontSize: 22,
                          color: isProfit
                              ? PdfColor.fromHex('#62D9C8')
                              : PdfColor.fromHex('#FFB86B'),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  width: 1,
                  height: 42,
                  color: PdfColor.fromHex('#41627A'),
                ),
                pw.SizedBox(width: 14),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Report Period',
                        style: pw.TextStyle(
                          font: _pdfRegularFont,
                          fontSize: 8,
                          color: PdfColor.fromHex('#B7C9D8'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '${_formatDate(_fromDate)} – ${_formatDate(_toDate)}',
                        style: pw.TextStyle(
                          font: _pdfBoldFont,
                          fontSize: 9,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'FARM DETAILS',
            style: pw.TextStyle(
              font: _pdfBoldFont,
              fontSize: 9,
              color: PdfColor.fromHex('#62D9C8'),
            ),
          ),
          pw.SizedBox(height: 7),
          _pdfDarkRow(
            'Farm',
            AppConstants.farmName,
          ),
          _pdfDarkRow(
            'Owner',
            AppConstants.farmOwner,
          ),
          _pdfDarkRow(
            'Address',
            '${AppConstants.farmAddress} - ${AppConstants.farmPin}',
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#173E5C'),
              borderRadius: pw.BorderRadius.circular(9),
            ),
            child: pw.Text(
              'निव्वळ नफा = दूध उत्पन्न − (सामान्य खर्च + आरोग्य/उपचार खर्च). '
              'हा रिपोर्ट Satva Dhara ERP मधील निवडलेल्या कालावधीच्या नोंदींवर आधारित आहे. '
              'व्यवस्थापन निर्णय घेण्यापूर्वी आवश्यक नोंदींची पडताळणी करा.',
              style: pw.TextStyle(
                font: _pdfRegularFont,
                fontSize: 7.5,
                color: PdfColor.fromHex('#D9EAF7'),
                lineSpacing: 2,
              ),
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Center(
            child: pw.Text(
              'Generated by Satva Dhara ERP',
              style: pw.TextStyle(
                font: _pdfRegularFont,
                fontSize: 7,
                color: PdfColor.fromHex('#829AB1'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfDarkRow(
    String label,
    String value,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        vertical: 5,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColor.fromHex('#294F6A'),
            width: 0.5,
          ),
        ),
      ),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 55,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: _pdfRegularFont,
                fontSize: 7.5,
                color: PdfColor.fromHex('#B7C9D8'),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: _pdfBoldFont,
                fontSize: 7.5,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final netProfit = _totalIncome - _totalExpense;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;

    if (isDesktop) {
      return DesktopAppShell(
        currentIndex: 7,
        title: 'रिपोर्ट्स',
        subtitle: 'Reports & Business Overview',
        actions: [
          IconButton(
            tooltip: 'Refresh reports',
            onPressed: _isLoading ? null : _loadReportData,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: _isGenerating ? null : _generatePdfReport,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 18,
                  ),
            label: const Text('PDF रिपोर्ट'),
          ),
          const SizedBox(width: 8),
        ],
        onDestinationSelected: _handleDesktopNavigation,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadReportData,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _buildDesktopReportPage(netProfit),
        ),
      );
    }

    // Existing mobile Reports UI remains unchanged.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'रिपोर्ट्स व नफा-तोटा',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadReportData,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadReportData,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDateRange(),
                  const SizedBox(height: 10),
                  _buildQuickFilters(),
                  const SizedBox(height: 16),
                  _buildProfitCard(netProfit),
                  const SizedBox(height: 14),
                  _buildFinancialCards(),
                  const SizedBox(height: 14),
                  _buildMilkBreakdownCard(),
                  const SizedBox(height: 14),
                  _buildDailyMilkCard(),
                  const SizedBox(height: 14),
                  _buildIncomeExpenseCard(),
                  const SizedBox(height: 14),
                  _buildExpenseCategoryCard(),
                  const SizedBox(height: 14),
                  _buildReportSummaryCard(),
                  const SizedBox(height: 14),
                  _buildOperationsCard(),
                  const SizedBox(height: 14),
                  _buildPdfCard(),
                  const SizedBox(height: 30),
                ],
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

  Widget _buildDesktopReportPage(double netProfit) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1580,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDesktopReportHeader(),
                const SizedBox(height: 18),
                _buildDesktopDateToolbar(),
                const SizedBox(height: 18),
                _buildDesktopKpiRow(netProfit),
                const SizedBox(height: 18),
                _buildDesktopAnalyticsGrid(),
                const SizedBox(height: 18),
                _buildDesktopOperationsPanel(),
                const SizedBox(height: 18),
                _buildDesktopPdfPanel(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopReportHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'रिपोर्ट्स व बिझनेस आढावा',
                style: TextStyle(
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'दूध उत्पादन, उत्पन्न, खर्च आणि फार्म ऑपरेशन्स एका नजरेत.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.date_range_outlined,
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${_formatDate(_fromDate)} – ${_formatDate(_toDate)}',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopDateToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: _desktopDateButton(
                    label: 'पासून',
                    date: _fromDate,
                    onTap: _selectFromDate,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ),
                Expanded(
                  child: _desktopDateButton(
                    label: 'पर्यंत',
                    date: _toDate,
                    onTap: _selectToDate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          const VerticalDivider(
            width: 1,
            thickness: 1,
          ),
          const SizedBox(width: 18),
          const Text(
            'Quick:',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          _quickFilter('आज', _isQuickRange('आज')),
          const SizedBox(width: 7),
          _quickFilter('7 दिवस', _isQuickRange('7 दिवस')),
          const SizedBox(width: 7),
          _quickFilter(
            'या महिन्यात',
            _isQuickRange('या महिन्यात'),
          ),
        ],
      ),
    );
  }

  Widget _desktopDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
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
                      fontSize: 8.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopKpiRow(double netProfit) {
    final isProfit = netProfit >= 0;

    return Row(
      children: [
        Expanded(
          child: _desktopKpi(
            icon: Icons.water_drop_outlined,
            title: 'एकूण दूध',
            value: '${_totalMilk.toStringAsFixed(1)} L',
            subtitle: 'Selected period',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopKpi(
            icon: Icons.trending_up_rounded,
            title: 'दूध उत्पन्न',
            value: '₹ ${_totalIncome.toStringAsFixed(0)}',
            subtitle: 'Milk income',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopKpi(
            icon: Icons.payments_outlined,
            title: 'एकूण खर्च',
            value: '₹ ${_totalExpense.toStringAsFixed(0)}',
            subtitle: 'General + Health/Treatment',
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopKpi(
            icon: isProfit
                ? Icons.account_balance_wallet_outlined
                : Icons.warning_amber_rounded,
            title: isProfit ? 'निव्वळ नफा' : 'निव्वळ तोटा',
            value: '₹ ${netProfit.abs().toStringAsFixed(0)}',
            subtitle: 'Income − (General + Health Expense)',
            color: isProfit
                ? AppColors.primary
                : AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _desktopKpi({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
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
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
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

  Widget _buildDesktopAnalyticsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1200;

        if (!wide) {
          return Column(
            children: [
              _buildMilkBreakdownCard(),
              const SizedBox(height: 14),
              _buildDailyMilkCard(),
              const SizedBox(height: 14),
              _buildIncomeExpenseCard(),
              const SizedBox(height: 14),
              _buildExpenseCategoryCard(),
              const SizedBox(height: 14),
              _buildReportSummaryCard(),
            ],
          );
        }

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildMilkBreakdownCard(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 7,
                  child: _buildDailyMilkCard(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildIncomeExpenseCard(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildExpenseCategoryCard(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildReportSummaryCard(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopOperationsPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.insights_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'फार्म ऑपरेशनल आढावा',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Animals, health, pregnancy आणि inventory status',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000 ? 6 : 3;
              final gap = 10.0;
              final cardWidth =
                  (constraints.maxWidth -
                          (gap * (columns - 1))) /
                      columns;

              final items = [
                _DesktopOperationData(
                  Icons.pets_outlined,
                  'एकूण जनावरे',
                  '$_animalCount',
                  AppColors.primary,
                ),
                _DesktopOperationData(
                  Icons.water_drop_outlined,
                  'दूध देणारी',
                  '$_milkingAnimalCount',
                  AppColors.secondary,
                ),
                _DesktopOperationData(
                  Icons.health_and_safety_outlined,
                  'आरोग्य खर्च',
                  '₹ ${_healthExpense.toStringAsFixed(0)}',
                  AppColors.warning,
                ),
                _DesktopOperationData(
                  Icons.pregnant_woman_outlined,
                  'गाभण / तपासणी',
                  '$_pregnancyCount',
                  AppColors.secondary,
                ),
                _DesktopOperationData(
                  Icons.inventory_2_outlined,
                  'Low Stock',
                  '$_lowStockCount',
                  _lowStockCount > 0
                      ? AppColors.error
                      : AppColors.primary,
                ),
                _DesktopOperationData(
                  Icons.speed_outlined,
                  'सरासरी दूध / दिवस',
                  _milkByDay.isEmpty
                      ? '0.0 L'
                      : '${(_totalMilk / _milkByDay.length).toStringAsFixed(1)} L',
                  AppColors.primary,
                ),
              ];

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: cardWidth,
                        child: _desktopOperationTile(item),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _desktopOperationTile(
    _DesktopOperationData item,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 18,
            color: item.color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: item.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopPdfPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.error,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'फार्म रिपोर्ट PDF',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'निवडलेल्या कालावधीचा संपूर्ण रिपोर्ट तयार करा आणि print/share करा.',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          OutlinedButton.icon(
            onPressed: _isGenerating
                ? null
                : _generatePdfReport,
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              size: 17,
            ),
            label: const Text('PDF तयार करा'),
          ),
        ],
      ),
    );
  }

  // QUICK FILTERS
  // ============================================================

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _quickFilter(
            'आज',
            _isQuickRange('आज'),
          ),
          const SizedBox(width: 8),
          _quickFilter(
            '7 दिवस',
            _isQuickRange('7 दिवस'),
          ),
          const SizedBox(width: 8),
          _quickFilter(
            'या महिन्यात',
            _isQuickRange('या महिन्यात'),
          ),
        ],
      ),
    );
  }

  bool _isQuickRange(String range) {
    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    if (range == 'आज') {
      return _sameDay(_fromDate, today) &&
          _sameDay(_toDate, today);
    }

    if (range == '7 दिवस') {
      final from = today.subtract(
        const Duration(days: 6),
      );

      return _sameDay(_fromDate, from) &&
          _sameDay(_toDate, today);
    }

    if (range == 'या महिन्यात') {
      final from = DateTime(
        now.year,
        now.month,
        1,
      );

      return _sameDay(_fromDate, from) &&
          _sameDay(_toDate, today);
    }

    return false;
  }

  Widget _quickFilter(
    String label,
    bool selected,
  ) {
    return InkWell(
      onTap: () => _setQuickRange(label),
      borderRadius:
          BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: selected
                ? Colors.white
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  bool _sameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  // ============================================================
  // DATE RANGE CARD
  // ============================================================

  Widget _buildDateRange() {
    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'अहवालाचा कालावधी',
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          const Text(
            'तुम्हाला हवा तो कालावधी निवडा.',
            style: TextStyle(
              fontSize: 10,
              color:
                  AppColors.textSecondary,
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          Row(
            children: [
              Expanded(
                child: _dateButton(
                  label:
                      'पासून',
                  date:
                      _fromDate,
                  onTap:
                      _selectFromDate,
                ),
              ),

              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Icon(
                  Icons
                      .arrow_forward_rounded,
                  size: 18,
                  color:
                      AppColors.textTertiary,
                ),
              ),

              Expanded(
                child: _dateButton(
                  label:
                      'पर्यंत',
                  date:
                      _toDate,
                  onTap:
                      _selectToDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        12,
      ),
      child: Container(
        padding:
            const EdgeInsets.all(11),
        decoration:
            BoxDecoration(
          color:
              AppColors.background,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style:
                  const TextStyle(
                fontSize: 9,
                color:
                    AppColors.textTertiary,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              children: [
                const Icon(
                  Icons
                      .calendar_today_outlined,
                  size: 15,
                  color:
                      AppColors.primary,
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style:
                        const TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFIT CARD
  // ============================================================

  Widget _buildProfitCard(
    double profit,
  ) {
    final isProfit =
        profit >= 0;

    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          colors: [
            isProfit
                ? AppColors.primary
                : AppColors.error,
            isProfit
                ? AppColors.primaryDark
                : const Color(0xFF8E0000),
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isProfit
                    ? Icons
                        .trending_up_rounded
                    : Icons
                        .trending_down_rounded,
                color:
                    Colors.white,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                isProfit
                    ? 'निव्वळ नफा'
                    : 'निव्वळ तोटा',
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            '₹ ${profit.abs().toStringAsFixed(2)}',
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 28,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            '${_formatDate(_fromDate)} - ${_formatDate(_toDate)}',
            style:
                const TextStyle(
              color:
                  Colors.white70,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FINANCIAL
  // ============================================================

  Widget _buildFinancialCards() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            icon:
                Icons.water_drop_outlined,
            title:
                'दूध उत्पन्न',
            value:
                '₹ ${_totalIncome.toStringAsFixed(0)}',
            color:
                AppColors.secondary,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: _metricCard(
            icon:
                Icons.payments_outlined,
            title:
                'एकूण खर्च',
            value:
                '₹ ${_totalExpense.toStringAsFixed(0)}',
            color:
                AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                color,
            size: 22,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 10,
              color:
                  AppColors.textSecondary,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w900,
              color:
                  color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPERATIONS
  // ============================================================

  Widget _buildOperationsCard() {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'फार्म ऑपरेशनल आढावा',
            style:
                TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          _operationRow(
            Icons.water_drop_outlined,
            'एकूण दूध',
            '${_totalMilk.toStringAsFixed(1)} L',
            AppColors.secondary,
          ),

          _operationRow(
            Icons.pets_outlined,
            'एकूण जनावरे',
            '$_animalCount',
            AppColors.primary,
          ),

          _operationRow(
            Icons
                .water_drop_outlined,
            'दूध देणारी जनावरे',
            '$_milkingAnimalCount',
            AppColors.secondary,
          ),

          _operationRow(
            Icons
                .health_and_safety_outlined,
            'आरोग्य खर्च',
            '₹ ${_healthExpense.toStringAsFixed(0)}',
            AppColors.warning,
          ),

          _operationRow(
            Icons
                .pregnant_woman_outlined,
            'गाभण / तपासणी',
            '$_pregnancyCount',
            Colors.pink,
          ),

          _operationRow(
            Icons
                .warning_amber_rounded,
            'Low Stock',
            '$_lowStockCount',
            _lowStockCount > 0
                ? AppColors.error
                : AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _operationRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration:
                BoxDecoration(
              color:
                  color.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color:
                  color,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          Text(
            value,
            style:
                TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w800,
              color:
                  color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PDF CARD
  // ============================================================

  Widget _buildPdfCard() {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              color: AppColors.error
                  .withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: const Icon(
              Icons
                  .picture_as_pdf_outlined,
              color:
                  AppColors.error,
              size: 25,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'फार्म रिपोर्ट PDF',
                  style:
                      TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  'निवडलेल्या कालावधीचा संपूर्ण रिपोर्ट तयार करा.',
                  style:
                      TextStyle(
                    fontSize: 9,
                    color: AppColors
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          ElevatedButton(
            onPressed:
                _isGenerating
                    ? null
                    : _generatePdfReport,
            child: _isGenerating
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'PDF',
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _isDateInRange(
    DateTime date,
    DateTime from,
    DateTime to,
  ) {
    final current =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    final start =
        DateTime(
      from.year,
      from.month,
      from.day,
    );

    final end =
        DateTime(
      to.year,
      to.month,
      to.day,
      23,
      59,
      59,
    );

    return !current.isBefore(start) &&
        !current.isAfter(end);
  }

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