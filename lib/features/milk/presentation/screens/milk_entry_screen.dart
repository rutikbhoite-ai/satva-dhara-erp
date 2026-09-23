import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/desktop_app_shell.dart';
import '../../../../routing/routes.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

import '../../../../app/app_colors.dart';
import '../../../../core/widgets/animal_selector.dart';
import '../../../animals/data/animal_repository.dart';
import '../../../animals/data/models/animal_model.dart';
import '../../data/milk_repository.dart';
import '../../data/models/milk_model.dart';

class MilkEntryScreen extends StatefulWidget {
  const MilkEntryScreen({super.key});

  @override
  State<MilkEntryScreen> createState() =>
      _MilkEntryScreenState();
}

class _MilkEntryScreenState
    extends State<MilkEntryScreen> {
  final MilkRepository _repository =
      MilkRepository();

  final AnimalRepository _animalRepository =
      AnimalRepository();

  final _formKey =
      GlobalKey<FormState>();

  final _tagController =
      TextEditingController();

  final _qtyController =
      TextEditingController();

  final _fatController =
      TextEditingController();

  final _snfController =
      TextEditingController();

  final _rateController =
      TextEditingController();

  String _shift = 'सकाळ';

  DateTime _selectedDate =
      DateTime.now();

  double _calculatedTotal = 0.0;

  bool _isSaving = false;

  bool _isLoadingEntries = true;

  MilkModel? _editingMilk;

  AnimalModel? _selectedAnimal;

  List<MilkModel> _milkEntries = [];
  List<MilkModel> _filteredMilkEntries = [];

  final TextEditingController _desktopSearchController =
      TextEditingController();

  String _desktopShiftFilter = 'सर्व';

  @override
  void initState() {
    super.initState();

    _qtyController.addListener(
      _calculateTotal,
    );

    _rateController.addListener(
      _calculateTotal,
    );

    _desktopSearchController.addListener(
      _applyDesktopFilters,
    );

    _loadMilkEntries();
  }

  @override
  void dispose() {
    _qtyController.removeListener(
      _calculateTotal,
    );

    _rateController.removeListener(
      _calculateTotal,
    );

    _tagController.dispose();
    _qtyController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    _rateController.dispose();
    _desktopSearchController.removeListener(
      _applyDesktopFilters,
    );
    _desktopSearchController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD ENTRIES
  // ============================================================

  Future<void> _loadMilkEntries() async {
    try {
      final data =
          await _repository.getAllMilkEntries();

      if (!mounted) return;

      setState(() {
        _milkEntries = data;
        _filteredMilkEntries = data;
        _isLoadingEntries = false;
      });

      _applyDesktopFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingEntries = false;
      });

      _showMessage(
        'दूध नोंदी मिळवताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  void _applyDesktopFilters() {
    final search =
        _desktopSearchController.text.trim().toLowerCase();

    final result = _milkEntries.where((milk) {
      final matchesSearch =
          search.isEmpty ||
          milk.animalTagNumber.toLowerCase().contains(search) ||
          milk.shift.toLowerCase().contains(search);

      final matchesShift =
          _desktopShiftFilter == 'सर्व' ||
          milk.shift == _desktopShiftFilter;

      return matchesSearch && matchesShift;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredMilkEntries = result;
    });
  }

  // ============================================================
  // CALCULATE
  // ============================================================

  void _calculateTotal() {
    final qty =
        double.tryParse(
              _qtyController.text.trim(),
            ) ??
            0.0;

    final rate =
        double.tryParse(
              _rateController.text.trim(),
            ) ??
            0.0;

    final total =
        qty * rate;

    if (!mounted) return;

    setState(() {
      _calculatedTotal = total;
    });
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
      helpText: 'दूध संकलन तारीख',
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
  // DUPLICATE SESSION GUARD
  // ============================================================

  bool _hasDuplicateSession({
    required String tag,
    required DateTime date,
    required String shift,
  }) {
    return _milkEntries.any((milk) {
      // The record currently being edited is allowed to keep its
      // own date/shift/tag combination.
      if (_editingMilk != null && milk.id == _editingMilk!.id) {
        return false;
      }

      return milk.animalTagNumber.trim().toUpperCase() ==
              tag.trim().toUpperCase() &&
          milk.date.year == date.year &&
          milk.date.month == date.month &&
          milk.date.day == date.day &&
          milk.shift == shift;
    });
  }

  // ============================================================
  // SAVE / UPDATE
  // ============================================================

  Future<void> _saveMilkRecord() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final qty =
        double.tryParse(
      _qtyController.text.trim(),
    );

    final fat =
        double.tryParse(
      _fatController.text.trim(),
    );

    final snf =
        double.tryParse(
      _snfController.text.trim(),
    );

    final rate =
        double.tryParse(
      _rateController.text.trim(),
    );

    if (_selectedAnimal == null) {
      _showMessage(
        'कृपया जनावर निवडा.',
        isError: true,
      );
      return;
    }

    if (qty == null ||
        qty <= 0 ||
        fat == null ||
        fat < 0 ||
        fat > 15 ||
        snf == null ||
        snf < 0 ||
        snf > 15 ||
        rate == null ||
        rate < 0) {
      _showMessage(
        'प्रमाण, FAT, SNF आणि दर योग्य पद्धतीने भरा.',
        isError: true,
      );
      return;
    }

    final tag = _selectedAnimal!.tagNumber.trim().toUpperCase();

    if (_hasDuplicateSession(
      tag: tag,
      date: _selectedDate,
      shift: _shift,
    )) {
      _showMessage(
        '$tag साठी ${_formatDate(_selectedDate)} • $_shift ची नोंद आधीच आहे.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final milkRecord =
          MilkModel(
        animalFirebaseId: _selectedAnimal!.firebaseId?.trim(),
        animalTagNumber: tag,
        date: _selectedDate,
        shift: _shift,
        quantityInLiters: qty,
        fat: fat,
        snf: snf,
        ratePerLiter: rate,
        totalPrice:
            _calculatedTotal,
      );

      // IMPORTANT:
      // Edit असल्यास existing Isar ID + Firebase ID
      // preserve करणे आवश्यक आहे.
      if (_editingMilk != null) {
        milkRecord.id =
            _editingMilk!.id;

        milkRecord.firebaseId =
            _editingMilk!.firebaseId;

        milkRecord.lastSyncAt =
            _editingMilk!.lastSyncAt;
      }

      await _repository
          .addMilkEntry(
        milkRecord,
      );

      if (!mounted) return;

      final wasEditing =
          _editingMilk != null;

      setState(() {
        _editingMilk = null;
        _isSaving = false;
      });

      _resetForm();

      await _loadMilkEntries();

      if (!mounted) return;

      _showMessage(
        wasEditing
            ? 'दुधाची नोंद अपडेट झाली.'
            : 'दुधाची नोंद यशस्वीरीत्या सेव्ह झाली.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'दूध नोंद सेव्ह करताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // EDIT
  // ============================================================

  Future<void> _editMilkEntry(
    MilkModel milk,
  ) async {
    AnimalModel? animal;

    try {
      final animals =
          await _animalRepository.getAllAnimals();

      final animalFirebaseId = milk.animalFirebaseId?.trim();

      if (animalFirebaseId != null && animalFirebaseId.isNotEmpty) {
        for (final candidate in animals) {
          if (candidate.firebaseId?.trim() == animalFirebaseId) {
            animal = candidate;
            break;
          }
        }
      }

      // Backward compatibility for older milk records that were created
      // before animalFirebaseId was added.
      if (animal == null) {
        for (final candidate in animals) {
          if (candidate.tagNumber.trim().toLowerCase() ==
              milk.animalTagNumber.trim().toLowerCase()) {
            animal = candidate;
            break;
          }
        }
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'जनावरांची यादी मिळवता आली नाही.\n$e',
        isError: true,
      );
      return;
    }

    if (!mounted) return;

    if (animal == null) {
      _showMessage(
        '${milk.animalTagNumber} हे जनावर Animal Master मध्ये सापडले नाही.',
        isError: true,
      );
      return;
    }

    setState(() {
      _editingMilk = milk;
      _selectedAnimal = animal;

      _tagController.text =
          milk.animalTagNumber;

      _qtyController.text =
          milk.quantityInLiters
              .toString();

      _fatController.text =
          milk.fat.toString();

      _snfController.text =
          milk.snf.toString();

      _rateController.text =
          milk.ratePerLiter.toString();

      _shift = milk.shift;

      _selectedDate = milk.date;

      _calculatedTotal =
          milk.totalPrice;
    });

    _showMessage(
      'नोंद Edit करण्यासाठी form मध्ये भरली आहे.',
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteMilkEntry(
    MilkModel milk,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'दुधाची नोंद हटवायची?',
          ),
          content: Text(
            '${milk.animalTagNumber} ची '
            '${_formatDate(milk.date)} '
            'दुधाची नोंद कायमची हटवली जाईल.',
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
          await _repository
              .deleteMilkEntry(
        milk,
      );

      if (!mounted) return;

      if (success) {
        // जर delete केलेली entry edit mode मध्ये असेल
        if (_editingMilk?.id == milk.id) {
          _resetForm();
          setState(() {
            _editingMilk = null;
          });
        }

        await _loadMilkEntries();

        if (!mounted) return;

        _showMessage(
          'दुधाची नोंद हटवली.',
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
        'दुधाची नोंद हटवताना त्रुटी आली.\n$e',
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
        currentIndex: 2,
        title: 'दूध',
        subtitle: 'Milk Collection Management',
        actions: [
          IconButton(
            tooltip: 'Refresh milk entries',
            onPressed:
                _isLoadingEntries ? null : _loadMilkEntries,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: _isSaving ? null : _resetForm,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('नवीन दूध नोंद'),
          ),
          const SizedBox(width: 8),
        ],
        onDestinationSelected: _handleDesktopNavigation,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadMilkEntries,
          child: _isLoadingEntries
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _buildDesktopContent(),
        ),
      );
    }

    // Existing mobile UI is preserved.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _editingMilk == null
              ? 'दूध संकलन नोंद'
              : 'दूध नोंद Edit',
        ),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: _isSaving ? null : _resetForm,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildAnimalSection(),
              const SizedBox(height: 14),
              _buildDateShiftSection(),
              const SizedBox(height: 14),
              _buildMilkQuantitySection(),
              const SizedBox(height: 14),
              _buildQualitySection(),
              const SizedBox(height: 14),
              _buildRateSection(),
              const SizedBox(height: 18),
              _buildTotalCard(),
              const SizedBox(height: 20),
              _buildSaveButton(),
              if (_editingMilk != null) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _isSaving ? null : _resetForm,
                  child: const Text('Edit रद्द करा'),
                ),
              ],
              const SizedBox(height: 30),
              _buildMilkEntriesSection(),
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
                constraints: const BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    _buildDesktopIntro(),
                    const SizedBox(height: 18),
                    _buildDesktopSummary(),
                    const SizedBox(height: 18),
                    _buildDesktopWorkspace(),
                    const SizedBox(height: 18),
                    _buildDesktopEntries(
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
                'दूध संकलन व्यवस्थापन',
                style: TextStyle(
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'जनावरनिहाय दूध, शिफ्ट, गुणवत्ता, दर आणि एकूण रक्कम एका ठिकाणी व्यवस्थापित करा.',
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
          value: '${_milkEntries.length}',
          color: AppColors.primary,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.divider,
        ),
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
    final today = DateTime.now();

    final todayEntries = _milkEntries.where(
      (milk) =>
          milk.date.year == today.year &&
          milk.date.month == today.month &&
          milk.date.day == today.day,
    );

    final todayTotal = todayEntries.fold<double>(
      0,
      (sum, milk) => sum + milk.quantityInLiters,
    );

    final morningTotal = todayEntries
        .where((milk) => milk.shift == 'सकाळ')
        .fold<double>(
          0,
          (sum, milk) => sum + milk.quantityInLiters,
        );

    final eveningTotal = todayEntries
        .where((milk) => milk.shift == 'संध्याकाळ')
        .fold<double>(
          0,
          (sum, milk) => sum + milk.quantityInLiters,
        );

    final todayValue = todayEntries.fold<double>(
      0,
      (sum, milk) => sum + milk.totalPrice,
    );

    return Row(
      children: [
        Expanded(
          child: _desktopMetric(
            icon: Icons.water_drop_outlined,
            title: 'आजचे दूध',
            value:
                '${todayTotal.toStringAsFixed(1)} L',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.wb_sunny_outlined,
            title: 'सकाळ',
            value:
                '${morningTotal.toStringAsFixed(1)} L',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.nightlight_outlined,
            title: 'संध्याकाळ',
            value:
                '${eveningTotal.toStringAsFixed(1)} L',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.currency_rupee_rounded,
            title: 'आजची अंदाजित रक्कम',
            value:
                '₹${todayValue.toStringAsFixed(0)}',
            color: AppColors.success,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.divider,
        ),
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
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.water_drop_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _editingMilk == null
                        ? 'नवीन दूध संकलन नोंद'
                        : 'दूध नोंद Edit',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_editingMilk != null)
                  TextButton(
                    onPressed:
                        _isSaving ? null : _resetForm,
                    child: const Text(
                      'Edit रद्द करा',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _buildDesktopFormFields(),
            const SizedBox(height: 16),
            _buildDesktopTotal(),
            const SizedBox(height: 16),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFormFields() {
    return Column(
      children: [
        _buildAnimalSection(),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                onTap: _isSaving ? null : _selectDate,
                borderRadius:
                    BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'संकलन तारीख',
                    prefixIcon: Icon(
                      Icons.calendar_today_outlined,
                    ),
                  ),
                  child: Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _shift,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'सकाळ',
                    child: Text(
                      'सकाळ (Morning)',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'संध्याकाळ',
                    child: Text(
                      'संध्याकाळ (Evening)',
                    ),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _shift = value;
                        });
                      },
                decoration:
                    const InputDecoration(
                  labelText: 'शिफ्ट',
                  prefixIcon:
                      Icon(Icons.schedule_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDesktopNumberField(
                controller: _qtyController,
                label: 'प्रमाण (लिटर)',
                hint: '12.5',
                suffix: 'L',
                icon: Icons.water_drop_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'प्रमाण टाका';
                  }
                  final qty =
                      double.tryParse(value.trim());
                  if (qty == null || qty <= 0) {
                    return 'योग्य प्रमाण टाका';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDesktopNumberField(
                controller: _rateController,
                label: 'दर (₹ / लिटर)',
                hint: '42',
                suffix: '₹ / L',
                icon: Icons.currency_rupee_rounded,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'दर टाका';
                  }
                  final rate =
                      double.tryParse(value.trim());
                  if (rate == null || rate < 0) {
                    return 'योग्य दर टाका';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDesktopNumberField(
                controller: _fatController,
                label: 'FAT %',
                hint: '3.5',
                suffix: '%',
                icon: Icons.opacity_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'FAT टाका';
                  }
                  final fat =
                      double.tryParse(value.trim());
                  if (fat == null || fat < 0) {
                    return 'योग्य FAT टाका';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDesktopNumberField(
                controller: _snfController,
                label: 'SNF %',
                hint: '8.5',
                suffix: '%',
                icon: Icons.science_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'SNF टाका';
                  }
                  final snf =
                      double.tryParse(value.trim());
                  if (snf == null || snf < 0) {
                    return 'योग्य SNF टाका';
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

  Widget _buildDesktopNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixText: suffix,
      ),
      validator: validator,
    );
  }

  Widget _buildDesktopTotal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary
            .withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secondary
              .withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calculate_outlined,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'अंदाजित एकूण रक्कम',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '₹ ${_calculatedTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopQuickInfo() {
    final today = DateTime.now();
    final todayEntries = _milkEntries.where(
      (milk) =>
          milk.date.year == today.year &&
          milk.date.month == today.month &&
          milk.date.day == today.day,
    ).toList();

    final averageFat = todayEntries.isEmpty
        ? 0.0
        : todayEntries.fold<double>(
              0,
              (sum, milk) => sum + milk.fat,
            ) /
            todayEntries.length;

    final averageSnf = todayEntries.isEmpty
        ? 0.0
        : todayEntries.fold<double>(
              0,
              (sum, milk) => sum + milk.snf,
            ) /
            todayEntries.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Milk Overview',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'दूध संकलनाची माहिती पटकन तपासा आणि नोंदी शोधा.',
            style: TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _desktopSearchController,
            decoration: InputDecoration(
              hintText: 'Animal tag किंवा shift शोधा...',
              prefixIcon:
                  const Icon(Icons.search_rounded),
              suffixIcon:
                  _desktopSearchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed:
                              _desktopSearchController.clear,
                          icon: const Icon(
                            Icons.clear_rounded,
                          ),
                        ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _desktopShiftFilter,
            decoration: const InputDecoration(
              labelText: 'Shift filter',
              prefixIcon:
                  Icon(Icons.filter_alt_outlined),
            ),
            items: const [
              DropdownMenuItem(
                value: 'सर्व',
                child: Text('सर्व'),
              ),
              DropdownMenuItem(
                value: 'सकाळ',
                child: Text('सकाळ'),
              ),
              DropdownMenuItem(
                value: 'संध्याकाळ',
                child: Text('संध्याकाळ'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _desktopShiftFilter = value;
              });
              _applyDesktopFilters();
            },
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          _desktopInfoRow(
            Icons.opacity_outlined,
            'आजचा Average FAT',
            '${averageFat.toStringAsFixed(2)}%',
          ),
          _desktopInfoRow(
            Icons.science_outlined,
            'आजचा Average SNF',
            '${averageSnf.toStringAsFixed(2)}%',
          ),
          _desktopInfoRow(
            Icons.receipt_long_outlined,
            'आजच्या नोंदी',
            '${todayEntries.length}',
          ),
          const SizedBox(height: 12),
          const Text(
            'Calculation',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'एकूण रक्कम = प्रमाण (L) × दर (₹/L). FAT आणि SNF नोंद स्वतंत्रपणे जतन केली जाते.',
            style: TextStyle(
              fontSize: 9.5,
              height: 1.45,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
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
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopEntries(int columns) {
    if (_filteredMilkEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: 60,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.divider,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 42,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 10),
            Text(
              'या filter साठी कोणतीही दूध नोंद नाही.',
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
            (constraints.maxWidth -
                    ((columns - 1) * gap)) /
                columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _filteredMilkEntries
              .map(
                (milk) => SizedBox(
                  width: cardWidth,
                  child: _buildDesktopMilkCard(milk),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildDesktopMilkCard(MilkModel milk) {
    final isMorning = milk.shift == 'सकाळ';
    final shiftColor =
        isMorning ? AppColors.warning : AppColors.secondary;

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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      milk.animalTagNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(milk.date),
                      style: const TextStyle(
                        fontSize: 9.5,
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: shiftColor
                      .withValues(alpha: 0.09),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  milk.shift,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: shiftColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _desktopMilkValue(
                  'प्रमाण',
                  '${milk.quantityInLiters.toStringAsFixed(1)} L',
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _desktopMilkValue(
                  'FAT',
                  '${milk.fat}%',
                  AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _desktopMilkValue(
                  'SNF',
                  '${milk.snf}%',
                  AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _desktopMilkValue(
                  'दर',
                  '₹${milk.ratePerLiter}',
                  AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: _desktopMilkValue(
                  'एकूण',
                  '₹${milk.totalPrice.toStringAsFixed(2)}',
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => _editMilkEntry(milk),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                ),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => _deleteMilkEntry(milk),
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

  Widget _desktopMilkValue(
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8.5,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  // HEADER
  // ============================================================

  Widget _buildHeaderCard() {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.primary,
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(20),
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
              Icons.local_drink_outlined,
              color: Colors.white,
              size: 28,
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
                  _editingMilk == null
                      ? 'दूध संकलन'
                      : 'दूध नोंद Edit',
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
                  'Milk Collection Entry',
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
  // ANIMAL
  // ============================================================

  Widget _buildAnimalSection() {
    return _sectionCard(
      title: 'जनावराची माहिती',
      icon: Icons.pets_outlined,
      children: [
        AnimalSelector(
          initialAnimal: _selectedAnimal,
          activeOnly: false,
          onChanged: (animal) {
            setState(() {
              _selectedAnimal = animal;
            });
          },
          validator: (animal) {
            if (animal == null) {
              return 'कृपया जनावर निवडा.';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ============================================================
  // DATE + SHIFT
  // ============================================================

  Widget _buildDateShiftSection() {
    return _sectionCard(
      title: 'संकलन माहिती',
      icon:
          Icons.calendar_month_outlined,
      children: [
        InkWell(
          onTap: _selectDate,
          borderRadius:
              BorderRadius.circular(12),
          child: InputDecorator(
            decoration:
                const InputDecoration(
              labelText:
                  'संकलन तारीख',
              prefixIcon: Icon(
                Icons.calendar_today_outlined,
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

        const SizedBox(
          height: 13,
        ),

        DropdownButtonFormField<
            String>(
          initialValue: _shift,
          isExpanded: true,
          items: const [
            DropdownMenuItem(
              value: 'सकाळ',
              child: Text(
                'सकाळ (Morning)',
              ),
            ),
            DropdownMenuItem(
              value: 'संध्याकाळ',
              child: Text(
                'संध्याकाळ (Evening)',
              ),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _shift = value;
            });
          },
          decoration:
              const InputDecoration(
            labelText: 'शिफ्ट',
            prefixIcon: Icon(
              Icons.schedule_outlined,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUANTITY
  // ============================================================

  Widget _buildMilkQuantitySection() {
    return _sectionCard(
      title: 'दुधाचे प्रमाण',
      icon:
          Icons.water_drop_outlined,
      children: [
        TextFormField(
          controller:
              _qtyController,
          keyboardType:
              const TextInputType
                  .numberWithOptions(
            decimal: true,
          ),
          decoration:
              const InputDecoration(
            labelText:
                'प्रमाण (लिटर)',
            hintText: 'उदा. 12.5',
            prefixIcon: Icon(
              Icons.water_drop_outlined,
            ),
            suffixText: 'L',
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'प्रमाण टाका';
            }

            final qty =
                double.tryParse(
              value.trim(),
            );

            if (qty == null ||
                qty <= 0) {
              return 'योग्य प्रमाण टाका';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ============================================================
  // QUALITY
  // ============================================================

  Widget _buildQualitySection() {
    return _sectionCard(
      title: 'दुधाची गुणवत्ता',
      icon:
          Icons.science_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child:
                  TextFormField(
                controller:
                    _fatController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText: 'FAT %',
                  hintText: '3.5',
                  prefixIcon:
                      Icon(
                    Icons.opacity_outlined,
                  ),
                  suffixText: '%',
                ),
                validator:
                    (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'FAT टाका';
                  }

                  final fat =
                      double.tryParse(
                    value.trim(),
                  );

                  if (fat == null ||
                      fat < 0) {
                    return 'योग्य FAT टाका';
                  }

                  return null;
                },
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child:
                  TextFormField(
                controller:
                    _snfController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText: 'SNF %',
                  hintText: '8.5',
                  prefixIcon:
                      Icon(
                    Icons.science_outlined,
                  ),
                  suffixText: '%',
                ),
                validator:
                    (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'SNF टाका';
                  }

                  final snf =
                      double.tryParse(
                    value.trim(),
                  );

                  if (snf == null ||
                      snf < 0) {
                    return 'योग्य SNF टाका';
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

  // ============================================================
  // RATE
  // ============================================================

  Widget _buildRateSection() {
    return _sectionCard(
      title: 'दुधाचा दर',
      icon:
          Icons.currency_rupee_rounded,
      children: [
        TextFormField(
          controller:
              _rateController,
          keyboardType:
              const TextInputType
                  .numberWithOptions(
            decimal: true,
          ),
          decoration:
              const InputDecoration(
            labelText:
                'दर (₹ / लिटर)',
            hintText: 'उदा. 42',
            prefixIcon:
                Icon(
              Icons.currency_rupee_rounded,
            ),
            suffixText: '₹ / L',
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'दर टाका';
            }

            final rate =
                double.tryParse(
              value.trim(),
            );

            if (rate == null ||
                rate < 0) {
              return 'योग्य दर टाका';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ============================================================
  // TOTAL
  // ============================================================

  Widget _buildTotalCard() {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color:
            AppColors.secondary
                .withValues(
          alpha: 0.07,
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              AppColors.secondary
                  .withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.calculate_outlined,
                color:
                    AppColors.secondary,
              ),
              const SizedBox(
                width: 8,
              ),
              const Expanded(
                child: Text(
                  'अंदाजित एकूण रक्कम',
                  style:
                      TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '₹ ${_calculatedTotal.toStringAsFixed(2)}',
                style:
                    const TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.w900,
                  color:
                      AppColors.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          const Divider(),

          const SizedBox(
            height: 5,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Text(
                '${_qtyController.text.isEmpty ? '0' : _qtyController.text} L',
                style:
                    const TextStyle(
                  fontSize: 11,
                  color: AppColors
                      .textSecondary,
                ),
              ),
              const Text(
                '×',
                style:
                    TextStyle(
                  fontSize: 12,
                  color: AppColors
                      .textTertiary,
                ),
              ),
              Text(
                '₹ ${_rateController.text.isEmpty ? '0' : _rateController.text} / L',
                style:
                    const TextStyle(
                  fontSize: 11,
                  color: AppColors
                      .textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    final isEditing =
        _editingMilk != null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isSaving
            ? null
            : _saveMilkRecord,
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
                  ? 'दूध नोंद अपडेट करा'
                  : 'दूध नोंद सेव्ह करा',
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
  // MILK ENTRIES LIST
  // ============================================================

  Widget _buildMilkEntriesSection() {
    return _sectionCard(
      title:
          'दुधाच्या नोंदी (${_milkEntries.length})',
      icon:
          Icons.receipt_long_outlined,
      children: [
        if (_isLoadingEntries)
          const Padding(
            padding:
                EdgeInsets.all(20),
            child: Center(
              child:
                  CircularProgressIndicator(),
            ),
          )
        else if (_milkEntries.isEmpty)
          const Padding(
            padding:
                EdgeInsets.all(20),
            child: Center(
              child: Text(
                'अद्याप कोणतीही दूध नोंद उपलब्ध नाही.',
                style:
                    TextStyle(
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ..._milkEntries.map(
            _buildMilkEntryCard,
          ),
      ],
    );
  }

  // ============================================================
  // MILK ENTRY CARD
  // ============================================================

  Widget _buildMilkEntryCard(
    MilkModel milk,
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
                      AppColors.primary
                          .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  color:
                      AppColors.primary,
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
                      milk.animalTagNumber,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      '${_formatDate(milk.date)} • ${milk.shift}',
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
                '${milk.quantityInLiters.toStringAsFixed(1)} L',
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w900,
                  color:
                      AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Row(
            children: [
              Expanded(
                child: _buildSmallInfo(
                  'FAT',
                  '${milk.fat}%',
                ),
              ),
              Expanded(
                child: _buildSmallInfo(
                  'SNF',
                  '${milk.snf}%',
                ),
              ),
              Expanded(
                child: _buildSmallInfo(
                  'दर',
                  '₹${milk.ratePerLiter}',
                ),
              ),
              Expanded(
                child: _buildSmallInfo(
                  'एकूण',
                  '₹${milk.totalPrice.toStringAsFixed(2)}',
                ),
              ),
            ],
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
                        _editMilkEntry(
                          milk,
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
                        _deleteMilkEntry(
                          milk,
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

  Widget _buildSmallInfo(
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 9,
            color:
                AppColors.textTertiary,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          value,
          style:
              const TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget>
        children,
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
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primary
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
                      AppColors.primary,
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
    _tagController.clear();
    _qtyController.clear();
    _fatController.clear();
    _snfController.clear();
    _rateController.clear();

    setState(() {
      _shift = 'सकाळ';
      _selectedDate =
          DateTime.now();
      _calculatedTotal = 0.0;
      _editingMilk = null;
      _selectedAnimal = null;
    });
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