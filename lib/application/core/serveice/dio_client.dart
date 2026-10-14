import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/application/core/serveice/local_db_serveice.dart';
import 'package:flutter_application_1/application/core/utils/extentions.dart';
import 'package:flutter_application_1/application/core/utils/logger.dart';
import 'package:flutter_application_1/application/core/utils/urls.dart';
import 'package:flutter_application_1/domain/core/exception/custom_exception.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@lazySingleton
class DioClient {
  final Dio dio;
  final LocalDbService localDbService;

  DioClient(this.dio, this.localDbService) {
    dio
      ..options.baseUrl = Urls.apiVersionUrl
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.sendTimeout = const Duration(seconds: 30);

    dio.interceptors.clear();

    // 1. Connectivity Check Interceptor (fails fast if offline)
    dio.interceptors.add(ConnectivityInterceptor());

    // 2. Auth & Request Metadata Interceptor
    dio.interceptors.add(AuthInterceptor(localDbService));

    // 3. Custom Logging Interceptor
    dio.interceptors.add(LoggingInterceptor());

    // 4. Pretty Dio Logger for dev inspection
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );

    // 5. Global Error Handling Interceptor
    dio.interceptors.add(ErrorInterceptor(localDbService));
  }

  Future<Response<T>> get<T>(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.get<T>(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on SocketException catch (e) {
      Logger.logError('SocketException in GET: $e');
      throw CustomException(errMsg: 'No network connection. Please check your internet.');
    } on FormatException catch (_) {
      throw CustomException(errMsg: 'Unable to process server response.');
    } catch (e) {
      Logger.logError('Unexpected error in GET: $e');
      throw CustomException(errMsg: e.toString());
    }
  }

  Future<Response<T>> post<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.post<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on SocketException catch (e) {
      Logger.logError('SocketException in POST: $e');
      throw CustomException(errMsg: 'No network connection. Please check your internet.');
    } on FormatException catch (_) {
      throw CustomException(errMsg: 'Unable to process server response.');
    } catch (e) {
      Logger.logError('Unexpected error in POST: $e');
      throw CustomException(errMsg: e.toString());
    }
  }

  Future<Response<T>> put<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.put<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on SocketException catch (_) {
      throw CustomException(errMsg: 'No network connection.');
    } catch (e) {
      throw CustomException(errMsg: e.toString());
    }
  }

  Future<Response<T>> patch<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.patch<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw CustomException(errMsg: e.toString());
    }
  }

  Future<Response<T>> delete<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw CustomException(errMsg: e.toString());
    }
  }

  Future<Response<T>> uploadFile<T>(
    String uri, {
    required String filePath,
    required String fileFieldName,
    Map<String, dynamic>? additionalData,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        fileFieldName: await MultipartFile.fromFile(filePath, filename: fileName),
        ...?additionalData,
      });

      final response = await dio.post<T>(
        uri,
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw CustomException(errMsg: e.toString());
    }
  }

  CustomException _handleDioError(DioException e) {
    if (e.error is CustomException) {
      return e.error as CustomException;
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return CustomException(errMsg: 'Connection timed out. Please try again.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return CustomException(errMsg: 'No internet connection. Please check your network.');
    }

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? data['detail'];
        if (message != null && message.toString().isNotEmpty) {
          return CustomException(errMsg: message.toString().capitalize);
        }
      }

      if (statusCode == 401) {
        return CustomException(errMsg: 'Unauthorized. Session expired.');
      } else if (statusCode == 403) {
        return CustomException(errMsg: 'Access forbidden.');
      } else if (statusCode == 404) {
        return CustomException(errMsg: 'Requested resource not found.');
      } else if (statusCode != null && statusCode >= 500) {
        return CustomException(errMsg: 'Server error ($statusCode). Please try again later.');
      }
    }

    return CustomException(errMsg: e.message ?? 'An unexpected network error occurred.');
  }
}

// ==========================================
// 1. Connectivity Interceptor
// ==========================================
class ConnectivityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return handler.reject(
          DioException(
            requestOptions: options,
            message: 'No internet connection',
            type: DioExceptionType.connectionError,
            error: CustomException(errMsg: 'No internet connection. Please verify your connection.'),
          ),
        );
      }
    } catch (_) {
      // If connectivity check fails, proceed and let network call handle it
    }
    return handler.next(options);
  }
}

// ==========================================
// 2. Auth & Request Headers Interceptor
// ==========================================
class AuthInterceptor extends Interceptor {
  final LocalDbService localDbService;

  AuthInterceptor(this.localDbService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final now = DateTime.now().toUtc();
    final token = localDbService.getToken();

    final defaultHeaders = <String, dynamic>{
      'Timestamp': now.millisecondsSinceEpoch.toString(),
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Device-Type': Platform.isAndroid ? '1' : Platform.isIOS ? '2' : '0',
    };

    if (token != null && token.isNotEmpty) {
      defaultHeaders['Authorization'] = 'Bearer $token';
    }

    options.headers.addAll(defaultHeaders);
    return handler.next(options);
  }
}

// ==========================================
// 3. Logging Interceptor
// ==========================================
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.logInfo('--> [DIO REQUEST] ${options.method.toUpperCase()} ${options.uri}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.logSuccess('<-- [DIO RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.logError('<-- [DIO ERROR] ${err.response?.statusCode} ${err.requestOptions.uri}: ${err.message}');
    return handler.next(err);
  }
}

// ==========================================
// 4. Global Error Interceptor
// ==========================================
class ErrorInterceptor extends Interceptor {
  final LocalDbService localDbService;

  ErrorInterceptor(this.localDbService);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    // Handle 401 Unauthorized globally
    if (statusCode == 401) {
      Logger.logWarning('User session expired (401). Clearing local session...');
      await localDbService.clearSession();
      // Application can listen to session state or navigate to login
    }

    return handler.next(err);
  }
}
