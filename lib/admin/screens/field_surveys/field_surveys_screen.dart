import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/admin_colors.dart';
import '../../data/models/field_survey_record.dart';
import '../../data/repositories/field_survey_repository.dart';
import '../../../admin_widgets/stat_card.dart';

/// FieldSurveysScreen
/// BiliRoute Admin Portal screen for managing primary GPS field surveys and verification.
class FieldSurveysScreen extends StatefulWidget {
  const FieldSurveysScreen({super.key});

  @override
  State<FieldSurveysScreen> createState() => _FieldSurveysScreenState();
}

class _FieldSurveysScreenState extends State<FieldSurveysScreen> {
  String _searchQuery = '';
  SurveyStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FieldSurveyRepository>();

    var items = repo.items;
    if (_searchQuery.isNotEmpty) {
      items = items
          .where((s) =>
              s.destinationName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.surveyorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.municipality.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_filterStatus != null) {
      items = items.where((s) => s.status == _filterStatus).toList();
    }

    return Scaffold(
      backgroundColor: AdminColors.contentBg,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────────
            _buildHeader(context, repo),
            const SizedBox(height: 20),

            // ── Status Chips ──────────────────────────────────────────────────
            _buildStatusChips(repo),
            const SizedBox(height: 20),

            // ── Search Bar ────────────────────────────────────────────────────
            _buildSearchBar(context),
            const SizedBox(height: 16),

            // ── Survey Table ──────────────────────────────────────────────────
            Expanded(child: _buildTable(context, items, repo)),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, FieldSurveyRepository repo) {
    return Row(
      children: [
        const Icon(Icons.gps_fixed_rounded, color: AdminColors.surveyAccent, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Field Survey Records',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text('${repo.items.length} total surveys · ${repo.validatedCount} validated / approved',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => repo.fetchSurveys(),
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Refresh Data'),
        ),
      ],
    );
  }

  // ── Status summary chips ────────────────────────────────────────────────────

  Widget _buildStatusChips(FieldSurveyRepository repo) {
    final statuses = [
      (status: null,                   label: 'All (${repo.items.length})',   color: AdminColors.textSecondary),
      (status: SurveyStatus.pending,   label: 'Pending (${repo.pendingCount})', color: AdminColors.warning),
      (status: SurveyStatus.validated, label: 'Validated (${repo.validatedCount})', color: AdminColors.success),
      (status: SurveyStatus.rejected,  label: 'Rejected (${repo.items.where((s) => s.status == SurveyStatus.rejected).length})', color: AdminColors.danger),
    ];

    return Wrap(
      spacing: 8,
      children: statuses.map((s) {
        final selected = _filterStatus == s.status;
        return GestureDetector(
          onTap: () => setState(() => _filterStatus = s.status),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? s.color.withValues(alpha: 0.15) : AdminColors.tableHeader,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? s.color : AdminColors.tableBorder,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              s.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? s.color : AdminColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Search field surveys by destination, surveyor, or municipality…',
        prefixIcon: Icon(Icons.search_rounded, size: 18),
      ),
      onChanged: (v) => setState(() => _searchQuery = v),
    );
  }

  // ── Table ───────────────────────────────────────────────────────────────────

  Widget _buildTable(
      BuildContext context, List<FieldSurveyRecord> items, FieldSurveyRepository repo) {
    if (items.isEmpty) {
      return AdminEmptyState(
        icon: Icons.gps_off_rounded,
        title: 'No field surveys found',
        description: _searchQuery.isNotEmpty
            ? 'No records matching "$_searchQuery".'
            : 'No field surveys match the selected status filter.',
        action: _searchQuery.isNotEmpty || _filterStatus != null
            ? TextButton.icon(
                onPressed: () => setState(() {
                  _searchQuery = '';
                  _filterStatus = null;
                }),
                icon: const Icon(Icons.clear_rounded, size: 14),
                label: const Text('Clear Filters'),
              )
            : null,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.cardBorder),
        boxShadow: const [BoxShadow(color: AdminColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _TableHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) => _SurveyRow(
                  survey: items[i],
                  onViewDetails: () => _showDetailsModal(context, items[i], repo),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsModal(BuildContext context, FieldSurveyRecord survey, FieldSurveyRepository repo) {
    showDialog(
      context: context,
      builder: (_) => SurveyDetailsDialog(survey: survey, repo: repo),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Table header row
// ─────────────────────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AdminColors.textMuted,
      letterSpacing: 0.5,
    );
    return Container(
      color: AdminColors.tableHeader,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('DESTINATION', style: style)),
          Expanded(flex: 3, child: Text('GPS COORDINATES', style: style)),
          Expanded(flex: 2, child: Text('SURVEYOR TEAM', style: style)),
          Expanded(flex: 2, child: Text('SURVEY DATE', style: style)),
          Expanded(flex: 2, child: Text('STATUS', style: style)),
          SizedBox(width: 100, child: Text('ACTIONS', style: style)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual survey row
// ─────────────────────────────────────────────────────────────────────────────

class _SurveyRow extends StatelessWidget {
  const _SurveyRow({required this.survey, required this.onViewDetails});
  final FieldSurveyRecord survey;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final statusColor = survey.status == SurveyStatus.validated || survey.status == SurveyStatus.published
        ? AdminColors.success
        : survey.status == SurveyStatus.rejected
            ? AdminColors.danger
            : AdminColors.warning;

    return InkWell(
      onTap: onViewDetails,
      hoverColor: AdminColors.tableRowHover,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Destination
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(survey.destinationName, style: Theme.of(context).textTheme.labelLarge),
                  Text('${survey.municipality}, ${survey.barangay}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            // GPS
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(survey.coordinatesDisplay, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AdminColors.textPrimary)),
                  Text('Accuracy: ${survey.accuracyDisplay}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            // Surveyor
            Expanded(
              flex: 2,
              child: Text(survey.surveyorName, style: Theme.of(context).textTheme.bodyMedium),
            ),
            // Date
            Expanded(
              flex: 2,
              child: Text(survey.surveyDateDisplay, style: Theme.of(context).textTheme.bodyMedium),
            ),
            // Status
            Expanded(
              flex: 2,
              child: StatusBadge(
                label: survey.status.label,
                color: statusColor,
                icon: survey.status == SurveyStatus.pending
                    ? Icons.pending_rounded
                    : survey.status == SurveyStatus.rejected
                        ? Icons.cancel_rounded
                        : Icons.check_circle_rounded,
              ),
            ),
            // Action
            SizedBox(
              width: 100,
              child: ElevatedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.visibility_rounded, size: 14),
                label: const Text('Review', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Survey Details & Review Dialog
// ─────────────────────────────────────────────────────────────────────────────

class SurveyDetailsDialog extends StatefulWidget {
  const SurveyDetailsDialog({super.key, required this.survey, required this.repo});
  final FieldSurveyRecord survey;
  final FieldSurveyRepository repo;

  @override
  State<SurveyDetailsDialog> createState() => _SurveyDetailsDialogState();
}

class _SurveyDetailsDialogState extends State<SurveyDetailsDialog> {
  final TextEditingController _reviewNotesCtrl = TextEditingController();

  @override
  void dispose() {
    _reviewNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.survey;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 680,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              decoration: const BoxDecoration(
                color: AdminColors.navyBlue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Field Survey Review — ${s.destinationName}',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Info Row
                    Row(
                      children: [
                        Expanded(child: _infoBlock('SURVEYOR TEAM', s.surveyorName)),
                        Expanded(child: _infoBlock('SURVEY DATE', s.surveyDateDisplay)),
                        Expanded(child: _infoBlock('STATUS', s.status.label)),
                      ],
                    ),
                    const Divider(height: 24),

                    // GPS Block
                    Text('GeoJSON GPS Coordinates', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AdminColors.textPrimary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AdminColors.tableHeader,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AdminColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText('Coordinates: [${s.gpsLongitude.toStringAsFixed(6)}, ${s.gpsLatitude.toStringAsFixed(6)}]',
                              style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700, color: AdminColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('Latitude: ${s.gpsLatitude} | Longitude: ${s.gpsLongitude} | Accuracy: ${s.accuracyDisplay}',
                              style: GoogleFonts.inter(fontSize: 11, color: AdminColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field Observations
                    if (s.observations != null && s.observations!.isNotEmpty) ...[
                      Text('Raw Field Notes & Observations', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AdminColors.textPrimary)),
                      const SizedBox(height: 6),
                      Text(s.observations!, style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: AdminColors.textSecondary)),
                      const SizedBox(height: 16),
                    ],

                    // Access & Weather
                    Row(
                      children: [
                        if (s.weatherCondition != null)
                          Expanded(child: _infoBlock('WEATHER CONDITION', s.weatherCondition!)),
                        if (s.accessCondition != null)
                          Expanded(child: _infoBlock('ACCESS & TRANSPORT', s.accessCondition!)),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Review notes input
                    Text('Reviewer Notes & Verification Decision', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AdminColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _reviewNotesCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Enter review comments or approval rationale…',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            // Actions Footer
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Close'),
                  ),
                  const Spacer(),
                  // Reject Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.danger,
                      side: const BorderSide(color: AdminColors.danger),
                    ),
                    onPressed: () async {
                      final ok = await widget.repo.rejectSurvey(s.id, reviewNotes: _reviewNotesCtrl.text.trim());
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'Field survey record rejected.' : 'Failed to reject survey.'),
                            backgroundColor: AdminColors.danger,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.cancel_rounded, size: 16),
                    label: const Text('Reject Survey'),
                  ),
                  const SizedBox(width: 10),
                  // Approve Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AdminColors.success),
                    onPressed: () async {
                      final ok = await widget.repo.approveSurvey(s.id, reviewNotes: _reviewNotesCtrl.text.trim());
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'Field survey approved & linked to destination!' : 'Failed to approve survey.'),
                            backgroundColor: AdminColors.success,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                    label: const Text('Approve & Link Destination'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBlock(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AdminColors.textMuted)),
        const SizedBox(height: 2),
        Text(content, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
      ],
    );
  }
}
