import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

/// Allows the user to reorder, remove, or replace itinerary stops.
///
/// Uses a [ReorderableListView] for drag-and-drop reordering.
/// Shows warning banners and suggested alternatives at the bottom.
/// UI-only — all data is mocked.
class EditItineraryScreen extends StatefulWidget {
  const EditItineraryScreen({super.key});

  @override
  State<EditItineraryScreen> createState() => _EditItineraryScreenState();
}

class _EditItineraryScreenState extends State<EditItineraryScreen> {
  // ── Mutable stop list (editable copy) ────────────────────────────────────
  final List<_EditStop> _stops = [
    _EditStop(id: '1', time: '07:00 AM', name: 'Divisoria, CDO',       icon: Icons.home_rounded,          isFirst: true),
    _EditStop(id: '2', time: '07:30 AM', name: 'CDO Agora Terminal',   icon: Icons.directions_bus_rounded),
    _EditStop(id: '3', time: '08:00 AM', name: 'Balingoan Port',       icon: Icons.anchor_rounded),
    _EditStop(id: '4', time: '10:30 AM', name: 'Camiguin Island',      icon: Icons.sailing_rounded),
    _EditStop(id: '5', time: '11:00 AM', name: 'White Island Sandbar', icon: Icons.beach_access_rounded),
    _EditStop(id: '6', time: '01:00 PM', name: 'Sunken Cemetery',      icon: Icons.explore_rounded),
    _EditStop(id: '7', time: '03:00 PM', name: 'Ardent Hot Spring',    icon: Icons.water_rounded),
    _EditStop(id: '8', time: '06:30 PM', name: 'Return to CDO',        icon: Icons.home_rounded,          isLast: true),
  ];

  bool _showBudgetWarning = true;

  // ── Mock alternatives ─────────────────────────────────────────────────────
  static const _alternatives = [
    'Mantigue Island Snorkeling — ₱120',
    'Katibawasan Falls — ₱40',
    'Old Volcano Museum — ₱30',
    'Santo Niño Cold Spring — ₱80',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // ── Warning banner ────────────────────────────────────────────────
          if (_showBudgetWarning)
            _WarningBanner(
              message: 'Budget may be exceeded with current stops.',
              onDismiss: () => setState(() => _showBudgetWarning = false),
            ),

          // ── Reorderable list ──────────────────────────────────────────────
          Expanded(
            child: ReorderableListView.builder(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              physics: const BouncingScrollPhysics(),
              itemCount: _stops.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _stops.removeAt(oldIndex);
                  _stops.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final stop = _stops[index];
                return _EditStopTile(
                  key: ValueKey(stop.id),
                  stop: stop,
                  index: index,
                  onRemove: stop.isFirst || stop.isLast
                      ? null // can't remove first/last
                      : () => setState(() => _stops.removeAt(index)),
                  onReplace: stop.isFirst || stop.isLast
                      ? null
                      : () => _showReplaceSheet(context, index),
                );
              },
            ),
          ),

          // ── Alternatives suggestion panel ─────────────────────────────────
          _AlternativesSuggestion(alternatives: _alternatives),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: AppColors.backgroundStart,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 15.sp, color: AppColors.textPrimary),
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Edit Itinerary',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 14.w),
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Done',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom sheet to select a replacement stop.
  void _showReplaceSheet(BuildContext context, int index) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Replace with',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 16.h),
            ..._alternatives.map(
              (alt) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.place_rounded,
                      color: AppColors.primary, size: 20.sp),
                ),
                title: Text(
                  alt,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                onTap: () {
                  setState(() {
                    final parts = alt.split('—');
                    _stops[index] = _EditStop(
                      id: _stops[index].id,
                      time: _stops[index].time,
                      name: parts[0].trim(),
                      icon: Icons.place_rounded,
                    );
                  });
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _EditStop {
  _EditStop({
    required this.id,
    required this.time,
    required this.name,
    required this.icon,
    this.isFirst = false,
    this.isLast  = false,
  });
  final String   id;
  final String   time;
  String         name;
  final IconData icon;
  final bool     isFirst;
  final bool     isLast;
}

// ── Private sub-widgets ────────────────────────────────────────────────────────

/// Individual draggable stop row.
class _EditStopTile extends StatelessWidget {
  const _EditStopTile({
    super.key,
    required this.stop,
    required this.index,
    required this.onRemove,
    required this.onReplace,
  });
  final _EditStop    stop;
  final int          index;
  final VoidCallback? onRemove;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        leading: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: stop.isFirst
                ? AppColors.success.withValues(alpha: 0.12)
                : stop.isLast
                    ? AppColors.danger.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            stop.icon,
            color: stop.isFirst
                ? AppColors.success
                : stop.isLast
                    ? AppColors.danger
                    : AppColors.primary,
            size: 20.sp,
          ),
        ),
        title: Text(
          stop.name,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        subtitle: Text(
          stop.time,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Replace button
            if (onReplace != null)
              GestureDetector(
                onTap: onReplace,
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(Icons.swap_horiz_rounded,
                      size: 16.sp, color: AppColors.info),
                ),
              ),
            if (onReplace != null) SizedBox(width: 6.w),
            // Remove button
            if (onRemove != null)
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 16.sp, color: AppColors.danger),
                ),
              ),
            if (onRemove != null) SizedBox(width: 6.w),
            // Drag handle
            Icon(Icons.drag_handle_rounded,
                size: 20.sp, color: AppColors.textSecondary),
          ],
        ),
      ),
    )
        .animate(delay: (80 + index * 40).ms)
        .fade(duration: 350.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

/// Yellow dismissable warning banner.
class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message, required this.onDismiss});
  final String       message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.warning, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded,
                color: AppColors.warning, size: 16.sp),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }
}

/// Horizontal scrolling suggested alternatives panel.
class _AlternativesSuggestion extends StatelessWidget {
  const _AlternativesSuggestion({required this.alternatives});
  final List<String> alternatives;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 0, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Alternatives',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 46.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(right: 20.w),
              itemCount: alternatives.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, i) => Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_rounded,
                        size: 15.sp, color: AppColors.primary),
                    SizedBox(width: 6.w),
                    Text(
                      alternatives[i].split('—')[0].trim(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
