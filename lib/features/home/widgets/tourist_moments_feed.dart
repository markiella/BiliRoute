import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tourist moment data model
// ─────────────────────────────────────────────────────────────────────────────

class _Moment {
  const _Moment({
    required this.username,
    required this.destination,
    required this.timeAgo,
    required this.imageAsset,
    required this.avatarEmoji,
    required this.avatarColor,
    required this.caption,
    required this.likes,
    required this.comments,
  });
  final String username;
  final String destination;
  final String timeAgo;
  final String imageAsset;
  final String avatarEmoji;
  final Color  avatarColor;
  final String caption;
  final int    likes;
  final int    comments;
}

const _moments = [
  _Moment(
    username:    '@mj_travels',
    destination: 'Sambawan Island',
    timeAgo:     '2h ago',
    imageAsset:  'assets/images/sambawan.jpg',
    avatarEmoji: '🧑',
    avatarColor: Color(0xFF1E3A8A),
    caption:     'Crystal clear waters — absolutely worth the boat ride! 🌊✨',
    likes:       142,
    comments:    28,
  ),
  _Moment(
    username:    '@ana.explores',
    destination: 'Ulan-ulan Falls',
    timeAgo:     '5h ago',
    imageAsset:  'assets/images/ulan-ulan.jpg',
    avatarEmoji: '👩',
    avatarColor: Color(0xFF7C3AED),
    caption:     'The mist hits different when you\'ve trekked 2km for it 🏔️💦',
    likes:       98,
    comments:    14,
  ),
  _Moment(
    username:    '@rj_biliran',
    destination: 'Agta Beach',
    timeAgo:     '1d ago',
    imageAsset:  'assets/images/agta.JPG',
    avatarEmoji: '🧔',
    avatarColor: Color(0xFF059669),
    caption:     'Sunset magic at Agta Beach — hidden gem of Biliran 🌅',
    likes:       211,
    comments:    43,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Section widget
// ─────────────────────────────────────────────────────────────────────────────

class TouristMomentsFeed extends StatelessWidget {
  const TouristMomentsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_moments.length, (i) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, i == 0 ? 10.h : 12.h, 16.w, 0),
        child: _MomentCard(moment: _moments[i], delay: (i * 90).ms),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Moment card
// ─────────────────────────────────────────────────────────────────────────────

class _MomentCard extends StatefulWidget {
  const _MomentCard({required this.moment, required this.delay});
  final _Moment  moment;
  final Duration delay;

  @override
  State<_MomentCard> createState() => _MomentCardState();
}

class _MomentCardState extends State<_MomentCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.moment;
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset:     const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.09),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width:  40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: m.avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(m.avatarEmoji,
                        style: TextStyle(fontSize: 18.sp)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.username,
                          style: TextStyle(
                            fontSize:   12.sp,
                            fontWeight: FontWeight.w800,
                            color:      AppColors.textPrimary,
                          )),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 9.sp, color: AppColors.primary),
                          SizedBox(width: 2.w),
                          Text(m.destination,
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color:    AppColors.primary,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(m.timeAgo,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color:    AppColors.textSecondary,
                    )),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          // ── Image ────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft:     Radius.zero,
              topRight:    Radius.zero,
              bottomLeft:  Radius.circular(0.r),
              bottomRight: Radius.circular(0.r),
            ),
            child: SizedBox(
              height: 175.h,
              width:  double.infinity,
              child: Image.asset(
                m.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        m.avatarColor.withValues(alpha: 0.5),
                        m.avatarColor,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Caption + engagement ──────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.caption,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:    AppColors.textPrimary,
                      height:   1.4,
                    )),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _liked = !_liked),
                      child: Row(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _liked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              key:   ValueKey(_liked),
                              size:  18.sp,
                              color: _liked
                                  ? const Color(0xFFEF4444)
                                  : AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${_liked ? m.likes + 1 : m.likes}',
                            style: TextStyle(
                              fontSize:   10.sp,
                              color:      _liked
                                  ? const Color(0xFFEF4444)
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 16.sp, color: AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Text('${m.comments}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color:    AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        )),
                    const Spacer(),
                    Icon(Icons.ios_share_rounded,
                        size: 16.sp, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: widget.delay)
        .fade(duration: 400.ms)
        .slideY(begin: 0.08, end: 0);
  }
}
