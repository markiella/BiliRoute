import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/admin_colors.dart';
import '../../data/models/admin_schedule.dart';
import '../../data/repositories/provider_repository.dart';
import '../../data/repositories/route_repository.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../../admin_widgets/stat_card.dart';

/// SchedulesScreen
/// BiliRoute Admin Portal screen for managing transport departure schedules.
class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  String _searchQuery = '';
  ScheduleStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ScheduleRepository>();

    var items = repo.items;
    if (_searchQuery.isNotEmpty) {
      items = items.where((s) =>
          s.providerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.routeLabel.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
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
            // Header
            Row(
              children: [
                const Icon(Icons.schedule_rounded, color: AdminColors.royalBlue, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transport Schedules', style: Theme.of(context).textTheme.headlineSmall),
                      Text('${repo.items.length} total schedules · ${repo.getActive().length} active',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showForm(context, null),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Schedule'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status Chips
            Row(
              children: [
                _chip('All (${repo.items.length})', null, AdminColors.textSecondary),
                const SizedBox(width: 8),
                _chip('Active (${repo.getActive().length})', ScheduleStatus.active, AdminColors.success),
                const SizedBox(width: 8),
                _chip('Seasonal (${repo.items.where((s) => s.status == ScheduleStatus.seasonal).length})', ScheduleStatus.seasonal, AdminColors.warning),
              ],
            ),
            const SizedBox(height: 16),

            // Search
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search schedules by provider or route name…',
                prefixIcon: Icon(Icons.search_rounded, size: 18),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: items.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.schedule_rounded,
                      title: 'No schedules found',
                      description: 'Try adjusting your search query or status filter.',
                    )
                  : _buildTable(context, items, repo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, ScheduleStatus? status, Color color) {
    final selected = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AdminColors.tableHeader,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? color : AdminColors.tableBorder, width: selected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? color : AdminColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<AdminSchedule> items, ScheduleRepository repo) {
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
            Container(
              color: AdminColors.tableHeader,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: _TH('PROVIDER')),
                  Expanded(flex: 3, child: _TH('ROUTE')),
                  Expanded(flex: 3, child: _TH('DEPARTURE TIMES')),
                  Expanded(flex: 2, child: _TH('DAYS')),
                  Expanded(flex: 2, child: _TH('STATUS')),
                  SizedBox(width: 100, child: _TH('ACTIONS')),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final s = items[i];
                  return InkWell(
                    onTap: () => _showForm(context, s),
                    hoverColor: AdminColors.tableRowHover,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(s.providerName, style: Theme.of(context).textTheme.labelLarge),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(s.routeLabel, style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(s.departureDisplay,
                                style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(s.daysDisplay, style: Theme.of(context).textTheme.bodySmall),
                          ),
                          Expanded(
                            flex: 2,
                            child: StatusBadge(
                              label: s.statusLabel,
                              color: s.status == ScheduleStatus.active
                                  ? AdminColors.success
                                  : s.status == ScheduleStatus.seasonal
                                      ? AdminColors.warning
                                      : AdminColors.textMuted,
                              icon: Icons.access_time_rounded,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                Tooltip(
                                  message: 'Edit',
                                  child: IconButton(
                                    onPressed: () => _showForm(context, s),
                                    icon: const Icon(Icons.edit_rounded, size: 16, color: AdminColors.textSecondary),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                Tooltip(
                                  message: 'Delete',
                                  child: IconButton(
                                    onPressed: () async {
                                      await repo.deleteSchedule(s.id);
                                    },
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AdminColors.danger),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForm(BuildContext context, AdminSchedule? schedule) {
    showDialog(
      context: context,
      builder: (_) => ScheduleFormDialog(schedule: schedule),
    );
  }
}

class _TH extends StatelessWidget {
  const _TH(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AdminColors.textMuted,
          letterSpacing: 0.5,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Schedule Add/Edit Form Dialog
// ─────────────────────────────────────────────────────────────────────────────

class ScheduleFormDialog extends StatefulWidget {
  const ScheduleFormDialog({super.key, this.schedule});
  final AdminSchedule? schedule;

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedProviderId;
  late String _selectedRouteId;
  late final TextEditingController _departuresCtrl;
  late final TextEditingController _daysCtrl;
  late final TextEditingController _notesCtrl;
  late ScheduleStatus _status;

  bool get _isEdit => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _selectedProviderId = s?.providerId ?? '';
    _selectedRouteId = s?.routeId ?? '';
    _departuresCtrl = TextEditingController(text: s?.departureTimes.join(', ') ?? '06:00, 08:00, 10:00');
    _daysCtrl = TextEditingController(text: s?.operatingDays.join(', ') ?? 'Mon, Tue, Wed, Thu, Fri, Sat, Sun');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _status = s?.status ?? ScheduleStatus.active;
  }

  @override
  void dispose() {
    _departuresCtrl.dispose();
    _daysCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = context.read<ScheduleRepository>();
    final providers = context.read<ProviderRepository>().items;
    final routes = context.read<RouteRepository>().items;

    final prov = providers.firstWhere((p) => p.id == _selectedProviderId, orElse: () => providers.first);
    final rt = routes.firstWhere((r) => r.id == _selectedRouteId, orElse: () => routes.first);

    final departures = _departuresCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final days = _daysCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    try {
      if (_isEdit) {
        final updated = widget.schedule!.copyWith(
          providerId: prov.id,
          providerName: prov.name,
          routeId: rt.id,
          routeLabel: rt.label,
          departureTimes: departures,
          operatingDays: days,
          status: _status,
          notes: _notesCtrl.text.trim(),
        );
        await repo.updateScheduleApi(updated);
      } else {
        final newSched = AdminSchedule(
          id: 'sched_${DateTime.now().millisecondsSinceEpoch}',
          providerId: prov.id,
          providerName: prov.name,
          routeId: rt.id,
          routeLabel: rt.label,
          departureTimes: departures,
          operatingDays: days,
          status: _status,
          notes: _notesCtrl.text.trim(),
          dateAdded: DateTime.now(),
        );
        await repo.createSchedule(newSched);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving schedule: $e'), backgroundColor: AdminColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<ProviderRepository>().items;
    final routes = context.watch<RouteRepository>().items;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 580,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                decoration: const BoxDecoration(
                  color: AdminColors.navyBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isEdit ? 'Edit Transport Schedule' : 'Add Transport Schedule',
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
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Provider Select
                      Text('Transport Provider', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AdminColors.inputFill,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AdminColors.inputBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: providers.any((p) => p.id == _selectedProviderId) ? _selectedProviderId : (providers.isNotEmpty ? providers.first.id : null),
                            isExpanded: true,
                            hint: const Text('Select Provider'),
                            items: providers.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.name} (${p.providerType.label})'))).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedProviderId = v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Route Select
                      Text('Target Route', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AdminColors.inputFill,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AdminColors.inputBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: routes.any((r) => r.id == _selectedRouteId) ? _selectedRouteId : (routes.isNotEmpty ? routes.first.id : null),
                            isExpanded: true,
                            hint: const Text('Select Route'),
                            items: routes.map((r) => DropdownMenuItem(value: r.id, child: Text(r.label))).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedRouteId = v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _departuresCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Departure Times (comma-separated)',
                          hintText: '06:00, 08:00, 10:00',
                        ),
                        validator: (v) => (v?.isEmpty ?? true) ? 'Departure times required' : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _daysCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Operating Days (comma-separated)',
                          hintText: 'Mon, Tue, Wed, Thu, Fri, Sat, Sun',
                        ),
                        validator: (v) => (v?.isEmpty ?? true) ? 'Operating days required' : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(labelText: 'Notes / Weather Dependencies'),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 10),
                    ElevatedButton(onPressed: _save, child: Text(_isEdit ? 'Save Schedule' : 'Add Schedule')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
