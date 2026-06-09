import 'dart:async';

import 'package:app_links/app_links.dart';

class DeepLinkService {
  DeepLinkService({required this.resolver, AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  final String? Function(Uri uri) resolver;

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;
  final _controller = StreamController<String>.broadcast();

  Stream<String> get locations => _controller.stream;

  Future<String?> initialLocation() async {
    final uri = await _appLinks.getInitialLink();
    return uri == null ? null : resolver(uri);
  }

  void start() => _sub ??= _appLinks.uriLinkStream.listen((uri) {
    final loc = resolver(uri);
    if (loc != null) _controller.add(loc);
  });

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}
