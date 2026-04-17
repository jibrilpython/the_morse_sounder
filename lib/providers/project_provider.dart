import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:the_morse_sounder/models/sounder_model.dart';
import 'package:the_morse_sounder/providers/image_provider.dart';
import 'package:the_morse_sounder/providers/input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<SounderModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'tms_entries_v1';
  final _uuid = const Uuid();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries = decodedList
            .map((item) => SounderModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }

  void addEntry(WidgetRef ref) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);

    entries.add(
      SounderModel(
        id: _uuid.v4(),
        telegraphIdentifier: p.telegraphIdentifier,
        sounderType: p.sounderType,
        specialization: p.specialization,
        telegraphCompany: p.telegraphCompany,
        manufacturer: p.manufacturer,
        countryOfManufacture: p.countryOfManufacture,
        presumedEra: p.presumedEra,
        manufacturingMaterial: p.manufacturingMaterial,
        coilResistance: p.coilResistance,
        armatureType: p.armatureType,
        adjustments: p.adjustments,
        dimensions: p.dimensions,
        contactType: p.contactType,
        conditionState: p.conditionState,
        stampsAndMarkings: p.stampsAndMarkings,
        provenance: p.provenance,
        notes: p.notes,
        photoPath: imgProv.resultImage.isNotEmpty ? imgProv.resultImage : p.photoPath,
        tags: List<String>.from(p.tags),
        dateAdded: p.dateAdded,
      ),
    );

    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final existing = entries[index];

    entries[index] = SounderModel(
      id: existing.id,
      telegraphIdentifier: p.telegraphIdentifier,
      sounderType: p.sounderType,
      specialization: p.specialization,
      telegraphCompany: p.telegraphCompany,
      manufacturer: p.manufacturer,
      countryOfManufacture: p.countryOfManufacture,
      presumedEra: p.presumedEra,
      manufacturingMaterial: p.manufacturingMaterial,
      coilResistance: p.coilResistance,
      armatureType: p.armatureType,
      adjustments: p.adjustments,
      dimensions: p.dimensions,
      contactType: p.contactType,
      conditionState: p.conditionState,
      stampsAndMarkings: p.stampsAndMarkings,
      provenance: p.provenance,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty ? imgProv.resultImage : existing.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: existing.dateAdded,
    );

    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    entries.removeAt(index);
    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];

    p.telegraphIdentifier = entry.telegraphIdentifier;
    p.sounderType = entry.sounderType;
    p.specialization = entry.specialization;
    p.telegraphCompany = entry.telegraphCompany;
    p.manufacturer = entry.manufacturer;
    p.countryOfManufacture = entry.countryOfManufacture;
    p.presumedEra = entry.presumedEra;
    p.manufacturingMaterial = entry.manufacturingMaterial;
    p.coilResistance = entry.coilResistance;
    p.armatureType = entry.armatureType;
    p.adjustments = entry.adjustments;
    p.dimensions = entry.dimensions;
    p.contactType = entry.contactType;
    p.conditionState = entry.conditionState;
    p.stampsAndMarkings = entry.stampsAndMarkings;
    p.provenance = entry.provenance;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;

    imgProv.resultImage = entry.photoPath;

    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
