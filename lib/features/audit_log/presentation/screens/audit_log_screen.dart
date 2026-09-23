import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_colors.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/desktop_app_shell.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

import '../../data/audit_log_model.dart';
import '../../data/audit_log_service.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() =>
      _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final AuditLogService _service =
      AuditLogService.instance;

  final TextEditingController _searchController =
      TextEditingController();

  List<AuditLogModel> _logs = [];
  List<AuditLogModel> _filteredLogs = [];

  bool _isLoading = true;

  String _selectedModule = 'सर्व';
  String _selectedAction = 'सर्व';

  DateTime? _startDate;
  DateTime? _endDate;

  static const List<String> _modules = [
    'AUTH',
    'ANIMAL',
    'MILK',
    'EXPENSE',
    'INVENTORY',
    'HEALTH',
    'PREGNANCY',
    'REPORT',
    'SETTINGS',
  ];

  static const List<String> _actions = [
    'CREATE',
    'UPDATE',
    'DELETE',
    'LOGIN',
    'LOGOUT',
    'VIEW',
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _applyFilters,
    );

    _loadLogs();
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

  Future<void> _loadLogs() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data = await _service.getAllLogs(
        limit: 500,
      );

      if (!mounted) return;

      setState(() {
        _logs = data;
        _filteredLogs = data;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Audit log मिळवताना त्रुटी आली.\n$e',
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

    final result = _logs.where((log) {
      final searchableText = [
        log.userName,
        log.userEmail,
        log.userRole,
        log.action,
        log.module,
        log.summary,
        log.entityId,
        log.entityType,
      ].join(' ').toLowerCase();

      final matchesSearch =
          search.isEmpty ||
          searchableText.contains(search);

      final matchesModule =
          _selectedModule == 'सर्व' ||
          log.module == _selectedModule;

      final matchesAction =
          _selectedAction == 'सर्व' ||
          log.action == _selectedAction;

      final matchesStartDate =
          _startDate == null ||
          !log.createdAt.isBefore(
            DateTime(
              _startDate!.year,
              _startDate!.month,
              _startDate!.day,
            ),
          );

      final matchesEndDate =
          _endDate == null ||
          !log.createdAt.isAfter(
            DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day,
              23,
              59,
              59,
              999,
            ),
          );

      return matchesSearch &&
          matchesModule &&
          matchesAction &&
          matchesStartDate &&
          matchesEndDate;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredLogs = result;
    });
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'सुरुवातीची तारीख',
      cancelText: 'रद्द',
      confirmText: 'निवडा',
    );

    if (selected == null) return;

    setState(() {
      _startDate = selected;

      if (_endDate != null &&
          _endDate!.isBefore(selected)) {
        _endDate = selected;
      }
    });

    _applyFilters();
  }

  Future<void> _selectEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _endDate ?? DateTime.now(),
      firstDate:
          _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'शेवटची तारीख',
      cancelText: 'रद्द',
      confirmText: 'निवडा',
    );

    if (selected == null) return;

    setState(() {
      _endDate = selected;
    });

    _applyFilters();
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _selectedModule = 'सर्व';
      _selectedAction = 'सर्व';
      _startDate = null;
      _endDate = null;
    });

    _applyFilters();
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteLog(
    AuditLogModel log,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Audit Log Delete करायचा?',
          ),
          content: Text(
            'हा audit record कायमचा delete होईल.\n\n'
            '${log.summary}',
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
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final logId = log.id;

    if (logId == null || logId.trim().isEmpty) {
      if (!mounted) return;

      _showMessage(
        'Audit log ID उपलब्ध नाही.',
        isError: true,
      );

      return;
    }

    final success =
        await _service.deleteLog(logId);

    if (!mounted) return;

    if (success) {
      _showMessage(
        'Audit log delete झाला.',
      );

      await _loadLogs();
    } else {
      _showMessage(
        'Audit log delete करता आला नाही.',
        isError: true,
      );
    }
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
        currentIndex: 9,
        title: 'Audit Log',
        subtitle:
            'System Activity History',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _isLoading
                    ? null
                    : _loadLogs,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
        onDestinationSelected:
            _handleDesktopNavigation,
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _buildDesktopContent(),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Audit Log',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _isLoading
                    ? null
                    : _loadLogs,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadLogs,
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _buildMobileContent(),
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
        context.go(AppRoutes.auditLog,);
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
                    if (_filteredLogs
                        .isEmpty)
                      _buildEmptyState()
                    else
                      _buildDesktopLogTable(),
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
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Audit Log',
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
                'फार्ममध्ये झालेल्या सर्व महत्त्वाच्या activity चा इतिहास.',
                style: TextStyle(
                  fontSize: 11,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _countPill(
          Icons.history_rounded,
          'Records',
          '${_logs.length}',
          AppColors.primary,
        ),
      ],
    );
  }

  Widget _countPill(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
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
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildDesktopSummary() {
    final createCount =
        _logs
            .where(
              (log) =>
                  log.action == 'CREATE',
            )
            .length;

    final updateCount =
        _logs
            .where(
              (log) =>
                  log.action == 'UPDATE',
            )
            .length;

    final deleteCount =
        _logs
            .where(
              (log) =>
                  log.action == 'DELETE',
            )
            .length;

    final loginCount =
        _logs
            .where(
              (log) =>
                  log.action == 'LOGIN',
            )
            .length;

    return Row(
      children: [
        Expanded(
          child: _metric(
            icon: Icons.add_circle_outline,
            title: 'CREATE',
            value: '$createCount',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metric(
            icon: Icons.edit_outlined,
            title: 'UPDATE',
            value: '$updateCount',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metric(
            icon: Icons.delete_outline,
            title: 'DELETE',
            value: '$deleteCount',
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metric(
            icon: Icons.login_rounded,
            title: 'LOGIN',
            value: '$loginCount',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _metric({
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
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(10),
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
                  style:
                      const TextStyle(
                    fontSize: 9.5,
                    color:
                        AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
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
  // TOOLBAR
  // ============================================================

  Widget _buildDesktopToolbar() {
    return Row(
      children: [
        Expanded(
          child: _buildSearch(),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 180,
          child: _buildFilter(
            label: 'Module',
            value:
                _selectedModule,
            icon:
                Icons.apps_outlined,
            items: [
              'सर्व',
              ..._modules,
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedModule =
                    value;
              });

              _applyFilters();
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 180,
          child: _buildFilter(
            label: 'Action',
            value:
                _selectedAction,
            icon:
                Icons.bolt_outlined,
            items: [
              'सर्व',
              ..._actions,
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedAction =
                    value;
              });

              _applyFilters();
            },
          ),
        ),
        const SizedBox(width: 12),
        _dateButton(
          label: _startDate == null
              ? 'From'
              : _formatDate(
                  _startDate!,
                ),
          icon:
              Icons.calendar_today_outlined,
          onPressed:
              _selectStartDate,
        ),
        const SizedBox(width: 8),
        _dateButton(
          label: _endDate == null
              ? 'To'
              : _formatDate(
                  _endDate!,
                ),
          icon:
              Icons.event_outlined,
          onPressed:
              _selectEndDate,
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip:
              'Clear filters',
          onPressed:
              _hasActiveFilters()
                  ? _clearFilters
                  : null,
          icon: const Icon(
            Icons.filter_alt_off_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller:
          _searchController,
      decoration:
          InputDecoration(
        hintText:
            'User, email, action, module किंवा description शोधा...',
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

  Widget _buildFilter({
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
                DropdownMenuItem<String>(
              value: item,
              child: Text(item),
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

  Widget _dateButton({
    required String label,
    required IconData icon,
    required VoidCallback
        onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 16,
      ),
      label: Text(label),
      style:
          OutlinedButton.styleFrom(
        minimumSize:
            const Size(110, 48),
      ),
    );
  }

  // ============================================================
  // DESKTOP TABLE
  // ============================================================

  Widget _buildDesktopLogTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection:
              Axis.horizontal,
          child: DataTable(
            headingRowHeight: 48,
            dataRowMinHeight: 68,
            dataRowMaxHeight: 82,
            columns: const [
              DataColumn(
                label: Text('TIME'),
              ),
              DataColumn(
                label: Text('USER'),
              ),
              DataColumn(
                label: Text('ACTION'),
              ),
              DataColumn(
                label: Text('MODULE'),
              ),
              DataColumn(
                label: Text('DESCRIPTION'),
              ),
              DataColumn(
                label: Text('ENTITY'),
              ),
              DataColumn(
                label: Text(''),
              ),
            ],
            rows: _filteredLogs
                .map(
                  (log) =>
                      DataRow(
                    cells: [
                      DataCell(
                        Text(
                          _formatDateTime(
                            log.createdAt,
                          ),
                          style:
                              const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 170,
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                log.userName
                                        .trim()
                                        .isEmpty
                                    ? 'Unknown User'
                                    : log.userName,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                log.userEmail,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 9,
                                  color:
                                      AppColors
                                          .textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        _actionChip(
                          log.action,
                        ),
                      ),
                      DataCell(
                        _moduleChip(
                          log.module,
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 300,
                          child: Text(
                            log.summary,
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          log.entityId.trim().isEmpty
                              ? '—'
                              : log.entityId,
                          style:
                              const TextStyle(
                            fontSize: 10,
                            color:
                                AppColors
                                    .textSecondary,
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          tooltip:
                              'Delete',
                          onPressed:
                              () =>
                                  _deleteLog(
                            log,
                          ),
                          icon:
                              const Icon(
                            Icons
                                .delete_outline,
                            size: 18,
                            color:
                                AppColors
                                    .error,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileContent() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(16),
      children: [
        _buildMobileSummary(),
        const SizedBox(height: 16),
        _buildSearch(),
        const SizedBox(height: 12),
        _buildMobileFilters(),
        const SizedBox(height: 16),
        if (_filteredLogs.isEmpty)
          _buildEmptyState()
        else
          ..._filteredLogs.map(
            (log) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              child:
                  _buildLogCard(log),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMobileSummary() {
    return Container(
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'System Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Audit Log Overview',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child:
                    _mobileSummaryItem(
                  Icons.history,
                  'Records',
                  '${_logs.length}',
                ),
              ),
              Expanded(
                child:
                    _mobileSummaryItem(
                  Icons.add_circle_outline,
                  'Create',
                  '${_countAction('CREATE')}',
                ),
              ),
              Expanded(
                child:
                    _mobileSummaryItem(
                  Icons.edit_outlined,
                  'Update',
                  '${_countAction('UPDATE')}',
                ),
              ),
              Expanded(
                child:
                    _mobileSummaryItem(
                  Icons.delete_outline,
                  'Delete',
                  '${_countAction('DELETE')}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobileSummaryItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 19,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style:
              const TextStyle(
            color: Colors.white70,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFilter(
                label: 'Module',
                value:
                    _selectedModule,
                icon:
                    Icons.apps_outlined,
                items: [
                  'सर्व',
                  ..._modules,
                ],
                onChanged:
                    (value) {
                  if (value ==
                      null) {
                    return;
                  }

                  setState(() {
                    _selectedModule =
                        value;
                  });

                  _applyFilters();
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: _buildFilter(
                label: 'Action',
                value:
                    _selectedAction,
                icon:
                    Icons.bolt_outlined,
                items: [
                  'सर्व',
                  ..._actions,
                ],
                onChanged:
                    (value) {
                  if (value ==
                      null) {
                    return;
                  }

                  setState(() {
                    _selectedAction =
                        value;
                  });

                  _applyFilters();
                },
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
              child: _dateButton(
                label:
                    _startDate ==
                            null
                        ? 'From'
                        : _formatDate(
                            _startDate!,
                          ),
                icon:
                    Icons.calendar_today_outlined,
                onPressed:
                    _selectStartDate,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: _dateButton(
                label:
                    _endDate ==
                            null
                        ? 'To'
                        : _formatDate(
                            _endDate!,
                          ),
                icon:
                    Icons.event_outlined,
                onPressed:
                    _selectEndDate,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            IconButton(
              tooltip:
                  'Clear filters',
              onPressed:
                  _hasActiveFilters()
                      ? _clearFilters
                      : null,
              icon:
                  const Icon(
                Icons
                    .filter_alt_off_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // LOG CARD
  // ============================================================

  Widget _buildLogCard(
    AuditLogModel log,
  ) {
    final actionColor =
        _actionColor(
      log.action,
    );

    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color:
                      actionColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  _actionIcon(
                    log.action,
                  ),
                  color: actionColor,
                  size: 20,
                ),
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _actionChip(
                          log.action,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        _moduleChip(
                          log.module,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      log.summary,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity:
                    VisualDensity.compact,
                tooltip: 'Delete',
                onPressed:
                    () => _deleteLog(
                  log,
                ),
                icon:
                    const Icon(
                  Icons
                      .delete_outline,
                  size: 18,
                  color:
                      AppColors.error,
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
                child: _smallInfo(
                  icon:
                      Icons.person_outline,
                  label: 'User',
                  value:
                      log.userName
                              .trim()
                              .isEmpty
                          ? log.userEmail
                          : log.userName,
                ),
              ),
              Expanded(
                child: _smallInfo(
                  icon:
                      Icons.access_time_outlined,
                  label: 'Time',
                  value:
                      _formatDateTime(
                    log.createdAt,
                  ),
                ),
              ),
            ],
          ),
          if (log.entityId.trim().isNotEmpty) ...[
            const SizedBox(
              height: 9,
            ),
            _smallInfo(
              icon:
                  Icons.link_outlined,
              label:
                  log.entityType.trim().isEmpty
                      ? 'Entity'
                      : log.entityType,
              value:
                  log.entityId,
            ),
          ],
        ],
      ),
    );
  }

  Widget _smallInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color:
              AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(
                  fontSize: 8.5,
                  color:
                      AppColors.textTertiary,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                value,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontSize: 10.5,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CHIPS
  // ============================================================

  Widget _actionChip(
    String action,
  ) {
    final color =
        _actionColor(action);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color:
            color.withValues(
          alpha: 0.09,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        action,
        style: TextStyle(
          fontSize: 8,
          fontWeight:
              FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _moduleChip(
    String module,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.primaryLight,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        module,
        style:
            const TextStyle(
          fontSize: 8,
          fontWeight:
              FontWeight.w800,
          color:
              AppColors.primaryDark,
        ),
      ),
    );
  }

  Color _actionColor(
    String action,
  ) {
    switch (action) {
      case 'CREATE':
        return AppColors.primary;

      case 'UPDATE':
        return AppColors.info;

      case 'DELETE':
        return AppColors.error;

      case 'LOGIN':
        return AppColors.secondary;

      case 'LOGOUT':
        return AppColors.warning;

      case 'VIEW':
        return AppColors.textSecondary;

      default:
        return AppColors.textSecondary;
    }
  }

  IconData _actionIcon(
    String action,
  ) {
    switch (action) {
      case 'CREATE':
        return Icons.add_circle_outline;

      case 'UPDATE':
        return Icons.edit_outlined;

      case 'DELETE':
        return Icons.delete_outline;

      case 'LOGIN':
        return Icons.login_rounded;

      case 'LOGOUT':
        return Icons.logout_rounded;

      case 'VIEW':
        return Icons.visibility_outlined;

      default:
        return Icons.history_rounded;
    }
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    final hasFilter =
        _hasActiveFilters();

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 45,
      ),
      decoration:
          BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.divider,
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
              shape: BoxShape.circle,
            ),
            child:
                const Icon(
              Icons.history_rounded,
              size: 34,
              color:
                  AppColors.primary,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            hasFilter
                ? 'तुमच्या filter नुसार audit log सापडला नाही'
                : 'अद्याप कोणताही audit log नाही',
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
                : 'System मध्ये activity झाल्यावर audit records येथे दिसतील.',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 12,
              color:
                  AppColors.textSecondary,
            ),
          ),
          if (hasFilter) ...[
            const SizedBox(
              height: 16,
            ),
            OutlinedButton.icon(
              onPressed:
                  _clearFilters,
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

  int _countAction(
    String action,
  ) {
    return _logs
        .where(
          (log) =>
              log.action == action,
        )
        .length;
  }

  bool _hasActiveFilters() {
    return _searchController.text
            .trim()
            .isNotEmpty ||
        _selectedModule != 'सर्व' ||
        _selectedAction != 'सर्व' ||
        _startDate != null ||
        _endDate != null;
  }

  String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDateTime(
    DateTime date,
  ) {
    final datePart =
        _formatDate(date);

    final hour =
        date.hour.toString().padLeft(
              2,
              '0',
            );

    final minute =
        date.minute.toString().padLeft(
              2,
              '0',
            );

    return '$datePart $hour:$minute';
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