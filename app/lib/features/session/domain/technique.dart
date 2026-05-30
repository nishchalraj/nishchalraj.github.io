import 'phase.dart';

enum TechniqueCategory { calm, focus, sleep, energy }

class Technique {
  const Technique({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.phases,
    required this.cycles,
    required this.category,
    required this.pattern,
    this.recommendedSound,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final List<Phase> phases;
  final int cycles;
  final TechniqueCategory category;
  final String pattern;
  final String? recommendedSound;

  int get totalSeconds => phases.fold(0, (s, p) => s + p.seconds) * cycles;
}

class TechniqueRegistry {
  TechniqueRegistry._();

  static final List<Technique> all = <Technique>[
    Technique(
      id: 'relax-478',
      name: 'Relax',
      tagline: '4-7-8 breathing',
      description:
          'A calming pattern: inhale for 4, hold for 7, exhale for 8. Activates the parasympathetic system and slows the heart.',
      phases: const [
        Phase(kind: PhaseKind.inhale, seconds: 4),
        Phase(kind: PhaseKind.holdIn, seconds: 7),
        Phase(kind: PhaseKind.exhale, seconds: 8),
        Phase(kind: PhaseKind.holdOut, seconds: 0),
      ],
      cycles: 6,
      category: TechniqueCategory.calm,
      pattern: '4-7-8',
      recommendedSound: 'rain',
    ),
    Technique(
      id: 'box-4444',
      name: 'Box',
      tagline: 'Equal four-part',
      description:
          'Four equal parts. Used by Navy SEALs to stay calm under pressure. Excellent for focus.',
      phases: const [
        Phase(kind: PhaseKind.inhale, seconds: 4),
        Phase(kind: PhaseKind.holdIn, seconds: 4),
        Phase(kind: PhaseKind.exhale, seconds: 4),
        Phase(kind: PhaseKind.holdOut, seconds: 4),
      ],
      cycles: 8,
      category: TechniqueCategory.focus,
      pattern: '4-4-4-4',
      recommendedSound: 'wind',
    ),
    Technique(
      id: 'calm-extended',
      name: 'Calm',
      tagline: 'Extended exhale',
      description:
          'A long, slow exhale that gently downshifts the nervous system. Inhale 4, exhale 8.',
      phases: const [
        Phase(kind: PhaseKind.inhale, seconds: 4),
        Phase(kind: PhaseKind.holdIn, seconds: 0),
        Phase(kind: PhaseKind.exhale, seconds: 8),
        Phase(kind: PhaseKind.holdOut, seconds: 0),
      ],
      cycles: 10,
      category: TechniqueCategory.calm,
      pattern: '4-0-8',
      recommendedSound: 'ocean',
    ),
    Technique(
      id: 'coherent-55',
      name: 'Coherent',
      tagline: '5-5 heart rhythm',
      description:
          'Resonant breathing at 5 in / 5 out maximizes heart-rate variability — a marker of recovery and calm.',
      phases: const [
        Phase(kind: PhaseKind.inhale, seconds: 5),
        Phase(kind: PhaseKind.holdIn, seconds: 0),
        Phase(kind: PhaseKind.exhale, seconds: 5),
        Phase(kind: PhaseKind.holdOut, seconds: 0),
      ],
      cycles: 12,
      category: TechniqueCategory.calm,
      pattern: '5-5',
      recommendedSound: 'forest',
    ),
    Technique(
      id: 'energize',
      name: 'Energize',
      tagline: 'Stimulating breath',
      description:
          'Short, brisk inhale and slightly longer exhale. Wakes the body without overdoing it.',
      phases: const [
        Phase(kind: PhaseKind.inhale, seconds: 2),
        Phase(kind: PhaseKind.holdIn, seconds: 0),
        Phase(kind: PhaseKind.exhale, seconds: 3),
        Phase(kind: PhaseKind.holdOut, seconds: 0),
      ],
      cycles: 20,
      category: TechniqueCategory.energy,
      pattern: '2-3',
      recommendedSound: 'forest',
    ),
    Technique(
      id: 'strengthen',
      name: 'Strengthen',
      tagline: 'Belly breath',
      description:
          'Slow diaphragmatic breathing. Place a hand on your belly and let it rise. Builds breath capacity.',
      phases: const [
        Phase(kind: PhaseKind.inhale, seconds: 6),
        Phase(kind: PhaseKind.holdIn, seconds: 2),
        Phase(kind: PhaseKind.exhale, seconds: 6),
        Phase(kind: PhaseKind.holdOut, seconds: 2),
      ],
      cycles: 8,
      category: TechniqueCategory.focus,
      pattern: '6-2-6-2',
      recommendedSound: 'waves',
    ),
    Technique(
      id: 'wim-hof-light',
      name: 'Wim Hof (light)',
      tagline: 'Power breath',
      description:
          'A gentle take on the Wim Hof method — fast deep breaths followed by a relaxed exhale. Beginner-safe.',
      phases: const [
        Phase(kind: PhaseKind.inhale, seconds: 2),
        Phase(kind: PhaseKind.holdIn, seconds: 0),
        Phase(kind: PhaseKind.exhale, seconds: 2),
        Phase(kind: PhaseKind.holdOut, seconds: 0),
      ],
      cycles: 30,
      category: TechniqueCategory.energy,
      pattern: '2-2',
      recommendedSound: 'wind',
    ),
  ];

  static Technique? byId(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  static Technique custom({
    required int inhale,
    required int holdIn,
    required int exhale,
    required int holdOut,
    required int cycles,
  }) =>
      Technique(
        id: 'custom',
        name: 'Custom',
        tagline: '$inhale-$holdIn-$exhale-$holdOut',
        description: 'Your custom pattern.',
        phases: [
          Phase(kind: PhaseKind.inhale, seconds: inhale),
          Phase(kind: PhaseKind.holdIn, seconds: holdIn),
          Phase(kind: PhaseKind.exhale, seconds: exhale),
          Phase(kind: PhaseKind.holdOut, seconds: holdOut),
        ],
        cycles: cycles,
        category: TechniqueCategory.focus,
        pattern: '$inhale-$holdIn-$exhale-$holdOut',
      );
}
