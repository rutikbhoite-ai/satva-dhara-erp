import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../data/animal_repository.dart';
import '../../data/models/animal_model.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // BASIC CONTROLLERS
  // ============================================================

  final _tagController = TextEditingController();
  final _breedController = TextEditingController();

  // ============================================================
  // FARM HISTORY CONTROLLERS
  // ============================================================

  final _farmEntrySeasonController = TextEditingController();
  final _previousFarmController = TextEditingController();
  final _purchasePriceController = TextEditingController();

  // ============================================================
  // LINEAGE CONTROLLERS
  // ============================================================

  final _motherAnimalIdController = TextEditingController();
  final _fatherAnimalIdController = TextEditingController();
  final _motherTagController = TextEditingController();
  final _fatherTagController = TextEditingController();

  // ============================================================
  // IDENTIFICATION CONTROLLERS
  // ============================================================

  final _rfidController = TextEditingController();
  final _colorController = TextEditingController();
  final _identificationNotesController = TextEditingController();

  // ============================================================
  // PRODUCTION / BREEDING
  // ============================================================

  final _lactationController = TextEditingController();

  // ============================================================
  // DATES
  // ============================================================

  DateTime? _dateOfBirth;
  DateTime? _farmEntryDate;
  DateTime? _purchaseDate;
  DateTime? _lastCalvingDate;
  DateTime? _expectedCalvingDate;

  // ============================================================
  // DROPDOWNS
  // ============================================================

  String _type = 'गाय';

  String _status = 'Active';

  String _sourceType = 'unknown';

  String _pregnancyStatus = 'unknown';

  // ============================================================
  // SWITCH
  // ============================================================

  bool _isMilking = true;

  bool _isSaving = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _tagController.dispose();
    _breedController.dispose();

    _farmEntrySeasonController.dispose();
    _previousFarmController.dispose();
    _purchasePriceController.dispose();

    _motherAnimalIdController.dispose();
    _fatherAnimalIdController.dispose();
    _motherTagController.dispose();
    _fatherTagController.dispose();

    _rfidController.dispose();
    _colorController.dispose();
    _identificationNotesController.dispose();

    _lactationController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveAnimal() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      _showMessage(
        'जन्मतारीख निवडा.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // --------------------------------------------------------
      // PURCHASE PRICE
      // --------------------------------------------------------

      final purchaseText =
          _purchasePriceController.text.trim();

      final purchasePrice = purchaseText.isEmpty
          ? null
          : double.tryParse(purchaseText);

      if (purchaseText.isNotEmpty &&
          purchasePrice == null) {
        _showMessage(
          'खरेदी किंमत योग्य पद्धतीने टाका.',
          isError: true,
        );

        setState(() {
          _isSaving = false;
        });

        return;
      }

      // --------------------------------------------------------
      // LACTATION NUMBER
      // --------------------------------------------------------

      final lactationText =
          _lactationController.text.trim();

      final lactationNumber = lactationText.isEmpty
          ? null
          : int.tryParse(lactationText);

      if (lactationText.isNotEmpty &&
          lactationNumber == null) {
        _showMessage(
          'Lactation Number योग्य पद्धतीने टाका.',
          isError: true,
        );

        setState(() {
          _isSaving = false;
        });

        return;
      }

      // --------------------------------------------------------
      // CREATE ANIMAL
      // --------------------------------------------------------

      final animal = AnimalModel(
        tagNumber:
            _tagController.text.trim(),

        type: _type,

        breed:
            _breedController.text.trim(),

        dateOfBirth:
            _dateOfBirth!,

        status:
            _status,

        isMilking:
            _isMilking,

        // ------------------------------------------------------
        // FARM HISTORY
        // ------------------------------------------------------

        sourceType:
            _sourceType,

        farmEntryDate:
            _farmEntryDate,

        farmEntrySeason:
            _emptyToNull(
              _farmEntrySeasonController.text,
            ),

        previousFarm:
            _emptyToNull(
              _previousFarmController.text,
            ),

        purchaseDate:
            _purchaseDate,

        purchasePrice:
            purchasePrice,

        // ------------------------------------------------------
        // LINEAGE
        // ------------------------------------------------------

        motherAnimalId:
            _emptyToNull(
              _motherAnimalIdController.text,
            ),

        fatherAnimalId:
            _emptyToNull(
              _fatherAnimalIdController.text,
            ),

        motherTagNumber:
            _emptyToNull(
              _motherTagController.text,
            ),

        fatherTagNumber:
            _emptyToNull(
              _fatherTagController.text,
            ),

        // ------------------------------------------------------
        // IDENTIFICATION
        // ------------------------------------------------------

        rfidNumber:
            _emptyToNull(
              _rfidController.text,
            ),

        color:
            _emptyToNull(
              _colorController.text,
            ),

        identificationNotes:
            _emptyToNull(
              _identificationNotesController.text,
            ),

        // ------------------------------------------------------
        // PRODUCTION / BREEDING
        // ------------------------------------------------------

        lactationNumber:
            lactationNumber,

        lastCalvingDate:
            _lastCalvingDate,

        expectedCalvingDate:
            _expectedCalvingDate,

        pregnancyStatus:
            _pregnancyStatus,
      );

      // --------------------------------------------------------
      // SAVE
      // --------------------------------------------------------

      final success =
          await AnimalRepository().addAnimal(animal);

      if (!mounted) return;

      if (!success) {
        setState(() {
          _isSaving = false;
        });

        _showMessage(
          'जनावर सेव्ह करता आले नाही.',
          isError: true,
        );

        return;
      }

      _showMessage(
        'जनावराची नोंद यशस्वीरीत्या सेव्ह झाली.',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'जनावर सेव्ह करताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<DateTime?> _pickDate({
    required String helpText,
    DateTime? currentDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate:
          currentDate ??
          DateTime(
            now.year,
            now.month,
            now.day,
          ),
      firstDate:
          firstDate ??
          DateTime(1990),
      lastDate:
          lastDate ??
          now,
      helpText: helpText,
      cancelText: 'रद्द',
      confirmText: 'निवडा',
    );

    return selected;
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    final selected = await _pickDate(
      helpText: 'जन्मतारीख निवडा',
      currentDate:
          _dateOfBirth ??
          DateTime(
            now.year - 2,
            now.month,
            now.day,
          ),
      firstDate: DateTime(1990),
      lastDate: now,
    );

    if (selected == null) return;

    setState(() {
      _dateOfBirth = selected;
    });
  }

  Future<void> _selectFarmEntryDate() async {
    final selected = await _pickDate(
      helpText: 'फार्ममध्ये दाखल तारीख निवडा',
      currentDate:
          _farmEntryDate ??
          DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      _farmEntryDate = selected;
    });
  }

  Future<void> _selectPurchaseDate() async {
    final selected = await _pickDate(
      helpText: 'खरेदी तारीख निवडा',
      currentDate:
          _purchaseDate ??
          DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      _purchaseDate = selected;
    });
  }

  Future<void> _selectLastCalvingDate() async {
    final selected = await _pickDate(
      helpText: 'शेवटची व्यायल तारीख निवडा',
      currentDate:
          _lastCalvingDate ??
          DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      _lastCalvingDate = selected;
    });
  }

  Future<void> _selectExpectedCalvingDate() async {
    final selected = await _pickDate(
      helpText: 'अपेक्षित व्यायल तारीख निवडा',
      currentDate:
          _expectedCalvingDate ??
          DateTime.now(),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(
        const Duration(days: 365 * 2),
      ),
    );

    if (selected == null) return;

    setState(() {
      _expectedCalvingDate = selected;
    });
  }

  // ============================================================
  // MESSAGE
  // ============================================================

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
                  : AppColors.success,
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title:
            const Text('नवीन जनावर नोंदवा'),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                EdgeInsets.symmetric(
              horizontal:
                  isWide ? 32 : 16,
              vertical: 20,
            ),
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              _buildBasicInformation(),

              const SizedBox(height: 14),

              _buildAnimalStatus(),

              const SizedBox(height: 14),

              _buildFarmHistory(),

              const SizedBox(height: 14),

              _buildLineage(),

              const SizedBox(height: 14),

              _buildIdentification(),

              const SizedBox(height: 14),

              _buildProductionBreeding(),

              const SizedBox(height: 22),

              _buildSaveButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            AppColors.primaryLight,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              AppColors.primary
                  .withValues(alpha: 0.15),
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor:
                AppColors.primary,
            child: Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'जनावराची माहिती',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'मूलभूत माहिती, इतिहास, वंशावळ आणि उत्पादन माहिती भरा.',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        AppColors.textSecondary,
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
  // BASIC INFORMATION
  // ============================================================

  Widget _buildBasicInformation() {
    return _buildSectionCard(
      title: 'मूलभूत माहिती',
      icon: Icons.badge_outlined,
      children: [
        TextFormField(
          controller:
              _tagController,
          textCapitalization:
              TextCapitalization.characters,
          decoration:
              const InputDecoration(
            labelText:
                'टॅग नंबर / नाव',
            hintText:
                'उदा. C-01',
            prefixIcon:
                Icon(Icons.tag_outlined),
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'टॅग नंबर टाका';
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        const Text(
          'प्रकार',
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
            color:
                AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                value: 'गाय',
                icon: '🐄',
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildTypeOption(
                value: 'म्हैस',
                icon: '🐃',
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller:
              _breedController,
          decoration:
              const InputDecoration(
            labelText: 'जात',
            hintText:
                'उदा. HF, गिर, जाफराबादी',
            prefixIcon:
                Icon(Icons.category_outlined),
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'जात टाका';
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        _buildDateField(
          label:
              'जन्मतारीख',
          value:
              _dateOfBirth,
          emptyText:
              'जन्मतारीख निवडा',
          icon:
              Icons.calendar_today_outlined,
          onTap:
              _selectDateOfBirth,
        ),
      ],
    );
  }

  // ============================================================
  // TYPE OPTION
  // ============================================================

  Widget _buildTypeOption({
    required String value,
    required String icon,
  }) {
    final selected =
        _type == value;

    return InkWell(
      onTap: () {
        setState(() {
          _type = value;
        });
      },
      borderRadius:
          BorderRadius.circular(14),
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? AppColors.primaryLight
              : AppColors.surface,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.divider,
            width:
                selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style:
                  const TextStyle(
                fontSize: 25,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),

            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              size: 20,
              color: selected
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildAnimalStatus() {
    return _buildSectionCard(
      title: 'जनावराची स्थिती',
      icon:
          Icons.info_outline_rounded,
      children: [
        DropdownButtonFormField<
            String>(
          initialValue:
              _status,
          isExpanded: true,
          items: const [
            DropdownMenuItem(
              value: 'Active',
              child: Text(
                'Active — फार्ममध्ये आहे',
              ),
            ),
            DropdownMenuItem(
              value: 'Sold',
              child: Text(
                'Sold — विकले आहे',
              ),
            ),
            DropdownMenuItem(
              value: 'Deceased',
              child: Text(
                'Deceased — मृत',
              ),
            ),
          ],
          onChanged:
              (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _status = value;
            });
          },
          decoration:
              const InputDecoration(
            labelText:
                'स्थिती',
            prefixIcon:
                Icon(
              Icons.toggle_on_outlined,
            ),
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration:
              BoxDecoration(
            color: _isMilking
                ? AppColors.secondaryLight
                : AppColors.surfaceVariant,
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Icon(
                _isMilking
                    ? Icons.water_drop_rounded
                    : Icons.water_drop_outlined,
                color: _isMilking
                    ? AppColors.secondary
                    : AppColors.textTertiary,
              ),

              const SizedBox(
                width: 11,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'दूध देणारे जनावर',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'सध्या दूध देत असल्यास ON ठेवा.',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Switch(
                value:
                    _isMilking,
                onChanged:
                    (value) {
                  setState(() {
                    _isMilking =
                        value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FARM HISTORY
  // ============================================================

  Widget _buildFarmHistory() {
    return _buildSectionCard(
      title: 'फार्म इतिहास',
      icon:
          Icons.history_rounded,
      children: [
        const Text(
          'हे जनावर आपल्या फार्ममध्ये कसे आले?',
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
            color:
                AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<
            String>(
          initialValue:
              _sourceType,
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
                'Transfer झालेले',
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
            if (value == null) {
              return;
            }

            setState(() {
              _sourceType =
                  value;
            });
          },
          decoration:
              const InputDecoration(
            labelText:
                'Source',
            prefixIcon:
                Icon(
              Icons.input_rounded,
            ),
          ),
        ),

        const SizedBox(height: 14),

        _buildDateField(
          label:
              'फार्ममध्ये दाखल तारीख',
          value:
              _farmEntryDate,
          emptyText:
              'दाखल तारीख निवडा',
          icon:
              Icons.login_rounded,
          onTap:
              _selectFarmEntryDate,
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller:
              _farmEntrySeasonController,
          decoration:
              const InputDecoration(
            labelText:
                'Farm Entry Season / Batch',
            hintText:
                'उदा. 2025-26',
            prefixIcon:
                Icon(
              Icons.calendar_view_month_outlined,
            ),
          ),
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller:
              _previousFarmController,
          decoration:
              const InputDecoration(
            labelText:
                'Previous Farm / Owner',
            hintText:
                'पूर्वीचे फार्म / मालक',
            prefixIcon:
                Icon(
              Icons.agriculture_outlined,
            ),
          ),
        ),

        const SizedBox(height: 14),

        _buildDateField(
          label:
              'खरेदी तारीख',
          value:
              _purchaseDate,
          emptyText:
              'खरेदी तारीख निवडा',
          icon:
              Icons.shopping_cart_outlined,
          onTap:
              _selectPurchaseDate,
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller:
              _purchasePriceController,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration:
              const InputDecoration(
            labelText:
                'खरेदी किंमत',
            hintText:
                'उदा. 85000',
            prefixIcon:
                Icon(
              Icons.currency_rupee_rounded,
            ),
            suffixText:
                '₹',
          ),
          validator: (value) {
            final text =
                value?.trim() ??
                    '';

            if (text.isEmpty) {
              return null;
            }

            final amount =
                double.tryParse(
              text,
            );

            if (amount == null ||
                amount < 0) {
              return 'योग्य रक्कम टाका';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ============================================================
  // LINEAGE
  // ============================================================

  Widget _buildLineage() {
    return _buildSectionCard(
      title: 'वंशावळ / Lineage',
      icon:
          Icons.family_restroom_rounded,
      children: [
        const Text(
          'या जनावराची आई आणि वडील / Bull ची माहिती द्या.',
          style: TextStyle(
            fontSize: 11,
            color:
                AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller:
              _motherAnimalIdController,
          decoration:
              const InputDecoration(
            labelText:
                'Mother Animal ID',
            hintText:
                'आईचा Firebase / Animal ID',
            prefixIcon:
                Icon(
              Icons.female_rounded,
            ),
          ),
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller:
              _motherTagController,
          decoration:
              const InputDecoration(
            labelText:
                'Mother Tag Number',
            hintText:
                'उदा. C-05',
            prefixIcon:
                Icon(
              Icons.tag_outlined,
            ),
          ),
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller:
              _fatherAnimalIdController,
          decoration:
              const InputDecoration(
            labelText:
                'Father / Bull Animal ID',
            hintText:
                'वडील / Bull चा Animal ID',
            prefixIcon:
                Icon(
              Icons.male_rounded,
            ),
          ),
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller:
              _fatherTagController,
          decoration:
              const InputDecoration(
            labelText:
                'Father / Bull Tag Number',
            hintText:
                'उदा. B-02',
            prefixIcon:
                Icon(
              Icons.tag_outlined,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IDENTIFICATION
  // ============================================================

  Widget _buildIdentification() {
    return _buildSectionCard(
      title: 'ओळख माहिती',
      icon:
          Icons.qr_code_2_rounded,
      children: [
        TextFormField(
          controller:
              _rfidController,
          decoration:
              const InputDecoration(
            labelText:
                'RFID Number',
            hintText:
                'RFID / Electronic ID',
            prefixIcon:
                Icon(
              Icons.nfc_rounded,
            ),
          ),
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller:
              _colorController,
          decoration:
              const InputDecoration(
            labelText:
                'रंग',
            hintText:
                'उदा. पांढरा, काळा, तपकिरी',
            prefixIcon:
                Icon(
              Icons.palette_outlined,
            ),
          ),
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller:
              _identificationNotesController,
          maxLines: 3,
          decoration:
              const InputDecoration(
            labelText:
                'ओळख खूण / Notes',
            hintText:
                'शरीरावरील विशेष खूण किंवा इतर माहिती',
            prefixIcon:
                Icon(
              Icons.notes_rounded,
            ),
            alignLabelWithHint:
                true,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCTION / BREEDING
  // ============================================================

  Widget _buildProductionBreeding() {
    return _buildSectionCard(
      title:
          'उत्पादन / प्रजनन माहिती',
      icon:
          Icons.pets_outlined,
      children: [
        TextFormField(
          controller:
              _lactationController,
          keyboardType:
              TextInputType.number,
          decoration:
              const InputDecoration(
            labelText:
                'Lactation Number',
            hintText:
                'उदा. 2',
            prefixIcon:
                Icon(
              Icons.format_list_numbered_rounded,
            ),
          ),
          validator: (value) {
            final text =
                value?.trim() ??
                    '';

            if (text.isEmpty) {
              return null;
            }

            final number =
                int.tryParse(
              text,
            );

            if (number == null ||
                number < 0) {
              return 'योग्य Lactation Number टाका';
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        _buildDateField(
          label:
              'शेवटची व्यायल तारीख',
          value:
              _lastCalvingDate,
          emptyText:
              'तारीख निवडा',
          icon:
              Icons.event_available_outlined,
          onTap:
              _selectLastCalvingDate,
        ),

        const SizedBox(height: 14),

        _buildDateField(
          label:
              'अपेक्षित पुढील व्यायल तारीख',
          value:
              _expectedCalvingDate,
          emptyText:
              'तारीख निवडा',
          icon:
              Icons.event_outlined,
          onTap:
              _selectExpectedCalvingDate,
        ),

        const SizedBox(height: 14),

        DropdownButtonFormField<
            String>(
          initialValue:
              _pregnancyStatus,
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
            if (value == null) {
              return;
            }

            setState(() {
              _pregnancyStatus =
                  value;
            });
          },
          decoration:
              const InputDecoration(
            labelText:
                'गर्भधारणा स्थिती',
            prefixIcon:
                Icon(
              Icons.pregnant_woman_outlined,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required String emptyText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: InputDecorator(
        decoration:
            InputDecoration(
          labelText:
              label,
          prefixIcon:
              Icon(icon),
        ),
        child: Text(
          value == null
              ? emptyText
              : _formatDate(value),
          style: TextStyle(
            fontSize: 14,
            color: value == null
                ? AppColors.textTertiary
                : AppColors.textPrimary,
            fontWeight: value == null
                ? FontWeight.normal
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(18),
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
                      AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color:
                      AppColors.primary,
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
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child:
          ElevatedButton.icon(
        onPressed:
            _isSaving
                ? null
                : _saveAnimal,
        icon: _isSaving
            ? const SizedBox(
                width: 19,
                height: 19,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                      Colors.white,
                ),
              )
            : const Icon(
                Icons.save_rounded,
              ),
        label: Text(
          _isSaving
              ? 'सेव्ह होत आहे...'
              : 'जनावर सेव्ह करा',
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String? _emptyToNull(
    String value,
  ) {
    final result =
        value.trim();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}