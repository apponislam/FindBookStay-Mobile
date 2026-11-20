import 'package:flutter/widgets.dart';

import 'url_utils.dart';

/// Image utility helper for FindBookStay.
///
/// Wraps [UrlUtils] and provides [ImageProvider] resolution for avatars and listing media.
class ImageUtils {
  ImageUtils._();

  /// Resolves an image or file path to an absolute URL string.
  static String resolve(String? pathOrUrl) => UrlUtils.resolveUrl(pathOrUrl);

  /// Resolves an image or file path to an absolute URL, or returns null if empty.
  static String? resolveNullable(String? pathOrUrl) =>
      UrlUtils.resolveNullableUrl(pathOrUrl);

  /// Resolves a list of image paths to complete URL strings.
  static List<String> resolveList(List<dynamic>? paths) =>
      UrlUtils.resolveUrlList(paths);

  /// Returns a [NetworkImage] if the path/URL resolves to a valid URL, or null if empty.
  static NetworkImage? getNetworkImage(String? pathOrUrl) {
    final resolved = resolveNullable(pathOrUrl);
    if (resolved == null || resolved.isEmpty) return null;
    return NetworkImage(resolved);
  }

  /// Returns an [ImageProvider] for the given path/url or a provided [fallback].
  static ImageProvider? getImageProvider(
    String? pathOrUrl, {
    ImageProvider? fallback,
  }) {
    final netImage = getNetworkImage(pathOrUrl);
    return netImage ?? fallback;
  }
}
