import 'package:dio/dio.dart';
import '../security/token_manager.dart';
import '../utils/logger.dart';

/// API Interceptor for handling authentication and errors
class ApiInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  ApiInterceptor(this._tokenManager);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add access token to headers
    final accessToken = await _tokenManager.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    AppLogger.info('Request: ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    AppLogger.info('Response: ${response.statusCode} ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    AppLogger.error(
      'Error: ${err.response?.statusCode} ${err.requestOptions.path}',
      err,
    );

    // Handle 401 Unauthorized - Try to refresh token
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await _tokenManager.getRefreshToken();
        if (refreshToken != null) {
          // TODO: Implement token refresh logic
          // final newAccessToken = await refreshAccessToken(refreshToken);
          // await _tokenManager.saveAccessToken(newAccessToken);
          
          // Retry the original request
          // final options = err.requestOptions;
          // options.headers['Authorization'] = 'Bearer $newAccessToken';
          // final response = await Dio().fetch(options);
          // return handler.resolve(response);
        }
      } catch (e) {
        // Refresh token failed, logout user
        await _tokenManager.clearTokens();
      }
    }

    super.onError(err, handler);
  }
}
