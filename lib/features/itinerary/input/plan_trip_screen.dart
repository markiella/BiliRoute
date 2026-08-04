import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';

/// Screen that collects travel preferences before finding the best route.
///
/// [navClearance] — extra bottom space so content clears the floating nav bar.
/// The back button is only rendered when the screen is pushed as a full route
/// (context.canPop() == true), not when it is embedded as a tab.
class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key, this.navClearance = 0});

  /// Bottom padding that clears the floating navigation bar.
  final double navClearance;

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  // ── Form state ─────────────────────────────────────────────────────────────
  String _selectedStart         = 'Tacloban Airport';
  double _budget                = 2000;
  int    _hoursAvailable        = 8;
  final  Set<String> _prefs     = {'Beach', 'Nature'};
  String _priority              = 'balanced';
  int    _travelers             = 2;

  // ── Static option lists ────────────────────────────────────────────────────
  static const _startingPoints = [
    'Tacloban Airport',
    'Ormoc Port',
    'Naval Terminal, Biliran',
    'Kawayan Port, Biliran',
    'Biliran Port',
    'Maripipi Port',
    'Cebu (via ferry)',
  ];

  static const _preferenceOptions = [
    'Budget-Friendly', 'Fastest Route', 'Fewer Transfers',
    'Safer Travel',    'Avoid Sea Travel', 'Scenic Route',
    'Nature',          'Cultural Sites',
  ];

  static const _priorityOptions = [
    (value: 'budget',   icon: Icons.savings_rounded,   label: 'Cheapest'),
    (value: 'time',     icon: Icons.bolt_rounded,      label: 'Fastest'),
    (value: 'safety',   icon: Icons.shield_rounded,    label: 'Safest'),
    (value: 'balanced', icon: Icons.balance_rounded,   label: 'Balanced'),
  ];

  // ── Helpers ────────────────────────────────────────────────────────────────
  String get _budgetDisplay =>
      '₱${_budget.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (m) => ',',
          )}';

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      appBar: _buildAppBar(context, showBack: canPop),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Starting point ─────────────────────────────────────
                  _SectionCard(
                    animIndex: 0,
                    child: _buildStartingPoint(),
                  ),

                  SizedBox(height: 14.h),

                  // ── Budget ─────────────────────────────────────────────
                  _SectionCard(
                    animIndex: 1,
                    child: _buildBudget(),
                  ),

                  SizedBox(height: 14.h),

                  // ── Time available ─────────────────────────────────────
                  _SectionCard(
                    animIndex: 2,
                    child: _buildTimeAvailable(),
                  ),

                  SizedBox(height: 14.h),

                  // ── Destination preferences ────────────────────────────
                  _SectionCard(
                    animIndex: 3,
                    child: _buildPreferences(),
                  ),

                  SizedBox(height: 14.h),

                  // ── Travel priority ────────────────────────────────────
                  _SectionCard(
                    animIndex: 4,
                    child: _buildPriority(),
                  ),

                  SizedBox(height: 14.h),

                  // ── Number of travelers ────────────────────────────────
                  _SectionCard(
                    animIndex: 5,
                    child: _buildTravelers(),
                  ),

                  SizedBox(height: 20.h),

                  // ── Generate button (inline, not bottomSheet) ────────────
                  _buildGenerateButton(context),

                  // ── Clearance for floating nav bar ─────────────────────
                  SizedBox(height: widget.navClearance + 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, {bool showBack = false}) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // Back button only shown when pushed as a full-screen route
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              onPressed: () => context.pop(),
            )
          : null,
      title: Text(
        AppStrings.planTripTitle,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
      ),
      centerTitle: true,
    );
  }

  // ── Section: Starting point dropdown ──────────────────────────────────────
  Widget _buildStartingPoint() {
    return _FormSection(
      icon: Icons.my_location_rounded,
      iconColor: AppColors.primary,
      label: AppStrings.startingPoint,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundStart,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: DropdownButton<String>(
          value: _selectedStart,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary, size: 20.sp),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
          items: _startingPoints
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) => setState(() => _selectedStart = v ?? _selectedStart),
        ),
      ),
    );
  }

  // ── Section: Budget slider ─────────────────────────────────────────────────
  Widget _buildBudget() {
    return _FormSection(
      icon: Icons.wallet_rounded,
      iconColor: AppColors.accent,
      label: AppStrings.budgetLabel,
      trailing: Text(
        _budgetDisplay,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.divider,
          thumbColor: AppColors.primary,
          overlayColor: AppColors.primary.withValues(alpha: 0.12),
        ),
        child: Slider(
          min: 500,
          max: 15000,
          divisions: 58,
          value: _budget,
          onChanged: (v) => setState(() => _budget = v),
        ),
      ),
    );
  }

  // ── Section: Time available stepper ───────────────────────────────────────
  Widget _buildTimeAvailable() {
    return _FormSection(
      icon: Icons.schedule_rounded,
      iconColor: AppColors.info,
      label: AppStrings.timeLabel,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$_hoursAvailable ${_hoursAvailable == 1 ? "hour" : "hours"}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          Row(
            children: [
              _StepperButton(
                icon: Icons.remove,
                onTap: () {
                  if (_hoursAvailable > 1) {
                    setState(() => _hoursAvailable--);
                  }
                },
              ),
              SizedBox(width: 12.w),
              _StepperButton(
                icon: Icons.add,
                onTap: () {
                  if (_hoursAvailable < 24) {
                    setState(() => _hoursAvailable++);
                  }
                },
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section: Destination preferences chips ────────────────────────────────
  Widget _buildPreferences() {
    return _FormSection(
      icon: Icons.favorite_rounded,
      iconColor: AppColors.danger,
      label: AppStrings.preferencesLabel,
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: _preferenceOptions.map((pref) {
          final selected = _prefs.contains(pref);
          return FilterChip(
            label: Text(pref),
            selected: selected,
            onSelected: (v) => setState(() {
              if (v) {
                _prefs.add(pref);
              } else {
                _prefs.remove(pref);
              }
            }),
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            backgroundColor: AppColors.backgroundStart,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section: Travel priority chips ────────────────────────────────────────
  Widget _buildPriority() {
    return _FormSection(
      icon: Icons.tune_rounded,
      iconColor: AppColors.success,
      label: AppStrings.priorityLabel,
      child: Row(
        children: _priorityOptions.map((opt) {
          final selected = _priority == opt.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: opt.value != 'balanced' ? 8.w : 0,
              ),
              child: GestureDetector(
                onTap: () => setState(() => _priority = opt.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color:
                        selected ? AppColors.primary : AppColors.backgroundStart,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        opt.icon,
                        size: 20.sp,
                        color:
                            selected ? Colors.white : AppColors.textSecondary,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        opt.label,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section: Number of travelers ──────────────────────────────────────────
  Widget _buildTravelers() {
    return _FormSection(
      icon: Icons.group_rounded,
      iconColor: AppColors.accentSoft,
      label: AppStrings.travelersLabel,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$_travelers ${_travelers == 1 ? "traveler" : "travelers"}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          Row(
            children: [
              _StepperButton(
                icon: Icons.remove,
                onTap: () {
                  if (_travelers > 1) setState(() => _travelers--);
                },
              ),
              SizedBox(width: 12.w),
              _StepperButton(
                icon: Icons.add,
                onTap: () {
                  if (_travelers < 20) setState(() => _travelers++);
                },
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Generate button (inline inside scroll content) ──────────────────────
  Widget _buildGenerateButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => context.push(
          '${AppRouter.routeSelection}?destination=Sambawan+Island',
        ),
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.route_rounded, color: Colors.white, size: 20.sp),
              SizedBox(width: 10.w),
              Text(
                'Find Best Route',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

/// White rounded card wrapper for each form section with entry animation.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.animIndex = 0});
  final Widget child;
  final int    animIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    )
        .animate(delay: (100 + animIndex * 60).ms)
        .fade(duration: 400.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

/// Icon + label row header inside a form section.
class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final Color    iconColor;
  final String   label;
  final Widget   child;
  final Widget?  trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Icon(icon, color: iconColor, size: 17.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
            ?trailing,
          ],
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }
}

/// Small circular +/- button for steppers.
class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });
  final IconData     icon;
  final VoidCallback onTap;
  final bool         isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.backgroundStart,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: isPrimary ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}
