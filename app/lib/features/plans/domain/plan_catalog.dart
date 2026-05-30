class PlanDay {
  const PlanDay({required this.techniqueId, required this.cycles});
  final String techniqueId;
  final int cycles;
}

class PlanDef {
  const PlanDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.days,
  });
  final String id;
  final String title;
  final String subtitle;
  final List<PlanDay> days;
}

class PlanCatalog {
  PlanCatalog._();

  static final List<PlanDef> all = [
    PlanDef(
      id: 'morning-calm',
      title: 'Morning Calm',
      subtitle: '7 days · Start the day quiet',
      days: const [
        PlanDay(techniqueId: 'coherent-55',   cycles: 8),
        PlanDay(techniqueId: 'box-4444',      cycles: 8),
        PlanDay(techniqueId: 'relax-478',     cycles: 5),
        PlanDay(techniqueId: 'coherent-55',   cycles: 10),
        PlanDay(techniqueId: 'calm-extended', cycles: 8),
        PlanDay(techniqueId: 'box-4444',      cycles: 10),
        PlanDay(techniqueId: 'coherent-55',   cycles: 12),
      ],
    ),
    PlanDef(
      id: 'cloud-breath',
      title: 'Breathe with the Clouds',
      subtitle: '5 days · Soft afternoon reset',
      days: const [
        PlanDay(techniqueId: 'calm-extended', cycles: 6),
        PlanDay(techniqueId: 'box-4444',      cycles: 6),
        PlanDay(techniqueId: 'coherent-55',   cycles: 8),
        PlanDay(techniqueId: 'relax-478',     cycles: 4),
        PlanDay(techniqueId: 'calm-extended', cycles: 8),
      ],
    ),
    PlanDef(
      id: 'deep-recovery',
      title: 'Deep Recovery',
      subtitle: '10 days · For the worn-out evenings',
      days: List<PlanDay>.generate(10, (i) =>
        PlanDay(techniqueId: i.isEven ? 'relax-478' : 'calm-extended', cycles: 5 + i),
      ),
    ),
    PlanDef(
      id: 'monthly-stress',
      title: 'Monthly Stress Reflection',
      subtitle: '28 days · A small daily practice',
      days: List<PlanDay>.generate(28, (i) {
        const techniques = ['coherent-55','box-4444','calm-extended','relax-478'];
        return PlanDay(techniqueId: techniques[i % 4], cycles: 6 + (i % 6));
      }),
    ),
  ];

  static PlanDef? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
