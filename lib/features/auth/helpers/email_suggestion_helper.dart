// ─────────────────────────────────────────────────────────────────────────────
// EmailSuggestionHelper — Domain typo detection service
//
// Detects common email domain typos (e.g. gmail.con -> gmail.com) while avoiding
// false positives on custom or valid domain names.
// ─────────────────────────────────────────────────────────────────────────────

class EmailSuggestionHelper {
  EmailSuggestionHelper._();

  static const List<String> supportedDomains = [
    'gmail.com',
    'yahoo.com',
    'outlook.com',
    'hotmail.com',
    'icloud.com',
    'edu.ph',
  ];

  static const Map<String, String> _explicitTypos = {
    'gmail.con': 'gmail.com',
    'gmail.co': 'gmail.com',
    'gmaill.com': 'gmail.com',
    'gamil.com': 'gmail.com',
    'gmai.com': 'gmail.com',
    'yahho.com': 'yahoo.com',
    'yaho.com': 'yahoo.com',
    'yahoo.co': 'yahoo.com',
    'yahoo.con': 'yahoo.com',
    'outlok.com': 'outlook.com',
    'outlook.co': 'outlook.com',
    'outlook.con': 'outlook.com',
    'hotmial.com': 'hotmail.com',
    'hotmail.co': 'hotmail.com',
    'hotmail.con': 'hotmail.com',
    'icloud.co': 'icloud.com',
    'icloud.con': 'icloud.com',
    'edu.p': 'edu.ph',
    'edu.phh': 'edu.ph',
  };

  /// Returns suggested email String (e.g. "mark@gmail.com") or null if no typo / email is valid / unknown domain.
  static String? getSuggestion(String input) {
    final trimmed = input.trim();
    final atIndex = trimmed.lastIndexOf('@');
    if (atIndex <= 0 || atIndex == trimmed.length - 1) return null;

    final username = trimmed.substring(0, atIndex);
    final domain = trimmed.substring(atIndex + 1).toLowerCase();

    // Check valid username format
    if (!RegExp(r'^[\w.+\-]+$').hasMatch(username)) return null;

    // If domain is already one of the valid supported domains, no suggestion needed
    if (supportedDomains.contains(domain)) return null;

    // Check explicit typo map first
    if (_explicitTypos.containsKey(domain)) {
      return '$username@${_explicitTypos[domain]}';
    }

    // Levenshtein distance check
    String? bestMatch;
    int minDistance = 999;

    for (final target in supportedDomains) {
      final dist = _levenshtein(domain, target);
      // Max allowed edit distance: 1 for short domains (edu.ph), 2 for longer ones
      final maxAllowed = target.length <= 6 ? 1 : 2;
      if (dist > 0 && dist <= maxAllowed && dist < minDistance) {
        minDistance = dist;
        bestMatch = target;
      }
    }

    if (bestMatch != null) {
      return '$username@$bestMatch';
    }

    return null;
  }

  static int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final v0 = List<int>.generate(t.length + 1, (i) => i);
    final v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }
}
