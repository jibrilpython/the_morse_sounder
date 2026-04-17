import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_morse_sounder/enum/my_enums.dart';
import 'package:the_morse_sounder/models/sounder_model.dart';
import 'package:the_morse_sounder/providers/image_provider.dart';
import 'package:the_morse_sounder/providers/project_provider.dart';
import 'package:the_morse_sounder/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends ConsumerWidget {
  final int index;
  const InfoScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectProv = ref.watch(projectProvider);
    if (index < 0 || index >= projectProv.entries.length) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Text(
            'SOUNDER NOT FOUND',
            style: GoogleFonts.jetBrainsMono(color: kAccent),
          ),
        ),
      );
    }
    final entry = projectProv.entries[index];
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final hasImage =
        entry.photoPath.isNotEmpty &&
        imagePath != null &&
        File(imagePath).existsSync();

    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // ── 1. Hero Background (Fixed) ──────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: hasImage
                ? Image.file(File(imagePath), fit: BoxFit.cover)
                : Container(
                    color: kPanelBg,
                    child: Center(
                      child: Icon(
                        Icons.cable_outlined,
                        size: 80.sp,
                        color: kOutline,
                      ),
                    ),
                  ),
          ),
          // Gradient Fade over image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kBackground.withAlpha(200),
                    Colors.transparent,
                    kBackground.withAlpha(100),
                  ],
                ),
              ),
            ),
          ),

          // ── 2. Scrollable Editorial Content ─────────────────────────────
          // Moved BEFORE Top Navigation Bar so buttons sit on top and receive taps
          Positioned.fill(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                // Transparent spacer to reveal the image
                SizedBox(height: size.height * 0.40),

                // Content Panel overlapping image
                Container(
                  decoration: BoxDecoration(
                    color: kBackground,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: kAccent.withAlpha(150),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(28.w, 40.h, 28.w, 120.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title Block ──────────────────────────
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: kAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'SPECIMEN',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: kBackground,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  entry.telegraphIdentifier.isNotEmpty
                                      ? entry.telegraphIdentifier.toUpperCase()
                                      : 'UNIDENTIFIED',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: kAccent,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            entry.manufacturer.isNotEmpty
                                ? entry.manufacturer.toUpperCase()
                                : 'UNKNOWN MAKER',
                            style: GoogleFonts.outfit(
                              color: kPrimaryText,
                              fontSize: 38.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              letterSpacing: -1.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),

                          SizedBox(height: 24.h),
                          // ── Tags ──────────────────────────
                          Wrap(
                            spacing: 12.w,
                            runSpacing: 12.h,
                            children: [
                              _editorialTag(
                                entry.sounderType.label.toUpperCase(),
                                getSounderTypeColor(entry.sounderType),
                                true,
                              ),
                              _editorialTag(
                                entry.conditionState.label
                                    .split('—')
                                    .first
                                    .trim()
                                    .toUpperCase(),
                                getConditionColor(entry.conditionState),
                                false,
                              ),
                              if (entry.presumedEra.isNotEmpty)
                                _editorialTag(
                                  entry.presumedEra.toUpperCase(),
                                  kPrimaryText,
                                  false,
                                ),
                            ],
                          ),

                          SizedBox(height: 48.h),
                          // ── Specs Table ──────────────────────────
                          if (_hasSpecs(entry) ||
                              entry.telegraphCompany.isNotEmpty) ...[
                            _sectionHeader('TECHNICAL DATA'),
                            _buildModernTable(entry),
                            SizedBox(height: 48.h),
                          ],

                          // ── Text Records ──────────────────────────
                          ..._textPanels(entry),

                          if (entry.tags.isNotEmpty) ...[
                            _sectionHeader('INDEX TAGS'),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: entry.tags
                                  .map(
                                    (t) => Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kPanelBg,
                                        borderRadius: BorderRadius.circular(
                                          kRadiusMedium,
                                        ),
                                        border: Border.all(color: kOutline),
                                      ),
                                      child: Text(
                                        '#${t.toUpperCase()}',
                                        style: GoogleFonts.jetBrainsMono(
                                          color: kSecondaryText,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 3. Top Navigation Bar ───────────────────────────────────────
          // Placed at the end of stack record to be on top
          Positioned(
            top: topPadding + 10.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _glassButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    _glassButton(
                      icon: Icons.edit_outlined,
                      onTap: () {
                        projectProv.fillInput(ref, index);
                        Navigator.pushNamed(
                          context,
                          '/add_screen',
                          arguments: {'isEdit': true, 'currentIndex': index},
                        );
                      },
                    ),
                    SizedBox(width: 12.w),
                    _glassButton(
                      icon: Icons.delete_outline,
                      iconColor: kError,
                      onTap: () => _confirmDelete(context, projectProv, index),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editorialTag(String text, Color color, bool filled) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(kRadiusPill),
      ),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          color: filled ? kBackground : color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: const BoxDecoration(color: kAccent),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: kPrimaryText,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasSpecs(SounderModel e) =>
      e.armatureType != ArmatureType.straight ||
      e.coilResistance.isNotEmpty ||
      e.contactType.isNotEmpty ||
      e.dimensions.isNotEmpty ||
      e.specialization != SounderSpecialization.other;

  Widget _buildModernTable(SounderModel e) {
    final rows = <_SpecRow>[];
    if (e.telegraphCompany.isNotEmpty) {
      rows.add(_SpecRow('Operator / Network', e.telegraphCompany));
    }
    if (e.countryOfManufacture.isNotEmpty) {
      rows.add(_SpecRow('Origin', e.countryOfManufacture));
    }
    rows.add(_SpecRow('Armature', e.armatureType.label));
    rows.add(_SpecRow('Material Focus', e.manufacturingMaterial.label));
    rows.add(_SpecRow('Specialization', e.specialization.label));

    if (e.coilResistance.isNotEmpty) {
      rows.add(_SpecRow('Coil Resistance', '${e.coilResistance} Ω'));
    }
    if (e.contactType.isNotEmpty) {
      rows.add(_SpecRow('Contacts', e.contactType));
    }
    if (e.dimensions.isNotEmpty) {
      rows.add(_SpecRow('Dimensions', e.dimensions));
    }
    if (e.adjustments.isNotEmpty) {
      rows.add(_SpecRow('Adjustments', e.adjustments));
    }

    return Column(
      children: rows.map((row) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusMedium),
            border: Border.all(color: kOutline, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120.w,
                child: Text(
                  row.label.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    color: kSecondaryText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  row.value,
                  style: GoogleFonts.dmSans(
                    color: kPrimaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _textPanels(SounderModel e) {
    final items = <_TextPanel>[];
    if (e.stampsAndMarkings.isNotEmpty) {
      items.add(_TextPanel('STAMPS & MARKINGS', e.stampsAndMarkings));
    }
    if (e.provenance.isNotEmpty) {
      items.add(_TextPanel('PROVENANCE', e.provenance));
    }
    if (e.notes.isNotEmpty) {
      items.add(_TextPanel('ARCHIVAL NOTES', e.notes));
    }

    return items
        .expand(
          (panel) => [
            _sectionHeader(panel.label),
            Padding(
              padding: EdgeInsets.only(bottom: 40.h),
              child: Text(
                panel.text,
                style: GoogleFonts.dmSans(
                  color: kPrimaryText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w300,
                  height: 1.8,
                ),
              ),
            ),
          ],
        )
        .toList();
  }

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = kPrimaryText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          kRadiusMedium,
        ), // Standardized radius
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: kPanelBg.withAlpha(200),
              borderRadius: BorderRadius.circular(
                kRadiusMedium,
              ), // Standardized radius
              border: Border.all(color: kOutline.withAlpha(100), width: 1.5),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ProjectNotifier projectProv,
    int idx,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          MediaQuery.of(ctx).padding.bottom + 20.h,
        ),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(kRadiusMedium),
          ),
          border: const Border(top: BorderSide(color: kOutline, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 3.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: kOutline,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
              ),
            ),
            Text(
              'DELETE RECORD?',
              style: GoogleFonts.outfit(
                color: kError,
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This will permanently remove this sounder from the archive. You cannot undo this.',
              style: GoogleFonts.dmSans(
                color: kSecondaryText,
                fontSize: 15.sp,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      height: 52.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(kRadiusMedium),
                        border: Border.all(color: kOutline),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(
                          color: kPrimaryText,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      projectProv.deleteEntry(idx);
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 52.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kError,
                        borderRadius: BorderRadius.circular(kRadiusMedium),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecRow {
  final String label;
  final String value;
  _SpecRow(this.label, this.value);
}

class _TextPanel {
  final String label;
  final String text;
  _TextPanel(this.label, this.text);
}
