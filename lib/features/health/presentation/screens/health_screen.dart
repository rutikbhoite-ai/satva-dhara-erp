import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/desktop_app_shell.dart';
import '../../../../routing/routes.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

import '../../../../app/app_colors.dart';
import '../../../../core/widgets/animal_selector.dart';
import '../../../animals/data/animal_repository.dart';
import '../../../animals/data/models/animal_model.dart';
import '../../data/health_repository.dart';
import '../../data/models/health_model.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() =>
      _HealthScreenState();
}

class _HealthScreenState
    extends State<HealthScreen> {
  final HealthRepository _repository =
      HealthRepository();

  final AnimalRepository _animalRepository =
      AnimalRepository();

  final TextEditingController _searchController =
      TextEditingController();

  List<HealthModel> _records = [];
  List<HealthModel> _filteredRecords = [];

  bool _isLoading = true;

  String _selectedType = 'सर्व';

  final List<String> _types = [
    'लसीकरण',
    'आजारपण',
    'तपासणी',
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _applyFilters,
    );

    _loadHealthRecords();
  }

  @override
  void dispose() {
    _searchController.removeListener(
      _applyFilters,
    );

    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadHealthRecords() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data =
          await _repository
              .getAllHealthRecords();

      if (!mounted) return;

      setState(() {
        _records = data;
        _filteredRecords = data;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'आरोग्य नोंदी मिळवताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  void _applyFilters() {
    final search =
        _searchController.text
            .trim()
            .toLowerCase();

    final result =
        _records.where((record) {
      final matchesSearch =
          search.isEmpty ||
          record.animalTagNumber
              .toLowerCase()
              .contains(search) ||
          record.diagnosis
              .toLowerCase()
              .contains(search) ||
          record.treatment
              .toLowerCase()
              .contains(search);

      final matchesType =
          _selectedType == 'सर्व' ||
          record.type ==
              _selectedType;

      return matchesSearch &&
          matchesType;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredRecords = result;
    });
  }

  // ============================================================
  // FOLLOW-UP STATUS
  // ============================================================

  String _followUpStatus(
    HealthModel record,
  ) {
    final date =
        record.nextFollowUpDate;

    if (date == null) {
      return 'फॉलो-अप नाही';
    }

    final today =
        _dateOnly(DateTime.now());

    final followUp =
        _dateOnly(date);

    if (followUp.isBefore(today)) {
      return 'फॉलो-अप बाकी';
    }

    if (followUp.isAtSameMomentAs(
      today,
    )) {
      return 'आज फॉलो-अप';
    }

    final days =
        followUp
            .difference(today)
            .inDays;

    if (days <= 7) {
      return '7 दिवसांत';
    }

    if (days <= 30) {
      return '30 दिवसांत';
    }

    return 'आगामी';
  }

  // ============================================================
  // ADD RECORD
  // ============================================================

  Future<void> _showAddHealthDialog({
    HealthModel? editingRecord,
  }) async {
    AnimalModel? initialAnimal;

    if (editingRecord != null) {
      try {
        final animalFirebaseId =
            editingRecord.animalFirebaseId?.trim();

        // Primary relationship: stable Animal Master Firebase ID.
        if (animalFirebaseId != null &&
            animalFirebaseId.isNotEmpty) {
          initialAnimal =
              await _animalRepository.getAnimalByFirebaseId(
            animalFirebaseId,
          );
        }

        // Backward compatibility for older health records that were
        // created before animalFirebaseId was introduced.
        if (initialAnimal == null) {
          final animals =
              await _animalRepository.getAllAnimals();

          for (final animal in animals) {
            if (animal.tagNumber.trim().toLowerCase() ==
                editingRecord.animalTagNumber.trim().toLowerCase()) {
              initialAnimal = animal;
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
    }

    // Animal Master is loaded asynchronously for edit mode.
    // Guard the State before using the State-owned BuildContext below.
    if (!mounted) return;

    final diagnosisController = TextEditingController(
      text: editingRecord?.diagnosis ?? '',
    );
    final treatmentController = TextEditingController(
      text: editingRecord?.treatment ?? '',
    );
    final costController = TextEditingController(
      text: editingRecord == null
          ? ''
          : editingRecord.cost.toString(),
    );

    String type =
        editingRecord?.type ?? 'लसीकरण';
    DateTime treatmentDate =
        editingRecord?.date ?? DateTime.now();
    DateTime? nextFollowUpDate =
        editingRecord?.nextFollowUpDate;
    AnimalModel? selectedAnimal = initialAnimal;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickTreatmentDate() async {
              final selected = await showDatePicker(
                context: context,
                initialDate: treatmentDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                helpText: 'उपचार / लसीकरण तारीख',
                cancelText: 'रद्द',
                confirmText: 'निवडा',
              );

              if (selected == null) return;

              setSheetState(() {
                treatmentDate = selected;
              });
            }

            Future<void> pickFollowUpDate() async {
              final selected = await showDatePicker(
                context: context,
                initialDate:
                    nextFollowUpDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                helpText: 'पुढील फॉलो-अप तारीख',
                cancelText: 'रद्द',
                confirmText: 'निवडा',
              );

              if (selected == null) return;

              setSheetState(() {
                nextFollowUpDate = selected;
              });
            }

            Future<void> saveRecord() async {
              final diagnosis =
                  diagnosisController.text.trim();
              final treatment =
                  treatmentController.text.trim();
              final cost =
                  double.tryParse(
                costController.text.trim(),
              );

              if (selectedAnimal == null ||
                  diagnosis.isEmpty ||
                  treatment.isEmpty ||
                  cost == null ||
                  cost < 0) {
                _showMessage(
                  'कृपया सर्व माहिती योग्य प्रकारे भरा.',
                  isError: true,
                );
                return;
              }

              setSheetState(() {
                isSaving = true;
              });

              try {
                final record = HealthModel(
                  animalFirebaseId:
                      selectedAnimal!.firebaseId,
                  animalTagNumber:
                      selectedAnimal!.tagNumber
                          .trim()
                          .toUpperCase(),
                  date: treatmentDate,
                  type: type,
                  diagnosis: diagnosis,
                  treatment: treatment,
                  cost: cost,
                  nextFollowUpDate:
                      nextFollowUpDate,
                );

                if (editingRecord != null) {
                  record.id = editingRecord.id;
                  record.firebaseId =
                      editingRecord.firebaseId;
                  record.animalFirebaseId =
                      selectedAnimal!.firebaseId ??
                      editingRecord.animalFirebaseId;
                  record.lastSyncAt =
                      editingRecord.lastSyncAt;
                }

                await _repository.addHealthRecord(record);

                if (!mounted ||
                    !sheetContext.mounted) {
                  return;
                }

                Navigator.pop(sheetContext);

                await _loadHealthRecords();

                if (!mounted) return;

                _showMessage(
                  editingRecord == null
                      ? 'आरोग्य नोंद सेव्ह झाली.'
                      : 'आरोग्य नोंद अपडेट झाली.',
                );
              } catch (e) {
                if (!sheetContext.mounted) return;

                setSheetState(() {
                  isSaving = false;
                });

                _showMessage(
                  'आरोग्य नोंद सेव्ह करताना त्रुटी आली.\n$e',
                  isError: true,
                );
              }
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 10,
                  bottom:
                      MediaQuery.viewInsetsOf(context)
                          .bottom +
                          18,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                AppColors.textTertiary,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        editingRecord == null
                            ? 'आरोग्य / लसीकरण नोंद'
                            : 'आरोग्य नोंद Edit',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AnimalSelector(
                        initialAnimal: selectedAnimal,
                        onChanged: (animal) {
                          setSheetState(() {
                            selectedAnimal = animal;
                          });
                        },
                        validator: (animal) {
                          if (animal == null) {
                            return 'कृपया जनावर निवडा.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 13),
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'लसीकरण',
                            child: Text(
                              'लसीकरण (Vaccination)',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'आजारपण',
                            child: Text(
                              'आजारपण / उपचार',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'तपासणी',
                            child: Text(
                              'रूटीन तपासणी',
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setSheetState(() {
                            type = value;
                          });
                        },
                        decoration:
                            const InputDecoration(
                          labelText: 'प्रकार',
                          prefixIcon: Icon(
                            Icons
                                .medical_services_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      InkWell(
                        onTap: pickTreatmentDate,
                        borderRadius:
                            BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(
                            labelText:
                                'उपचार / लसीकरण तारीख',
                            prefixIcon: Icon(
                              Icons
                                  .calendar_today_outlined,
                            ),
                          ),
                          child: Text(
                            _formatDate(treatmentDate),
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      TextFormField(
                        controller: diagnosisController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'आजार / लसीचे नाव',
                          hintText: 'उदा. FMD लस',
                          prefixIcon: Icon(
                            Icons.vaccines_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      TextFormField(
                        controller: treatmentController,
                        maxLines: 2,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'दिलेले औषध / उपचार',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                              bottom: 20,
                            ),
                            child: Icon(
                              Icons
                                  .medication_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      TextFormField(
                        controller: costController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText: 'उपचार खर्च (₹)',
                          prefixIcon: Icon(
                            Icons
                                .currency_rupee_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      InkWell(
                        onTap: pickFollowUpDate,
                        borderRadius:
                            BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(
                            labelText:
                                'पुढील फॉलो-अप तारीख',
                            prefixIcon: Icon(
                              Icons
                                  .event_available_outlined,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  nextFollowUpDate == null
                                      ? 'तारीख निवडलेली नाही'
                                      : _formatDate(
                                          nextFollowUpDate!,
                                        ),
                                ),
                              ),
                              if (nextFollowUpDate != null)
                                IconButton(
                                  onPressed: () {
                                    setSheetState(() {
                                      nextFollowUpDate =
                                          null;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed:
                              isSaving ? null : saveRecord,
                          icon: isSaving
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
                                  editingRecord == null
                                      ? Icons.save_rounded
                                      : Icons.update_rounded,
                                ),
                          label: Text(
                            isSaving
                                ? 'सेव्ह होत आहे...'
                                : editingRecord == null
                                    ? 'नोंद सेव्ह करा'
                                    : 'नोंद अपडेट करा',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editHealthRecord(
    HealthModel record,
  ) async {
    await _showAddHealthDialog(
      editingRecord: record,
    );
  }

  Future<void> _deleteHealthRecord(
    HealthModel record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'आरोग्य नोंद हटवायची?',
          ),
          content: Text(
            '${record.animalTagNumber} • '
            '${record.diagnosis}\n'
            '${_formatDate(record.date)}',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('रद्द'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('हटवा'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final success =
          await _repository.deleteHealthRecord(record);

      if (!mounted) return;

      if (success) {
        await _loadHealthRecords();

        if (!mounted) return;

        _showMessage('आरोग्य नोंद हटवली.');
      } else {
        _showMessage(
          'Firebase मधून नोंद हटवता आली नाही. '
          'Local record सुरक्षित आहे.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'आरोग्य नोंद हटवताना त्रुटी आली.\n$e',
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
        currentIndex: 5,
        title: 'आरोग्य',
        subtitle: 'Animal Health',
        actions: [
          IconButton(
            tooltip: 'Refresh health records',
            onPressed: _isLoading ? null : _loadHealthRecords,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => _showAddHealthDialog(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('नवीन आरोग्य नोंद'),
          ),
          const SizedBox(width: 8),
        ],
        onDestinationSelected: _handleDesktopNavigation,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadHealthRecords,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _buildDesktopContent(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('आरोग्य व लसीकरण'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadHealthRecords,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadHealthRecords,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _buildContent(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHealthDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('आरोग्य नोंद'),
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
        final contentWidth = constraints.maxWidth > maxWidth
            ? maxWidth
            : constraints.maxWidth;

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
                    _buildDesktopToolbar(),
                    const SizedBox(height: 18),
                    if (_filteredRecords.isEmpty)
                      _buildEmptyState()
                    else
                      _buildDesktopHealthGrid(contentWidth),
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
                'आरोग्य व लसीकरण',
                style: TextStyle(
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'जनावरांचे उपचार, लसीकरण आणि follow-up एका ठिकाणी व्यवस्थापित करा.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _desktopCountPill(
          icon: Icons.health_and_safety_outlined,
          label: 'एकूण नोंदी',
          value: '${_records.length}',
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
    final vaccinationCount =
        _records.where((record) => record.type == 'लसीकरण').length;
    final treatmentCount =
        _records.where((record) => record.type == 'आजारपण').length;
    final checkupCount =
        _records.where((record) => record.type == 'तपासणी').length;

    final followUpDue = _records.where((record) {
      final status = _followUpStatus(record);
      return status == 'फॉलो-अप बाकी' || status == 'आज फॉलो-अप';
    }).length;

    return Row(
      children: [
        Expanded(
          child: _desktopMetric(
            icon: Icons.vaccines_outlined,
            title: 'लसीकरण',
            value: '$vaccinationCount',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.medical_services_outlined,
            title: 'उपचार',
            value: '$treatmentCount',
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.health_and_safety_outlined,
            title: 'तपासणी',
            value: '$checkupCount',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.notifications_active_outlined,
            title: 'Follow-up बाकी',
            value: '$followUpDue',
            color: followUpDue > 0
                ? AppColors.warning
                : AppColors.success,
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
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopToolbar() {
    return Row(
      children: [
        Expanded(child: _buildSearch()),
        const SizedBox(width: 12),
        SizedBox(
          width: 210,
          child: _buildTypeFilter(),
        ),
      ],
    );
  }

  Widget _buildDesktopHealthGrid(double width) {
    const gap = 14.0;
    final columns = width >= 1350 ? 3 : 2;
    final cardWidth =
        (width - ((columns - 1) * gap)) / columns;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: _filteredRecords.map((record) {
        return SizedBox(
          width: cardWidth,
          child: _buildHealthCard(record),
        );
      }).toList(),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(16),
      children: [
        _buildSummary(),

        const SizedBox(
          height: 16,
        ),

        _buildSearch(),

        const SizedBox(
          height: 12,
        ),

        _buildTypeFilter(),

        const SizedBox(
          height: 16,
        ),

        if (_filteredRecords.isEmpty)
          _buildEmptyState()
        else
          ..._filteredRecords.map(
            (record) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              child:
                  _buildHealthCard(
                record,
              ),
            ),
          ),

        const SizedBox(
          height: 90,
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    final vaccinationCount =
        _records.where(
      (record) =>
          record.type ==
          'लसीकरण',
    ).length;

    final treatmentCount =
        _records.where(
      (record) =>
          record.type ==
          'आजारपण',
    ).length;

    final followUpDue =
        _records.where(
      (record) {
        final status =
            _followUpStatus(
          record,
        );

        return status ==
                'फॉलो-अप बाकी' ||
            status ==
                'आज फॉलो-अप';
      },
    ).length;

    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'आरोग्य आढावा',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          const Text(
            'Animal Health Overview',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  Icons.vaccines_outlined,
                  'लसीकरण',
                  '$vaccinationCount',
                ),
              ),
              Expanded(
                child: _summaryItem(
                  Icons
                      .medical_services_outlined,
                  'उपचार',
                  '$treatmentCount',
                ),
              ),
              Expanded(
                child: _summaryItem(
                  Icons
                      .notifications_active_outlined,
                  'फॉलो-अप',
                  '$followUpDue',
                ),
              ),
            ],
          ),

          if (followUpDue > 0) ...[
            const SizedBox(
              height: 14,
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .notifications_active_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      '$followUpDue आरोग्य नोंदींचा फॉलो-अप बाकी आहे.',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          value,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          label,
          style:
              const TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return TextField(
      controller:
          _searchController,
      decoration:
          InputDecoration(
        hintText:
            'टॅग, आजार किंवा उपचार शोधा...',
        prefixIcon:
            const Icon(
          Icons.search_rounded,
          color:
              AppColors.primary,
        ),
        suffixIcon:
            _searchController.text
                    .isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController
                          .clear();
                    },
                    icon:
                        const Icon(
                      Icons
                          .clear_rounded,
                    ),
                  )
                : null,
      ),
    );
  }

  // ============================================================
  // TYPE FILTER
  // ============================================================

  Widget _buildTypeFilter() {
    final types = [
      'सर्व',
      ..._types,
    ];

    return DropdownButtonFormField<
        String>(
      initialValue:
          _selectedType,
      isExpanded: true,
      items: types
          .map(
            (type) =>
                DropdownMenuItem<
                    String>(
              value: type,
              child: Text(
                type == 'सर्व'
                    ? 'प्रकार: सर्व'
                    : type,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _selectedType =
              value;
        });

        _applyFilters();
      },
      decoration:
          const InputDecoration(
        labelText:
            'प्रकार फिल्टर',
        prefixIcon:
            Icon(
          Icons.filter_alt_outlined,
        ),
      ),
    );
  }

  // ============================================================
  // HEALTH CARD
  // ============================================================

  Widget _buildHealthCard(
    HealthModel record,
  ) {
    final followUp =
        _followUpStatus(
      record,
    );

    final isFollowUpDue =
        followUp ==
                'फॉलो-अप बाकी' ||
            followUp ==
                'आज फॉलो-अप';

    final color =
        record.type ==
                'लसीकरण'
            ? AppColors.secondary
            : record.type ==
                    'आजारपण'
                ? AppColors.error
                : AppColors.primary;

    final icon =
        record.type ==
                'लसीकरण'
            ? Icons
                .vaccines_outlined
            : record.type ==
                    'आजारपण'
                ? Icons
                    .medical_services_outlined
                : Icons
                    .health_and_safety_outlined;

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
          color: isFollowUpDue
              ? AppColors.warning
                  .withValues(
                  alpha: 0.30,
                )
              : AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                  color: color
                      .withValues(
                    alpha: 0.09,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 25,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child:
                              Text(
                            '${record.animalTagNumber} • ${record.diagnosis}',
                            maxLines:
                                2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize:
                                  14,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        _typeChip(
                          record.type,
                          color,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Text(
                      'उपचार: ${record.treatment}',
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 10,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .calendar_today_outlined,
                          size: 12,
                          color: AppColors
                              .textTertiary,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          _formatDate(
                            record.date,
                          ),
                          style:
                              const TextStyle(
                            fontSize: 9,
                            color: AppColors
                                .textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          const Divider(
            height: 1,
          ),

          const SizedBox(
            height: 11,
          ),

          Row(
            children: [
              Expanded(
                child: _infoValue(
                  label: 'खर्च',
                  value:
                      '₹ ${record.cost.toStringAsFixed(0)}',
                  color:
                      AppColors.error,
                ),
              ),

              Expanded(
                child: _infoValue(
                  label: 'फॉलो-अप',
                  value:
                      record.nextFollowUpDate ==
                              null
                          ? 'नाही'
                          : _formatDate(
                              record
                                  .nextFollowUpDate!,
                            ),
                  color: isFollowUpDue
                      ? AppColors.warning
                      : AppColors
                          .textPrimary,
                ),
              ),

              if (record
                      .nextFollowUpDate !=
                  null)
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color: isFollowUpDue
                        ? AppColors
                            .warning
                            .withValues(
                            alpha:
                                0.09,
                          )
                        : AppColors
                            .primary
                            .withValues(
                            alpha:
                                0.08,
                          ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Text(
                    followUp,
                    style:
                        TextStyle(
                      fontSize: 8,
                      fontWeight:
                          FontWeight
                              .w800,
                      color:
                          isFollowUpDue
                              ? AppColors
                                  .warning
                              : AppColors
                                  .primary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          const Divider(height: 1),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () =>
                    _editHealthRecord(record),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                ),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () =>
                    _deleteHealthRecord(record),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                ),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeChip(
    String text,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration:
          BoxDecoration(
        color: color.withValues(
          alpha: 0.09,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        text,
        style:
            TextStyle(
          fontSize: 7,
          fontWeight:
              FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _infoValue({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(
            fontSize: 9,
            color: AppColors
                .textTertiary,
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          value,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    final hasFilter =
        _searchController.text
                .trim()
                .isNotEmpty ||
            _selectedType !=
                'सर्व';

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 45,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration:
                const BoxDecoration(
              color:
                  AppColors.primaryLight,
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .health_and_safety_outlined,
              color:
                  AppColors.primary,
              size: 34,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            hasFilter
                ? 'तुमच्या शोधानुसार नोंद सापडली नाही'
                : 'अद्याप आरोग्य नोंद उपलब्ध नाही',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            hasFilter
                ? 'Search किंवा filter बदलून पुन्हा प्रयत्न करा.'
                : 'पहिली आरोग्य किंवा लसीकरण नोंद जोडण्यासाठी खालील बटन वापरा.',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 12,
              color: AppColors
                  .textSecondary,
            ),
          ),

          if (hasFilter) ...[
            const SizedBox(
              height: 16,
            ),
            OutlinedButton.icon(
              onPressed: () {
                _searchController
                    .clear();

                setState(() {
                  _selectedType =
                      'सर्व';
                });

                _applyFilters();
              },
              icon: const Icon(
                Icons
                    .filter_alt_off_outlined,
              ),
              label: const Text(
                'Filter Clear करा',
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  DateTime _dateOnly(
    DateTime date,
  ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
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