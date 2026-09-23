import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';
import '../../../animals/data/animal_repository.dart';
import '../../../animals/data/models/animal_model.dart';
import '../../../../core/widgets/animal_selector.dart';
import '../../../../shared/widgets/desktop_app_shell.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

import '../../../../app/app_colors.dart';
import '../../data/models/pregnancy_model.dart';
import '../../data/pregnancy_repository.dart';

class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  final PregnancyRepository _repository =
      PregnancyRepository();

  final TextEditingController _searchController =
      TextEditingController();

  List<PregnancyModel> _records = [];
  List<PregnancyModel> _filteredRecords = [];

  bool _isLoading = true;

  String _selectedStatus = 'सर्व';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_applyFilters);

    _loadRecords();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadRecords() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data =
          await _repository.getAllPregnancyRecords();

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
        'प्रजनन नोंदी मिळवताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  void _applyFilters() {
    final search =
        _searchController.text.trim().toLowerCase();

    final result = _records.where((record) {
      final matchesSearch =
          search.isEmpty ||
          record.animalTagNumber
              .toLowerCase()
              .contains(search) ||
          record.bullOrSemenDetail
              .toLowerCase()
              .contains(search);

      final matchesStatus =
          _selectedStatus == 'सर्व' ||
          record.status == _selectedStatus;

      return matchesSearch &&
          matchesStatus;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredRecords = result;
    });
  }

  // ============================================================
  // EDD STATUS
  // ============================================================

  String _deliveryStatus(
    PregnancyModel record,
  ) {
    final edd = record.expectedDeliveryDate;

    if (edd == null) {
      return 'EDD नाही';
    }

    if (record.actualDeliveryDate != null) {
      return 'प्रसूती झाली';
    }

    final today = _dateOnly(DateTime.now());
    final deliveryDate = _dateOnly(edd);

    if (deliveryDate.isBefore(today)) {
      return 'EDD ओव्हरड्यू';
    }

    if (deliveryDate.isAtSameMomentAs(today)) {
      return 'आज EDD';
    }

    final days =
        deliveryDate.difference(today).inDays;

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

  Future<void> _showAddDialog({PregnancyModel? existingRecord}) async {
    final isEditing = existingRecord != null;

    final tagCtrl = TextEditingController(
      text: existingRecord?.animalTagNumber ?? '',
    );

    AnimalModel? selectedAnimal;

    if (existingRecord != null) {
      final animalRepository = AnimalRepository();

      // Prefer the permanent Animal Master Firebase ID.
      // Fall back to the historical tag for legacy records.
      final animalFirebaseId =
          existingRecord.animalFirebaseId?.trim();

      if (animalFirebaseId != null &&
          animalFirebaseId.isNotEmpty) {
        selectedAnimal = await animalRepository
            .getAnimalByFirebaseId(animalFirebaseId);
      }

      if (selectedAnimal == null) {
        final animals = await animalRepository.getAllAnimals();

        if (!mounted) return;

        for (final animal in animals) {
          if (animal.tagNumber.trim().toLowerCase() ==
              existingRecord.animalTagNumber.trim().toLowerCase()) {
            selectedAnimal = animal;
            break;
          }
        }
      }
    }

    // Animal lookup above contains async gaps.
    // Make sure this State is still mounted before using its BuildContext.
    if (!mounted) return;

    final semenCtrl = TextEditingController(
      text: existingRecord?.bullOrSemenDetail ?? '',
    );

    String status =
        existingRecord?.status ?? 'Pregnant (गाभण)';

    DateTime breedingDate =
        existingRecord?.breedingDate ?? DateTime.now();

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
          builder: (
            context,
            setSheetState,
          ) {
            Future<void> selectBreedingDate() async {
              final selected =
                  await showDatePicker(
                context: context,
                initialDate: breedingDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                helpText:
                    'रेतन / भरवल्याची तारीख',
                cancelText: 'रद्द',
                confirmText: 'निवडा',
              );

              if (selected == null) return;

              setSheetState(() {
                breedingDate = selected;
              });
            }

            Future<void> saveRecord() async {
              final tag =
                  selectedAnimal?.tagNumber.trim() ??
                  tagCtrl.text.trim();

              final semen =
                  semenCtrl.text.trim();

              if (selectedAnimal == null || tag.isEmpty) {
                _showMessage(
                  'कृपया Animal Master मधून जनावर निवडा.',
                  isError: true,
                );
                return;
              }

              if (semen.isEmpty) {
                _showMessage(
                  'सीमेन नंबर / बुल डिटेल टाका.',
                  isError: true,
                );
                return;
              }

              setSheetState(() {
                isSaving = true;
              });

              try {
                // अंदाजे 280 दिवस
                final edd =
                    breedingDate.add(
                  const Duration(days: 280),
                );

                final record = existingRecord ??
                    PregnancyModel(
                  animalFirebaseId:
                      selectedAnimal!.firebaseId,
                  animalTagNumber: tag,
                  breedingDate: breedingDate,
                  bullOrSemenDetail: semen,
                  status: status,
                  expectedDeliveryDate: edd,
                );

                // Permanent relationship to Animal Master.
                // animalTagNumber remains only as a historical/display snapshot.
                record.animalFirebaseId =
                    selectedAnimal!.firebaseId;
                record.animalTagNumber = tag;
                record.breedingDate = breedingDate;
                record.bullOrSemenDetail = semen;
                record.status = status;
                record.expectedDeliveryDate = edd;

                await _repository.addPregnancyRecord(
                  record,
                );

                if (!mounted || !sheetContext.mounted) return;

                Navigator.pop(
                  sheetContext,
                );

                await _loadRecords();

                _showMessage(
                  isEditing
                      ? 'प्रजनन नोंद अपडेट झाली.'
                      : 'प्रजनन नोंद सेव्ह झाली.',
                );
              } catch (e) {
                setSheetState(() {
                  isSaving = false;
                });

                _showMessage(
                  'नोंद सेव्ह करताना त्रुटी आली.\n$e',
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
                      MediaQuery.viewInsetsOf(
                            context,
                          ).bottom +
                          18,
                ),
                child:
                    SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration:
                              BoxDecoration(
                            color: AppColors
                                .textTertiary,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      Text(
                        isEditing
                            ? 'प्रजनन नोंद संपादित करा'
                            : 'प्रजनन / गाभण नोंद',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        isEditing
                            ? 'प्रजनन नोंदीतील माहिती अपडेट करा.'
                            : 'रेतन, सीमेन आणि अंदाजित प्रसूती तारीख व्यवस्थित नोंदवा.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors
                              .textSecondary,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      AnimalSelector(
                        initialAnimal: selectedAnimal,
                        activeOnly: false,
                        labelText: 'जनावर',
                        hintText: 'जनावर शोधा / निवडा',
                        validator: (animal) {
                          if (animal == null) {
                            return 'कृपया जनावर निवडा.';
                          }
                          return null;
                        },
                        onChanged: (animal) {
                          setSheetState(() {
                            selectedAnimal = animal;
                            tagCtrl.text =
                                animal?.tagNumber.trim() ?? '';
                          });
                        },
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      InkWell(
                        onTap:
                            selectBreedingDate,
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                        child:
                            InputDecorator(
                          decoration:
                              const InputDecoration(
                            labelText:
                                'रेतन / भरवल्याची तारीख',
                            prefixIcon:
                                Icon(
                              Icons
                                  .calendar_today_outlined,
                            ),
                          ),
                          child: Text(
                            _formatDate(
                              breedingDate,
                            ),
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      TextFormField(
                        controller:
                            semenCtrl,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'सीमेन नंबर / बुल डिटेल',
                          hintText:
                              'उदा. SEM-102',
                          prefixIcon:
                              Icon(
                            Icons
                                .science_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      DropdownButtonFormField<
                          String>(
                        initialValue:
                            status,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value:
                                'Pregnant (गाभण)',
                            child: Text(
                              'Pregnant (गाभण)',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'Pending Diagnosis',
                            child: Text(
                              'Pending (तपासणी बाकी)',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Failed',
                            child: Text(
                              'Failed (फिरली)',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Delivered',
                            child: Text(
                              'Delivered (प्रसूती झाली)',
                            ),
                          ),
                        ],
                        onChanged:
                            (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          setSheetState(
                            () {
                              status =
                                  value;
                            },
                          );
                        },
                        decoration:
                            const InputDecoration(
                          labelText:
                              'स्थिती',
                          prefixIcon:
                              Icon(
                            Icons
                                .pregnant_woman_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(
                          14,
                        ),
                        decoration:
                            BoxDecoration(
                          color: AppColors
                              .primary
                              .withValues(
                            alpha: 0.07,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                          border:
                              Border.all(
                            color: AppColors
                                .primary
                                .withValues(
                              alpha: 0.18,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .event_available_outlined,
                              color: AppColors
                                  .primary,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  const Text(
                                    'अंदाजित प्रसूती तारीख',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          10,
                                      color: AppColors
                                          .textSecondary,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    _formatDate(
                                      breedingDate.add(
                                        const Duration(
                                          days:
                                              280,
                                        ),
                                      ),
                                    ),
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          15,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                      color: AppColors
                                          .primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      const Text(
                        'EDD सध्या अंदाजे 280 दिवसांच्या आधारावर calculate केली जाते.',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors
                              .textTertiary,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        height: 50,
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              isSaving
                                  ? null
                                  : saveRecord,
                          icon: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .save_rounded,
                                ),
                          label: Text(
                            isSaving
                                ? 'सेव्ह होत आहे...'
                                : isEditing
                                    ? 'बदल सेव्ह करा'
                                    : 'नोंद सेव्ह करा',
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

  // ============================================================
  // DELETE RECORD
  // ============================================================

  Future<void> _deleteRecord(
    PregnancyModel record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('प्रजनन नोंद हटवायची?'),
          content: Text(
            '${record.animalTagNumber} ची प्रजनन नोंद कायमची हटवली जाईल.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('रद्द'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('हटवा'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final deleted =
          await _repository.deletePregnancyRecord(record);

      if (!mounted) return;

      if (deleted) {
        await _loadRecords();
        _showMessage('प्रजनन नोंद हटवली.');
      } else {
        _showMessage(
          'Firestore मधून नोंद हटवता आली नाही. '
          'Local record सुरक्षित ठेवला आहे.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'नोंद हटवताना त्रुटी आली.\n$e',
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
        currentIndex: 6,
        title: 'गाभण व प्रजनन',
        subtitle: 'Breeding & Pregnancy',
        actions: [
          IconButton(
            tooltip: 'Refresh pregnancy records',
            onPressed: _isLoading ? null : _loadRecords,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => _showAddDialog(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('नवीन प्रजनन नोंद'),
          ),
          const SizedBox(width: 8),
        ],
        onDestinationSelected: _handleDesktopNavigation,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadRecords,
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
        title: const Text('गाभण व प्रजनन'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadRecords,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadRecords,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _buildContent(width >= 850),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('प्रजनन नोंद'),
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
                      _buildDesktopPregnancyGrid(contentWidth),
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
                'गाभण व प्रजनन',
                style: TextStyle(
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Breeding records, EDD आणि delivery follow-up एका ठिकाणी व्यवस्थापित करा.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _desktopCountPill(
          icon: Icons.pregnant_woman_outlined,
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
    final pregnant = _records
        .where((record) => record.status == 'Pregnant (गाभण)')
        .length;

    final pending = _records
        .where((record) => record.status == 'Pending Diagnosis')
        .length;

    final delivered = _records
        .where((record) => record.status == 'Delivered')
        .length;

    final overdue = _records
        .where((record) => _deliveryStatus(record) == 'EDD ओव्हरड्यू')
        .length;

    return Row(
      children: [
        Expanded(
          child: _desktopMetric(
            icon: Icons.pregnant_woman_outlined,
            title: 'गाभण',
            value: '$pregnant',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.hourglass_empty_rounded,
            title: 'तपासणी बाकी',
            value: '$pending',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.event_busy_outlined,
            title: 'EDD Overdue',
            value: '$overdue',
            color: overdue > 0 ? AppColors.error : AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.child_friendly_outlined,
            title: 'प्रसूती झाली',
            value: '$delivered',
            color: AppColors.secondary,
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
          width: 235,
          child: _buildStatusFilter(),
        ),
      ],
    );
  }

  Widget _buildDesktopPregnancyGrid(double width) {
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
          child: _buildPregnancyCard(record),
        );
      }).toList(),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(bool isWide) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 16,
        vertical: 18,
      ),
      children: [
        _buildSummary(),

        const SizedBox(
          height: 18,
        ),

        _buildSearch(),

        const SizedBox(
          height: 12,
        ),

        _buildStatusFilter(),

        const SizedBox(
          height: 18,
        ),

        if (_filteredRecords.isEmpty)
          _buildEmptyState()
        else
          _buildRecordList(isWide),

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
    final pregnant =
        _records.where(
      (record) =>
          record.status ==
          'Pregnant (गाभण)',
    ).length;

    final pending =
        _records.where(
      (record) =>
          record.status ==
          'Pending Diagnosis',
    ).length;

    final overdue =
        _records.where(
      (record) =>
          _deliveryStatus(record) ==
          'EDD ओव्हरड्यू',
    ).length;

    final upcoming =
        _records.where(
      (record) {
        final status =
            _deliveryStatus(record);

        return status == '7 दिवसांत' ||
            status == '30 दिवसांत';
      },
    ).length;

    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'प्रजनन आढावा',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Breeding & Pregnancy Overview',
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
                  icon:
                      Icons.pregnant_woman_outlined,
                  label: 'गाभण',
                  value:
                      '$pregnant',
                ),
              ),
              Expanded(
                child: _summaryItem(
                  icon:
                      Icons.hourglass_empty_rounded,
                  label: 'तपासणी बाकी',
                  value:
                      '$pending',
                ),
              ),
              Expanded(
                child: _summaryItem(
                  icon:
                      Icons.event_busy_outlined,
                  label: 'EDD बाकी',
                  value:
                      '$overdue',
                ),
              ),
            ],
          ),

          if (upcoming > 0 ||
              overdue > 0) ...[
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
                    color:
                        Colors.white,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      overdue > 0
                          ? '$overdue EDD ओव्हरड्यू नोंदी आहेत.'
                          : '$upcoming जनावरांची प्रसूती तारीख जवळ आली आहे.',
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

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
      decoration: InputDecoration(
        hintText:
            'टॅग किंवा सीमेन नंबर शोधा...',
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
  // STATUS FILTER
  // ============================================================

  Widget _buildStatusFilter() {
    const statuses = [
      'सर्व',
      'Pregnant (गाभण)',
      'Pending Diagnosis',
      'Failed',
      'Delivered',
    ];

    return DropdownButtonFormField<String>(
      initialValue:
          _selectedStatus,
      isExpanded: true,
      items: statuses
          .map(
            (status) =>
                DropdownMenuItem<
                    String>(
              value: status,
              child: Text(
                status == 'सर्व'
                    ? 'स्थिती: सर्व'
                    : status,
                overflow:
                    TextOverflow
                        .ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _selectedStatus =
              value;
        });

        _applyFilters();
      },
      decoration:
          const InputDecoration(
        labelText:
            'स्थिती फिल्टर',
        prefixIcon:
            Icon(
          Icons.filter_alt_outlined,
        ),
      ),
    );
  }

  // ============================================================
  // LIST
  // ============================================================

  Widget _buildRecordList(
    bool isWide,
  ) {
    if (isWide) {
      return GridView.builder(
        itemCount:
            _filteredRecords
                .length,
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 500,
          mainAxisExtent: 185,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder:
            (context, index) {
          return _buildPregnancyCard(
            _filteredRecords[index],
          );
        },
      );
    }

    return Column(
      children:
          _filteredRecords
              .map(
                (record) =>
                    Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    bottom: 10,
                  ),
                  child:
                      _buildPregnancyCard(
                    record,
                  ),
                ),
              )
              .toList(),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildPregnancyCard(
    PregnancyModel record,
  ) {
    final deliveryStatus =
        _deliveryStatus(record);

    final isOverdue =
        deliveryStatus ==
            'EDD ओव्हरड्यू';

    final isNear =
        deliveryStatus ==
                '7 दिवसांत' ||
            deliveryStatus ==
                'आज EDD';

    final statusColor =
        record.status ==
                'Pregnant (गाभण)'
            ? AppColors.primary
            : record.status ==
                    'Failed'
                ? AppColors.error
                : record.status ==
                        'Delivered'
                    ? AppColors.secondary
                    : AppColors.warning;

    final deliveryColor =
        isOverdue
            ? AppColors.error
            : isNear
                ? AppColors.warning
                : AppColors.primary;

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
          color: isOverdue
              ? AppColors.error
                  .withValues(
                  alpha: 0.30,
                )
              : AppColors.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                BoxDecoration(
              color: statusColor
                  .withValues(
                alpha: 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              Icons
                  .pregnant_woman_outlined,
              color:
                  statusColor,
              size: 26,
            ),
          ),

          const SizedBox(
            width: 13,
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
                      child: Text(
                        record
                            .animalTagNumber,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight
                                  .w800,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    _statusChip(
                      record.status,
                      statusColor,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  'सीमेन / बुल: ${record.bullOrSemenDetail}',
                  maxLines: 1,
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
                  height: 5,
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
                      'रेतन: ${_formatDate(record.breedingDate)}',
                      style:
                          const TextStyle(
                        fontSize: 9,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),
                  ],
                ),

                if (record
                        .expectedDeliveryDate !=
                    null) ...[
                  const SizedBox(
                    height: 8,
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          deliveryColor
                              .withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOverdue
                              ? Icons
                                  .warning_amber_rounded
                              : Icons
                                  .event_available_outlined,
                          size: 14,
                          color:
                              deliveryColor,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            'EDD: ${_formatDate(record.expectedDeliveryDate!)} • $deliveryStatus',
                            style:
                                TextStyle(
                              fontSize:
                                  9,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color:
                                  deliveryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showAddDialog(
                            existingRecord: record,
                          ),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                          ),
                          label: const Text('संपादित करा'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteRecord(record),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                          ),
                          label: const Text('हटवा'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(
                              color: AppColors.error
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
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
        style: TextStyle(
          fontSize: 7,
          fontWeight:
              FontWeight.w800,
          color: color,
        ),
      ),
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
            _selectedStatus !=
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
                  .pregnant_woman_outlined,
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
                : 'अद्याप प्रजनन नोंद उपलब्ध नाही',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
              color: AppColors
                  .textPrimary,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            hasFilter
                ? 'Search किंवा filter बदलून पुन्हा प्रयत्न करा.'
                : 'पहिली प्रजनन नोंद जोडण्यासाठी खालील बटन वापरा.',
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
                  _selectedStatus =
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