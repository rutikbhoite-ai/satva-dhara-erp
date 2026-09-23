import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/desktop_app_shell.dart';
import '../../../../routing/routes.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

import '../../../../app/app_colors.dart';
import '../../data/animal_repository.dart';
import '../../data/models/animal_model.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  // ============================================================
  // CONSTANT OPTIONS
  // ============================================================

  static const List<String> _breedOptions = [
    'HF',
    'Jersey',
    'Gir',
    'Sahiwal',
    'Red Sindhi',
    'Jaffarabadi',
    'Murrah',
    'Mehsana',
  ];

  /// Animal source / farm entry options.
  static const List<String> _sourceTypes = [
    'born_on_farm',
    'purchased',
    'transferred',
    'unknown',
  ];

  /// Pregnancy status options.
  static const List<String> _pregnancyStatuses = [
    'not_pregnant',
    'pregnant',
    'unknown',
  ];

  final AnimalRepository _repository = AnimalRepository();

  final TextEditingController _searchController =
      TextEditingController();

  List<AnimalModel> _animals = [];
  List<AnimalModel> _filteredAnimals = [];

  bool _isLoading = true;

  String _selectedType = 'सर्व';
  String _selectedStatus = 'सर्व';

  final List<String> _types = [
    'गाय',
    'म्हैस',
  ];

  final List<String> _statuses = [
    'Active',
    'Sold',
    'Deceased',
  ];

  // ============================================================
  // INIT / DISPOSE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_applyFilters);

    _loadAnimals();
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

  Future<void> _loadAnimals() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data = await _repository.getAllAnimals();

      if (!mounted) return;

      setState(() {
        _animals = data;
        _filteredAnimals = data;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'जनावरांची माहिती मिळवताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  void _applyFilters() {
    final search = _searchController.text.trim().toLowerCase();

    final result = _animals.where((animal) {
      final matchesSearch =
          search.isEmpty ||
          animal.tagNumber.toLowerCase().contains(search) ||
          animal.breed.toLowerCase().contains(search) ||
          animal.type.toLowerCase().contains(search);

      final matchesType =
          _selectedType == 'सर्व' ||
          animal.type == _selectedType;

      final matchesStatus =
          _selectedStatus == 'सर्व' ||
          animal.status == _selectedStatus;

      return matchesSearch &&
          matchesType &&
          matchesStatus;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredAnimals = result;
    });
  }

  // ============================================================
  // TAG SUGGESTION
  // ============================================================

  String _suggestNextTag(String type) {
    final prefix = type == 'म्हैस' ? 'B' : 'C';
    final usedNumbers = <int>{};

    final pattern = RegExp(
      '^${RegExp.escape(prefix)}-(\\d+)\$',
      caseSensitive: false,
    );

    for (final animal in _animals) {
      final match = pattern.firstMatch(
        animal.tagNumber.trim(),
      );

      if (match == null) continue;

      final number = int.tryParse(match.group(1)!);

      if (number != null && number > 0) {
        usedNumbers.add(number);
      }
    }

    var nextNumber = 1;

    while (usedNumbers.contains(nextNumber)) {
      nextNumber++;
    }

    return '$prefix-${nextNumber.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // DUPLICATE TAG
  // ============================================================

  bool _isDuplicateTag(
    String tag, {
    AnimalModel? existingAnimal,
  }) {
    final normalizedTag = tag.trim().toLowerCase();

    return _animals.any((animal) {
      if (existingAnimal != null &&
          animal.id == existingAnimal.id) {
        return false;
      }

      return animal.tagNumber.trim().toLowerCase() ==
          normalizedTag;
    });
  }

  // ============================================================
  // DELETE ANIMAL
  // ============================================================

  Future<void> _deleteAnimal(
    AnimalModel animal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'जनावर हटवायचे आहे?',
          ),
          content: Text(
            '${animal.tagNumber} ची नोंद कायमची हटवली जाईल.\n\nही कृती पूर्ववत करता येणार नाही.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text('रद्द'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    AppColors.error,
              ),
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                true,
              ),
              child: const Text('हटवा'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      final deleted =
          await _repository.deleteAnimal(animal);

      if (!mounted) return;

      if (!deleted) {
        _showMessage(
          'जनावर हटवता आले नाही. कृपया पुन्हा प्रयत्न करा.',
          isError: true,
        );
        return;
      }

      await _loadAnimals();

      _showMessage(
        'जनावर ${animal.tagNumber} हटवले.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'जनावर हटवताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // ADD / EDIT ANIMAL
  // ============================================================

  void _showAnimalDialog({
    AnimalModel? existingAnimal,
  }) {
    final isEditing = existingAnimal != null;

    // ----------------------------------------------------------
    // BASIC CONTROLLERS
    // ----------------------------------------------------------

    final tagController = TextEditingController(
      text: existingAnimal?.tagNumber ?? '',
    );

    final breedController = TextEditingController(
      text: existingAnimal?.breed ?? '',
    );

    final purchasePriceController =
        TextEditingController(
      text: existingAnimal?.purchasePrice == null
          ? ''
          : existingAnimal!.purchasePrice!
              .toStringAsFixed(0),
    );

    final farmEntrySeasonController =
        TextEditingController(
      text: existingAnimal?.farmEntrySeason ?? '',
    );

    final previousFarmController =
        TextEditingController(
      text: existingAnimal?.previousFarm ?? '',
    );

    // ----------------------------------------------------------
    // STATE
    // ----------------------------------------------------------

    String type =
        existingAnimal?.type ?? 'गाय';

    String status =
        existingAnimal?.status ?? 'Active';

    bool isMilking =
        existingAnimal?.isMilking ?? true;

    DateTime dateOfBirth =
        existingAnimal?.dateOfBirth ??
        DateTime.now();

    // ----------------------------------------------------------
    // FARM HISTORY
    // ----------------------------------------------------------

    String sourceType =
        existingAnimal?.sourceType ?? 'unknown';

    DateTime? farmEntryDate =
        existingAnimal?.farmEntryDate;

    DateTime? purchaseDate =
        existingAnimal?.purchaseDate;

    // ----------------------------------------------------------
    // PREGNANCY
    // ----------------------------------------------------------

    String pregnancyStatus =
        existingAnimal?.pregnancyStatus ??
        'unknown';

    // ----------------------------------------------------------
    // SAVE STATE
    // ----------------------------------------------------------

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
            // ==================================================
            // DATE PICKER
            // ==================================================

            Future<DateTime?> pickDate({
              required DateTime initialDate,
              required String helpText,
            }) async {
              return showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(1990),
                lastDate: DateTime.now(),
                helpText: helpText,
                cancelText: 'रद्द',
                confirmText: 'निवडा',
              );
            }

            // ==================================================
            // DOB
            // ==================================================

            Future<void> selectDateOfBirth() async {
              final selected =
                  await pickDate(
                initialDate: dateOfBirth,
                helpText: 'जन्मतारीख निवडा',
              );

              if (selected == null) return;

              setSheetState(() {
                dateOfBirth = selected;
              });
            }

            // ==================================================
            // FARM ENTRY DATE
            // ==================================================

            Future<void> selectFarmEntryDate() async {
              final selected =
                  await pickDate(
                initialDate:
                    farmEntryDate ??
                    DateTime.now(),
                helpText:
                    'फार्ममध्ये आल्याची तारीख निवडा',
              );

              if (selected == null) return;

              setSheetState(() {
                farmEntryDate = selected;
              });
            }

            // ==================================================
            // PURCHASE DATE
            // ==================================================

            Future<void> selectPurchaseDate() async {
              final selected =
                  await pickDate(
                initialDate:
                    purchaseDate ??
                    DateTime.now(),
                helpText:
                    'खरेदी तारीख निवडा',
              );

              if (selected == null) return;

              setSheetState(() {
                purchaseDate = selected;
              });
            }

            // ==================================================
            // SAVE
            // ==================================================

            Future<void> saveAnimal() async {
              final tag =
                  tagController.text
                      .trim()
                      .toUpperCase();

              final breed =
                  breedController.text.trim();

              final purchaseText =
                  purchasePriceController
                      .text
                      .trim();

              final purchasePrice =
                  purchaseText.isEmpty
                      ? null
                      : double.tryParse(
                          purchaseText,
                        );

              // ----------------------------------------------
              // VALIDATION
              // ----------------------------------------------

              if (tag.isEmpty) {
                _showMessage(
                  'टॅग नंबर टाका.',
                  isError: true,
                );
                return;
              }

              if (_isDuplicateTag(
                tag,
                existingAnimal:
                    existingAnimal,
              )) {
                _showMessage(
                  'हा टॅग नंबर आधीच नोंदवलेला आहे. दुसरा टॅग नंबर वापरा.',
                  isError: true,
                );
                return;
              }

              if (breed.isEmpty) {
                _showMessage(
                  'जनावराची जात टाका.',
                  isError: true,
                );
                return;
              }

              if (purchaseText.isNotEmpty &&
                  (purchasePrice == null ||
                      purchasePrice < 0)) {
                _showMessage(
                  'खरेदीची योग्य किंमत टाका.',
                  isError: true,
                );
                return;
              }

              // ----------------------------------------------
              // PURCHASE LOGIC
              // ----------------------------------------------

              if (sourceType == 'purchased' &&
                  purchaseDate == null) {
                // Purchase date is optional,
                // therefore we don't block saving.
              }

              setSheetState(() {
                isSaving = true;
              });

              try {
                // ==================================================
                // CREATE MODEL
                // ==================================================

                final animal = AnimalModel(
                  tagNumber: tag,
                  type: type,
                  breed: breed,
                  dateOfBirth: dateOfBirth,
                  status: status,
                  isMilking: isMilking,

                  // Farm history
                  sourceType: sourceType,
                  farmEntryDate: farmEntryDate,
                  farmEntrySeason:
                      farmEntrySeasonController
                          .text
                          .trim()
                          .isEmpty
                      ? null
                      : farmEntrySeasonController
                          .text
                          .trim(),
                  previousFarm:
                      previousFarmController
                          .text
                          .trim()
                          .isEmpty
                      ? null
                      : previousFarmController
                          .text
                          .trim(),
                  purchaseDate: purchaseDate,
                  purchasePrice:
                      purchasePrice,

                  // Pregnancy
                  pregnancyStatus:
                      pregnancyStatus,
                );

                // ==================================================
                // PRESERVE EXISTING DATA WHILE EDITING
                // ==================================================

                if (isEditing) {
                  animal.id = existingAnimal.id;

                  animal.firebaseId =
                      existingAnimal.firebaseId;

                  animal.lastSyncAt =
                      existingAnimal.lastSyncAt;

                  // Preserve lineage.
                  animal.motherAnimalId =
                      existingAnimal.motherAnimalId;

                  animal.fatherAnimalId =
                      existingAnimal.fatherAnimalId;

                  animal.motherTagNumber =
                      existingAnimal.motherTagNumber;

                  animal.fatherTagNumber =
                      existingAnimal.fatherTagNumber;

                  // Preserve identification.
                  animal.rfidNumber =
                      existingAnimal.rfidNumber;

                  animal.color =
                      existingAnimal.color;

                  animal.identificationNotes =
                      existingAnimal.identificationNotes;

                  // Preserve production / breeding.
                  animal.lactationNumber =
                      existingAnimal.lactationNumber;

                  animal.lastCalvingDate =
                      existingAnimal.lastCalvingDate;

                  animal.expectedCalvingDate =
                      existingAnimal.expectedCalvingDate;
                }

                // ==================================================
                // SAVE
                // ==================================================

                await _repository.addAnimal(
                  animal,
                );

                if (!mounted ||
                    !sheetContext.mounted) {
                  return;
                }

                Navigator.pop(
                  sheetContext,
                );

                await _loadAnimals();

                _showMessage(
                  isEditing
                      ? 'जनावराची माहिती अपडेट झाली.'
                      : 'नवीन जनावराची नोंद सेव्ह झाली.',
                );
              } catch (e) {
                setSheetState(() {
                  isSaving = false;
                });

                _showMessage(
                  'जनावर सेव्ह करताना त्रुटी आली.\n$e',
                  isError: true,
                );
              }
            }

            // ==================================================
            // SHEET UI
            // ==================================================

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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // HANDLE
                      // ==================================================

                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration:
                              BoxDecoration(
                            color:
                                AppColors
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

                      // ==================================================
                      // TITLE
                      // ==================================================

                      Text(
                        isEditing
                            ? 'जनावराची माहिती अपडेट करा'
                            : 'नवीन जनावर नोंदवा',
                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const Text(
                        'जनावराची मूलभूत माहिती, फार्म इतिहास आणि breeding माहिती नोंदवा.',
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              AppColors
                                  .textSecondary,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // BASIC INFORMATION
                      // ==================================================

                      _sheetSectionTitle(
                        icon:
                            Icons.badge_outlined,
                        title:
                            'मूलभूत माहिती',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // TAG
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Expanded(
                            child:
                                TextFormField(
                              controller:
                                  tagController,
                              textCapitalization:
                                  TextCapitalization
                                      .characters,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'टॅग नंबर / नाव',
                                hintText:
                                    'उदा. C-01',
                                prefixIcon:
                                    Icon(
                                  Icons
                                      .tag_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              top: 2,
                            ),
                            child:
                                OutlinedButton.icon(
                              onPressed:
                                  isEditing
                                      ? null
                                      : () {
                                          setSheetState(
                                            () {
                                              tagController
                                                      .text =
                                                  _suggestNextTag(
                                                type,
                                              );
                                            },
                                          );
                                        },
                              icon:
                                  const Icon(
                                Icons
                                    .auto_fix_high_rounded,
                                size: 16,
                              ),
                              label:
                                  const Text(
                                'सुचवा',
                              ),
                              style:
                                  OutlinedButton
                                      .styleFrom(
                                minimumSize:
                                    const Size(
                                  82,
                                  48,
                                ),
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      // TYPE
                      DropdownButtonFormField<
                          String>(
                        initialValue: type,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'गाय',
                            child:
                                Text('गाय'),
                          ),
                          DropdownMenuItem(
                            value: 'म्हैस',
                            child:
                                Text('म्हैस'),
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
                              type = value;

                              if (!isEditing &&
                                  tagController
                                      .text
                                      .trim()
                                      .isEmpty) {
                                tagController
                                        .text =
                                    _suggestNextTag(
                                  value,
                                );
                              }
                            },
                          );
                        },
                        decoration:
                            const InputDecoration(
                          labelText:
                              'प्रकार',
                          prefixIcon:
                              Icon(
                            Icons
                                .pets_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      // BREED
                      DropdownButtonFormField<
                          String>(
                        initialValue:
                            _breedOptions
                                    .contains(
                          breedController
                              .text
                              .trim(),
                        )
                                ? breedController
                                    .text
                                    .trim()
                                : 'इतर',
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'HF',
                            child:
                                Text('HF'),
                          ),
                          DropdownMenuItem(
                            value:
                                'Jersey',
                            child:
                                Text(
                              'Jersey',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Gir',
                            child: Text(
                              'Gir / गिर',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'Sahiwal',
                            child:
                                Text(
                              'Sahiwal / साहिवाल',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'Red Sindhi',
                            child:
                                Text(
                              'Red Sindhi / लाल सिंधी',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'Jaffarabadi',
                            child:
                                Text(
                              'Jaffarabadi / जाफराबादी',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'Murrah',
                            child:
                                Text(
                              'Murrah / मुर्रा',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'Mehsana',
                            child:
                                Text(
                              'Mehsana / मेहसाणा',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'इतर',
                            child:
                                Text(
                              'इतर — स्वतःची जात लिहा',
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
                              if (value ==
                                  'इतर') {
                                breedController
                                    .clear();
                              } else {
                                breedController
                                        .text =
                                    value;
                              }
                            },
                          );
                        },
                        decoration:
                            const InputDecoration(
                          labelText:
                              'जात / Breed',
                          prefixIcon:
                              Icon(
                            Icons
                                .category_outlined,
                          ),
                        ),
                      ),

                      if (!_breedOptions
                          .contains(
                        breedController
                            .text
                            .trim(),
                      )) ...[
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller:
                              breedController,
                          textCapitalization:
                              TextCapitalization
                                  .words,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'जात नाव',
                            hintText:
                                'उदा. स्थानिक / Cross Breed',
                            prefixIcon:
                                Icon(
                              Icons
                                  .edit_outlined,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 13,
                      ),

                      // DOB
                      _buildSheetDateField(
                        label:
                            'जन्मतारीख',
                        value:
                            _formatDate(
                          dateOfBirth,
                        ),
                        icon: Icons
                            .calendar_today_outlined,
                        onTap:
                            selectDateOfBirth,
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // FARM HISTORY
                      // ==================================================

                      _sheetSectionTitle(
                        icon: Icons
                            .history_rounded,
                        title:
                            'फार्ममध्ये येण्याचा इतिहास',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // SOURCE TYPE
                      DropdownButtonFormField<
                          String>(
                        initialValue:
                            _sourceTypes
                                    .contains(
                          sourceType,
                        )
                                ? sourceType
                                : 'unknown',
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value:
                                'born_on_farm',
                            child: Text(
                              'फार्मवर जन्मलेले',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'purchased',
                            child: Text(
                              'खरेदी केलेले',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'transferred',
                            child: Text(
                              'दुसऱ्या फार्ममधून आणलेले',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'unknown',
                            child: Text(
                              'माहिती उपलब्ध नाही',
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
                              sourceType =
                                  value;
                            },
                          );
                        },
                        decoration:
                            const InputDecoration(
                          labelText:
                              'फार्ममध्ये येण्याचा प्रकार',
                          prefixIcon:
                              Icon(
                            Icons
                                .input_rounded,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      // FARM ENTRY DATE
                      _buildSheetDateField(
                        label:
                            'फार्ममध्ये आल्याची तारीख',
                        value:
                            farmEntryDate ==
                                    null
                                ? 'तारीख निवडा'
                                : _formatDate(
                                    farmEntryDate!,
                                  ),
                        icon: Icons
                            .event_available_outlined,
                        onTap:
                            selectFarmEntryDate,
                        isEmpty:
                            farmEntryDate ==
                                null,
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      // SEASON
                      TextFormField(
                        controller:
                            farmEntrySeasonController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'फार्म Entry Season / Batch',
                          hintText:
                              'उदा. 2025-26',
                          prefixIcon:
                              Icon(
                            Icons
                                .calendar_month_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      // PREVIOUS FARM
                      if (sourceType ==
                              'purchased' ||
                          sourceType ==
                              'transferred') ...[
                        TextFormField(
                          controller:
                              previousFarmController,
                          textCapitalization:
                              TextCapitalization
                                  .words,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Previous Farm / मालक',
                            hintText:
                                'उदा. Patil Dairy Farm',
                            prefixIcon:
                                Icon(
                              Icons
                                  .agriculture_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 13,
                        ),
                      ],

                      // PURCHASE DATE
                      if (sourceType ==
                          'purchased') ...[
                        _buildSheetDateField(
                          label:
                              'खरेदी तारीख',
                          value:
                              purchaseDate ==
                                      null
                                  ? 'खरेदी तारीख निवडा'
                                  : _formatDate(
                                      purchaseDate!,
                                    ),
                          icon: Icons
                              .shopping_cart_checkout_outlined,
                          onTap:
                              selectPurchaseDate,
                          isEmpty:
                              purchaseDate ==
                                  null,
                        ),
                        const SizedBox(
                          height: 13,
                        ),
                      ],

                      // PURCHASE PRICE
                      TextFormField(
                        controller:
                            purchasePriceController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'खरेदी किंमत (₹) - ऐच्छिक',
                          hintText:
                              'उदा. 85000',
                          prefixIcon:
                              Icon(
                            Icons
                                .currency_rupee_rounded,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // STATUS
                      // ==================================================

                      _sheetSectionTitle(
                        icon: Icons
                            .info_outline_rounded,
                        title:
                            'जनावराची स्थिती',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      DropdownButtonFormField<
                          String>(
                        initialValue:
                            status,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'Active',
                            child: Text(
                              'Active - सध्या फार्मवर',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Sold',
                            child: Text(
                              'Sold - विकलेले',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'Deceased',
                            child: Text(
                              'Deceased - मृत्यू',
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
                              status = value;
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
                                .toggle_on_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      SwitchListTile.adaptive(
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 4,
                        ),
                        value:
                            isMilking,
                        onChanged:
                            (value) {
                          setSheetState(
                            () {
                              isMilking =
                                  value;
                            },
                          );
                        },
                        title:
                            const Text(
                          'दूध देणारे जनावर',
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                        subtitle:
                            Text(
                          isMilking
                              ? 'सध्या दूध देत आहे'
                              : 'सध्या दूध देत नाही',
                          style:
                              const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                        secondary:
                            const Icon(
                          Icons
                              .water_drop_outlined,
                          color: AppColors
                              .secondary,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // PREGNANCY
                      // ==================================================

                      _sheetSectionTitle(
                        icon: Icons
                            .pregnant_woman_outlined,
                        title:
                            'Breeding / Pregnancy',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      DropdownButtonFormField<
                          String>(
                        initialValue:
                            _pregnancyStatuses
                                    .contains(
                          pregnancyStatus,
                        )
                                ? pregnancyStatus
                                : 'unknown',
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value:
                                'not_pregnant',
                            child: Text(
                              'गाभण नाही',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'pregnant',
                            child: Text(
                              'गाभण आहे',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'unknown',
                            child: Text(
                              'माहिती उपलब्ध नाही',
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
                              pregnancyStatus =
                                  value;
                            },
                          );
                        },
                        decoration:
                            const InputDecoration(
                          labelText:
                              'गाभण स्थिती',
                          prefixIcon:
                              Icon(
                            Icons
                                .pregnant_woman_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // SAVE BUTTON
                      // ==================================================

                      SizedBox(
                        width:
                            double.infinity,
                        height: 50,
                        child:
                            ElevatedButton
                                .icon(
                          onPressed:
                              isSaving
                                  ? null
                                  : saveAnimal,
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
                          label:
                              Text(
                            isSaving
                                ? 'सेव्ह होत आहे...'
                                : isEditing
                                    ? 'अपडेट करा'
                                    : 'सेव्ह करा',
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 8,
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
  // SHEET SECTION TITLE
  // ============================================================

  Widget _sheetSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius:
                BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 17,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SHEET DATE FIELD
  // ============================================================

  Widget _buildSheetDateField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool isEmpty = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isEmpty
                ? FontWeight.normal
                : FontWeight.w600,
            color: isEmpty
                ? AppColors.textTertiary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >=
            900;

    if (isDesktop) {
      return DesktopAppShell(
        currentIndex: 1,
        title: 'जनावरे',
        subtitle: 'Animal Master',
        actions: [
          IconButton(
            tooltip:
                'Refresh animals',
            onPressed:
                _isLoading
                    ? null
                    : _loadAnimals,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () =>
                _showAnimalDialog(),
            icon: const Icon(
              Icons.add_rounded,
              size: 18,
            ),
            label: const Text(
              'नवीन जनावर',
            ),
          ),
          const SizedBox(width: 8),
        ],
        onDestinationSelected:
            _handleDesktopNavigation,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadAnimals,
          child: _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : _buildDesktopContent(),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'माझी जनावरे',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _isLoading
                    ? null
                    : _loadAnimals,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadAnimals,
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _buildContent(),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () =>
            _showAnimalDialog(),
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'नवीन जनावर',
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP NAVIGATION
  // ============================================================

  void _handleDesktopNavigation(
    int index,
  ) {
    switch (index) {
      case 0:
        context.go(
          AppRoutes.dashboard,
        );
        break;

      case 1:
        context.go(
          AppRoutes.animalList,
        );
        break;

      case 2:
        context.go(
          AppRoutes.milkEntry,
        );
        break;

      case 3:
        context.go(
          AppRoutes.expenseEntry,
        );
        break;

      case 4:
        context.go(
          AppRoutes.inventory,
        );
        break;

      case 5:
        context.go(
          AppRoutes.health,
        );
        break;

      case 6:
        context.go(
          AppRoutes.pregnancy,
        );
        break;

      case 7:
        context.go(
          AppRoutes.reports,
        );
        break;

      case 8:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                const SettingsScreen(),
          ),
        );
        break;

      case 9:
        context.go(
          AppRoutes.auditLog,
        );
        break;
    }
  }

  // ============================================================
  // DESKTOP CONTENT
  // ============================================================

  Widget _buildDesktopContent() {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        const maxWidth = 1600.0;

        final width =
            constraints.maxWidth >
                    maxWidth
                ? maxWidth
                : constraints.maxWidth;

        return ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            28,
            24,
            28,
            32,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: [
                    _buildDesktopIntro(),
                    const SizedBox(
                      height: 18,
                    ),
                    _buildDesktopSummary(),
                    const SizedBox(
                      height: 18,
                    ),
                    _buildDesktopToolbar(),
                    const SizedBox(
                      height: 18,
                    ),
                    if (_filteredAnimals
                        .isEmpty)
                      _buildEmptyState()
                    else
                      _buildDesktopAnimalGrid(
                        width,
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

  // ============================================================
  // DESKTOP INTRO
  // ============================================================

  Widget _buildDesktopIntro() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'माझी जनावरे',
                style: TextStyle(
                  fontSize: 22,
                  height: 1.1,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'संपूर्ण Animal Master एका ठिकाणी व्यवस्थापित करा.',
                style: TextStyle(
                  fontSize: 11,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _desktopCountPill(
          icon:
              Icons.pets_outlined,
          label: 'एकूण',
          value:
              '${_animals.length}',
          color:
              AppColors.primary,
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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 7),
          Text(
            '$label  $value',
            style:
                const TextStyle(
              fontSize: 10.5,
              fontWeight:
                  FontWeight.w700,
              color:
                  AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DESKTOP SUMMARY
  // ============================================================

  Widget _buildDesktopSummary() {
    final activeCount =
        _animals
            .where(
              (animal) =>
                  animal.status ==
                  'Active',
            )
            .length;

    final milkingCount =
        _animals
            .where(
              (animal) =>
                  animal.status ==
                      'Active' &&
                  animal.isMilking,
            )
            .length;

    final cowsCount =
        _animals
            .where(
              (animal) =>
                  animal.type ==
                  'गाय',
            )
            .length;

    final buffaloCount =
        _animals
            .where(
              (animal) =>
                  animal.type ==
                  'म्हैस',
            )
            .length;

    return Row(
      children: [
        Expanded(
          child: _desktopMetric(
            icon:
                Icons.verified_outlined,
            title: 'Active',
            value:
                '$activeCount',
            color:
                AppColors.primary,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: _desktopMetric(
            icon:
                Icons.water_drop_outlined,
            title: 'दूध देणारे',
            value:
                '$milkingCount',
            color:
                AppColors.secondary,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: _desktopMetric(
            icon:
                Icons.pets_outlined,
            title: 'गाय',
            value:
                '$cowsCount',
            color:
                AppColors.warning,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: _desktopMetric(
            icon:
                Icons.pets_rounded,
            title: 'म्हैस',
            value:
                '$buffaloCount',
            color:
                AppColors.info,
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
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 9.5,
                    color: AppColors
                        .textTertiary,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    height: 1,
                    fontWeight:
                        FontWeight.w800,
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

  // ============================================================
  // DESKTOP TOOLBAR
  // ============================================================

  Widget _buildDesktopToolbar() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildSearch(),
        ),
        const SizedBox(
          width: 12,
        ),
        SizedBox(
          width: 190,
          child: _buildDesktopFilter(
            label: 'प्रकार',
            value:
                _selectedType,
            icon:
                Icons.pets_outlined,
            items: [
              'सर्व',
              ..._types,
            ],
            onChanged:
                (value) {
              if (value ==
                  null) {
                return;
              }

              setState(
                () =>
                    _selectedType =
                        value,
              );

              _applyFilters();
            },
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        SizedBox(
          width: 190,
          child: _buildDesktopFilter(
            label: 'स्थिती',
            value:
                _selectedStatus,
            icon: Icons
                .filter_alt_outlined,
            items: [
              'सर्व',
              ..._statuses,
            ],
            onChanged:
                (value) {
              if (value ==
                  null) {
                return;
              }

              setState(
                () =>
                    _selectedStatus =
                        value,
              );

              _applyFilters();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFilter({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?>
        onChanged,
  }) {
    return DropdownButtonFormField<
        String>(
      initialValue: value,
      isExpanded: true,
      items: items
          .map(
            (item) =>
                DropdownMenuItem<
                    String>(
              value: item,
              child:
                  Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration:
          InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(
          icon,
          size: 18,
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP GRID
  // ============================================================

  Widget _buildDesktopAnimalGrid(
    double width,
  ) {
    final columns = width >= 1350
        ? 3
        : width >= 950
            ? 2
            : 1;

    const gap = 14.0;

    final cardWidth =
        (width -
                ((columns - 1) *
                    gap)) /
            columns;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children:
          _filteredAnimals.map(
        (animal) {
          return SizedBox(
            width: cardWidth,
            child:
                _buildAnimalCard(
              animal,
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // MOBILE CONTENT
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

        _buildFilters(),

        const SizedBox(
          height: 16,
        ),

        if (_filteredAnimals
            .isEmpty)
          _buildEmptyState()
        else
          ..._filteredAnimals.map(
            (animal) =>
                Padding(
              padding:
                  const EdgeInsets
                      .only(
                bottom: 10,
              ),
              child:
                  _buildAnimalCard(
                animal,
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
  // MOBILE SUMMARY
  // ============================================================

  Widget _buildSummary() {
    final activeCount =
        _animals
            .where(
              (animal) =>
                  animal.status ==
                  'Active',
            )
            .length;

    final cowsCount =
        _animals
            .where(
              (animal) =>
                  animal.type ==
                  'गाय',
            )
            .length;

    final buffaloCount =
        _animals
            .where(
              (animal) =>
                  animal.type ==
                  'म्हैस',
            )
            .length;

    final milkingCount =
        _animals
            .where(
              (animal) =>
                  animal.status ==
                      'Active' &&
                  animal.isMilking,
            )
            .length;

    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration:
          const BoxDecoration(
        gradient:
            LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin:
              Alignment.topLeft,
          end: Alignment
              .bottomRight,
        ),
        borderRadius:
            BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          const Text(
            'फार्म जनावर आढावा',
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          const Text(
            'Animal Master Overview',
            style:
                TextStyle(
              color:
                  Colors.white70,
              fontSize: 10,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Row(
            children: [
              Expanded(
                child:
                    _summaryItem(
                  Icons
                      .pets_outlined,
                  'Active',
                  '$activeCount',
                ),
              ),
              Expanded(
                child:
                    _summaryItem(
                  Icons
                      .water_drop_outlined,
                  'दूध देणारे',
                  '$milkingCount',
                ),
              ),
              Expanded(
                child:
                    _summaryItem(
                  Icons
                      .catching_pokemon_outlined,
                  'गाय',
                  '$cowsCount',
                ),
              ),
              Expanded(
                child:
                    _summaryItem(
                  Icons.pets,
                  'म्हैस',
                  '$buffaloCount',
                ),
              ),
            ],
          ),
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
          color:
              Colors.white,
          size: 19,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          value,
          style:
              const TextStyle(
            color:
                Colors.white,
            fontSize: 17,
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
            color:
                Colors.white70,
            fontSize: 8,
          ),
          textAlign:
              TextAlign.center,
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
            'टॅग नंबर, जात किंवा प्रकार शोधा...',
        prefixIcon:
            const Icon(
          Icons.search_rounded,
          color:
              AppColors.primary,
        ),
        suffixIcon:
            _searchController
                    .text
                    .isNotEmpty
                ? IconButton(
                    onPressed:
                        () {
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
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child:
              DropdownButtonFormField<
                  String>(
            initialValue:
                _selectedType,
            isExpanded: true,
            items: [
              const DropdownMenuItem(
                value: 'सर्व',
                child: Text(
                  'सर्व प्रकार',
                ),
              ),
              ..._types.map(
                (type) =>
                    DropdownMenuItem(
                  value: type,
                  child:
                      Text(type),
                ),
              ),
            ],
            onChanged:
                (value) {
              if (value ==
                  null) {
                return;
              }

              setState(
                () {
                  _selectedType =
                      value;
                },
              );

              _applyFilters();
            },
            decoration:
                const InputDecoration(
              labelText:
                  'प्रकार',
              prefixIcon:
                  Icon(
                Icons
                    .pets_outlined,
                size: 19,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child:
              DropdownButtonFormField<
                  String>(
            initialValue:
                _selectedStatus,
            isExpanded: true,
            items: [
              const DropdownMenuItem(
                value: 'सर्व',
                child: Text(
                  'सर्व स्थिती',
                ),
              ),
              ..._statuses.map(
                (status) =>
                    DropdownMenuItem(
                  value: status,
                  child:
                      Text(status),
                ),
              ),
            ],
            onChanged:
                (value) {
              if (value ==
                  null) {
                return;
              }

              setState(
                () {
                  _selectedStatus =
                      value;
                },
              );

              _applyFilters();
            },
            decoration:
                const InputDecoration(
              labelText:
                  'स्थिती',
              prefixIcon:
                  Icon(
                Icons
                    .filter_alt_outlined,
                size: 19,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ANIMAL CARD
  // ============================================================

  Widget _buildAnimalCard(
    AnimalModel animal,
  ) {
    final isActive =
        animal.status ==
            'Active';

    final isMilking =
        animal.isMilking &&
        isActive;

    final statusColor =
        animal.status ==
                'Active'
            ? AppColors.primary
            : animal.status ==
                    'Sold'
                ? AppColors.warning
                : AppColors.error;

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
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration:
                    BoxDecoration(
                  color: AppColors
                      .primaryLight,
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                child:
                    Center(
                  child: Text(
                    animal.type ==
                            'गाय'
                        ? '🐄'
                        : '🐃',
                    style:
                        const TextStyle(
                      fontSize: 28,
                    ),
                  ),
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
                            animal
                                .tagNumber,
                            style:
                                const TextStyle(
                              fontSize:
                                  16,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity:
                              VisualDensity
                                  .compact,
                          tooltip:
                              'Edit',
                          onPressed:
                              () =>
                                  _showAnimalDialog(
                            existingAnimal:
                                animal,
                          ),
                          icon:
                              const Icon(
                            Icons
                                .edit_outlined,
                            size:
                                19,
                          ),
                        ),
                        IconButton(
                          visualDensity:
                              VisualDensity
                                  .compact,
                          tooltip:
                              'Delete',
                          onPressed:
                              () =>
                                  _deleteAnimal(
                            animal,
                          ),
                          icon:
                              const Icon(
                            Icons
                                .delete_outline_rounded,
                            size:
                                19,
                            color:
                                AppColors
                                    .error,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${animal.type} • ${animal.breed}',
                      style:
                          const TextStyle(
                        fontSize:
                            11,
                        color:
                            AppColors
                                .textSecondary,
                        fontWeight:
                            FontWeight
                                .w500,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing:
                          5,
                      children: [
                        _statusChip(
                          animal
                              .status,
                          statusColor,
                        ),
                        if (isMilking)
                          _statusChip(
                            'दूध देत आहे',
                            AppColors
                                .secondary,
                          ),
                        if (animal
                            .isPregnant)
                          _statusChip(
                            'गाभण',
                            AppColors
                                .info,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 13,
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
                child:
                    _infoValue(
                  label:
                      'जन्मतारीख',
                  value:
                      _formatDate(
                    animal
                        .dateOfBirth,
                  ),
                ),
              ),
              Expanded(
                child:
                    _infoValue(
                  label:
                      'वय',
                  value:
                      _calculateAge(
                    animal
                        .dateOfBirth,
                  ),
                ),
              ),
              Expanded(
                child:
                    _infoValue(
                  label:
                      'खरेदी किंमत',
                  value: animal
                              .purchasePrice ==
                          null
                      ? 'N/A'
                      : '₹ ${animal.purchasePrice!.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(
    String text,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
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
          fontSize: 8,
          fontWeight:
              FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // INFO VALUE
  // ============================================================

  Widget _infoValue({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
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
              const TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final hasFilter =
        _searchController.text
                .trim()
                .isNotEmpty ||
            _selectedType !=
                'सर्व' ||
            _selectedStatus !=
                'सर्व';

    return Container(
      padding:
          const EdgeInsets
              .symmetric(
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
              color: AppColors
                  .primaryLight,
              shape:
                  BoxShape.circle,
            ),
            child:
                const Center(
              child: Text(
                '🐄',
                style:
                    TextStyle(
                  fontSize: 34,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            hasFilter
                ? 'तुमच्या शोधानुसार जनावर सापडले नाही'
                : 'अद्याप कोणत्याही जनावराची नोंद नाही',
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
                : 'पहिले जनावर जोडण्यासाठी खालील बटन वापरा.',
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
                  _selectedStatus =
                      'सर्व';
                });

                _applyFilters();
              },
              icon:
                  const Icon(
                Icons
                    .filter_alt_off_outlined,
              ),
              label:
                  const Text(
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

  String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _calculateAge(
    DateTime birthDate,
  ) {
    final today =
        DateTime.now();

    int years =
        today.year -
        birthDate.year;

    int months =
        today.month -
        birthDate.month;

    if (today.day <
        birthDate.day) {
      months--;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years <= 0) {
      return '$months महिने';
    }

    return '$years वर्षे';
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    )
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