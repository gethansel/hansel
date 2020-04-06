import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

const BASE_URL = '<HANSEL_API_URL>';
const X_API_KEY = '<HANSEL_API_KEY>';

final Dio dio = Dio()
  ..options.baseUrl = BASE_URL
  ..options.connectTimeout = 5000
  ..options.receiveTimeout
  ..options.headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'x-api-key': X_API_KEY
  }
  ..interceptors.add(PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 90));

class ApiClient {
  // const ApiClient();

  Future<dynamic> get(String uri, [data]) async {
    final Response response = await dio.get(uri, queryParameters: data);
    return response.data;
  }

  Future<dynamic> post(String uri, dynamic data, {dynamic queryParameters}) async {
    try {
      var body = json.encode(data);
      final Response response = await dio.post(uri, data: body, queryParameters: Map<String, dynamic>.from(queryParameters));
      return response.data;
    } on DioError catch(e) {
      throw(e.message);
    } catch (e) {
      throw ('An error occurred $e');
    }
  }
}
