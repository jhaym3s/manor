/// Formats [time] relative to now as short strings like "10 mins ago",
/// "1h ago", "3d ago" — matching the style previously hardcoded into
/// screens that showed mock data.
String formatRelativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) {
    final mins = diff.inMinutes;
    return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
  }
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}
