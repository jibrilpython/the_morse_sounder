import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:the_morse_sounder/enum/my_enums.dart';
import 'package:the_morse_sounder/models/sounder_model.dart';
import 'package:the_morse_sounder/providers/image_provider.dart';
import 'package:the_morse_sounder/providers/project_provider.dart';
import 'package:the_morse_sounder/providers/search_provider.dart';
import 'package:the_morse_sounder/providers/input_provider.dart';
import 'package:the_morse_sounder/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  SounderType? _selectedTypeFilter;
  bool _searchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _searchController.clear();
        ref.read(searchProvider.notifier).clearSearchQuery();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final allEntries = ref.watch(projectProvider).entries;
    final filtered = _selectedTypeFilter == null
        ? allEntries
        : allEntries
              .where((e) => e.sounderType == _selectedTypeFilter)
              .toList();
    final entries = searchProv.filteredList(filtered);
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          // ── App Bar Redesign ──────────────────────────────────────────────
          _buildAppBar(top, allEntries.length),

          // ── Filter strip ──────────────────────────────────────────────────
          _buildFilterStrip(),

          // ── Entries Array ──────────────────────────────────────────────────
          Expanded(
            child: entries.isEmpty
                ? _buildEmptyState()
                : MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      4.h,
                      20.w,
                      bottom + 140.h,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: entries.length,
                    itemBuilder: (context, i) {
                      final entry = entries[i];
                      final mainIdx = ref
                          .read(projectProvider)
                          .entries
                          .indexOf(entry);
                      return _buildStaggeredCard(context, entry, mainIdx, i);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom + 96.h),
        child: GestureDetector(
          onTap: () {
            ref.read(inputProvider).clearAll();
            ref.read(imageProvider).clearImage();
            Navigator.pushNamed(context, '/add_screen');
          },
          child: Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: kAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kAccent.withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(Icons.add, color: kBackground, size: 26.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(double top, int count) {
    return Container(
      decoration: const BoxDecoration(color: kBackground),
      padding: EdgeInsets.fromLTRB(20.w, top + 32.h, 20.w, 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  margin: EdgeInsets.only(bottom: 14.h),
                  decoration: BoxDecoration(
                    color: kAccent.withAlpha(20),
                    border: Border.all(color: kAccent.withAlpha(80)),
                    borderRadius: BorderRadius.circular(kRadiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: kAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${count.toString().padLeft(2, '0')} LOGGED',
                        style: GoogleFonts.jetBrainsMono(
                          color: kAccent,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'THE',
                  style: GoogleFonts.outfit(
                    color: kSecondaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  'ARCHIVE',
                  style: GoogleFonts.outfit(
                    color: kPrimaryText,
                    fontSize: 38.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -1.0,
                  ),
                ),
              ],
            ),
          ),
          // Search icon container standardized radius
          Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: GestureDetector(
              onTap: _toggleSearch,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: _searchOpen ? kAccent : kPanelBg,
                  borderRadius: BorderRadius.circular(
                    kRadiusMedium,
                  ), // Standardized
                  border: Border.all(
                    color: _searchOpen ? kAccent : kOutline,
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  _searchOpen ? Icons.close : Icons.search,
                  color: _searchOpen ? kBackground : kPrimaryText,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: _searchOpen ? 70.h : 0,
          child: _searchOpen
              ? Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (v) =>
                        ref.read(searchProvider.notifier).setSearchQuery(v),
                    style: GoogleFonts.dmSans(
                      color: kPrimaryText,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search makers, eras, companies…',
                      hintStyle: GoogleFonts.dmSans(
                        color: kSecondaryText.withAlpha(90),
                        fontSize: 13.sp,
                      ),
                      filled: true,
                      fillColor: kPanelBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(kRadiusMedium),
                        borderSide: const BorderSide(color: kOutline, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(kRadiusMedium),
                        borderSide: const BorderSide(color: kOutline, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(kRadiusMedium),
                        borderSide: const BorderSide(
                          color: kAccent,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 13.h,
                      ),
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.search,
                        color: kSecondaryText,
                        size: 18.sp,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Type filter chips
        SizedBox(
          height: 38.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              _filterChip('All', null),
              ...SounderType.values.map((t) => _filterChip(t.label, t)),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Container(height: 1, color: kOutline.withAlpha(90)),
      ],
    );
  }

  Widget _filterChip(String label, SounderType? type) {
    final isSel = _selectedTypeFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedTypeFilter = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: isSel ? kAccent : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: isSel ? kAccent : kOutline, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            color: isSel ? kBackground : kSecondaryText,
            fontSize: 11.sp,
            fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredCard(
    BuildContext context,
    SounderModel entry,
    int idx,
    int listPos,
  ) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final hasImage =
        entry.photoPath.isNotEmpty &&
        imagePath != null &&
        File(imagePath).existsSync();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': idx},
      ),
      child: Stack(
        children: [
          // The base card with content
          Container(
            decoration: BoxDecoration(
              color: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusLarge),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasImage)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 180.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.file(File(imagePath), fit: BoxFit.cover),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 80.h,
                    color: kBackground.withAlpha(100),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: kSecondaryText.withAlpha(80),
                      size: 24.sp,
                    ),
                  ),

                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${(listPos + 1).toString().padLeft(2, '0')}',
                            style: GoogleFonts.jetBrainsMono(
                              color: kAccent,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: getSounderTypeColor(entry.sounderType),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        entry.manufacturer.isNotEmpty
                            ? entry.manufacturer.toUpperCase()
                            : 'UNKNOWN MAKER',
                        style: GoogleFonts.outfit(
                          color: kPrimaryText,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (entry.telegraphIdentifier.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          entry.telegraphIdentifier.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            color: kSecondaryText,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (entry.presumedEra.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Text(
                          entry.presumedEra,
                          style: GoogleFonts.jetBrainsMono(
                            color: kSecondaryText.withAlpha(200),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Positioned border on top to ensure corners are NEVER hidden
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kRadiusLarge),
                  border: Border.all(
                    color: kAccent.withAlpha(200),
                    width: 1.8.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
              'ARCHIVE IS SILENT.',
              style: GoogleFonts.outfit(
                color: kPrimaryText,
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Tap + to log your first sounder.',
              style: GoogleFonts.dmSans(
                color: kSecondaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w300,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
