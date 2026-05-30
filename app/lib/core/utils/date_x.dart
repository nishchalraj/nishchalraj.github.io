String dayKeyOf(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '$y-$m-$dd';
}

String todayKey() => dayKeyOf(DateTime.now());

String addDays(String key, int n) {
  final parts = key.split('-').map(int.parse).toList();
  final dt = DateTime(parts[0], parts[1], parts[2]).add(Duration(days: n));
  return dayKeyOf(dt);
}

String greetingFor([DateTime? now]) {
  final d = now ?? DateTime.now();
  final h = d.hour;
  if (h < 5) return 'Late night';
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  if (h < 21) return 'Good evening';
  return 'Good night';
}
