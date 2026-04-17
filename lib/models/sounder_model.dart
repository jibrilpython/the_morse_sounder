import 'package:the_morse_sounder/enum/my_enums.dart';

class SounderModel {
  String id;
  String telegraphIdentifier;
  SounderType sounderType;
  SounderSpecialization specialization;
  String telegraphCompany;
  String manufacturer;
  String countryOfManufacture;
  String presumedEra;
  ManufacturingMaterial manufacturingMaterial;
  String coilResistance;
  ArmatureType armatureType;
  String adjustments;
  String dimensions;
  String contactType;
  ConditionState conditionState;
  String stampsAndMarkings;
  String provenance;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  SounderModel({
    required this.id,
    required this.telegraphIdentifier,
    required this.sounderType,
    required this.specialization,
    required this.telegraphCompany,
    required this.manufacturer,
    required this.countryOfManufacture,
    required this.presumedEra,
    required this.manufacturingMaterial,
    required this.coilResistance,
    required this.armatureType,
    required this.adjustments,
    required this.dimensions,
    required this.contactType,
    required this.conditionState,
    required this.stampsAndMarkings,
    required this.provenance,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'telegraphIdentifier': telegraphIdentifier,
        'sounderType': sounderType.name,
        'specialization': specialization.name,
        'telegraphCompany': telegraphCompany,
        'manufacturer': manufacturer,
        'countryOfManufacture': countryOfManufacture,
        'presumedEra': presumedEra,
        'manufacturingMaterial': manufacturingMaterial.name,
        'coilResistance': coilResistance,
        'armatureType': armatureType.name,
        'adjustments': adjustments,
        'dimensions': dimensions,
        'contactType': contactType,
        'conditionState': conditionState.name,
        'stampsAndMarkings': stampsAndMarkings,
        'provenance': provenance,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory SounderModel.fromJson(Map<String, dynamic> json) => SounderModel(
        id: json['id'] ?? '',
        telegraphIdentifier: json['telegraphIdentifier'] ?? '',
        sounderType: SounderType.values.asNameMap()[json['sounderType']] ?? SounderType.mainSounder,
        specialization: SounderSpecialization.values.asNameMap()[json['specialization']] ?? SounderSpecialization.other,
        telegraphCompany: json['telegraphCompany'] ?? '',
        manufacturer: json['manufacturer'] ?? '',
        countryOfManufacture: json['countryOfManufacture'] ?? '',
        presumedEra: json['presumedEra'] ?? '',
        manufacturingMaterial: ManufacturingMaterial.values.asNameMap()[json['manufacturingMaterial']] ?? ManufacturingMaterial.brass,
        coilResistance: json['coilResistance'] ?? '',
        armatureType: ArmatureType.values.asNameMap()[json['armatureType']] ?? ArmatureType.straight,
        adjustments: json['adjustments'] ?? '',
        dimensions: json['dimensions'] ?? '',
        contactType: json['contactType'] ?? '',
        conditionState: ConditionState.values.asNameMap()[json['conditionState']] ?? ConditionState.unknown,
        stampsAndMarkings: json['stampsAndMarkings'] ?? '',
        provenance: json['provenance'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
