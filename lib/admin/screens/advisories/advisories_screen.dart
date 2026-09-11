import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/admin_colors.dart';
import '../../data/models/admin_advisory.dart';
import '../../data/repositories/advisory_repository.dart';
import '../../data/repositories/destination_repository.dart';
import '../../../admin_widgets/stat_card.dart';

/// AdvisoriesScreen
/// BiliRoute Admin Portal screen for managing safety and weather travel advisories.
class AdvisoriesScreen extends StatefulWidget {
  const AdvisoriesScreen({super.key});

  @override
  State<AdvisoriesScreen> createState() => _AdvisoriesScreenState();
}

class _AdvisoriesScreenState extends State<AdvisoriesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdvisoryRepository>();

    var items = repo.items;
    if (_searchQuery.isNotEmpty) {
      items = items.where((a) =>
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
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
                const Icon(Icons.warning_amber_rounded, color: AdminColors.advisoryAccent, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Travel Advisories', style: Theme.of(context).textTheme.headlineSmall),
                      Text('${repo.items.length} total advisories · ${repo.activeCount} active & published',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showForm(context, null),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('New Advisory'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search advisories by title or message…',
                prefixIcon: Icon(Icons.search_rounded, size: 18),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: items.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.warning_amber_rounded,
                      title: 'No advisories found',
                      description: 'Try adjusting your search query.',
                    )
                  : _buildTable(context, items, repo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<AdminAdvisory> items, AdvisoryRepository repo) {
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
                  Expanded(flex: 3, child: _TH('ADVISORY TITLE')),
                  Expanded(flex: 2, child: _TH('CATEGORY')),
                  Expanded(flex: 2, child: _TH('SEVERITY')),
                  Expanded(flex: 2, child: _TH('STATUS')),
                  Expanded(flex: 2, child: _TH('ISSUED BY')),
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
                  final a = items[i];
                  return InkWell(
                    onTap: () => _showForm(context, a),
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
                                Text(a.title, style: Theme.of(context).textTheme.labelLarge),
                                Text(a.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('${a.category.emoji} ${a.category.label}', style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          Expanded(
                            flex: 2,
                            child: StatusBadge(
                              label: a.severityLabel,
                              color: a.severityColor,
                              icon: Icons.warning_rounded,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: StatusBadge(
                              label: a.statusLabel,
                              color: a.statusColor,
                              icon: a.isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(a.publishedBy ?? 'Tourism Office', style: Theme.of(context).textTheme.bodySmall),
                          ),
                          SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                if (a.isActive)
                                  Tooltip(
                                    message: 'Deactivate',
                                    child: IconButton(
                                      onPressed: () async {
                                        await repo.deactivateAdvisory(a.id);
                                      },
                                      icon: const Icon(Icons.pause_circle_outline_rounded, size: 16, color: AdminColors.warning),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                Tooltip(
                                  message: 'Edit',
                                  child: IconButton(
                                    onPressed: () => _showForm(context, a),
                                    icon: const Icon(Icons.edit_rounded, size: 16, color: AdminColors.textSecondary),
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

  void _showForm(BuildContext context, AdminAdvisory? advisory) {
    showDialog(
      context: context,
      builder: (_) => AdvisoryFormDialog(advisory: advisory),
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
// Advisory Form Dialog
// ─────────────────────────────────────────────────────────────────────────────

class AdvisoryFormDialog extends StatefulWidget {
  const AdvisoryFormDialog({super.key, this.advisory});
  final AdminAdvisory? advisory;

  @override
  State<AdvisoryFormDialog> createState() => _AdvisoryFormDialogState();
}

class _AdvisoryFormDialogState extends State<AdvisoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _msgCtrl;
  late final TextEditingController _issuedByCtrl;
  late AdvisoryCategory _category;
  late AdvisorySeverity _severity;
  late AdvisoryStatus _status;
  late DateTime _startDate;
  late DateTime _endDate;
  final List<String> _selectedDestinationIds = [];

  bool get _isEdit => widget.advisory != null;

  @override
  void initState() {
    super.initState();
    final a = widget.advisory;
    _titleCtrl = TextEditingController(text: a?.title ?? '');
    _msgCtrl = TextEditingController(text: a?.description ?? '');
    _issuedByCtrl = TextEditingController(text: a?.publishedBy ?? 'Biliran Tourism Office');
    _category = a?.category ?? AdvisoryCategory.weather;
    _severity = a?.severity ?? AdvisorySeverity.moderate;
    _status = a?.status ?? AdvisoryStatus.published;
    _startDate = a?.startDate ?? DateTime.now();
    _endDate = a?.endDate ?? DateTime.now().add(const Duration(days: 7));
    if (a != null) {
      _selectedDestinationIds.addAll(a.affectedDestinationIds);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    _issuedByCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = context.read<AdvisoryRepository>();

    try {
      if (_isEdit) {
        final updated = widget.advisory!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _msgCtrl.text.trim(),
          category: _category,
          severity: _severity,
          status: _status,
          startDate: _startDate,
          endDate: _endDate,
          publishedBy: _issuedByCtrl.text.trim(),
          affectedDestinationIds: _selectedDestinationIds,
        );
        await repo.updateAdvisoryApi(updated);
      } else {
        final newAdv = AdminAdvisory(
          id: 'adv_${DateTime.now().millisecondsSinceEpoch}',
          title: _titleCtrl.text.trim(),
          description: _msgCtrl.text.trim(),
          category: _category,
          severity: _severity,
          status: _status,
          startDate: _startDate,
          endDate: _endDate,
          publishedBy: _issuedByCtrl.text.trim(),
          affectedDestinationIds: _selectedDestinationIds,
          dateAdded: DateTime.now(),
        );
        await repo.createAdvisory(newAdv);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving advisory: $e'), backgroundColor: AdminColors.danger),
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
        width: 600,
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
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isEdit ? 'Edit Advisory' : 'Create Travel Advisory',
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
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'Advisory Title', hintText: 'e.g. Gale Warning — Sea Travel Suspended'),
                        validator: (v) => (v?.isEmpty ?? true) ? 'Title required' : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _msgCtrl,
                        decoration: const InputDecoration(labelText: 'Message / Details'),
                        maxLines: 3,
                        validator: (v) => (v?.isEmpty ?? true) ? 'Message required' : null,
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<AdvisoryCategory>(
                              initialValue: _category,
                              decoration: const InputDecoration(labelText: 'Category'),
                              items: AdvisoryCategory.values
                                  .map((c) => DropdownMenuItem(value: c, child: Text('${c.emoji} ${c.label}')))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _category = v);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<AdvisorySeverity>(
                              initialValue: _severity,
                              decoration: const InputDecoration(labelText: 'Severity'),
                              items: AdvisorySeverity.values
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase())))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _severity = v);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _issuedByCtrl,
                        decoration: const InputDecoration(labelText: 'Issued By Agency'),
                      ),
                      const SizedBox(height: 14),

                      // Destination selection
                      if (dests.isNotEmpty) ...[
                        Text('Affected Destinations', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: dests.map((d) {
                            final selected = _selectedDestinationIds.contains(d.id);
                            return FilterChip(
                              label: Text(d.name, style: const TextStyle(fontSize: 11)),
                              selected: selected,
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedDestinationIds.add(d.id);
                                  } else {
                                    _selectedDestinationIds.remove(d.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
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
                    ElevatedButton(onPressed: _save, child: Text(_isEdit ? 'Save Changes' : 'Publish Advisory')),
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
