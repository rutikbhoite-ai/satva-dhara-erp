import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../core/sync/models/sync_operation_model.dart';
import '../../../../core/sync/sync_queue_service.dart';
import '../../../../shared/widgets/desktop_app_shell.dart';

class SyncConflictsScreen extends StatefulWidget {
  const SyncConflictsScreen({super.key});

  @override
  State<SyncConflictsScreen> createState() =>
      _SyncConflictsScreenState();
}

class _SyncConflictsScreenState extends State<SyncConflictsScreen> {
  final SyncQueueService _queue = SyncQueueService.instance;

  List<SyncOperationModel> _conflicts = const [];
  bool _isLoading = true;
  bool _isWorking = false;

  @override
  void initState() {
    super.initState();
    _loadConflicts();
  }

  Future<void> _loadConflicts() async {
    if (kIsWeb) {
      if (mounted) {
        setState(() {
          _conflicts = const [];
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final conflicts = await _queue.getConflictOperations();

      if (!mounted) return;

      setState(() {
        _conflicts = conflicts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Sync conflicts मिळवताना त्रुटी आली.\n$e',
        isError: true,
      );
    }
  }

  Future<void> _retryConflict(
    SyncOperationModel operation,
  ) async {
    if (_isWorking) return;

    setState(() {
      _isWorking = true;
    });

    try {
      final success = await _queue.retryConflict(operation.id);

      if (!mounted) return;

      if (success) {
        _showMessage(
          '${_displayEntity(operation.entityType)} conflict पुन्हा sync queue मध्ये ठेवला आहे.',
        );
      } else {
        _showMessage(
          'हा conflict आता उपलब्ध नाही.',
          isError: true,
        );
      }

      await _loadConflicts();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Conflict retry करताना त्रुटी आली.\n$e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  Future<void> _dismissConflict(
    SyncOperationModel operation,
  ) async {
    if (_isWorking) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Conflict dismiss करायचा?'),
          content: const Text(
            'हा sync queue conflict कायमचा queue मधून काढला जाईल. '
            'यामुळे local business record किंवा Firestore document आपोआप बदलणार नाही.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('रद्द'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isWorking = true;
    });

    try {
      final success = await _queue.dismissConflict(operation.id);

      if (!mounted) return;

      if (success) {
        _showMessage('Conflict queue मधून dismiss केला आहे.');
      } else {
        _showMessage(
          'हा conflict आता उपलब्ध नाही.',
          isError: true,
        );
      }

      await _loadConflicts();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Conflict dismiss करताना त्रुटी आली.\n$e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            isError ? AppColors.error : AppColors.primary,
        content: Text(message),
      ),
    );
  }

  String _displayEntity(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return 'Record';

    return clean[0].toUpperCase() + clean.substring(1);
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}  '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 900) {
      return DesktopAppShell(
        currentIndex: 8,
        title: 'Sync Conflicts',
        subtitle: 'Review unresolved offline sync conflicts',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadConflicts,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        onDestinationSelected: (_) {},
        child: _buildContent(maxWidth: 1180),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sync Conflicts'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadConflicts,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent({double? maxWidth}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            if (kIsWeb)
              _buildWebUnavailableCard()
            else if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_conflicts.isEmpty)
              _buildEmptyState()
            else
              ..._conflicts.map(_buildConflictCard),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.sync_problem_rounded,
              color: AppColors.error,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unresolved Sync Conflicts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_conflicts.length} conflict${_conflicts.length == 1 ? '' : 's'} waiting for review.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Conflict म्हणजे local operation आणि sync state यांच्यात सुरक्षितपणे automatic निर्णय घेता आला नाही. Review करूनच Retry किंवा Dismiss करा.',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictCard(SyncOperationModel operation) {
    final payload = operation.payloadJson;
    String? formattedPayload;

    if (payload != null && payload.trim().isNotEmpty) {
      try {
        formattedPayload = const JsonEncoder.withIndent('  ')
            .convert(jsonDecode(payload));
      } catch (_) {
        formattedPayload = payload;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _statusBadge(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_displayEntity(operation.entityType)} • ${operation.operation.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _detailRow('Local ID', operation.localId.toString()),
          _detailRow(
            'Remote ID',
            operation.remoteId?.trim().isNotEmpty == true
                ? operation.remoteId!.trim()
                : 'Not assigned',
          ),
          _detailRow('Created', _formatDate(operation.createdAt)),
          if (operation.lastAttemptAt != null)
            _detailRow(
              'Last attempt',
              _formatDate(operation.lastAttemptAt!),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              operation.lastError?.trim().isNotEmpty == true
                  ? operation.lastError!.trim()
                  : 'No conflict message available.',
              style: const TextStyle(
                fontSize: 11,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (formattedPayload != null) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: const Text(
                'Queued payload',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SelectableText(
                    formattedPayload,
                    style: const TextStyle(
                      fontSize: 9,
                      height: 1.35,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _isWorking
                    ? null
                    : () => _dismissConflict(operation),
                icon: const Icon(Icons.close_rounded, size: 17),
                label: const Text('Dismiss'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.35),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: _isWorking
                    ? null
                    : () => _retryConflict(operation),
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: const Text('Retry Sync'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: AppColors.error,
          ),
          SizedBox(width: 5),
          Text(
            'CONFLICT',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 50,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.cloud_done_rounded,
            size: 48,
            color: AppColors.success,
          ),
          SizedBox(height: 12),
          Text(
            'No unresolved conflicts',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'सध्या कोणतीही sync conflict बाकी नाही.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebUnavailableCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.desktop_windows_outlined,
            size: 42,
            color: AppColors.primary,
          ),
          SizedBox(height: 10),
          Text(
            'Web conflict view unavailable',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Web साठी Firestore-based sync data layer पूर्ण झाल्यानंतर हा भाग उपलब्ध होईल.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
