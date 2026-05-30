import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/notifications/notification_service.dart';
import '../../profile/data/prefs.dart';
import '../../profile/data/prefs_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});
  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  Goal _goal = Goal.calm;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final p = ref.read(prefsProvider.notifier);
    await p.setName(_nameCtrl.text.trim().isEmpty ? 'friend' : _nameCtrl.text.trim());
    await p.setGoal(_goal);
    await p.setReminderMinutes(_time.hour * 60 + _time.minute);
    // Notifications are best-effort — a denied permission or platform quirk
    // must NEVER block onboarding.
    try {
      await NotificationService.instance.requestPermissions();
      await NotificationService.instance.scheduleDaily(_time.hour, _time.minute);
    } catch (_) {/* swallowed; scheduleDaily already logs in debug */}
    await p.completeOnboarding();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [cs.primary.withValues(alpha: 0.2), cs.surface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _Header(step: _step),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  children: _stepChildren(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _stepChildren() {
    switch (_step) {
      case 0:
        return _welcomeChildren();
      case 1:
        return _nameChildren();
      case 2:
        return _goalChildren();
      case 3:
        return _reminderChildren();
      default:
        return const [SizedBox.shrink()];
    }
  }

  List<Widget> _welcomeChildren() {
    final cs = Theme.of(context).colorScheme;
    return [
      const SizedBox(height: 40),
      const Text(
        'Welcome.',
        style: TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 44,
          fontWeight: FontWeight.w500,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        "A quiet place to build a breathing routine. Three quick questions and we're in.",
        style: TextStyle(
          color: cs.onSurface.withValues(alpha: 0.7),
          height: 1.5,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 32),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton(
          onPressed: () => setState(() => _step = 1),
          child: const Text('Begin'),
        ),
      ),
    ];
  }

  List<Widget> _nameChildren() {
    return [
      const SizedBox(height: 40),
      const Text(
        'What should we call you?',
        style: TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 30,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.6,
        ),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _nameCtrl,
        autofocus: true,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: 'Your name',
          border: UnderlineInputBorder(),
        ),
        style: const TextStyle(fontFamily: 'Fraunces', fontSize: 22),
        onSubmitted: (_) => setState(() => _step = 2),
      ),
      const SizedBox(height: 32),
      Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => setState(() => _step = 0),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: () => setState(() => _step = 2),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _goalChildren() {
    final cs = Theme.of(context).colorScheme;
    const options = [
      (Goal.calm, 'Find calm', '🌿', 'Lower anxiety and slow the day down.'),
      (Goal.sleep, 'Sleep better', '🌙', 'A wind-down before bed.'),
      (Goal.focus, 'Sharpen focus', '🎯', 'Steady the mind before deep work.'),
      (Goal.energy, 'Energize', '⚡', 'Wake up without overdoing it.'),
    ];
    return [
      const SizedBox(height: 24),
      const Text(
        'What brings you here?',
        style: TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 30,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.6,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'You can change this anytime.',
        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
      ),
      const SizedBox(height: 20),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: [
          for (final opt in options)
            _GoalTile(
              selected: _goal == opt.$1,
              emoji: opt.$3,
              title: opt.$2,
              description: opt.$4,
              onTap: () => setState(() => _goal = opt.$1),
            ),
        ],
      ),
      const SizedBox(height: 24),
      Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => setState(() => _step = 1),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: () => setState(() => _step = 3),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _reminderChildren() {
    final cs = Theme.of(context).colorScheme;
    return [
      const SizedBox(height: 40),
      const Text(
        'When should we whisper?',
        style: TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 30,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.6,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'A gentle daily reminder. Pick a quiet moment.',
        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
      ),
      const SizedBox(height: 24),
      Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: _time);
            if (picked != null && mounted) setState(() => _time = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: cs.onSurface.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _time.format(context),
              style: const TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 32),
      Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => setState(() => _step = 2),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: _finish,
              child: const Text('Open niyam'),
            ),
          ],
        ),
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        const Text(
          'niyam',
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        for (var i = 0; i < 4; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(left: 4),
            height: 4,
            width: i <= step ? 24 : 12,
            decoration: BoxDecoration(
              color: i <= step ? cs.primary : cs.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.selected,
    required this.emoji,
    required this.title,
    required this.description,
    required this.onTap,
  });
  final bool selected;
  final String emoji;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.18)
              : cs.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? cs.primary : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
