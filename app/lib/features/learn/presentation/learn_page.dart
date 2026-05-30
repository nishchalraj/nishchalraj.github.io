import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../data/articles.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverAppBar(title: const Text('Learn'), floating: true, backgroundColor: Colors.transparent),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                if (i == 0) return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('Short notes on why these patterns work.',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
                );
                final a = ArticleCatalog.all[i - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => context.go('/learn/${a.slug}'),
                    borderRadius: BorderRadius.circular(20),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${a.readMin} MIN READ',
                                style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: cs.primary)),
                            const SizedBox(height: 4),
                            Text(a.title,
                                style: const TextStyle(fontFamily: 'Fraunces', fontSize: 19, fontWeight: FontWeight.w500, letterSpacing: -0.3)),
                            const SizedBox(height: 4),
                            Text(a.excerpt, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.7))),
                          ],
                        ),
                      ),
                    ),
                  ).animate(delay: (i * 60).ms).fadeIn(),
                );
              },
              childCount: ArticleCatalog.all.length + 1,
            ),
          ),
        ),
      ],
    );
  }
}
