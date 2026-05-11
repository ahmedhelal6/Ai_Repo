import 'dart:async';
import 'dart:convert';

import 'package:ai_fitness_coach/core/errors/error_handler.dart';
import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  late final Dio dio;
  late final Dio _authDio;

  static const String _baseUrl = 'http://aifitnesscoach.tryasp.net';

  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';

  static const String _skipAuthKey = 'skipAuth';
  static const String _alreadyRetriedKey = 'alreadyRetried';

  static Future<Map<String, dynamic>>? _runningRefresh;

  AuthService() {
    dio = Dio(_baseOptions());
    _authDio = Dio(_baseOptions());

    _setupInterceptor();
  }

  BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      validateStatus: (status) {
        return status != null && status >= 200 && status < 300;
      },
    );
  }

  void _setupInterceptor() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
  if (options.extra[_skipAuthKey] == true) {
    return handler.next(options);
  }

  final token = await getAccessToken();

  if (token != null && token.trim().isNotEmpty) {
    options.headers['Authorization'] = 'Bearer ${token.trim()}';
  }

  return handler.next(options);
},
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;

          final shouldRefresh = statusCode == 401 &&
              error.requestOptions.extra[_skipAuthKey] != true &&
              error.requestOptions.extra[_alreadyRetriedKey] != true;

          if (!shouldRefresh) {
            return handler.next(error);
          }

          try {
            await refreshAccessToken();

            final retryResponse = await _retry(error.requestOptions);
            return handler.resolve(retryResponse);
          } catch (e) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                type: DioExceptionType.badResponse,
                error: e,
              ),
            );
          }
        },
      ),
    );
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await getAccessToken();

    final headers = Map<String, dynamic>.from(requestOptions.headers);

    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    final extra = Map<String, dynamic>.from(requestOptions.extra);
    extra[_alreadyRetriedKey] = true;

    return dio.fetch<dynamic>(
      requestOptions.copyWith(
        headers: headers,
        extra: extra,
      ),
    );
  }

  // ====================== Helpers ======================

  Map<String, dynamic> _asMap(dynamic data) {
    if (data == null) return {};

    if (data is Map<String, dynamic>) return data;

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);

        if (decoded is Map<String, dynamic>) return decoded;

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return {};
      }
    }

    return {};
  }

  Map<String, dynamic> _tokenSource(Map<String, dynamic> data) {
    final possibleContainers = [
      data['data'],
      data['result'],
      data['value'],
      data['tokens'],
      data['auth'],
      data['user'],
    ];

    for (final item in possibleContainers) {
      final mapped = _asMap(item);
      if (mapped.isNotEmpty) return mapped;
    }

    return data;
  }

  String? _readToken(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return null;
  }

  String? _getAccessTokenFromData(Map<String, dynamic> data) {
    final source = _tokenSource(data);

    return _readToken(source, [
          'Token',
          'token',
          'AccessToken',
          'accessToken',
          'access_token',
          'Jwt',
          'jwt',
        ]) ??
        _readToken(data, [
          'Token',
          'token',
          'AccessToken',
          'accessToken',
          'access_token',
          'Jwt',
          'jwt',
        ]);
  }

  String? _getRefreshTokenFromData(Map<String, dynamic> data) {
    final source = _tokenSource(data);

    return _readToken(source, [
          'RefreshToken',
          'refreshToken',
          'refresh_token',
        ]) ??
        _readToken(data, [
          'RefreshToken',
          'refreshToken',
          'refresh_token',
        ]);
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final accessToken = _getAccessTokenFromData(data);
    final refreshToken = _getRefreshTokenFromData(data);

    final prefs = await SharedPreferences.getInstance();

    if (accessToken != null && accessToken.isNotEmpty) {
      await prefs.setString(_accessTokenKey, accessToken);
    }

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  Future<void> _clearOnlyTokens() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // ====================== Token Methods ======================

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.trim().isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);

    await prefs.remove('user');
    await prefs.remove('currentUser');
    await prefs.remove('userData');
  }

  // ====================== Refresh Token ======================

  Future<Map<String, dynamic>> refreshAccessToken() {
    final currentRefresh = _runningRefresh;

    if (currentRefresh != null) {
      return currentRefresh;
    }

    final refreshFuture = _refreshAccessTokenNow();
    _runningRefresh = refreshFuture;

    return refreshFuture.whenComplete(() {
      _runningRefresh = null;
    });
  }

  Future<Map<String, dynamic>> _refreshAccessTokenNow() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    if (accessToken == null ||
        accessToken.trim().isEmpty ||
        refreshToken == null ||
        refreshToken.trim().isEmpty) {
      await logout();
      throw Failure('Session expired. Please login again.');
    }

    try {
      final response = await _authDio.post<dynamic>(
        '/api/Auth/refresh',
        data: {
          'accessToken': accessToken.trim(),
          'refreshToken': refreshToken.trim(),
        },
        options: Options(
          extra: const {
            _skipAuthKey: true,
          },
        ),
      );

      final data = _asMap(response.data);

      final newAccessToken = _getAccessTokenFromData(data);
      final newRefreshToken = _getRefreshTokenFromData(data);

      if (newAccessToken == null ||
          newAccessToken.isEmpty ||
          newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        await logout();
        throw Failure('Session expired. Please login again.');
      }

      await _saveTokens(data);

      return data;
    } on DioException catch (error) {
      final status = error.response?.statusCode;

      if (status == 400 || status == 401 || status == 403) {
        await logout();
        throw Failure('Session expired. Please login again.');
      }

      throw Failure('Could not refresh session. Please check your connection.');
    } catch (_) {
      throw Failure('Could not refresh session. Please try again.');
    }
  }

  // ====================== Auth Methods ======================

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String goal,
    required int height,
    required int weight,
    required int age,
    required String gender,
  }) async {
    try {
      await _clearOnlyTokens();

      final response = await _authDio.post<dynamic>(
        '/api/Auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'username': username.trim(),
          'goal': goal,
          'height': height,
          'weight': weight,
          'age': age,
          'gender': gender,
        },
        options: Options(
          extra: const {
            _skipAuthKey: true,
          },
        ),
      );

      final data = _asMap(response.data);
      await _saveTokens(data);

      return data;
    } catch (error) {
      throw ErrorHandler.handle(error, fallback: 'Register failed');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      await _clearOnlyTokens();

      final response = await _authDio.post<dynamic>(
        '/api/Auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
        options: Options(
          extra: const {
            _skipAuthKey: true,
          },
        ),
      );

      final data = _asMap(response.data);
      await _saveTokens(data);

      final savedAccess = await getAccessToken();
      final savedRefresh = await getRefreshToken();

      if (savedAccess == null ||
          savedAccess.trim().isEmpty ||
          savedRefresh == null ||
          savedRefresh.trim().isEmpty) {
        throw Failure('Login response did not contain valid tokens');
      }

      return data;
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Login failed. Check your email and password.',
      );
    }
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _authDio.post<dynamic>(
        '/api/Auth/verify-email',
        data: {
          'email': email.trim(),
          'code': code.trim(),
        },
        options: Options(
          extra: const {
            _skipAuthKey: true,
          },
        ),
      );

      final data = _asMap(response.data);
      await _saveTokens(data);

      return data;
    } catch (error) {
      throw ErrorHandler.handle(error, fallback: 'Email verification failed');
    }
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _authDio.post<dynamic>(
        '/api/Auth/forgot-password',
        data: {
          'email': email.trim(),
        },
        options: Options(
          extra: const {
            _skipAuthKey: true,
          },
        ),
      );

      return _asMap(response.data);
    } catch (error) {
      throw ErrorHandler.handle(error, fallback: 'Forgot password failed');
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _authDio.post<dynamic>(
        '/api/Auth/reset-password',
        data: {
          'email': email.trim(),
          'otp': otp.trim(),
          'newPassword': newPassword,
        },
        options: Options(
          extra: const {
            _skipAuthKey: true,
          },
        ),
      );

      return _asMap(response.data);
    } catch (error) {
      throw ErrorHandler.handle(error, fallback: 'Reset password failed');
    }
  }

  Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    try {
      final response = await _authDio.post<dynamic>(
        '/api/Auth/resend-otp',
        data: {
          'email': email.trim(),
        },
        options: Options(
          extra: const {
            _skipAuthKey: true,
          },
        ),
      );

      return _asMap(response.data);
    } catch (error) {
      throw ErrorHandler.handle(error, fallback: 'Resend OTP failed');
    }
  }
}