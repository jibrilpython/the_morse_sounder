import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_morse_sounder/enum/my_enums.dart';
import 'package:the_morse_sounder/models/sounder_model.dart';
import 'package:the_morse_sounder/providers/project_provider.dart';
import 'package:the_morse_sounder/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int? _selectedEraIndex;
  static const List<String> _eras = [
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

  String? _decadeFromEra(String era) {
    if (era.isEmpty) return null;
    if (RegExp(r'^\d{3}0s$').hasMatch(era)) return era;
    final clean = era.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 4) return null;
    final year = int.tryParse(clean.substring(0, 4));
    if (year != null) return '${(year ~/ 10) * 10}s';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(projectProvider).entries;
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    final selectedEra = _selectedEraIndex != null
        ? _eras[_selectedEraIndex!]
        : null;
    final displayEntries = selectedEra == null
        ? allEntries
        : allEntries
              .where((e) => _decadeFromEra(e.presumedEra) == selectedEra)
              .toList();

    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header — generous breathing room ──────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, top + 24.h, 24.w, 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 12.w, height: 2.h, color: kAccent),
                    SizedBox(width: 8.w),
                    Text(
                      'LOGBOOK',
                      style: GoogleFonts.outfit(
                        color: kPrimaryText,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'COLLECTION AT A GLANCE',
                  style: GoogleFonts.dmSans(
                    color: kSecondaryText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: kOutline.withAlpha(120)),

          Expanded(
            child: allEntries.isEmpty
                ? _buildEmpty()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: bottom + 100.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Summary numbers ──────────────────────────────
                        _buildSummaryRow(allEntries),
                        Container(height: 1, color: kOutline),

                        // ── Era chart ────────────────────────────────────
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 4.h),
                          child: _colLabel('ERA DISTRIBUTION'),
                        ),
                        _buildEraChart(allEntries),

                        // Filter badge
                        if (_selectedEraIndex != null)
                          Padding(
                            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_alt_outlined,
                                  color: kAccent,
                                  size: 13.sp,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  'Viewing ${_eras[_selectedEraIndex!]} only',
                                  style: GoogleFonts.dmSans(
                                    color: kAccent,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedEraIndex = null),
                                  child: Text(
                                    '· clear',
                                    style: GoogleFonts.dmSans(
                                      color: kSecondaryText,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 28.h),
                        Container(height: 1, color: kOutline),

                        // ── Type breakdown ───────────────────────────────
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 16.h),
                          child: _colLabel('SOUNDER TYPES'),
                        ),
                        _buildTypeList(displayEntries),

                        Container(height: 1, color: kOutline),

                        // ── Material + Condition ─────────────────────────
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 18.h),
                          child: _colLabel('COMPOSITION & CONDITION'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildPropList<ManufacturingMaterial>(
                                  entries: displayEntries,
                                  label: 'Material',
                                  selector: (e) => e.manufacturingMaterial,
                                  labelFn: (m) => m.label,
                                  colorFn: getMaterialColor,
                                ),
                              ),
                              SizedBox(width: 24.w),
                              Container(
                                width: 1,
                                color: kOutline,
                                height: 180.h,
                              ),
                              SizedBox(width: 24.w),
                              Expanded(
                                child: _buildPropList<ConditionState>(
                                  entries: displayEntries,
                                  label: 'Condition',
                                  selector: (e) => e.conditionState,
                                  labelFn: (c) =>
                                      c.label.split('—').first.trim(),
                                  colorFn: getConditionColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28.h),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '—',
              style: GoogleFonts.outfit(
                color: kAccent,
                fontSize: 36.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'LOGBOOK EMPTY.',
              style: GoogleFonts.outfit(
                color: kPrimaryText,
                fontSize: 30.sp,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Add sounders to generate archive metrics.',
              style: GoogleFonts.dmSans(
                color: kSecondaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w300,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(List<SounderModel> entries) {
    final topMaker = () {
      final c = <String, int>{};
      for (var e in entries) {
        if (e.manufacturer.isNotEmpty) {
          c[e.manufacturer] = (c[e.manufacturer] ?? 0) + 1;
        }
      }
      return c.isEmpty
          ? '—'
          : c.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }();
    final typeCount = entries.map((e) => e.sounderType).toSet().length;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 28.h),
      child: Row(
        children: [
          // Large count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entries.length.toString().padLeft(2, '0'),
                  style: GoogleFonts.outfit(
                    color: kAccent,
                    fontSize: 56.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                Text(
                  'SOUNDERS\nCATALOGUED',
                  style: GoogleFonts.dmSans(
                    color: kAccent.withAlpha(180),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 72.h, color: kOutline),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryItem('Variants', '$typeCount types'),
                SizedBox(height: 14.h),
                _summaryItem('Top maker', topMaker),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: kSecondaryText,
            fontSize: 11.sp,
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: kPrimaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _colLabel(String label) {
    return Row(
      children: [
        Container(width: 8.w, height: 8.w, color: kAccent),
        SizedBox(width: 10.w),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: kAccent,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEraChart(List<SounderModel> entries) {
    final eraCounts = <String, int>{};
    for (var e in entries) {
      final d = _decadeFromEra(e.presumedEra);
      if (d != null) eraCounts[d] = (eraCounts[d] ?? 0) + 1;
    }
    if (eraCounts.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 0),
        child: Text(
          'No era data recorded.',
          style: GoogleFonts.dmSans(
            color: kSecondaryText,
            fontSize: 13.sp,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }
    final maxCount = eraCounts.values.reduce(math.max);

    return SizedBox(
      height: 130.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
        children: _eras.map((era) {
          final count = eraCounts[era] ?? 0;
          final idx = _eras.indexOf(era);
          final isSel = _selectedEraIndex == idx;
          final barH = count == 0 ? 2.0 : (count / maxCount) * 62.h;

          return GestureDetector(
            onTap: () {
              if (count == 0) return;
              HapticFeedback.selectionClick();
              setState(() => _selectedEraIndex = isSel ? null : idx);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 18.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (count > 0)
                    Text(
                      '$count',
                      style: GoogleFonts.jetBrainsMono(
                        color: isSel ? kAccent : kSecondaryText,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  SizedBox(height: 4.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 22.w,
                    height: barH,
                    decoration: BoxDecoration(
                      color: isSel
                          ? kAccent
                          : (count > 0
                                ? kAccent.withAlpha(40)
                                : kOutline.withAlpha(50)),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    era.substring(2, 5),
                    style: GoogleFonts.jetBrainsMono(
                      color: isSel ? kAccent : kSecondaryText.withAlpha(90),
                      fontSize: 8.sp,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeList(List<SounderModel> entries) {
    final counts = <SounderType, int>{};
    for (var e in entries) {
      counts[e.sounderType] = (counts[e.sounderType] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isEmpty ? 1 : sorted.first.value;

    return Column(
      children: sorted.map((entry) {
        final color = getSounderTypeColor(entry.key);
        final frac = entry.value / maxVal;
        return Container(
          padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 14.h),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: kOutline, width: 1)),
          ),
          child: Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  entry.key.label,
                  style: GoogleFonts.dmSans(
                    color: kPrimaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                width: 90.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.value}',
                      style: GoogleFonts.jetBrainsMono(
                        color: color,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 90.w * frac,
                      height: 2.h,
                      color: color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPropList<T>({
    required List<SounderModel> entries,
    required String label,
    required T Function(SounderModel) selector,
    required String Function(T) labelFn,
    required Color Function(T) colorFn,
  }) {
    final counts = <T, int>{};
    for (var e in entries) {
      final v = selector(e);
      counts[v] = (counts[v] ?? 0) + 1;
    }
    final sorted = counts.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            color: kAccent.withAlpha(180),
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        ...sorted
            .take(5)
            .map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  children: [
                    Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: BoxDecoration(
                        color: colorFn(e.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        labelFn(e.key),
                        style: GoogleFonts.dmSans(
                          color: kPrimaryText,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${e.value}',
                      style: GoogleFonts.jetBrainsMono(
                        color: kSecondaryText,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
