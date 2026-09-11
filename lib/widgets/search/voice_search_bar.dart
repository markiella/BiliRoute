import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/preferences/user_preferences_notifier.dart';
import '../../core/services/voice_search_service.dart';
import '../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VoiceSearchBar — reusable search bar with integrated voice input
//
// Plugs into ANY existing screen search pipeline via [onQueryChanged].
// Does NOT duplicate search logic — voice text flows through the same callback
// as typed text.
//
// Usage:
//   VoiceSearchBar(
//     hintText: l10n.searchHint,
//     onQueryChanged: (text) => setState(() => _query = text),
//   )
// ─────────────────────────────────────────────────────────────────────────────

class VoiceSearchBar extends StatefulWidget {
  const VoiceSearchBar({
    super.key,
    required this.onQueryChanged,
    this.hintText = 'Search...',
    this.autofocus = false,
    this.initialValue = '',
    this.onSubmitted,
  });

  /// Called whenever the query text changes (typed or voice).
  final ValueChanged<String> onQueryChanged;

  /// Placeholder text inside the search field.
  final String hintText;

  /// Whether to auto-focus the text field on mount.
  final bool autofocus;

  /// Initial text value (for pre-populated voice result).
  final String initialValue;

  /// Optional: called when user submits (keyboard Done / Enter).
  final ValueChanged<String>? onSubmitted;

  @override
  State<VoiceSearchBar> createState() => _VoiceSearchBarState();
}

class _VoiceSearchBarState extends State<VoiceSearchBar>
    with TickerProviderStateMixin {
  late final TextEditingController _ctrl;
  late final AnimationController   _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Voice mic tap handler ──────────────────────────────────────────────────

  Future<void> _onMicTap(BuildContext context) async {
    final voiceService = context.read<VoiceSearchService>();
    final prefs        = context.read<UserPreferencesNotifier>();

    if (voiceService.isListening) {
      await voiceService.stopListening();
      _pulseCtrl.stop();
      _pulseCtrl.reset();
      return;
    }

    // Derive locale hint from app language setting
    final localeId = _localeIdFromLanguageCode(prefs.languageCode);

    _pulseCtrl.repeat(reverse: true);

    await voiceService.startListening(
      localeId: localeId,
      onResult: (text) {
        if (mounted) {
          _ctrl.text = text;
          _ctrl.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
          widget.onQueryChanged(text);
          _pulseCtrl.stop();
          _pulseCtrl.reset();
        }
      },
    );
  }

  /// Maps the app locale language code to a BCP 47 locale ID for the
  /// Android speech recognizer hint.
  String? _localeIdFromLanguageCode(String code) {
    switch (code) {
      case 'es': return 'es-ES';
      case 'en':
      default:   return 'en-US';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final voiceService = context.watch<VoiceSearchService>();

    // Sync voice-result text into controller when recognizer produces text
    final recognizedText = voiceService.recognizedText;
    if (recognizedText.isNotEmpty &&
        voiceService.state == VoiceSearchState.listening &&
        _ctrl.text != recognizedText) {
      // Update in next frame to avoid build-phase setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _ctrl.text != recognizedText) {
          _ctrl.text = recognizedText;
          _ctrl.selection = TextSelection.fromPosition(
            TextPosition(offset: recognizedText.length),
          );
        }
      });
    }

    final isListening = voiceService.isListening;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color:        Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Search icon ────────────────────────────────────────────────────
          Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size:  22.sp,
          ),
          SizedBox(width: 10.w),

          // ── Text field ─────────────────────────────────────────────────────
          Expanded(
            child: TextField(
              controller:  _ctrl,
              autofocus:   widget.autofocus,
              style: TextStyle(
                fontSize:   13.sp,
                color:      AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText:        widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color:    AppColors.textSecondary,
                ),
                border:          InputBorder.none,
                isDense:         true,
                contentPadding:  EdgeInsets.zero,
                filled:          false,
              ),
              textInputAction: TextInputAction.search,
              onChanged:    widget.onQueryChanged,
              onSubmitted:  widget.onSubmitted,
            ),
          ),

          SizedBox(width: 8.w),

          // ── Clear button (shown when text is not empty) ────────────────────
          if (_ctrl.text.isNotEmpty && !isListening)
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                widget.onQueryChanged('');
              },
              child: Icon(
                Icons.close_rounded,
                size:  17.sp,
                color: AppColors.textSecondary,
              ),
            ),

          SizedBox(width: _ctrl.text.isNotEmpty && !isListening ? 8.w : 0),

          // ── Microphone button ──────────────────────────────────────────────
          Semantics(
            label:  isListening ? 'Stop voice search' : 'Search by voice',
            button: true,
            child:  GestureDetector(
              onTap: () => _onMicTap(context),
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) {
                  return Container(
                    width:  36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      gradient: isListening
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end:   Alignment.bottomRight,
                              colors: [
                                const Color(0xFFEF4444).withValues(
                                  alpha: 0.85 + 0.15 * _pulseCtrl.value),
                                const Color(0xFFDC2626).withValues(
                                  alpha: 0.85 + 0.15 * _pulseCtrl.value),
                              ],
                            )
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end:   Alignment.bottomRight,
                              colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                            ),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: isListening
                          ? [
                              BoxShadow(
                                color:      const Color(0xFFEF4444).withValues(
                                  alpha: 0.4 + 0.2 * _pulseCtrl.value),
                                blurRadius: 12 + 4 * _pulseCtrl.value,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size:  18.sp,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VoiceSearchErrorBanner — shows inline error under the search bar
// ─────────────────────────────────────────────────────────────────────────────

class VoiceSearchErrorBanner extends StatelessWidget {
  const VoiceSearchErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color:        AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border:       Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 15.sp, color: AppColors.danger),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize:   12.sp,
                color:      AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 250.ms).slideY(begin: -0.05, end: 0);
  }
}
