import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/transport/transport_route.dart';
import '../../core/admin_colors.dart';
import '../../data/models/admin_route.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/repositories/route_repository.dart';
import '../../../admin_widgets/stat_card.dart';

/// RoutesScreen
/// BiliRoute Admin Portal screen for multi-step route management.
class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  String _searchQuery = '';
  RouteStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<RouteRepository>();

    var items = repo.items;
    if (_searchQuery.isNotEmpty) {
      items = repo.search(_searchQuery);
    }
    if (_filterStatus != null) {
      items = items.where((r) => r.status == _filterStatus).toList();
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
                const Icon(Icons.alt_route_rounded, color: AdminColors.routeAccent, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Route Management', style: Theme.of(context).textTheme.headlineSmall),
                      Text('${repo.items.length} routes · ${repo.activeCount} active',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showForm(context, null),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Route'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter chips
            Row(
              children: [
                _chip('All (${repo.items.length})', null, AdminColors.textSecondary),
                const SizedBox(width: 8),
                _chip('Active (${repo.activeCount})', RouteStatus.active, AdminColors.success),
                const SizedBox(width: 8),
                _chip('Inactive (${repo.items.where((r) => r.status == RouteStatus.inactive).length})', RouteStatus.inactive, AdminColors.textMuted),
              ],
            ),
            const SizedBox(height: 16),

            // Search
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search routes by title, starting point, or destination…',
                prefixIcon: Icon(Icons.search_rounded, size: 18),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: items.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.alt_route_rounded,
                      title: 'No routes found',
                      description: 'Try adjusting your search query or filters.',
                    )
                  : _buildTable(context, items, repo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, RouteStatus? status, Color color) {
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

  Widget _buildTable(BuildContext context, List<AdminRoute> items, RouteRepository repo) {
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
                  Expanded(flex: 3, child: _TH('ROUTE LABEL')),
                  Expanded(flex: 4, child: _TH('ROUTE STEPS SUMMARY')),
                  Expanded(flex: 2, child: _TH('TOTAL FARE')),
                  Expanded(flex: 2, child: _TH('DURATION')),
                  Expanded(flex: 2, child: _TH('STATUS')),
                  SizedBox(width: 110, child: _TH('ACTIONS')),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = items[i];
                  return InkWell(
                    onTap: () => _showForm(context, r),
                    hoverColor: AdminColors.tableRowHover,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.label, style: Theme.of(context).textTheme.labelLarge),
                                Text('${r.startingPoint} → ${r.destination}',
                                    style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(r.routeSummary,
                                style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textPrimary)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(r.totalFareLabel,
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AdminColors.success)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(r.totalDurationLabel, style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          Expanded(
                            flex: 2,
                            child: StatusBadge(
                              label: r.statusLabel,
                              color: r.statusColor,
                              icon: r.status == RouteStatus.active ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                            ),
                          ),
                          SizedBox(
                            width: 110,
                            child: Row(
                              children: [
                                Tooltip(
                                  message: r.status == RouteStatus.active ? 'Deactivate' : 'Activate',
                                  child: IconButton(
                                    onPressed: () async {
                                      if (r.status == RouteStatus.active) {
                                        await repo.deactivateRoute(r.id);
                                      } else {
                                        r.status = RouteStatus.active;
                                        await repo.updateRouteApi(r);
                                      }
                                    },
                                    icon: Icon(
                                      r.status == RouteStatus.active ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                                      size: 16,
                                      color: r.status == RouteStatus.active ? AdminColors.warning : AdminColors.success,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                Tooltip(
                                  message: 'Edit',
                                  child: IconButton(
                                    onPressed: () => _showForm(context, r),
                                    icon: const Icon(Icons.edit_rounded, size: 16, color: AdminColors.textSecondary),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                Tooltip(
                                  message: 'Delete',
                                  child: IconButton(
                                    onPressed: () async {
                                      await repo.deleteRoute(r.id);
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

  void _showForm(BuildContext context, AdminRoute? route) {
    showDialog(
      context: context,
      builder: (_) => RouteFormDialog(route: route),
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
// Multi-Step Route Builder Dialog
// ─────────────────────────────────────────────────────────────────────────────

class RouteFormDialog extends StatefulWidget {
  const RouteFormDialog({super.key, this.route});
  final AdminRoute? route;

  @override
  State<RouteFormDialog> createState() => _RouteFormDialogState();
}

class _RouteFormDialogState extends State<RouteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _startingPointCtrl;
  late String _selectedDestinationId;
  late String _selectedDestinationName;
  late RouteType _routeType;
  late RouteStatus _status;
  late List<AdminRouteStep> _steps;

  bool get _isEdit => widget.route != null;

  @override
  void initState() {
    super.initState();
    final r = widget.route;
    _labelCtrl = TextEditingController(text: r?.label ?? '');
    _startingPointCtrl = TextEditingController(text: r?.startingPoint ?? 'Naval');
    _selectedDestinationId = r?.destinationId ?? '';
    _selectedDestinationName = r?.destination ?? '';
    _routeType = r?.routeType ?? RouteType.mixed;
    _status = r?.status ?? RouteStatus.active;
    _steps = r?.steps.map((s) => s.copyWith()).toList() ?? [
      AdminRouteStep(
        id: 'step_1',
        from: 'Naval',
        to: 'Kawayan Port',
        transportType: TransportType.multicab,
        fareAmount: 55,
        durationMinutes: 45,
      ),
    ];
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _startingPointCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one route step is required.')),
      );
      return;
    }

    final repo = context.read<RouteRepository>();
    final dests = context.read<DestinationRepository>().items;

    String destName = _selectedDestinationName;
    if (dests.isNotEmpty && _selectedDestinationId.isNotEmpty) {
      final match = dests.firstWhere((d) => d.id == _selectedDestinationId, orElse: () => dests.first);
      destName = match.name;
    }

    try {
      if (_isEdit) {
        final updated = widget.route!.copyWith(
          label: _labelCtrl.text.trim(),
          startingPoint: _startingPointCtrl.text.trim(),
          destination: destName,
          destinationId: _selectedDestinationId,
          routeType: _routeType,
          steps: _steps,
          status: _status,
        );
        await repo.updateRouteApi(updated);
      } else {
        final newRoute = AdminRoute(
          id: 'route_${DateTime.now().millisecondsSinceEpoch}',
          label: _labelCtrl.text.trim(),
          startingPoint: _startingPointCtrl.text.trim(),
          destination: destName.isNotEmpty ? destName : 'Sambawan Island',
          destinationId: _selectedDestinationId.isNotEmpty ? _selectedDestinationId : '664b9b94098327918f77a83d',
          routeType: _routeType,
          steps: _steps,
          status: _status,
          dateAdded: DateTime.now(),
        );
        await repo.createRoute(newRoute);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving route: $e'), backgroundColor: AdminColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dests = context.watch<DestinationRepository>().items;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 720,
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
                    const Icon(Icons.alt_route_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isEdit ? 'Edit Multi-Step Route' : 'Create Multi-Step Route',
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
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _field('Route Label', _labelCtrl, hint: 'e.g. Budget Route — Sambawan', required: true),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _field('Starting Point', _startingPointCtrl, hint: 'e.g. Naval', required: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Destination Dropdown
                      Text('Destination', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
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
                            value: dests.any((d) => d.id == _selectedDestinationId) ? _selectedDestinationId : (dests.isNotEmpty ? dests.first.id : null),
                            isExpanded: true,
                            hint: const Text('Select Destination'),
                            items: dests.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _selectedDestinationId = v;
                                  _selectedDestinationName = dests.firstWhere((d) => d.id == v).name;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Multi-Step Builder Header
                      Row(
                        children: [
                          Text('Route Steps Sequence', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AdminColors.textPrimary)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                final lastTo = _steps.isNotEmpty ? _steps.last.to : 'Port';
                                _steps.add(AdminRouteStep(
                                  id: 'step_${_steps.length + 1}',
                                  from: lastTo,
                                  to: 'Destination',
                                  transportType: TransportType.boatCharter,
                                  fareAmount: 100,
                                  durationMinutes: 30,
                                ));
                              });
                            },
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add Step'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Steps List
                      ..._steps.asMap().entries.map((entry) {
                        final i = entry.key;
                        final step = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AdminColors.tableHeader,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdminColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AdminColors.navyBlue,
                                    child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Step ${i + 1}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                                  const Spacer(),
                                  if (_steps.length > 1)
                                    IconButton(
                                      onPressed: () => setState(() => _steps.removeAt(i)),
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AdminColors.danger),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: step.from,
                                      decoration: const InputDecoration(labelText: 'From'),
                                      onChanged: (v) => step.from = v,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: step.to,
                                      decoration: const InputDecoration(labelText: 'To'),
                                      onChanged: (v) => step.to = v,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: step.fareAmount.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Fare (₱)'),
                                      onChanged: (v) => step.fareAmount = int.tryParse(v) ?? 0,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: step.durationMinutes.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Minutes'),
                                      onChanged: (v) => step.durationMinutes = int.tryParse(v) ?? 0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
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
                    ElevatedButton(onPressed: _save, child: Text(_isEdit ? 'Save Changes' : 'Create Route')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          decoration: InputDecoration(hintText: hint),
          validator: required ? (v) => (v?.isEmpty ?? true) ? '$label required' : null : null,
        ),
      ],
    );
  }
}
