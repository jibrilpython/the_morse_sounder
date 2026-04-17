import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_morse_sounder/common/photo_bottom_sheet.dart';
import 'package:the_morse_sounder/enum/my_enums.dart';
import 'package:the_morse_sounder/providers/image_provider.dart';
import 'package:the_morse_sounder/providers/input_provider.dart';
import 'package:the_morse_sounder/providers/project_provider.dart';
import 'package:the_morse_sounder/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late TextEditingController _idCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _manCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _eraCtrl;
  late TextEditingController _coilCtrl;
  late TextEditingController _dimCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _adjCtrl;
  late TextEditingController _stampsCtrl;
  late TextEditingController _provCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    final p = ref.read(inputProvider);
    _idCtrl = TextEditingController(text: p.telegraphIdentifier);
    _companyCtrl = TextEditingController(text: p.telegraphCompany);
    _manCtrl = TextEditingController(text: p.manufacturer);
    _countryCtrl = TextEditingController(text: p.countryOfManufacture);
    _eraCtrl = TextEditingController(text: p.presumedEra);
    _coilCtrl = TextEditingController(text: p.coilResistance);
    _dimCtrl = TextEditingController(text: p.dimensions);
    _contactCtrl = TextEditingController(text: p.contactType);
    _adjCtrl = TextEditingController(text: p.adjustments);
    _stampsCtrl = TextEditingController(text: p.stampsAndMarkings);
    _provCtrl = TextEditingController(text: p.provenance);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  @override
  void dispose() {
    for (final c in [
      _idCtrl,
      _companyCtrl,
      _manCtrl,
      _countryCtrl,
      _eraCtrl,
      _coilCtrl,
      _dimCtrl,
      _contactCtrl,
      _adjCtrl,
      _stampsCtrl,
      _provCtrl,
      _notesCtrl,
      _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final p = ref.read(inputProvider);
    if (p.telegraphIdentifier.trim().isEmpty || p.manufacturer.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Identifier and maker are required.',
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13.sp),
          ),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusCard),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }
    if (mounted) {
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final imgPath = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);

    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          // ── Top bar ────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20.w, top + 16.h, 16.w, 14.h),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kOutline, width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: kPanelBg,
                      borderRadius: BorderRadius.circular(kRadiusMedium),
                      border: Border.all(color: kOutline),
                    ),
                    child: Icon(Icons.close, color: kPrimaryText, size: 18.sp),
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isEdit ? 'EDIT RECORD' : 'NEW RECORD',
                      style: GoogleFonts.outfit(
                        color: kPrimaryText,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.isEdit
                          ? 'Update archive entry'
                          : 'Log a sounder specimen',
                      style: GoogleFonts.dmSans(
                        color: kSecondaryText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Form ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo block — generous height
                  _buildPhotoBlock(imgPath),

                  // 01 Identification
                  _sectionHeader('01', 'Identification'),
                  _field(
                    'Telegraph Identifier',
                    _idCtrl,
                    hint: 'TTSA-SOUNDER-1880-WU-047',
                    onChanged: (v) =>
                        ref.read(inputProvider).telegraphIdentifier = v,
                  ),
                  _field(
                    'Manufacturer',
                    _manCtrl,
                    hint: 'J.H. Bunnell & Co.',
                    onChanged: (v) => ref.read(inputProvider).manufacturer = v,
                  ),
                  _field(
                    'Telegraph Company',
                    _companyCtrl,
                    hint: 'Western Union',
                    onChanged: (v) =>
                        ref.read(inputProvider).telegraphCompany = v,
                  ),
                  _field(
                    'Country of Manufacture',
                    _countryCtrl,
                    hint: 'USA',
                    onChanged: (v) =>
                        ref.read(inputProvider).countryOfManufacture = v,
                  ),

                  // 02 Classification
                  _sectionHeader('02', 'Classification'),
                  _labelText('Sounder Type'),
                  _chipSelector<SounderType>(
                    values: SounderType.values,
                    current: ref.watch(inputProvider).sounderType,
                    label: (t) => t.label,
                    onSelect: (t) => ref.read(inputProvider).sounderType = t,
                    colorFn: (t) => getSounderTypeColor(t),
                  ),
                  SizedBox(height: 20.h),
                  _labelText('Specialization'),
                  _chipSelector<SounderSpecialization>(
                    values: SounderSpecialization.values,
                    current: ref.watch(inputProvider).specialization,
                    label: (t) => t.label,
                    onSelect: (t) => ref.read(inputProvider).specialization = t,
                  ),
                  SizedBox(height: 20.h),
                  _labelText('Presumed Era'),
                  _eraChips(),
                  SizedBox(height: 8.h),
                  _field(
                    'Or enter custom era',
                    _eraCtrl,
                    hint: '1882',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,4}s?$')),
                    ],
                    onChanged: (v) => ref.read(inputProvider).presumedEra = v,
                  ),

                  // 03 Technical
                  _sectionHeader('03', 'Technical'),
                  _labelText('Armature Type'),
                  _chipSelector<ArmatureType>(
                    values: ArmatureType.values,
                    current: ref.watch(inputProvider).armatureType,
                    label: (t) => t.label,
                    onSelect: (t) => ref.read(inputProvider).armatureType = t,
                    colorFn: (t) => getArmatureColor(t),
                  ),
                  SizedBox(height: 20.h),
                  _labelText('Material Composition'),
                  _chipSelector<ManufacturingMaterial>(
                    values: ManufacturingMaterial.values,
                    current: ref.watch(inputProvider).manufacturingMaterial,
                    label: (t) => t.label,
                    onSelect: (t) =>
                        ref.read(inputProvider).manufacturingMaterial = t,
                    colorFn: (t) => getMaterialColor(t),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: _inlineField(
                            'Coil Resistance (Ω)',
                            _coilCtrl,
                            hint: '4.5',
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                ref.read(inputProvider).coilResistance = v,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _inlineField(
                            'Contact Type',
                            _contactCtrl,
                            hint: 'Platinum',
                            onChanged: (v) =>
                                ref.read(inputProvider).contactType = v,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _field(
                    'Dimensions & Weight',
                    _dimCtrl,
                    hint: '120×80×95mm, 340g',
                    onChanged: (v) => ref.read(inputProvider).dimensions = v,
                  ),
                  _field(
                    'Adjustments',
                    _adjCtrl,
                    hint: 'Contact adj, spring tension, air gap…',
                    maxLines: 2,
                    onChanged: (v) => ref.read(inputProvider).adjustments = v,
                  ),

                  // 04 Archival
                  _sectionHeader('04', 'Archival'),
                  _labelText('Condition'),
                  _chipSelector<ConditionState>(
                    values: ConditionState.values,
                    current: ref.watch(inputProvider).conditionState,
                    label: (s) => s.label.split('—').first.trim(),
                    onSelect: (s) => ref.read(inputProvider).conditionState = s,
                    colorFn: (s) => getConditionColor(s),
                  ),
                  SizedBox(height: 20.h),
                  _field(
                    'Stamps & Markings',
                    _stampsCtrl,
                    hint: 'Factory stamp, serial number…',
                    maxLines: 2,
                    onChanged: (v) =>
                        ref.read(inputProvider).stampsAndMarkings = v,
                  ),
                  _field(
                    'Provenance',
                    _provCtrl,
                    hint: 'Closed telegraph station, auction…',
                    maxLines: 2,
                    onChanged: (v) => ref.read(inputProvider).provenance = v,
                  ),
                  _field(
                    'Archival Notes',
                    _notesCtrl,
                    hint: 'Observations and historical context…',
                    maxLines: 3,
                    onChanged: (v) => ref.read(inputProvider).notes = v,
                  ),
                  _field(
                    'Tags',
                    _tagsCtrl,
                    hint: 'rare, western-union, brass…',
                    onChanged: (v) => ref.read(inputProvider).tags = v
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList(),
                  ),

                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),

          // ── Save CTA ───────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, bottom + 20.h),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kOutline, width: 1)),
            ),
            child: GestureDetector(
              onTap: _save,
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(kRadiusCard),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.isEdit ? 'Update record' : 'Commit to archive',
                  style: GoogleFonts.outfit(
                    color: kBackground,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBlock(String? imgPath) {
    final hasImage = imgPath != null && File(imgPath).existsSync();
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        width: double.infinity,
        // Proper photo height — 200h without image, full 260h with
        height: hasImage ? 260.h : 160.h,
        color: kPanelBg,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(imgPath), fit: BoxFit.cover),
                  Positioned(
                    top: 14.h,
                    right: 14.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: kBackground.withAlpha(190),
                        borderRadius: BorderRadius.circular(kRadiusCard),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: kPrimaryText,
                            size: 14.sp,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'Edit',
                            style: GoogleFonts.dmSans(
                              color: kPrimaryText,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: kOutline.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: kSecondaryText,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Add photograph',
                    style: GoogleFonts.dmSans(
                      color: kSecondaryText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Tap to open camera or gallery',
                    style: GoogleFonts.dmSans(
                      color: kSecondaryText.withAlpha(100),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _sectionHeader(String num, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$num.',
            style: GoogleFonts.jetBrainsMono(
              color: kAccent,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: kPrimaryText,
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(child: Container(height: 1, color: kOutline)),
        ],
      ),
    );
  }

  Widget _labelText(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 10.h),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.dmSans(
          color: kSecondaryText,
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.dmSans(
          color: kPrimaryText,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
            color: kSecondaryText.withAlpha(60),
            fontSize: 13.sp,
            fontWeight: FontWeight.w300,
          ),
          labelStyle: GoogleFonts.dmSans(
            color: kSecondaryText,
            fontSize: 13.sp,
          ),
          floatingLabelStyle: GoogleFonts.dmSans(
            color: kAccent,
            fontSize: 12.sp,
          ),
          filled: true,
          fillColor: kPanelBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusCard),
            borderSide: const BorderSide(color: kOutline, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusCard),
            borderSide: const BorderSide(color: kOutline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusCard),
            borderSide: const BorderSide(color: kAccent, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _inlineField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(
        color: kPrimaryText,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.dmSans(color: kSecondaryText, fontSize: 13.sp),
        floatingLabelStyle: GoogleFonts.dmSans(color: kAccent, fontSize: 12.sp),
        hintStyle: GoogleFonts.dmSans(
          color: kSecondaryText.withAlpha(60),
          fontSize: 13.sp,
        ),
        filled: true,
        fillColor: kPanelBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusCard),
          borderSide: const BorderSide(color: kOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusCard),
          borderSide: const BorderSide(color: kOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusCard),
          borderSide: const BorderSide(color: kAccent, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        isDense: true,
      ),
    );
  }

  Widget _chipSelector<T>({
    required List<T> values,
    required T current,
    required String Function(T) label,
    required Function(T) onSelect,
    Color Function(T)? colorFn,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 10.h,
        children: values.map((v) {
          final isSel = v == current;
          final color = colorFn != null ? colorFn(v) : kAccent;
          return GestureDetector(
            onTap: () => onSelect(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSel ? color.withAlpha(28) : Colors.transparent,
                borderRadius: BorderRadius.circular(kRadiusCard),
                border: Border.all(
                  color: isSel ? color : kOutline,
                  width: isSel ? 1.5 : 1.0,
                ),
              ),
              child: Text(
                label(v),
                style: GoogleFonts.dmSans(
                  color: isSel ? color : kSecondaryText,
                  fontSize: 13.sp,
                  fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _eraChips() {
    final eras = [
      '1850s',
      '1860s',
      '1870s',
      '1880s',
      '1890s',
      '1900s',
      '1910s',
      '1920s',
      '1930s',
      '1940s',
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 10.h,
        children: eras.map((era) {
          final isSel = ref.watch(inputProvider).presumedEra == era;
          return GestureDetector(
            onTap: () {
              _eraCtrl.text = era;
              ref.read(inputProvider).presumedEra = era;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSel ? kAccent.withAlpha(22) : Colors.transparent,
                borderRadius: BorderRadius.circular(kRadiusCard),
                border: Border.all(
                  color: isSel ? kAccent : kOutline,
                  width: isSel ? 1.5 : 1.0,
                ),
              ),
              child: Text(
                era,
                style: GoogleFonts.jetBrainsMono(
                  color: isSel ? kAccent : kSecondaryText,
                  fontSize: 11.sp,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
