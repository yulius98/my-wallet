class StringUtils {
  /// Capitalize the first letter of each word in a string
  static String capitalizeEachWord(String text) {
    if (text.isEmpty) return text;
    
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Format email for display
  static String formatEmail(String? email) {
    return email ?? '-';
  }

  /// Get user display name or fallback
  static String getDisplayName(String? displayName) {
    return capitalizeEachWord(displayName ?? 'User');
  }
}
