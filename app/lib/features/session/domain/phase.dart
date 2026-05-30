enum PhaseKind { inhale, holdIn, exhale, holdOut }

extension PhaseKindX on PhaseKind {
  bool get isHold     => this == PhaseKind.holdIn || this == PhaseKind.holdOut;
  bool get isExpanding => this == PhaseKind.inhale || this == PhaseKind.holdIn;
  bool get isContracting => this == PhaseKind.exhale || this == PhaseKind.holdOut;

  String get label {
    switch (this) {
      case PhaseKind.inhale:  return 'Inhale';
      case PhaseKind.exhale:  return 'Exhale';
      case PhaseKind.holdIn:
      case PhaseKind.holdOut: return 'Hold';
    }
  }
}

class Phase {
  const Phase({required this.kind, required this.seconds});
  final PhaseKind kind;
  final int seconds;
}
