import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_morse_sounder/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _telegraphIdentifier = '';
  SounderType _sounderType = SounderType.mainSounder;
  SounderSpecialization _specialization = SounderSpecialization.other;
  String _telegraphCompany = '';
  String _manufacturer = '';
  String _countryOfManufacture = '';
  String _presumedEra = '';
  ManufacturingMaterial _manufacturingMaterial = ManufacturingMaterial.brass;
  String _coilResistance = '';
  ArmatureType _armatureType = ArmatureType.straight;
  String _adjustments = '';
  String _dimensions = '';
  String _contactType = '';
  ConditionState _conditionState = ConditionState.unknown;
  String _stampsAndMarkings = '';
  String _provenance = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  // Getters
  String get telegraphIdentifier => _telegraphIdentifier;
  SounderType get sounderType => _sounderType;
  SounderSpecialization get specialization => _specialization;
  String get telegraphCompany => _telegraphCompany;
  String get manufacturer => _manufacturer;
  String get countryOfManufacture => _countryOfManufacture;
  String get presumedEra => _presumedEra;
  ManufacturingMaterial get manufacturingMaterial => _manufacturingMaterial;
  String get coilResistance => _coilResistance;
  ArmatureType get armatureType => _armatureType;
  String get adjustments => _adjustments;
  String get dimensions => _dimensions;
  String get contactType => _contactType;
  ConditionState get conditionState => _conditionState;
  String get stampsAndMarkings => _stampsAndMarkings;
  String get provenance => _provenance;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  // Setters
  set telegraphIdentifier(String v) { _telegraphIdentifier = v; notifyListeners(); }
  set sounderType(SounderType v) { _sounderType = v; notifyListeners(); }
  set specialization(SounderSpecialization v) { _specialization = v; notifyListeners(); }
  set telegraphCompany(String v) { _telegraphCompany = v; notifyListeners(); }
  set manufacturer(String v) { _manufacturer = v; notifyListeners(); }
  set countryOfManufacture(String v) { _countryOfManufacture = v; notifyListeners(); }
  set presumedEra(String v) { _presumedEra = v; notifyListeners(); }
  set manufacturingMaterial(ManufacturingMaterial v) { _manufacturingMaterial = v; notifyListeners(); }
  set coilResistance(String v) { _coilResistance = v; notifyListeners(); }
  set armatureType(ArmatureType v) { _armatureType = v; notifyListeners(); }
  set adjustments(String v) { _adjustments = v; notifyListeners(); }
  set dimensions(String v) { _dimensions = v; notifyListeners(); }
  set contactType(String v) { _contactType = v; notifyListeners(); }
  set conditionState(ConditionState v) { _conditionState = v; notifyListeners(); }
  set stampsAndMarkings(String v) { _stampsAndMarkings = v; notifyListeners(); }
  set provenance(String v) { _provenance = v; notifyListeners(); }
  set notes(String v) { _notes = v; notifyListeners(); }
  set photoPath(String v) { _photoPath = v; notifyListeners(); }
  set tags(List<String> v) { _tags = v; notifyListeners(); }
  set dateAdded(DateTime v) { _dateAdded = v; notifyListeners(); }

  void clearAll() {
    _telegraphIdentifier = '';
    _sounderType = SounderType.mainSounder;
    _specialization = SounderSpecialization.other;
    _telegraphCompany = '';
    _manufacturer = '';
    _countryOfManufacture = '';
    _presumedEra = '';
    _manufacturingMaterial = ManufacturingMaterial.brass;
    _coilResistance = '';
    _armatureType = ArmatureType.straight;
    _adjustments = '';
    _dimensions = '';
    _contactType = '';
    _conditionState = ConditionState.unknown;
    _stampsAndMarkings = '';
    _provenance = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
