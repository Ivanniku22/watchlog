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
      // Trailing slash matters: Dio uses Uri.resolve, so
      // 'https://api.themoviedb.org/3' + '/tv/popular'
      // becomes 'https://api.themoviedb.org/tv/popular'.
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

  // Some Indian ISPs reset TMDB connections over IPv6 / TLS.
  // Prefer IPv4 and complete the TLS handshake ourselves.
  // HttpClient.connectionFactory replaces SecureSocket.startConnect,
  // so a plain Socket here would send HTTP on port 443 and get RST.
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient()
        ..userAgent = 'WatchLog/1.0'
        ..connectionTimeout = const Duration(seconds: 20)
        ..idleTimeout = const Duration(seconds: 15)
        ..findProxy = (_) => 'DIRECT';

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
    },
  );

  return dio;
}

class TmdbService {
  final Dio dio;

  TmdbService(this.dio);

  Future<Response> getPopularTvShows() async {
    DioException? lastError;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await dio.get('tv/popular');
      } on DioException catch (e) {
        lastError = e;
        if (!_shouldRetry(e) || attempt == 2) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }

    throw lastError!;
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
