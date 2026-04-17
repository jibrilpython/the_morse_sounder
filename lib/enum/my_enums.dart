// ─── SOUNDER TYPE ─────────────────────────────────────────────────────────────
enum SounderType {
  mainSounder('Main Sounder'),
  relaySounder('Relay Sounder'),
  towerSounder('Tower Sounder'),
  portableSounder('Portable Sounder'),
  galvanometricReceiver('Galvanometric Receiver');

  const SounderType(this.label);
  final String label;
}

// ─── SOUNDER SPECIALIZATION ───────────────────────────────────────────────────
enum SounderSpecialization {
  lineMessageReception('Line Message Reception'),
  signalRetransmission('Signal Retransmission'),
  stationAlerting('Station Alerting'),
  operatorTraining('Operator Training'),
  fieldCommunication('Field Communication'),
  other('Other');

  const SounderSpecialization(this.label);
  final String label;
}

// ─── MANUFACTURING MATERIAL ───────────────────────────────────────────────────
enum ManufacturingMaterial {
  brass('Brass'),
  castIron('Cast Iron'),
  steel('Steel'),
  copper('Copper'),
  ebony('Ebony'),
  wood('Wood'),
  mixed('Mixed');

  const ManufacturingMaterial(this.label);
  final String label;
}

// ─── ARMATURE TYPE ────────────────────────────────────────────────────────────
enum ArmatureType {
  straight('Straight'),
  lShaped('L-Shaped'),
  doubleLever('Double Lever'),
  balanced('Balanced');

  const ArmatureType(this.label);
  final String label;
}

// ─── CONDITION STATE ─────────────────────────────────────────────────────────
enum ConditionState {
  pristine('Pristine — Museum Quality'),
  functional('Functional — Operable'),
  corroded('Corroded — Surface Decay'),
  coilDamaged('Coil Damaged — Winding Fault'),
  incomplete('Incomplete — Parts Missing'),
  unknown('Unknown');

  const ConditionState(this.label);
  final String label;
}
