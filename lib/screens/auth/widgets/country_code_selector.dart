import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import 'country_data.dart';

/// Clean, high-performance country code selector widget for FindBookStay.
/// Uses 100% opaque, GPU-friendly rendering and clean English country data
/// to prevent black screen blinking, shader breaks, and localization bugs.
class CountryCodeSelector extends StatefulWidget {
  final String initialCountryCode;
  final ValueChanged<Map<String, String>> onChanged;

  const CountryCodeSelector({
    super.key,
    this.initialCountryCode = 'BD',
    required this.onChanged,
  });

  @override
  State<CountryCodeSelector> createState() => _CountryCodeSelectorState();
}

class _CountryCodeSelectorState extends State<CountryCodeSelector> {
  late Map<String, String> _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = kAllCountries.firstWhere(
      (c) => c['code']?.toUpperCase() == widget.initialCountryCode.toUpperCase(),
      orElse: () => {
        'name': 'Bangladesh',
        'code': 'BD',
        'dial_code': '+880',
      },
    );
  }

  void _openCountryPicker() async {
    HapticFeedback.lightImpact();

    final selected = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        builder: (_) => CountryPickerScreen(
          selectedCountryCode: _selectedCountry['code'] ?? 'BD',
        ),
      ),
    );

    if (!mounted) return;
    if (selected != null) {
      setState(() {
        _selectedCountry = selected;
      });
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _selectedCountry['code'] ?? 'BD';
    final dialCode = _selectedCountry['dial_code'] ?? '+880';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openCountryPicker,
      child: Padding(
        padding: const EdgeInsets.only(left: 14, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Country flag with downsampled cache to prevent emulator texture overflow
            Container(
              width: 24,
              height: 16,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 0.6),
                borderRadius: BorderRadius.circular(3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.5),
                child: Image.asset(
                  'flags/${code.toLowerCase()}.png',
                  package: 'country_code_picker',
                  cacheWidth: 48,
                  cacheHeight: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(
                    child: Text(
                      countryCodeToEmoji(code),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              dialCode,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 22,
              color: AppColors.border,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

/// Full-screen, solid opaque country picker screen.
/// Renders with 100% solid surfaces (no alpha layering) to guarantee
/// rock-solid 60fps scrolling on both physical phones and emulators.
class CountryPickerScreen extends StatefulWidget {
  final String selectedCountryCode;

  const CountryPickerScreen({
    super.key,
    required this.selectedCountryCode,
  });

  @override
  State<CountryPickerScreen> createState() => _CountryPickerScreenState();
}

class _CountryPickerScreenState extends State<CountryPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late final List<Map<String, String>> _suggestedCountries;

  @override
  void initState() {
    super.initState();
    _suggestedCountries = kAllCountries
        .where((c) => kSuggestedCountryCodes.contains(c['code']))
        .toList();
    // Keep suggested in priority order (BD first, SA second, etc.)
    _suggestedCountries.sort((a, b) {
      final indexA = kSuggestedCountryCodes.indexOf(a['code'] ?? '');
      final indexB = kSuggestedCountryCodes.indexOf(b['code'] ?? '');
      return indexA.compareTo(indexB);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final cleanQuery = query.replaceAll('+', '');

    final filteredCountries = query.isEmpty
        ? kAllCountries
        : kAllCountries.where((c) {
            final name = (c['name'] ?? '').toLowerCase();
            final dialCode = (c['dial_code'] ?? '').toLowerCase().replaceAll('+', '');
            final code = (c['code'] ?? '').toLowerCase();
            return name.contains(query) ||
                dialCode.contains(cleanQuery) ||
                code.contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          splashRadius: 22,
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Select Country',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by country or code (+880, BD)...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          child: const Icon(
                            Icons.cancel_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Country List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: (query.isEmpty ? _suggestedCountries.length + 1 : 0) +
                  filteredCountries.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                indent: 68,
                color: AppColors.borderSubtle,
              ),
              itemBuilder: (context, index) {
                if (query.isEmpty) {
                  // Suggested Header
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                      child: Text(
                        'SUGGESTED / POPULAR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.textMuted,
                        ),
                      ),
                    );
                  }
                  // Suggested items
                  if (index <= _suggestedCountries.length) {
                    final country = _suggestedCountries[index - 1];
                    return _buildCountryTile(context, country);
                  }
                  // All Countries section
                  final realIndex = index - (_suggestedCountries.length + 1);
                  if (realIndex == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 20, color: AppColors.border),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                          child: Text(
                            'ALL COUNTRIES',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        _buildCountryTile(context, filteredCountries[realIndex]),
                      ],
                    );
                  }
                  return _buildCountryTile(context, filteredCountries[realIndex]);
                }

                // Filtered search results
                return _buildCountryTile(context, filteredCountries[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryTile(BuildContext context, Map<String, String> country) {
    final code = country['code'] ?? '';
    final name = country['name'] ?? '';
    final dialCode = country['dial_code'] ?? '';
    final isSelected = widget.selectedCountryCode.toUpperCase() == code.toUpperCase();

    // Solid opaque Material wrapper eliminates transparent layer nesting
    return Material(
      color: isSelected ? const Color(0xFFE8F5E9) : AppColors.background,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).pop(country);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Flag Container with downsampled texture memory
              Container(
                width: 28,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.2),
                  child: Image.asset(
                    'flags/${code.toLowerCase()}.png',
                    package: 'country_code_picker',
                    cacheWidth: 56,
                    cacheHeight: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: Text(
                        countryCodeToEmoji(code),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Country Name (Clean English)
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),

              // Dial Code
              Text(
                dialCode,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),

              if (isSelected) ...[
                const SizedBox(width: 10),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
