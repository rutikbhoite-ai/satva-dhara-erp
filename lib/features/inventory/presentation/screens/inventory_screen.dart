import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';
import '../../../../shared/widgets/desktop_app_shell.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

import '../../../../app/app_colors.dart';
import '../../data/inventory_repository.dart';
import '../../data/models/inventory_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() =>
      _InventoryScreenState();
}

class _InventoryScreenState
    extends State<InventoryScreen> {
  final InventoryRepository _repository =
      InventoryRepository();

  final TextEditingController _searchController =
      TextEditingController();

  List<InventoryModel> _items = [];
  List<InventoryModel> _filteredItems = [];

  final TextEditingController _desktopSearchController =
      TextEditingController();

  String _desktopCategoryFilter = 'सर्व';
  String _desktopStockFilter = 'सर्व';

  bool _isLoading = true;

  String _selectedCategory = 'सर्व';

  final List<String> _categories = [
    'पशुखाद्य',
    'औषध',
    'मिनरल',
    'इतर',
  ];

  final List<String> _units = [
    'गोणी (Bags)',
    'किलो (Kg)',
    'लिटर (L)',
    'पॅकेट',
    'नग (Nos)',
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _applyFilters,
    );
    _desktopSearchController.addListener(
      _applyDesktopFilters,
    );

    _loadInventory();
  }

  @override
  void dispose() {
    _searchController.removeListener(
      _applyFilters,
    );
    _desktopSearchController.removeListener(
      _applyDesktopFilters,
    );

    _searchController.dispose();
    _desktopSearchController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadInventory() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data =
          await _repository.getAllItems();

      if (!mounted) return;

      setState(() {
        _items = data;
        _filteredItems = data;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'साठ्याची माहिती मिळवताना त्रुटी आली.\n$e',
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

    final result = _items.where((item) {
      final matchesSearch =
          search.isEmpty ||
          item.itemName
              .toLowerCase()
              .contains(search);

      final matchesCategory =
          _selectedCategory == 'सर्व' ||
          item.category ==
              _selectedCategory;

      return matchesSearch &&
          matchesCategory;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredItems = result;
    });
  }

  void _applyDesktopFilters() {
    final search =
        _desktopSearchController.text.trim().toLowerCase();

    final result = _items.where((item) {
      final matchesSearch =
          search.isEmpty ||
          item.itemName.toLowerCase().contains(search) ||
          item.category.toLowerCase().contains(search) ||
          item.unit.toLowerCase().contains(search);

      final matchesCategory =
          _desktopCategoryFilter == 'सर्व' ||
          item.category == _desktopCategoryFilter;

      final matchesStock =
          _desktopStockFilter == 'सर्व' ||
          (_desktopStockFilter == 'Low Stock'
              ? _isLowStock(item)
              : !_isLowStock(item));

      return matchesSearch &&
          matchesCategory &&
          matchesStock;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredItems = result;
    });
  }

  // ============================================================
  // LOW STOCK
  // ============================================================

  bool _isLowStock(
    InventoryModel item,
  ) {
    return item.quantity <=
        item.minThreshold;
  }

  bool _isDuplicateItem({
    required String name,
    required String category,
    required String unit,
    InventoryModel? editingItem,
  }) {
    final normalizedName = name.trim().toLowerCase();

    return _items.any((item) {
      if (editingItem != null && item.id == editingItem.id) {
        return false;
      }

      return item.itemName.trim().toLowerCase() ==
              normalizedName &&
          item.category.trim() == category.trim() &&
          item.unit.trim() == unit.trim();
    });
  }

  // ============================================================
  // ADD / EDIT
  // ============================================================

  void _showItemDialog({
    InventoryModel? existingItem,
  }) {
    final isEditing =
        existingItem != null;

    final nameController =
        TextEditingController(
      text: existingItem?.itemName ?? '',
    );

    final quantityController =
        TextEditingController(
      text: existingItem == null
          ? ''
          : existingItem.quantity
              .toString(),
    );

    final thresholdController =
        TextEditingController(
      text: existingItem == null
          ? '5'
          : existingItem.minThreshold
              .toString(),
    );

    String category =
        existingItem?.category ??
            'पशुखाद्य';

    String unit =
        existingItem?.unit ??
            'गोणी (Bags)';

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          AppColors.surface,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            Future<void> saveItem() async {
              final name =
                  nameController.text
                      .trim();

              final quantity =
                  double.tryParse(
                quantityController.text
                    .trim(),
              );

              final threshold =
                  double.tryParse(
                thresholdController.text
                    .trim(),
              );

              if (name.isEmpty) {
                _showMessage(
                  'साहित्याचे नाव टाका.',
                  isError: true,
                );
                return;
              }

              if (quantity == null ||
                  quantity < 0) {
                _showMessage(
                  'योग्य साठा प्रमाण टाका.',
                  isError: true,
                );
                return;
              }

              if (threshold == null ||
                  threshold < 0) {
                _showMessage(
                  'योग्य अलर्ट मर्यादा टाका.',
                  isError: true,
                );
                return;
              }

              if (threshold > 100000000) {
                _showMessage(
                  'अलर्ट मर्यादा खूप मोठी आहे.',
                  isError: true,
                );
                return;
              }

              if (_isDuplicateItem(
                name: name,
                category: category,
                unit: unit,
                editingItem: existingItem,
              )) {
                _showMessage(
                  'हेच साहित्य, category आणि unit असलेली नोंद आधीच उपलब्ध आहे.',
                  isError: true,
                );
                return;
              }

              setSheetState(() {
                isSaving = true;
              });

              try {
                final item =
                    InventoryModel(
                  itemName: name,
                  category: category,
                  quantity: quantity,
                  unit: unit,
                  minThreshold:
                      threshold,
                );

                if (isEditing) {
                  item.id =
                      existingItem.id;
                  item.firebaseId =
                      existingItem.firebaseId;
                  item.lastSyncAt =
                      existingItem.lastSyncAt;
                }

                await _repository
                    .addOrUpdateItem(item);

                if (!mounted || !sheetContext.mounted) return;

                Navigator.pop(
                  sheetContext,
                );

                await _loadInventory();

                _showMessage(
                  isEditing
                      ? 'साठ्याची माहिती अपडेट झाली.'
                      : 'नवीन साठा सेव्ह झाला.',
                );
              } catch (e) {
                setSheetState(() {
                  isSaving = false;
                });

                _showMessage(
                  'साठा सेव्ह करताना त्रुटी आली.\n$e',
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
                            ? 'साठा अपडेट करा'
                            : 'नवीन साठा जोडणे',
                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      TextFormField(
                        controller:
                            nameController,
                        textCapitalization:
                            TextCapitalization
                                .sentences,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'साहित्याचे नाव',
                          hintText:
                              'उदा. सरकी पेंड',
                          prefixIcon:
                              Icon(
                            Icons
                                .inventory_2_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      DropdownButtonFormField<
                          String>(
                        initialValue:
                            category,
                        isExpanded: true,
                        items: _categories
                            .map(
                              (value) =>
                                  DropdownMenuItem<
                                      String>(
                                value: value,
                                child:
                                    Text(
                                  value,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged:
                            (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          setSheetState(
                            () {
                              category =
                                  value;
                            },
                          );
                        },
                        decoration:
                            const InputDecoration(
                          labelText:
                              'कॅटेगरी',
                          prefixIcon:
                              Icon(
                            Icons
                                .category_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                TextFormField(
                              controller:
                                  quantityController,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal:
                                    true,
                              ),
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'सध्याचा साठा',
                                prefixIcon:
                                    Icon(
                                  Icons
                                      .numbers_outlined,
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
                                  unit,
                              isExpanded:
                                  true,
                              items: _units
                                  .map(
                                    (
                                      value,
                                    ) =>
                                        DropdownMenuItem<
                                            String>(
                                      value:
                                          value,
                                      child:
                                          Text(
                                        value,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged:
                                  (
                                value,
                              ) {
                                if (value ==
                                    null) {
                                  return;
                                }

                                setSheetState(
                                  () {
                                    unit =
                                        value;
                                  },
                                );
                              },
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'एकक',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      TextFormField(
                        controller:
                            thresholdController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal:
                              true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'किमान साठा अलर्ट मर्यादा',
                          hintText:
                              'उदा. 5',
                          prefixIcon:
                              Icon(
                            Icons
                                .warning_amber_outlined,
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
                          12,
                        ),
                        decoration:
                            BoxDecoration(
                          color: AppColors
                              .warning
                              .withValues(
                            alpha: 0.08,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                        child:
                            const Row(
                          children: [
                            Icon(
                              Icons
                                  .notifications_active_outlined,
                              size: 18,
                              color: AppColors
                                  .warning,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                'साठा अलर्ट मर्यादेपेक्षा कमी किंवा समान झाला की तो Low Stock म्हणून दाखवला जाईल.',
                                style:
                                    TextStyle(
                                  fontSize:
                                      10,
                                  color:
                                      AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
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
                                  : saveItem,
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
                                    ? 'अपडेट करा'
                                    : 'सेव्ह करा',
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
  // DELETE
  // ============================================================

  Future<void> _confirmDelete(InventoryModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('साठा हटवायचा आहे?'),
          content: Text(
            '“${item.itemName}” हा साठा कायमचा हटवला जाईल. '
            'ही कृती पूर्ववत करता येणार नाही.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('रद्द करा'),
            ),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('हटवा'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      final deleted =
          await _repository.deleteItem(item);

      if (!mounted) return;

      if (deleted) {
        await _loadInventory();

        _showMessage(
          '“${item.itemName}” साठा हटवला.',
        );
      } else {
        _showMessage(
          'साठा हटवता आला नाही. '
          'Firebase sync तपासा.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'साठा हटवताना त्रुटी आली.\n$e',
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
        currentIndex: 4,
        title: 'साठा',
        subtitle: 'Inventory Management',
        actions: [
          IconButton(
            tooltip: 'Refresh inventory',
            onPressed: _isLoading ? null : _loadInventory,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => _showItemDialog(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('नवीन साठा'),
          ),
          const SizedBox(width: 8),
        ],
        onDestinationSelected: _handleDesktopNavigation,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadInventory,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _buildDesktopContent(),
        ),
      );
    }

    // Existing mobile UI preserved.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('पशुखाद्य व साठा'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadInventory,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadInventory,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _buildContent(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('नवीन साठा'),
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
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDesktopIntro(),
                    const SizedBox(height: 18),
                    _buildDesktopSummary(),
                    const SizedBox(height: 18),
                    _buildDesktopToolbar(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'साठ्याच्या नोंदी',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${_filteredItems.length} नोंदी',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_filteredItems.isEmpty)
                      _buildEmptyState()
                    else
                      _buildDesktopInventoryGrid(
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
    final lowStockCount = _items.where(_isLowStock).length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'साठा व्यवस्थापन',
                style: TextStyle(
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'पशुखाद्य, औषध, मिनरल आणि इतर साहित्याचा साठा व alert मर्यादा एका ठिकाणी व्यवस्थापित करा.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (lowStockCount > 0)
          _desktopCountPill(
            icon: Icons.warning_amber_rounded,
            label: 'Low Stock',
            value: '$lowStockCount',
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
    final totalItems = _items.length;
    final lowStockCount = _items.where(_isLowStock).length;
    final normalStock = totalItems - lowStockCount;

    final categoryCounts = <String, int>{};
    for (final item in _items) {
      categoryCounts[item.category] =
          (categoryCounts[item.category] ?? 0) + 1;
    }

    String topCategory = '—';
    var topCategoryCount = 0;
    for (final entry in categoryCounts.entries) {
      if (entry.value > topCategoryCount) {
        topCategory = entry.key;
        topCategoryCount = entry.value;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _desktopMetric(
            icon: Icons.inventory_2_outlined,
            title: 'एकूण साहित्य',
            value: '$totalItems',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.check_circle_outline,
            title: 'पुरेसा साठा',
            value: '$normalStock',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.warning_amber_rounded,
            title: 'Low Stock',
            value: '$lowStockCount',
            color: lowStockCount > 0
                ? AppColors.error
                : AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _desktopMetric(
            icon: Icons.category_outlined,
            title: 'मुख्य category',
            value: topCategory,
            color: AppColors.secondary,
            subtitle: topCategoryCount > 0
                ? '$topCategoryCount items'
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
                    fontSize: value.length > 14 ? 12 : 20,
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

  Widget _buildDesktopToolbar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _desktopSearchController,
            decoration: InputDecoration(
              hintText: 'साहित्य, category किंवा unit शोधा...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _desktopSearchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _desktopSearchController.clear,
                      icon: const Icon(Icons.clear_rounded),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 210,
          child: DropdownButtonFormField<String>(
            initialValue: _desktopCategoryFilter,
            decoration: const InputDecoration(
              labelText: 'Category filter',
              prefixIcon: Icon(Icons.filter_alt_outlined),
            ),
            items: [
              const DropdownMenuItem(
                value: 'सर्व',
                child: Text('सर्व'),
              ),
              ..._categories.map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _desktopCategoryFilter = value;
              });
              _applyDesktopFilters();
            },
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 170,
          child: DropdownButtonFormField<String>(
            initialValue: _desktopStockFilter,
            decoration: const InputDecoration(
              labelText: 'Stock',
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
            items: const [
              DropdownMenuItem(
                value: 'सर्व',
                child: Text('सर्व'),
              ),
              DropdownMenuItem(
                value: 'Low Stock',
                child: Text('Low Stock'),
              ),
              DropdownMenuItem(
                value: 'Normal',
                child: Text('Normal'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _desktopStockFilter = value;
              });
              _applyDesktopFilters();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopInventoryGrid(int columns) {
    const gap = 14.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * gap)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _filteredItems.map(
            (item) {
              return SizedBox(
                width: cardWidth,
                child: _buildDesktopInventoryCard(item),
              );
            },
          ).toList(),
        );
      },
    );
  }

  Widget _buildDesktopInventoryCard(InventoryModel item) {
    final lowStock = _isLowStock(item);
    final stockColor =
        lowStock ? AppColors.error : AppColors.primary;

    final progress = item.minThreshold > 0
        ? (item.quantity / (item.minThreshold * 3))
            .clamp(0.0, 1.0)
        : item.quantity > 0
            ? 1.0
            : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: lowStock
              ? AppColors.error.withValues(alpha: 0.28)
              : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  lowStock
                      ? Icons.warning_amber_rounded
                      : Icons.inventory_2_outlined,
                  color: stockColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (lowStock)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'LOW STOCK',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _desktopStockValue(
                  label: 'सध्याचा साठा',
                  value:
                      '${_formatQuantity(item.quantity)} ${item.unit}',
                  color: stockColor,
                ),
              ),
              Expanded(
                child: _desktopStockValue(
                  label: 'Alert मर्यादा',
                  value:
                      '${_formatQuantity(item.minThreshold)} ${item.unit}',
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress,
              backgroundColor:
                  AppColors.divider.withValues(alpha: 0.45),
              color: stockColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lowStock
                ? 'साठा alert मर्यादेवर किंवा त्याखाली आहे — replenishment आवश्यक.'
                : 'साठा सध्या alert मर्यादेपेक्षा वर आहे.',
            style: TextStyle(
              fontSize: 8.5,
              color: lowStock
                  ? AppColors.error
                  : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showItemDialog(
                  existingItem: item,
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () => _confirmDelete(item),
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

  Widget _desktopStockValue({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

        _buildCategoryFilter(),

        const SizedBox(
          height: 16,
        ),

        if (_filteredItems.isEmpty)
          _buildEmptyState()
        else
          ..._filteredItems.map(
            (item) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              child:
                  _buildInventoryCard(
                item,
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
    final lowStockCount =
        _items.where(
      _isLowStock,
    ).length;

    final totalItems =
        _items.length;

    final normalStock =
        totalItems -
            lowStockCount;

    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
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
            'साठा आढावा',
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
            'Inventory Overview',
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
                  Icons.inventory_2_outlined,
                  'एकूण साहित्य',
                  '$totalItems',
                ),
              ),
              Expanded(
                child: _summaryItem(
                  Icons.check_circle_outline,
                  'पुरेसा साठा',
                  '$normalStock',
                ),
              ),
              Expanded(
                child: _summaryItem(
                  Icons.warning_amber_rounded,
                  'Low Stock',
                  '$lowStockCount',
                ),
              ),
            ],
          ),

          if (lowStockCount > 0) ...[
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
                      '$lowStockCount साहित्याचा साठा अलर्ट मर्यादेवर किंवा त्याखाली आहे.',
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
            'साहित्याचे नाव शोधा...',
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
  // CATEGORY FILTER
  // ============================================================

  Widget _buildCategoryFilter() {
    final categories = [
      'सर्व',
      ..._categories,
    ];

    return DropdownButtonFormField<
        String>(
      initialValue:
          _selectedCategory,
      isExpanded: true,
      items: categories
          .map(
            (category) =>
                DropdownMenuItem<
                    String>(
              value: category,
              child: Text(
                category == 'सर्व'
                    ? 'कॅटेगरी: सर्व'
                    : category,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _selectedCategory =
              value;
        });

        _applyFilters();
      },
      decoration:
          const InputDecoration(
        labelText:
            'कॅटेगरी फिल्टर',
        prefixIcon:
            Icon(
          Icons.filter_alt_outlined,
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildInventoryCard(
    InventoryModel item,
  ) {
    final lowStock =
        _isLowStock(item);

    final stockColor =
        lowStock
            ? AppColors.error
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
          color: lowStock
              ? AppColors.error
                  .withValues(
                  alpha: 0.25,
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
                  color: stockColor
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
                  lowStock
                      ? Icons
                          .warning_amber_rounded
                      : Icons
                          .inventory_2_outlined,
                  color:
                      stockColor,
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
                            item.itemName,
                            maxLines:
                                1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize:
                                  15,
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
                                  _showItemDialog(
                            existingItem:
                                item,
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
                              () => _confirmDelete(
                            item,
                          ),
                          icon:
                              const Icon(
                            Icons
                                .delete_outline_rounded,
                            size:
                                19,
                            color:
                                AppColors.error,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      item.category,
                      style:
                          const TextStyle(
                        fontSize: 10,
                        color: AppColors
                            .textSecondary,
                      ),
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
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _stockValue(
                  label:
                      'सध्याचा साठा',
                  value:
                      '${_formatQuantity(item.quantity)} ${item.unit}',
                  color:
                      stockColor,
                ),
              ),

              Expanded(
                child:
                    _stockValue(
                  label:
                      'अलर्ट मर्यादा',
                  value:
                      '${_formatQuantity(item.minThreshold)} ${item.unit}',
                  color:
                      AppColors.textPrimary,
                ),
              ),

              if (lowStock)
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color: AppColors
                        .error
                        .withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child:
                      const Text(
                    'LOW STOCK',
                    style:
                        TextStyle(
                      fontSize: 8,
                      fontWeight:
                          FontWeight
                              .w800,
                      color: AppColors
                          .error,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stockValue({
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
            _selectedCategory !=
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
                  .inventory_2_outlined,
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
                ? 'तुमच्या शोधानुसार साठा सापडला नाही'
                : 'अद्याप साठ्याची नोंद नाही',
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
                ? 'Search किंवा category filter बदलून पुन्हा प्रयत्न करा.'
                : 'पहिला साठा जोडण्यासाठी खालील बटन वापरा.',
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
                  _selectedCategory = 'सर्व';
                  _desktopCategoryFilter = 'सर्व';
                  _desktopStockFilter = 'सर्व';
                });

                _applyFilters();
                _applyDesktopFilters();
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

  String _formatQuantity(
    double value,
  ) {
    if (value == value.roundToDouble()) {
      return value
          .toStringAsFixed(0);
    }

    return value
        .toStringAsFixed(2);
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