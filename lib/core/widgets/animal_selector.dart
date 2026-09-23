import 'package:flutter/material.dart';

import '../../features/animals/data/models/animal_model.dart';
import '../../features/animals/data/animal_repository.dart';

/// Reusable Animal Master selector for Milk / Health / Pregnancy.
///
/// The selected value is an [AnimalModel], so screens can store only the
/// required value (for example `animal.tagNumber`) in their existing models.
class AnimalSelector extends StatefulWidget {
  const AnimalSelector({
    super.key,
    required this.onChanged,
    this.initialAnimal,
    this.labelText = 'जनावर',
    this.hintText = 'जनावर शोधा / निवडा',
    this.validator,
    this.enabled = true,
    this.activeOnly = true,
    this.milkingOnly = false,
    this.autofocus = false,
  });

  final ValueChanged<AnimalModel?> onChanged;
  final AnimalModel? initialAnimal;

  final String labelText;
  final String hintText;

  final String? Function(AnimalModel?)? validator;

  final bool enabled;
  final bool activeOnly;
  final bool milkingOnly;
  final bool autofocus;

  @override
  State<AnimalSelector> createState() => _AnimalSelectorState();
}

class _AnimalSelectorState extends State<AnimalSelector> {
  final AnimalRepository _repository = AnimalRepository();

  late Future<List<AnimalModel>> _animalsFuture;

  AnimalModel? _selectedAnimal;
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _selectedAnimal = widget.initialAnimal;
    _animalsFuture = _loadAnimals();
  }

  @override
  void didUpdateWidget(covariant AnimalSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialAnimal?.id != widget.initialAnimal?.id) {
      _selectedAnimal = widget.initialAnimal;
      _searchController.clear();
    }
  }

  Future<List<AnimalModel>> _loadAnimals() async {
    final animals = await _repository.getAllAnimals();

    final result = animals
        .whereType<AnimalModel>()
        .where((animal) {
          if (widget.activeOnly &&
              animal.status.trim().toLowerCase() != 'active') {
            return false;
          }

          if (widget.milkingOnly && !animal.isMilking) {
            return false;
          }

          return true;
        })
        .toList();

    result.sort(
      (a, b) => a.tagNumber.toLowerCase().compareTo(
            b.tagNumber.toLowerCase(),
          ),
    );

    return result;
  }

  void _refresh() {
    setState(() {
      _animalsFuture = _loadAnimals();
    });
  }

  String _animalLabel(AnimalModel animal) {
    final tag = animal.tagNumber.trim();
    final type = animal.type.trim();
    final breed = animal.breed.trim();

    if (breed.isEmpty) {
      return '$tag • $type';
    }

    return '$tag • $type • $breed';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AnimalModel>>(
      future: _animalsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: 'जनावरांची यादी लोड होत आहे...',
              prefixIcon: const Icon(Icons.pets_outlined),
              suffixIcon: const Padding(
                padding: EdgeInsets.all(13),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return TextFormField(
            readOnly: true,
            onTap: widget.enabled ? _refresh : null,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: 'यादी लोड करता आली नाही. पुन्हा प्रयत्न करा.',
              prefixIcon: const Icon(Icons.pets_outlined),
              suffixIcon: IconButton(
                tooltip: 'पुन्हा लोड करा',
                onPressed: widget.enabled ? _refresh : null,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
          );
        }

        final animals = snapshot.data ?? <AnimalModel>[];

        if (animals.isEmpty) {
          return TextFormField(
            readOnly: true,
            onTap: widget.enabled ? _refresh : null,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.milkingOnly
                  ? 'दूध देणारे सक्रिय जनावर उपलब्ध नाही'
                  : 'सक्रिय जनावर उपलब्ध नाही',
              prefixIcon: const Icon(Icons.pets_outlined),
              suffixIcon: IconButton(
                tooltip: 'Refresh',
                onPressed: widget.enabled ? _refresh : null,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
            validator: (_) {
              if (widget.validator != null) {
                return widget.validator!(_selectedAnimal);
              }

              return 'कृपया जनावर निवडा.';
            },
          );
        }

        return FormField<AnimalModel>(
          initialValue: _selectedAnimal,
          validator: widget.validator,
          enabled: widget.enabled,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Autocomplete<AnimalModel>(
                  initialValue: _selectedAnimal == null
                      ? const TextEditingValue()
                      : TextEditingValue(
                          text: _animalLabel(_selectedAnimal!),
                        ),
                  displayStringForOption: _animalLabel,
                  optionsBuilder: (textEditingValue) {
                    final query =
                        textEditingValue.text.trim().toLowerCase();

                    if (query.isEmpty) {
                      return animals;
                    }

                    return animals.where((animal) {
                      final searchable =
                          '${animal.tagNumber} '
                          '${animal.type} '
                          '${animal.breed}'
                              .toLowerCase();

                      return searchable.contains(query);
                    });
                  },
                  onSelected: (animal) {
                    _selectedAnimal = animal;
                    field.didChange(animal);
                    widget.onChanged(animal);
                  },
                  fieldViewBuilder: (
                    context,
                    textController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    if (_selectedAnimal != null &&
                        textController.text.isEmpty) {
                      textController.text =
                          _animalLabel(_selectedAnimal!);
                      textController.selection =
                          TextSelection.collapsed(
                        offset: textController.text.length,
                      );
                    }

                    return TextFormField(
                      controller: textController,
                      focusNode: focusNode,
                      enabled: widget.enabled,
                      autofocus: widget.autofocus,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: widget.labelText,
                        hintText: widget.hintText,
                        prefixIcon:
                            const Icon(Icons.pets_outlined),
                        suffixIcon: IconButton(
                          tooltip: 'यादी Refresh करा',
                          onPressed:
                              widget.enabled ? _refresh : null,
                          icon: const Icon(
                            Icons.refresh_rounded,
                          ),
                        ),
                        errorText: field.errorText,
                      ),
                      onChanged: (_) {
                        // Typing alone must never be treated as a valid
                        // animal selection.
                        if (_selectedAnimal != null) {
                          _selectedAnimal = null;
                          field.didChange(null);
                          widget.onChanged(null);
                        }
                      },
                      onFieldSubmitted: (_) => onFieldSubmitted(),
                    );
                  },
                  optionsViewBuilder: (
                    context,
                    onSelected,
                    options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 280,
                            minWidth: 280,
                          ),
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 6,
                            ),
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final animal =
                                  options.elementAt(index);

                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                  child: Icon(
                                    Icons.pets,
                                    size: 19,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                                title: Text(
                                  animal.tagNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  '${animal.type} • ${animal.breed}',
                                ),
                                onTap: () => onSelected(animal),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
