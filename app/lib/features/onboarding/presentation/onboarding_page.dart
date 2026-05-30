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
    await NotificationService.instance.requestPermissions();
    await NotificationService.instance.scheduleDaily(_time.hour, _time.minute);
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(step: _step),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Expanded(child: _stepBody())],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _Welcome(onNext: () => setState(() => _step = 1));
      case 1:
        return _NameStep(
          controller: _nameCtrl,
          onBack: () => setState(() => _step = 0),
          onNext: () => setState(() => _step = 2),
        );
      case 2:
        return _GoalStep(
          value: _goal,
          onChange: (g) => setState(() => _goal = g),
          onBack: () => setState(() => _step = 1),
          onNext: () => setState(() => _step = 3),
        );
      case 3:
        return _ReminderStep(
          time: _time,
          onChange: (t) => setState(() => _time = t),
          onBack: () => setState(() => _step = 2),
          onFinish: _finish,
        );
      default:
        return const SizedBox.shrink();
    }
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
        const Text('niyam',
            style: TextStyle(fontFamily: 'Fraunces', fontSize: 24, fontWeight: FontWeight.w500)),
        const Spacer(),
        ...List.generate(4, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(left: 4),
            height: 4,
            width: i <= step ? 24 : 12,
            decoration: BoxDecoration(
              color: i <= step ? cs.primary : cs.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ],
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onNext});
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        const Text('Welcome.',
            style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 44,
                fontWeight: FontWeight.w500,
                letterSpacing: -1)),
        const SizedBox(height: 14),
        Text(
          'A quiet place to build a breathing routine. Three quick questions and we\'re in.',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
              fontSize: 15),
        ),
        const SizedBox(height: 32),
        FilledButton(onPressed: onNext, child: const Text('Begin')),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({
    required this.controller,
    required this.onBack,
    required this.onNext,
  });
  final TextEditingController controller;
  final VoidCallback onBack;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        const Text('What should we call you?',
            style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 30,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.6)),
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'Your name',
            border: UnderlineInputBorder(),
          ),
          style: const TextStyle(fontFamily: 'Fraunces', fontSize: 22),
          onSubmitted: (_) => onNext(),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            TextButton(onPressed: onBack, child: const Text('Back')),
            const SizedBox(width: 8),
            FilledButton(onPressed: onNext, child: const Text('Continue')),
          ],
        ),
      ],
    );
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({
    required this.value,
    required this.onChange,
    required this.onBack,
    required this.onNext,
  });
  final Goal value;
  final ValueChanged<Goal> onChange;
  final VoidCallback onBack;
  final VoidCallback onNext;

  static const _options = [
    (Goal.calm, 'Find calm', '🌿', 'Lower anxiety and slow the day down.'),
    (Goal.sleep, 'Sleep better', '🌙', 'A wind-down before bed.'),
    (Goal.focus, 'Sharpen focus', '🎯', 'Steady the mind before deep work.'),
    (Goal.energy, 'Energize', '⚡', 'Wake up without overdoing it.'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text('What brings you here?',
            style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 30,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.6)),
        const SizedBox(height: 6),
        Text('You can change this anytime.',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (_, i) {
            final opt = _options[i];
            final selected = opt.$1 == value;
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onChange(opt.$1),
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
                  children: [
                    Text(opt.$3, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(opt.$2, style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        opt.$4,
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
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            TextButton(onPressed: onBack, child: const Text('Back')),
            const SizedBox(width: 8),
            FilledButton(onPressed: onNext, child: const Text('Continue')),
          ],
        ),
      ],
    );
  }
}

class _ReminderStep extends StatelessWidget {
  const _ReminderStep({
    required this.time,
    required this.onChange,
    required this.onBack,
    required this.onFinish,
  });
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChange;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        const Text('When should we whisper?',
            style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 30,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.6)),
        const SizedBox(height: 6),
        Text('A gentle daily reminder. Pick a quiet moment.',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
        const SizedBox(height: 24),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: time);
            if (picked != null) onChange(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: cs.onSurface.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              time.format(context),
              style: const TextStyle(
                  fontFamily: 'Fraunces', fontSize: 28, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            TextButton(onPressed: onBack, child: const Text('Back')),
            const SizedBox(width: 8),
            FilledButton(onPressed: onFinish, child: const Text('Open niyam')),
          ],
        ),
      ],
    );
  }
}
