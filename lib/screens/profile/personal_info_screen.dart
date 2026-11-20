import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/url_utils.dart';
import '../../../features/auth/data/models/user_model.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';

/// Screen for viewing and editing Personal Information.
/// Uses GET /api/v1/auth/me to fetch fresh user data and
/// PATCH /api/v1/auth/profile to update profile details.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _presentStreetController;
  late final TextEditingController _presentCityController;
  late final TextEditingController _presentStateController;
  late final TextEditingController _presentZipController;
  late final TextEditingController _permanentStreetController;
  late final TextEditingController _permanentCityController;
  late final TextEditingController _permanentStateController;
  late final TextEditingController _permanentZipController;

  bool _isEditing = false;
  bool _isFetching = false;
  bool _isSaving = false;
  bool _sameAsPresent = false;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _presentStreetController = TextEditingController();
    _presentCityController = TextEditingController();
    _presentStateController = TextEditingController();
    _presentZipController = TextEditingController();
    _permanentStreetController = TextEditingController();
    _permanentCityController = TextEditingController();
    _permanentStateController = TextEditingController();
    _permanentZipController = TextEditingController();

    // Populate from cached state immediately
    final user = ref.read(authControllerProvider).user;
    if (user != null && !user.isGuest) {
      _populateFields(user);
    }

    // Concurrently fetch latest data from GET /api/v1/auth/me
    Future.microtask(() => _fetchFreshProfile());
  }

  void _populateFields(UserModel user) {
    _nameController.text = user.name;
    _phoneController.text = user.phone ?? '';

    final present = user.presentAddress;
    if (present != null) {
      _presentStreetController.text = present.street ?? '';
      _presentCityController.text = present.city ?? '';
      _presentStateController.text = present.state ?? '';
      _presentZipController.text = present.zipCode ?? '';
    }

    final permanent = user.permanentAddress;
    if (permanent != null) {
      _permanentStreetController.text = permanent.street ?? '';
      _permanentCityController.text = permanent.city ?? '';
      _permanentStateController.text = permanent.state ?? '';
      _permanentZipController.text = permanent.zipCode ?? '';
    }

    // Detect if permanent address matches present
    if (present != null && permanent != null && !present.isEmpty) {
      _sameAsPresent =
          present.street == permanent.street &&
          present.city == permanent.city &&
          present.state == permanent.state &&
          present.zipCode == permanent.zipCode;
    }
  }

  Future<void> _fetchFreshProfile() async {
    if (!mounted) return;
    setState(() => _isFetching = true);

    try {
      final freshUser = await ref
          .read(authControllerProvider.notifier)
          .fetchCurrentUser();
      if (mounted && freshUser != null && !freshUser.isGuest) {
        _populateFields(freshUser);
      }
    } finally {
      if (mounted) {
        setState(() => _isFetching = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _presentStreetController.dispose();
    _presentCityController.dispose();
    _presentStateController.dispose();
    _presentZipController.dispose();
    _permanentStreetController.dispose();
    _permanentCityController.dispose();
    _permanentStateController.dispose();
    _permanentZipController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          _pickedImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Could not access photo: $e'),
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sheetIsDark = Theme.of(ctx).brightness == Brightness.dark;
        final textColor = sheetIsDark
            ? AppColors.darkTextPrimary
            : AppColors.textPrimary;
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: sheetIsDark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sheetIsDark
                        ? AppColors.darkBorder
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Change Profile Photo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sheetIsDark
                          ? const Color(0xFF132F28)
                          : AppColors.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      size: 20,
                      color: sheetIsDark ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 6),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sheetIsDark
                          ? const Color(0xFF132F28)
                          : AppColors.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 20,
                      color: sheetIsDark ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                  title: Text(
                    'Take a Photo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_pickedImage != null) ...[
                  const SizedBox(height: 6),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.error,
                      ),
                    ),
                    title: Text(
                      'Remove Selected Photo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() => _pickedImage = null);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final presentMap = {
        'street': _presentStreetController.text.trim(),
        'city': _presentCityController.text.trim(),
        'state': _presentStateController.text.trim(),
        'zipCode': _presentZipController.text.trim(),
      };

      final permanentMap = _sameAsPresent
          ? presentMap
          : {
              'street': _permanentStreetController.text.trim(),
              'city': _permanentCityController.text.trim(),
              'state': _permanentStateController.text.trim(),
              'zipCode': _permanentZipController.text.trim(),
            };

      final payload = <String, dynamic>{
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'presentAddress': presentMap,
        'permanentAddress': permanentMap,
        'sameAsPresent': _sameAsPresent,
      };

      await ref
          .read(authControllerProvider.notifier)
          .updateProfile(payload, imageFilePath: _pickedImage?.path);

      if (!mounted) return;

      setState(() {
        _isEditing = false;
        _isSaving = false;
        _pickedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Profile updated successfully!',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user ?? UserModel.guest;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          splashRadius: 22,
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Profile' : 'Personal Information',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isEditing = true);
              },
              icon: Icon(
                Icons.edit_outlined,
                size: 16,
                color: isDark ? AppColors.accent : AppColors.primary,
              ),
              label: Text(
                'Edit',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.accent : AppColors.primary,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      _populateFields(user);
                      setState(() {
                        _isEditing = false;
                        _pickedImage = null;
                      });
                    },
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFreshProfile,
        color: AppColors.primary,
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            children: [
              if (_isFetching)
                const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: AppColors.accent,
                  minHeight: 2.5,
                ),

              const SizedBox(height: 12),

              // ── Avatar & Identity Section ─────────────────────────
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.22),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _pickedImage != null
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            : () {
                                final displayAvatarUrl =
                                    UrlUtils.resolveNullableUrl(
                                      user.avatarUrl ?? user.profileImage,
                                    );
                                return (displayAvatarUrl != null &&
                                        displayAvatarUrl.isNotEmpty)
                                    ? Image.network(
                                        displayAvatarUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) return child;
                                          return const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (_, _, _) =>
                                            _buildInitials(user.name),
                                      )
                                    : _buildInitials(user.name);
                              }(),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImageSourceSheet,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  user.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Center(
                child: Text(
                  user.email,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Basic Info Section ────────────────────────────────
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 12),

              _buildCardContainer([
                _buildField(
                  label: 'Full Name',
                  controller: _nameController,
                  enabled: _isEditing,
                  icon: Icons.person_outline_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
                ),
                _buildField(
                  label: 'Email Address',
                  value: user.email,
                  enabled: false,
                  icon: Icons.mail_outline_rounded,
                  suffixBadge: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: user.isEmailVerified
                          ? (isDark
                                ? const Color(0xFF132F28)
                                : AppColors.accentLight)
                          : (isDark
                                ? AppColors.darkSurface
                                : AppColors.surface),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: user.isEmailVerified
                            ? AppColors.accent
                            : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.isEmailVerified
                              ? Icons.check_circle_rounded
                              : Icons.pending_outlined,
                          size: 13,
                          color: user.isEmailVerified
                              ? (isDark ? AppColors.accent : AppColors.primary)
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.isEmailVerified ? 'Verified' : 'Unverified',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: user.isEmailVerified
                                ? (isDark
                                      ? AppColors.accent
                                      : AppColors.primary)
                                : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
                ),
                _buildField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  enabled: _isEditing,
                  icon: Icons.phone_outlined,
                  hint: '+880 1712-345678',
                  keyboardType: TextInputType.phone,
                ),
              ]),

              const SizedBox(height: 24),

              // ── Present Address Section ───────────────────────────
              _buildSectionHeader('Present Address'),
              const SizedBox(height: 12),

              _buildCardContainer([
                _buildField(
                  label: 'Street Address',
                  controller: _presentStreetController,
                  enabled: _isEditing,
                  hint: 'House 12, Road 4, Sector 3',
                  icon: Icons.home_outlined,
                ),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
                ),
                _buildField(
                  label: 'City / District',
                  controller: _presentCityController,
                  enabled: _isEditing,
                  hint: 'Dhaka',
                  icon: Icons.location_city_rounded,
                ),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
                ),
                _buildField(
                  label: 'State / Division',
                  controller: _presentStateController,
                  enabled: _isEditing,
                  hint: 'Dhaka Division',
                  icon: Icons.map_outlined,
                ),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
                ),
                _buildField(
                  label: 'Postal / Zip Code',
                  controller: _presentZipController,
                  enabled: _isEditing,
                  hint: '1230',
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                ),
              ]),

              const SizedBox(height: 24),

              // ── Permanent Address Section ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('Permanent Address'),
                  if (_isEditing)
                    Row(
                      children: [
                        Checkbox(
                          value: _sameAsPresent,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _sameAsPresent = val ?? false;
                              if (_sameAsPresent) {
                                _permanentStreetController.text =
                                    _presentStreetController.text;
                                _permanentCityController.text =
                                    _presentCityController.text;
                                _permanentStateController.text =
                                    _presentStateController.text;
                                _permanentZipController.text =
                                    _presentZipController.text;
                              }
                            });
                          },
                        ),
                        Text(
                          'Same as present',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (!_sameAsPresent || !_isEditing)
                _buildCardContainer([
                  _buildField(
                    label: 'Street Address',
                    controller: _permanentStreetController,
                    enabled: _isEditing,
                    hint: 'Village / Holding',
                    icon: Icons.home_work_outlined,
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.borderSubtle,
                  ),
                  _buildField(
                    label: 'City / District',
                    controller: _permanentCityController,
                    enabled: _isEditing,
                    hint: 'District',
                    icon: Icons.location_city_rounded,
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.borderSubtle,
                  ),
                  _buildField(
                    label: 'State / Division',
                    controller: _permanentStateController,
                    enabled: _isEditing,
                    hint: 'Division',
                    icon: Icons.map_outlined,
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.borderSubtle,
                  ),
                  _buildField(
                    label: 'Postal / Zip Code',
                    controller: _permanentZipController,
                    enabled: _isEditing,
                    hint: 'Zip Code',
                    icon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ])
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkAccentLight
                        : AppColors.accentLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accent.withValues(
                        alpha: isDark ? 0.45 : 0.3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: isDark ? AppColors.accent : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Permanent address is set to the same as present address.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.accent
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // ── Action Buttons ────────────────────────────────────
              if (_isEditing)
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.accent
                        : AppColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: isDark
                                ? AppColors.primaryDark
                                : Colors.white,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.primaryDark
                                : Colors.white,
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitials(String name) {
    final initials = name
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join();
    return Center(
      child: Text(
        initials.isNotEmpty ? initials : 'U',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required String label,
    String? value,
    TextEditingController? controller,
    bool enabled = true,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixBadge,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final mutedTextColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.accent : secondaryTextColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: mutedTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                if (!enabled)
                  Text(
                    (controller?.text ?? value ?? '').isNotEmpty
                        ? (controller?.text ?? value ?? '')
                        : 'Not set',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: (controller?.text ?? value ?? '').isNotEmpty
                          ? primaryTextColor
                          : mutedTextColor,
                    ),
                  )
                else
                  TextFormField(
                    controller: controller,
                    validator: validator,
                    keyboardType: keyboardType,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: mutedTextColor,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      border: InputBorder.none,
                      errorStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
          ?suffixBadge,
        ],
      ),
    );
  }
}
