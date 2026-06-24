class AuthSession {
  static Future<void> Function()? onUnauthorized;

  static Future<void> handleUnauthorized() async {
    if (onUnauthorized != null) {
      await onUnauthorized!();
    }
  }
}
