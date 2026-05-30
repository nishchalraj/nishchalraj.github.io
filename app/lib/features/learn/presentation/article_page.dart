import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/articles.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key, required this.slug});
  final String slug;
  @override
  Widget build(BuildContext context) {
    final a = ArticleCatalog.bySlug(slug);
    if (a == null) return const Scaffold(body: Center(child: Text('Not found.')));
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/learn')),
        title: const Text('Learn'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${a.readMin} MIN READ',
                style: TextStyle(fontSize: 11, letterSpacing: 1.4, color: cs.primary)),
            const SizedBox(height: 6),
            Text(a.title,
                style: const TextStyle(fontFamily: 'Fraunces', fontSize: 36, fontWeight: FontWeight.w500, letterSpacing: -0.8, height: 1.05)),
            const SizedBox(height: 8),
            Text(a.excerpt,
                style: TextStyle(fontSize: 16, color: cs.onSurface.withValues(alpha: 0.7), height: 1.4)),
            const SizedBox(height: 24),
            Text(a.body, style: const TextStyle(fontSize: 15, height: 1.55)),
          ],
        ),
      ),
    );
  }
}
