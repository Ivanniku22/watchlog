import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Dio createTmdbDio() {
  final token = dotenv.env['TMDB_ACCESS_TOKEN']?.trim();
  if (token == null || token.isEmpty) {
    throw StateError(
      'TMDB_ACCESS_TOKEN is missing. Check that .env is loaded and listed in pubspec assets.',
    );
  }

  final dio = Dio(
    BaseOptions(
      // Trailing slash is required. Dio uses Uri.resolve, so
      // '.../3' + '/tv/popular' becomes '.../tv/popular'.
      baseUrl: 'https://api.themoviedb.org/3/',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'WatchLog/1.0',
      },
    ),
  );

  dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: _createHttpClient);
  dio.interceptors.add(_TmdbRetryInterceptor(dio));
  return dio;
}

HttpClient _createHttpClient() {
  final client = HttpClient()
    ..userAgent = 'WatchLog/1.0'
    ..connectionTimeout = const Duration(seconds: 20)
    ..idleTimeout = const Duration(seconds: 15)
    ..findProxy = (_) => 'DIRECT';

  // Prefer IPv4, then wrap the socket in TLS. connectionFactory
  // replaces SecureSocket.startConnect, so a plain Socket on 443
  // would send HTTP and get "Connection reset by peer".
  client.connectionFactory = (uri, proxyHost, proxyPort) async {
    if (proxyHost != null && proxyPort != null) {
      return uri.scheme == 'https'
          ? SecureSocket.startConnect(proxyHost, proxyPort)
          : Socket.startConnect(proxyHost, proxyPort);
    }

    final resolved = await InternetAddress.lookup(uri.host);
    final ipv4 = resolved.where((a) => a.type == InternetAddressType.IPv4);
    final target = ipv4.isNotEmpty
        ? ipv4.first
        : (resolved.isNotEmpty ? resolved.first : null);
    if (target == null) {
      throw SocketException('Failed to resolve ${uri.host}');
    }

    if (uri.scheme != 'https') {
      return Socket.startConnect(target, uri.port);
    }

    final tcpTask = await Socket.startConnect(target, uri.port);
    return ConnectionTask.fromSocket(
      tcpTask.socket.then(
        (socket) => SecureSocket.secure(
          socket,
          host: uri.host,
          supportedProtocols: const ['http/1.1'],
        ),
      ),
      tcpTask.cancel,
    );
  };

  return client;
}

class _TmdbRetryInterceptor extends Interceptor {
  _TmdbRetryInterceptor(this._dio);

  final Dio _dio;
  static const _maxAttempts = 3;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = (err.requestOptions.extra['tmdb_attempt'] as int?) ?? 1;
    if (attempt >= _maxAttempts || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
    final options = err.requestOptions;
    options.extra['tmdb_attempt'] = attempt + 1;

    try {
      handler.resolve(await _dio.fetch(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return true;
    }
    final message = e.error?.toString() ?? e.message ?? '';
    return e.type == DioExceptionType.unknown &&
        message.contains('Connection reset by peer');
  }
}
