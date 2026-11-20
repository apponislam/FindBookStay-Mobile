import '../config/env_config.dart';

/// Central URL & Media Link Utility for FindBookStay.
///
/// Converts relative file and image paths returned by FindBookStay-Backend
/// (e.g. `/uploads/profile/profile-1795109555374-157292906.webp`) into fully
/// qualified absolute URLs (e.g. `https://findbookstayapi.apponislam.top/uploads/profile/profile-1795109555374-157292906.webp`),
/// while preserving full URLs (HTTP/HTTPS), Base64 data URIs, and local file references.
class UrlUtils {
  UrlUtils._();

  /// The root server origin (e.g. 'https://findbookstayapi.apponislam.top').
  static String get serverBaseUrl => EnvConfig.serverOrigin;

  /// Resolves an image or file path to an absolute, network-loadable URL.
  ///
  /// Examples:
  /// - `'/uploads/profile/pic.webp'` -> `'https://findbookstayapi.apponislam.top/uploads/profile/pic.webp'`
  /// - `'uploads/profile/pic.webp'`  -> `'https://findbookstayapi.apponislam.top/uploads/profile/pic.webp'`
  /// - `'https://cdn.example.com/img.jpg'` -> `'https://cdn.example.com/img.jpg'`
  /// - `'data:image/png;base64,...'` -> `'data:image/png;base64,...'`
  /// - `null` or `''` -> `''`
  static String resolveUrl(String? pathOrUrl) {
    if (pathOrUrl == null) return '';
    final trimmed = pathOrUrl.trim();
    if (trimmed.isEmpty) return '';

    final lower = trimmed.toLowerCase();
    // Return early if already an absolute URL or data/blob/file URI
    if (lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('data:') ||
        lower.startsWith('blob:') ||
        lower.startsWith('file:')) {
      return trimmed;
    }

    // Normalize any backslashes from file paths to web slashes
    var cleanPath = trimmed.replaceAll(r'\', '/');

    // Ensure single leading slash for the relative path
    if (!cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }

    final origin = serverBaseUrl;
    return '$origin$cleanPath';
  }

  /// Resolves an image or file path to an absolute URL, returning `null` if the input is null or blank.
  static String? resolveNullableUrl(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) return null;
    return resolveUrl(pathOrUrl);
  }

  /// Resolves a list of paths/URLs into absolute URLs, filtering out empty entries.
  static List<String> resolveUrlList(List<dynamic>? paths) {
    if (paths == null || paths.isEmpty) return const [];
    return paths
        .map((p) => resolveUrl(p?.toString()))
        .where((u) => u.isNotEmpty)
        .toList();
  }

  /// Checks if a string is a network URL (HTTP/HTTPS).
  static bool isNetworkUrl(String? url) {
    if (url == null) return false;
    final lower = url.trim().toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  /// Checks if a string is a relative server path (e.g. starts with `/uploads/`).
  static bool isRelativePath(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final lower = url.trim().toLowerCase();
    return !lower.startsWith('http://') &&
        !lower.startsWith('https://') &&
        !lower.startsWith('data:') &&
        !lower.startsWith('blob:') &&
        !lower.startsWith('file:');
  }
}
