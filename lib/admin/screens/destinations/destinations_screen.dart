import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/admin_colors.dart';
import '../../data/models/admin_destination.dart';
import '../../data/repositories/destination_repository.dart';
import '../../../admin_widgets/stat_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DestinationsScreen — Destination CRUD with Verification Workflow
// ─────────────────────────────────────────────────────────────────────────────

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  String              _searchQuery  = '';
  DestinationStatus?  _filterStatus;
  DestinationCategory? _filterCategory;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DestinationRepository>();

    // Apply filters
    var items = repo.getAll();
    if (_searchQuery.isNotEmpty) {
      items = repo.search(_searchQuery);
    }
    if (_filterStatus != null) {
      items = items.where((d) => d.status == _filterStatus).toList();
    }
    if (_filterCategory != null) {
      items = items.where((d) => d.category == _filterCategory).toList();
    }

    return Scaffold(
      backgroundColor: AdminColors.contentBg,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            _buildHeader(context, repo),
            const SizedBox(height: 20),

            // ── Summary chips ─────────────────────────────────────────────
            _buildStatusChips(repo),
            const SizedBox(height: 20),

            // ── Search + filters ──────────────────────────────────────────
            _buildSearchBar(context),
            const SizedBox(height: 16),

            // ── Destination table ─────────────────────────────────────────
            Expanded(child: _buildTable(context, items, repo)),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, DestinationRepository repo) {
    return Row(
      children: [
        const Icon(Icons.place_rounded, color: AdminColors.destinationAccent, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Destination Management',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text('${repo.count} destinations · ${repo.publishedCount} published',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddEditModal(context, null),
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Destination'),
        ),
      ],
    );
  }

  // ── Status summary chips ──────────────────────────────────────────────────────

  Widget _buildStatusChips(DestinationRepository repo) {
    final statuses = [
      (status: null,                            label: 'All (${repo.count})',       color: AdminColors.textSecondary),
      (status: DestinationStatus.pending,       label: 'Pending (${repo.pendingCount})', color: DestinationStatus.pending.color),
      (status: DestinationStatus.fieldSurveyed, label: 'Field Surveyed (${repo.items.where((d) => d.status == DestinationStatus.fieldSurveyed).length})', color: DestinationStatus.fieldSurveyed.color),
      (status: DestinationStatus.verified,      label: 'Verified (${repo.verifiedCount})', color: DestinationStatus.verified.color),
      (status: DestinationStatus.published,     label: 'Published (${repo.publishedCount})', color: DestinationStatus.published.color),
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
              color:        selected ? s.color.withValues(alpha: 0.15) : AdminColors.tableHeader,
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
                color:      selected ? s.color : AdminColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText:    'Search destinations by name or municipality…',
              prefixIcon:  Icon(Icons.search_rounded, size: 18),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        const SizedBox(width: 12),
        // Category filter dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color:        AdminColors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AdminColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DestinationCategory?>(
              value:     _filterCategory,
              hint:      Text('All Categories',
                  style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary)),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Categories')),
                ...DestinationCategory.values.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.label),
                )),
              ],
              onChanged: (v) => setState(() => _filterCategory = v),
              style: GoogleFonts.inter(fontSize: 13, color: AdminColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  // ── Table ─────────────────────────────────────────────────────────────────────

  Widget _buildTable(BuildContext context, List<AdminDestination> items,
      DestinationRepository repo) {
    if (items.isEmpty) {
      return AdminEmptyState(
        icon:        Icons.location_off_rounded,
        title:       'No destinations found',
        description: _searchQuery.isNotEmpty
            ? 'No results for "$_searchQuery". Try a different search.'
            : 'No destinations match the selected filter.',
        action: _searchQuery.isNotEmpty || _filterStatus != null
            ? TextButton.icon(
                onPressed: () => setState(() {
                  _searchQuery   = '';
                  _filterStatus  = null;
                  _filterCategory= null;
                }),
                icon:  const Icon(Icons.clear_rounded, size: 14),
                label: const Text('Clear Filters'),
              )
            : null,
      );
    }

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
            // Table header
            _TableHeader(),
            const Divider(height: 1),
            // Table rows
            Expanded(
              child: ListView.separated(
                itemCount:        items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) => _DestinationRow(
                  destination: items[i],
                  onEdit:      () => _showAddEditModal(context, items[i]),
                  onVerify:    () => _advanceStatus(context, repo, items[i]),
                  onDelete:    () => _confirmDelete(context, repo, items[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void _showAddEditModal(BuildContext context, AdminDestination? dest) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DestinationFormDialog(destination: dest),
    );
  }

  void _advanceStatus(BuildContext context, DestinationRepository repo,
      AdminDestination dest) {
    final next = dest.status.next;
    if (next == null) return;
    repo.advanceStatus(dest.id, officerName: 'Tourism Officer');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${dest.name} → ${next.label}'),
        backgroundColor: next.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, DestinationRepository repo,
      AdminDestination dest) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Destination'),
        content: Text(
          'Archive "${dest.name}"? It will no longer be visible to tourists.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.danger),
            onPressed: () {
              repo.delete(dest.id);
              Navigator.pop(ctx);
            },
            child: const Text('Archive'),
          ),
        ],
      ),
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
          Expanded(flex: 4, child: Text('DESTINATION', style: style)),
          Expanded(flex: 2, child: Text('CATEGORY', style: style)),
          Expanded(flex: 3, child: Text('MUNICIPALITY', style: style)),
          Expanded(flex: 2, child: Text('STATUS', style: style)),
          Expanded(flex: 2, child: Text('COORDINATES', style: style)),
          SizedBox(width: 120, child: Text('ACTIONS', style: style)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual destination table row
// ─────────────────────────────────────────────────────────────────────────────

class _DestinationRow extends StatelessWidget {
  const _DestinationRow({
    required this.destination,
    required this.onEdit,
    required this.onVerify,
    required this.onDelete,
  });

  final AdminDestination destination;
  final VoidCallback     onEdit;
  final VoidCallback     onVerify;
  final VoidCallback     onDelete;

  @override
  Widget build(BuildContext context) {
    final d = destination;
    final canAdvance = d.status.next != null;

    return InkWell(
      onTap: onEdit,
      hoverColor: AdminColors.tableRowHover,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // ── Name ────────────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  if (d.isFieldVerified)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.gps_fixed_rounded,
                          size: 13, color: AdminColors.surveyAccent),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name,
                            style: Theme.of(context).textTheme.labelLarge),
                        Text(d.locationDisplay,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Category ────────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Text(d.category.label,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),

            // ── Municipality ─────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Text(d.municipality,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),

            // ── Status badge ─────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: StatusBadge(
                label: d.status.label,
                color: d.status.color,
                icon:  d.status.icon,
              ),
            ),

            // ── Coordinates ──────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Text(
                d.coordinatesDisplay,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: AdminColors.textMuted,
                ),
              ),
            ),

            // ── Actions ──────────────────────────────────────────────────
            SizedBox(
              width: 120,
              child: Row(
                children: [
                  // Advance status
                  if (canAdvance)
                    Tooltip(
                      message: '→ ${d.status.next!.label}',
                      child: IconButton(
                        onPressed: onVerify,
                        icon: Icon(d.status.next!.icon,
                            size: 16, color: d.status.next!.color),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  // Edit
                  Tooltip(
                    message: 'Edit',
                    child: IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded,
                          size: 16, color: AdminColors.textSecondary),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  // Delete
                  Tooltip(
                    message: 'Archive',
                    child: IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.archive_rounded,
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
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Destination Add/Edit Dialog
// ─────────────────────────────────────────────────────────────────────────────

class DestinationFormDialog extends StatefulWidget {
  const DestinationFormDialog({super.key, this.destination});
  final AdminDestination? destination;

  @override
  State<DestinationFormDialog> createState() => _DestinationFormDialogState();
}

class _DestinationFormDialogState extends State<DestinationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _municipalityCtrl;
  late final TextEditingController _barangayCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _entranceFeeCtrl;
  late final TextEditingController _envFeeCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _travelTimeCtrl;
  late DestinationCategory _category;
  late DestinationStatus   _status;

  bool get _isEdit => widget.destination != null;

  @override
  void initState() {
    super.initState();
    final d = widget.destination;
    _nameCtrl        = TextEditingController(text: d?.name ?? '');
    _municipalityCtrl= TextEditingController(text: d?.municipality ?? '');
    _barangayCtrl    = TextEditingController(text: d?.barangay ?? '');
    _latCtrl         = TextEditingController(text: d?.latitude.toString() ?? '');
    _lngCtrl         = TextEditingController(text: d?.longitude.toString() ?? '');
    _entranceFeeCtrl = TextEditingController(text: d?.entranceFee.toString() ?? '0');
    _envFeeCtrl      = TextEditingController(text: d?.envFee.toString() ?? '0');
    _descriptionCtrl = TextEditingController(text: d?.description ?? '');
    _travelTimeCtrl  = TextEditingController(text: d?.travelTime ?? '');
    _category        = d?.category ?? DestinationCategory.island;
    _status          = d?.status ?? DestinationStatus.pending;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _municipalityCtrl.dispose();
    _barangayCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _entranceFeeCtrl.dispose();
    _envFeeCtrl.dispose();
    _descriptionCtrl.dispose();
    _travelTimeCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final repo = context.read<DestinationRepository>();

    if (_isEdit) {
      final updated = widget.destination!.copyWith(
        name:         _nameCtrl.text.trim(),
        municipality: _municipalityCtrl.text.trim(),
        barangay:     _barangayCtrl.text.trim(),
        latitude:     double.tryParse(_latCtrl.text) ?? widget.destination!.latitude,
        longitude:    double.tryParse(_lngCtrl.text) ?? widget.destination!.longitude,
        entranceFee:  int.tryParse(_entranceFeeCtrl.text) ?? 0,
        envFee:       int.tryParse(_envFeeCtrl.text) ?? 0,
        description:  _descriptionCtrl.text.trim(),
        travelTime:   _travelTimeCtrl.text.trim(),
        category:     _category,
        status:       _status,
        dateUpdated:  DateTime.now(),
      );
      repo.updateDestination(updated);
    } else {
      final newDest = AdminDestination(
        id:              'dest_${DateTime.now().millisecondsSinceEpoch}',
        name:            _nameCtrl.text.trim(),
        category:        _category,
        municipality:    _municipalityCtrl.text.trim(),
        barangay:        _barangayCtrl.text.trim(),
        province:        'Biliran Province',
        description:     _descriptionCtrl.text.trim(),
        latitude:        double.tryParse(_latCtrl.text) ?? 0,
        longitude:       double.tryParse(_lngCtrl.text) ?? 0,
        entranceFee:     int.tryParse(_entranceFeeCtrl.text) ?? 0,
        envFee:          int.tryParse(_envFeeCtrl.text) ?? 0,
        estimatedFare:   0,
        travelTime:      _travelTimeCtrl.text.trim(),
        bestSeason:      '',
        difficulty:      'Easy',
        signalStrength:  SignalStrength.none,
        thingsToDo:      [],
        whatToBring:     [],
        safetyReminders: [],
        galleryAssets:   [],
        status:          DestinationStatus.pending,
        dateAdded:       DateTime.now(),
      );
      repo.create(newDest);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Destination updated.' : 'New destination added.'),
        backgroundColor: AdminColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 640,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Dialog header ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                decoration: const BoxDecoration(
                  color: AdminColors.navyBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isEdit ? 'Edit Destination' : 'Add Destination',
                        style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                    ),
                  ],
                ),
              ),

              // ── Form fields ──────────────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Name + Category
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _field('Destination Name', _nameCtrl,
                                hint: 'e.g. Sambawan Island', required: true),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _dropdown('Category'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Row 2: Municipality + Barangay
                      Row(
                        children: [
                          Expanded(child: _field('Municipality', _municipalityCtrl,
                              hint: 'e.g. Kawayan', required: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _field('Barangay', _barangayCtrl,
                              hint: 'e.g. Sambawan')),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Row 3: GPS Coordinates
                      _label('GPS Coordinates'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(child: TextFormField(
                            controller:  _latCtrl,
                            keyboardType:const TextInputType.numberWithOptions(decimal: true),
                            decoration:  const InputDecoration(
                              hintText:  'Latitude (e.g. 11.7664)',
                              prefixIcon:Icon(Icons.gps_fixed_rounded, size: 16),
                            ),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: TextFormField(
                            controller:  _lngCtrl,
                            keyboardType:const TextInputType.numberWithOptions(decimal: true),
                            decoration:  const InputDecoration(
                              hintText:  'Longitude (e.g. 124.2643)',
                              prefixIcon:Icon(Icons.gps_fixed_rounded, size: 16),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Row 4: Fees
                      Row(
                        children: [
                          Expanded(child: _field('Entrance Fee (₱)', _entranceFeeCtrl,
                              hint: '0', keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: _field('Environmental Fee (₱)', _envFeeCtrl,
                              hint: '0', keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: _field('Travel Time', _travelTimeCtrl,
                              hint: 'e.g. 2-3 hrs from Naval')),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Description
                      _label('Description'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller:  _descriptionCtrl,
                        maxLines:    3,
                        decoration:  const InputDecoration(
                          hintText:  'Describe this destination…',
                          alignLabelWithHint: true,
                        ),
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Description required' : null,
                      ),

                      if (_isEdit) ...[
                        const SizedBox(height: 14),
                        _label('Verification Status'),
                        const SizedBox(height: 6),
                        _statusDropdown(),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Footer buttons ────────────────────────────────────────────
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _save,
                      icon:  Icon(_isEdit ? Icons.save_rounded : Icons.add_rounded, size: 16),
                      label: Text(_isEdit ? 'Save Changes' : 'Add Destination'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {
    String? hint,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextFormField(
          controller:   ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
          validator: required
              ? (v) => (v?.isEmpty ?? true) ? '$label is required' : null
              : null,
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textPrimary,
    ),
  );

  Widget _dropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AdminColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AdminColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DestinationCategory>(
              value:    _category,
              isExpanded: true,
              items: DestinationCategory.values.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c.label, style: GoogleFonts.inter(fontSize: 13)),
              )).toList(),
              onChanged: (v) { if (v != null) setState(() => _category = v); },
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AdminColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DestinationStatus>(
          value:    _status,
          isExpanded: true,
          items: DestinationStatus.values.map((s) => DropdownMenuItem(
            value: s,
            child: Row(
              children: [
                Icon(s.icon, size: 14, color: s.color),
                const SizedBox(width: 8),
                Text(s.label, style: GoogleFonts.inter(fontSize: 13, color: s.color)),
              ],
            ),
          )).toList(),
          onChanged: (v) { if (v != null) setState(() => _status = v); },
        ),
      ),
    );
  }
}
