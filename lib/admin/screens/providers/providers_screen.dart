import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/admin_colors.dart';
import '../../data/models/admin_provider.dart';
import '../../data/repositories/provider_repository.dart';
import '../../../admin_widgets/stat_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProvidersScreen — Service Provider CRUD with verification
// ─────────────────────────────────────────────────────────────────────────────

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  String          _search = '';
  ProviderStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ProviderRepository>();

    var items = repo.getAll();
    if (_search.isNotEmpty) items = repo.search(_search);
    if (_filterStatus != null) {
      items = items.where((p) => p.status == _filterStatus).toList();
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
                const Icon(Icons.directions_car_rounded,
                    color: AdminColors.providerAccent, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service Providers',
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                        '${repo.verifiedCount} verified · ${repo.pendingCount} pending',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showForm(context, null),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Provider'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status filter chips
            Row(
              children: [
                _chip('All (${repo.count})',      null,                      AdminColors.textSecondary),
                const SizedBox(width: 8),
                _chip('Verified (${repo.verifiedCount})', ProviderStatus.verified,  AdminColors.success),
                const SizedBox(width: 8),
                _chip('Pending (${repo.pendingCount})',   ProviderStatus.pending,   AdminColors.warning),
              ],
            ),
            const SizedBox(height: 16),

            // Search
            TextField(
              decoration: const InputDecoration(
                hintText:   'Search providers by name, municipality, or service area…',
                prefixIcon: Icon(Icons.search_rounded, size: 18),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: items.isEmpty
                  ? AdminEmptyState(
                      icon:        Icons.people_outline_rounded,
                      title:       'No providers found',
                      description: 'Try adjusting your search or filters.',
                    )
                  : _buildTable(context, items, repo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, ProviderStatus? status, Color color) {
    final selected = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        selected ? color.withValues(alpha: 0.15) : AdminColors.tableHeader,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color : AdminColors.tableBorder,
              width: selected ? 1.5 : 1),
        ),
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? color : AdminColors.textSecondary,
        )),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<AdminProvider> items,
      ProviderRepository repo) {
    return Container(
      decoration: BoxDecoration(
        color:        AdminColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.cardBorder),
        boxShadow: const [BoxShadow(
            color: AdminColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header row
            Container(
              color: AdminColors.tableHeader,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: _TH('PROVIDER')),
                  Expanded(flex: 2, child: _TH('CATEGORY')),
                  Expanded(flex: 3, child: _TH('SERVICE AREA')),
                  Expanded(flex: 2, child: _TH('CONTACT')),
                  Expanded(flex: 2, child: _TH('STATUS')),
                  SizedBox(width: 100, child: _TH('ACTIONS')),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount:        items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = items[i];
                  return InkWell(
                    hoverColor: AdminColors.tableRowHover,
                    onTap: () => _showForm(context, p),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    style: Theme.of(context).textTheme.labelLarge),
                                Text(p.municipality,
                                    style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(p.providerType.icon,
                                    size: 14, color: p.providerType.color),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(p.providerType.label,
                                      style: Theme.of(context).textTheme.bodyMedium),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(p.serviceArea,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(p.contactNumber,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          Expanded(
                            flex: 2,
                            child: StatusBadge(
                              label: p.statusLabel,
                              color: p.statusColor,
                              icon: p.isVerified
                                  ? Icons.verified_rounded
                                  : Icons.hourglass_empty_rounded,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                if (p.status == ProviderStatus.pending)
                                  Tooltip(
                                    message: 'Verify',
                                    child: IconButton(
                                      onPressed: () => repo.verifyProvider(p.id,
                                          verifiedBy: 'Tourism Officer'),
                                      icon: const Icon(Icons.verified_rounded,
                                          size: 16, color: AdminColors.success),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                Tooltip(
                                  message: 'Edit',
                                  child: IconButton(
                                    onPressed: () => _showForm(context, p),
                                    icon: const Icon(Icons.edit_rounded,
                                        size: 16, color: AdminColors.textSecondary),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                Tooltip(
                                  message: 'Remove',
                                  child: IconButton(
                                    onPressed: () => repo.delete(p.id),
                                    icon: const Icon(Icons.delete_outline_rounded,
                                        size: 16, color: AdminColors.danger),
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

  void _showForm(BuildContext context, AdminProvider? provider) {
    showDialog(
      context: context,
      builder: (_) => _ProviderFormDialog(provider: provider),
    );
  }
}

class _TH extends StatelessWidget {
  const _TH(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700,
        color: AdminColors.textMuted, letterSpacing: 0.5,
      ));
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider Add/Edit Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _ProviderFormDialog extends StatefulWidget {
  const _ProviderFormDialog({this.provider});
  final AdminProvider? provider;

  @override
  State<_ProviderFormDialog> createState() => _ProviderFormDialogState();
}

class _ProviderFormDialogState extends State<_ProviderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _municipalityCtrl;
  late final TextEditingController _serviceAreaCtrl;
  late final TextEditingController _notesCtrl;
  late ProviderCategory _category;
  late ProviderStatus   _status;

  bool get _isEdit => widget.provider != null;

  @override
  void initState() {
    super.initState();
    final p = widget.provider;
    _nameCtrl         = TextEditingController(text: p?.name ?? '');
    _contactCtrl      = TextEditingController(text: p?.contactNumber ?? '');
    _municipalityCtrl = TextEditingController(text: p?.municipality ?? '');
    _serviceAreaCtrl  = TextEditingController(text: p?.serviceArea ?? '');
    _notesCtrl        = TextEditingController(text: p?.serviceNotes ?? '');
    _category         = p?.providerType ?? ProviderCategory.boatOperator;
    _status           = p?.status ?? ProviderStatus.pending;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _municipalityCtrl.dispose();
    _serviceAreaCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final repo = context.read<ProviderRepository>();

    if (_isEdit) {
      final updated = widget.provider!.copyWith(
        name:         _nameCtrl.text.trim(),
        contactNumber:_contactCtrl.text.trim(),
        municipality: _municipalityCtrl.text.trim(),
        serviceArea:  _serviceAreaCtrl.text.trim(),
        serviceNotes: _notesCtrl.text.trim(),
        providerType: _category,
        status:       _status,
      );
      repo.updateProvider(updated);
    } else {
      repo.create(AdminProvider(
        id:                       'sp-${DateTime.now().millisecondsSinceEpoch}',
        name:                     _nameCtrl.text.trim(),
        providerType:             _category,
        contactNumber:            _contactCtrl.text.trim(),
        municipality:             _municipalityCtrl.text.trim(),
        serviceArea:              _serviceAreaCtrl.text.trim(),
        compatibleTransportTypes: [],
        status:                   _status,
        serviceNotes:             _notesCtrl.text.trim(),
        dateAdded:                DateTime.now(),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 520,
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
                    const Icon(Icons.directions_car_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isEdit ? 'Edit Provider' : 'Add Provider',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white70, size: 18),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(child: _tf('Provider Name', _nameCtrl, required: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _tf('Contact Number', _contactCtrl, required: true)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _tf('Municipality', _municipalityCtrl)),
                        const SizedBox(width: 12),
                        Expanded(child: _tf('Service Area', _serviceAreaCtrl)),
                      ]),
                      const SizedBox(height: 12),
                      _tf('Service Notes', _notesCtrl, maxLines: 2),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _catDropdown()),
                        const SizedBox(width: 12),
                        Expanded(child: _statusDropdown()),
                      ]),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: _save,
                        child: Text(_isEdit ? 'Save' : 'Add Provider')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tf(String label, TextEditingController c,
      {bool required = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: AdminColors.textPrimary)),
        const SizedBox(height: 5),
        TextFormField(
          controller: c, maxLines: maxLines,
          validator: required
              ? (v) => (v?.isEmpty ?? true) ? '$label required' : null
              : null,
        ),
      ],
    );
  }

  Widget _catDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: AdminColors.textPrimary)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AdminColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AdminColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ProviderCategory>(
              value: _category, isExpanded: true,
              items: ProviderCategory.values.map((c) => DropdownMenuItem(
                value: c,
                child: Text('${c.emoji} ${c.label}',
                    style: GoogleFonts.inter(fontSize: 13)),
              )).toList(),
              onChanged: (v) { if (v != null) setState(() => _category = v); },
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: AdminColors.textPrimary)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AdminColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AdminColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ProviderStatus>(
              value: _status, isExpanded: true,
              items: ProviderStatus.values.map((s) => DropdownMenuItem(
                value: s,
                child: Text(s.name, style: GoogleFonts.inter(fontSize: 13)),
              )).toList(),
              onChanged: (v) { if (v != null) setState(() => _status = v); },
            ),
          ),
        ),
      ],
    );
  }
}
