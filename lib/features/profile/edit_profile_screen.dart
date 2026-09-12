import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../auth/repositories/auth_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _emergencyContactController;

  late String _selectedPreference;
  String? _profilePicPath;
  String? _coverPicPath;
  bool _isSubmitting = false;

  static const _supportedPreferences = [
    (key: 'recommended', label: 'Balanced', emoji: '⭐', description: 'Optimal balance of fare, speed, and comfort'),
    (key: 'budget', label: 'Budget-Friendly', emoji: '💰', description: 'Prioritizes lowest total fare options'),
    (key: 'fastest', label: 'Fastest Route', emoji: '⚡', description: 'Prioritizes shortest estimated travel time'),
    (key: 'fewer_transfers', label: 'Fewer Transfers', emoji: '🚌', description: 'Minimizes vehicle changes and connections'),
    (key: 'safer', label: 'Safer Travel', emoji: '🛡️', description: 'Prioritizes highly rated & safe transport options'),
  ];

  static const _presetCovers = [
    (id: 'default_blue', label: 'Signature Blue', asset: null, isBlue: true),
    (id: 'sambawan', label: 'Sambawan Island', asset: 'assets/images/sambawan.jpg', isBlue: false),
    (id: 'ulan_ulan', label: 'Ulan-Ulan Falls', asset: 'assets/images/ulan-ulan.jpg', isBlue: false),
    (id: 'dalutan', label: 'Dalutan Beach', asset: 'assets/images/dalutan.jpg', isBlue: false),
    (id: 'higatangan', label: 'Higatangan Sandbar', asset: 'assets/images/higatangan.jpg', isBlue: false),
  ];

  static const _presetAvatars = [
    (id: 'avatar_1', icon: Icons.explore_rounded, label: 'Explorer', color: Color(0xFF1458D4)),
    (id: 'avatar_2', icon: Icons.hiking_rounded, label: 'Adventurer', color: Color(0xFF10B981)),
    (id: 'avatar_3', icon: Icons.camera_alt_rounded, label: 'Photographer', color: Color(0xFFF59E0B)),
    (id: 'avatar_4', icon: Icons.directions_boat_rounded, label: 'Island Hopper', color: Color(0xFF06B6D4)),
    (id: 'avatar_5', icon: Icons.map_rounded, label: 'Navigator', color: Color(0xFF8B5CF6)),
    (id: 'avatar_6', icon: Icons.stars_rounded, label: 'VIP Tourist', color: Color(0xFFEC4899)),
  ];

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthRepository>().currentSession;
    _fullNameController = TextEditingController(text: session.fullName ?? '');
    _bioController = TextEditingController(text: session.bio ?? '');
    _phoneController = TextEditingController(text: session.phoneNumber ?? '');
    _locationController = TextEditingController(text: session.location ?? '');
    _emergencyContactController = TextEditingController(text: session.emergencyContact ?? '');

    _selectedPreference = session.preferenceProfile.isNotEmpty
        ? session.preferenceProfile
        : 'recommended';
    _profilePicPath = session.profilePic;
    _coverPicPath = session.coverPic;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (image != null) {
        setState(() => _coverPicPath = image.path);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('MissingPluginException')
            ? 'Gallery image picker requires an app restart to load native plugins. Please perform a full restart (R in terminal).'
            : 'Could not pick image: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _pickProfileImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (image != null) {
        setState(() => _profilePicPath = image.path);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('MissingPluginException')
            ? 'Gallery image picker requires an app restart to load native plugins. Please perform a full restart (R in terminal).'
            : 'Could not pick image: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showCoverSelectionModal() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Change Cover Picture',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.royalBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_photo_alternate_rounded, color: AppColors.royalBlue, size: 22.sp),
                  ),
                  title: Text(
                    'Upload Image from Gallery',
                    style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  subtitle: Text(
                    'Select a high quality cover photo from device storage',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickCoverImageFromGallery();
                  },
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'Select Preset Cover Theme',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),
                SizedBox(
                  height: 90.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetCovers.length,
                    separatorBuilder: (context, index) => SizedBox(width: 10.w),
                    itemBuilder: (_, index) {
                      final item = _presetCovers[index];
                      final isSelected = _coverPicPath == item.asset ||
                          (item.isBlue && (_coverPicPath == null || _coverPicPath == 'default_blue'));
                      return GestureDetector(
                        onTap: () {
                          setState(() => _coverPicPath = item.asset ?? 'default_blue');
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: 110.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isSelected ? AppColors.royalBlue : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (item.isBlue)
                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF0A2E73), Color(0xFF1458D4), Color(0xFF15C6D9)],
                                      ),
                                    ),
                                  )
                                else
                                  Image.asset(item.asset!, fit: BoxFit.cover),
                                Container(
                                  color: Colors.black.withValues(alpha: 0.30),
                                ),
                                Center(
                                  child: Text(
                                    item.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                      shadows: const [
                                        Shadow(blurRadius: 4, color: Colors.black54),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      },
    );
  }

  void _showProfileAvatarModal() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Change Profile Picture',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.royalBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_a_photo_rounded, color: AppColors.royalBlue, size: 22.sp),
                  ),
                  title: Text(
                    'Upload Photo from Gallery',
                    style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  subtitle: Text(
                    'Choose a selfie or profile photo from your device',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickProfileImageFromGallery();
                  },
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'Select Curated Traveler Avatar',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),
                Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: _presetAvatars.map((av) {
                    final isSelected = _profilePicPath == av.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _profilePicPath = av.id);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 95.w,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? av.color.withValues(alpha: 0.15)
                              : cs.surface,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected ? av.color : AppColors.divider,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: av.color,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(av.icon, color: Colors.white, size: 20.sp),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              av.label,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 12.h),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() => _profilePicPath = null);
                      Navigator.pop(ctx);
                    },
                    icon: Icon(Icons.refresh_rounded, size: 16.sp, color: AppColors.textSecondary),
                    label: Text(
                      'Reset to Default Avatar',
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final trimmedName = _fullNameController.text.trim();
    final trimmedBio = _bioController.text.trim();
    final trimmedPhone = _phoneController.text.trim();
    final trimmedLocation = _locationController.text.trim();
    final trimmedEmergency = _emergencyContactController.text.trim();

    setState(() => _isSubmitting = true);

    final authRepo = context.read<AuthRepository>();
    final success = await authRepo.updateProfile(
      fullName: trimmedName,
      bio: trimmedBio,
      phoneNumber: trimmedPhone,
      location: trimmedLocation,
      emergencyContact: trimmedEmergency,
      profilePic: _profilePicPath,
      coverPic: _coverPicPath,
      preferences: {'preferenceProfile': _selectedPreference},
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } else {
      final error = authRepo.errorMessage ?? 'Failed to update profile.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildCoverHeaderPreview() {
    final isCustomImage = _coverPicPath != null && _coverPicPath != 'default_blue';
    final isAssetImage = _coverPicPath != null && _coverPicPath!.startsWith('assets/');

    Widget coverContent;
    if (!isCustomImage) {
      coverContent = _buildDefaultBlueGradient();
    } else if (isAssetImage) {
      coverContent = Image.asset(_coverPicPath!, fit: BoxFit.cover);
    } else if (kIsWeb || _coverPicPath!.startsWith('http') || _coverPicPath!.startsWith('blob:')) {
      coverContent = Image.network(
        _coverPicPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultBlueGradient(),
      );
    } else {
      bool exists = false;
      try {
        exists = File(_coverPicPath!).existsSync();
      } catch (_) {}

      if (exists) {
        coverContent = Image.file(
          File(_coverPicPath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultBlueGradient(),
        );
      } else {
        coverContent = _buildDefaultBlueGradient();
      }
    }

    return Container(
      height: 150.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            coverContent,

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),

            // Top Label & Edit Cover Button
            Positioned(
              top: 12.h,
              right: 12.w,
              child: GestureDetector(
                onTap: _showCoverSelectionModal,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Change Cover',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16.w,
              bottom: 12.h,
              child: Row(
                children: [
                  Icon(Icons.wallpaper_rounded, color: Colors.white70, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    _coverPicPath != null && _coverPicPath != 'default_blue'
                        ? 'Customized Cover Picture'
                        : 'Default Blue Ocean Cover',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDefaultBlueGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2E73), Color(0xFF1458D4), Color(0xFF15C6D9)],
        ),
      ),
    );
  }

  Widget _buildProfileAvatarHeader() {
    final cs = Theme.of(context).colorScheme;
    final isCustomAvatar = _profilePicPath != null && !_profilePicPath!.startsWith('avatar_');
    final isPresetAvatar = _profilePicPath != null && _profilePicPath!.startsWith('avatar_');
    final presetObj = isPresetAvatar
        ? _presetAvatars.firstWhere((a) => a.id == _profilePicPath, orElse: () => _presetAvatars.first)
        : null;

    Widget avatarChild;
    if (isPresetAvatar) {
      avatarChild = Icon(presetObj!.icon, size: 44.sp, color: Colors.white);
    } else if (isCustomAvatar) {
      if (kIsWeb || _profilePicPath!.startsWith('http') || _profilePicPath!.startsWith('blob:')) {
        avatarChild = ClipOval(
          child: Image.network(
            _profilePicPath!,
            width: 92.r,
            height: 92.r,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Icon(Icons.person_rounded, size: 48.sp, color: AppColors.royalBlue),
          ),
        );
      } else {
        bool exists = false;
        try {
          exists = File(_profilePicPath!).existsSync();
        } catch (_) {}

        if (exists) {
          avatarChild = ClipOval(
            child: Image.file(
              File(_profilePicPath!),
              width: 92.r,
              height: 92.r,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Icon(Icons.person_rounded, size: 48.sp, color: AppColors.royalBlue),
            ),
          );
        } else {
          avatarChild = Icon(Icons.person_rounded, size: 48.sp, color: AppColors.royalBlue);
        }
      }
    } else {
      avatarChild = Icon(Icons.person_rounded, size: 48.sp, color: AppColors.royalBlue);
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF15C6D9), Color(0xFF1458D4)],
              ),
            ),
            child: CircleAvatar(
              radius: 46.r,
              backgroundColor: isPresetAvatar ? presetObj!.color : cs.surface,
              child: avatarChild,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _showProfileAvatarModal,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.royalBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(blurRadius: 6, color: Colors.black26, offset: Offset(0, 2)),
                  ],
                ),
                child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final session = context.watch<AuthRepository>().currentSession;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover Picture Interactive Header ──────────────────────────
              _buildCoverHeaderPreview(),

              SizedBox(height: 16.h),

              // ── Profile Photo Interactive Avatar ──────────────────────────
              _buildProfileAvatarHeader(),

              SizedBox(height: 20.h),

              // ── Account Readonly Badge Notice ──────────────────────────────
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.royalBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.royalBlue.withValues(alpha: 0.20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.royalBlue, size: 18.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Account: ${session.email ?? "Guest"} (${session.isEmailVerified ? "Verified Tourist" : "Unverified"})',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.royalBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // ── Section: Personal Information ─────────────────────────────
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(height: 12.h),

              // Full Name Field
              _buildLabel('Full Name *'),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _fullNameController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(fontSize: 13.5.sp, color: cs.onSurface),
                decoration: _buildInputDecoration(
                  hint: 'Enter full name',
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Full name is required';
                  if (val.trim().length < 2) return 'Must be at least 2 characters';
                  return null;
                },
              ),

              SizedBox(height: 14.h),

              // Bio / About Me Field
              _buildLabel('Bio / Traveler Story'),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontSize: 13.5.sp, color: cs.onSurface),
                decoration: _buildInputDecoration(
                  hint: 'Tell fellow travelers a bit about yourself...',
                  icon: Icons.edit_note_rounded,
                  isDark: isDark,
                ),
              ),

              SizedBox(height: 24.h),

              // ── Section: Contact & Emergency Details ──────────────────────
              Text(
                'Contact & Location Details',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(height: 12.h),

              // Phone Number Field
              _buildLabel('Phone Number'),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 13.5.sp, color: cs.onSurface),
                decoration: _buildInputDecoration(
                  hint: '+63 9XX XXX XXXX',
                  icon: Icons.phone_outlined,
                  isDark: isDark,
                ),
              ),

              SizedBox(height: 14.h),

              // Location / Hometown Field
              _buildLabel('Hometown / Current Location'),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(fontSize: 13.5.sp, color: cs.onSurface),
                decoration: _buildInputDecoration(
                  hint: 'e.g. Naval, Biliran or Manila, PH',
                  icon: Icons.location_on_outlined,
                  isDark: isDark,
                ),
              ),

              SizedBox(height: 14.h),

              // Emergency Contact Field
              _buildLabel('Emergency Contact (Name & Phone)'),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _emergencyContactController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(fontSize: 13.5.sp, color: cs.onSurface),
                decoration: _buildInputDecoration(
                  hint: 'e.g. Maria Cruz (Spouse) - 0917 123 4567',
                  icon: Icons.contact_phone_outlined,
                  isDark: isDark,
                ),
              ),

              SizedBox(height: 28.h),

              // ── Travel Preference Section ────────────────────────────────
              Text(
                'Default Travel Preference',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Used by BiliRoute scoring engine when recommending routes',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),

              Column(
                children: _supportedPreferences.map((pref) {
                  final isSelected = _selectedPreference == pref.key;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedPreference = pref.key);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.royalBlue.withValues(alpha: 0.08)
                              : (isDark ? DarkColors.card : Colors.white),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected ? AppColors.royalBlue : AppColors.divider,
                            width: isSelected ? 1.8 : 1.0,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.royalBlue.withValues(alpha: 0.10),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(pref.emoji, style: TextStyle(fontSize: 22.sp)),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pref.label,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? AppColors.royalBlue : cs.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    pref.description,
                                    style: TextStyle(
                                      fontSize: 10.5.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected ? AppColors.royalBlue : AppColors.textSecondary,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 28.h),

              // ── Save Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.royalBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 3,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Save Profile Changes',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20.sp, color: AppColors.textSecondary),
      filled: true,
      fillColor: isDark ? DarkColors.card : AppColors.backgroundStart,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.royalBlue, width: 1.5),
      ),
    );
  }
}
