import 'package:http/http.dart' as original_http;
export 'package:http/http.dart' show Response, Client, MultipartRequest, MultipartFile, StreamedResponse, BaseRequest, BaseResponse, ByteStream;
import 'secure_client.dart';
import 'dart:convert';

Future<original_http.Response> get(Uri url, {Map<String, String>? headers}) {
  final client = SecureClient.getClient();
  return client.get(url, headers: headers).whenComplete(() => client.close());
}

Future<original_http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
  final client = SecureClient.getClient();
  return client.post(url, headers: headers, body: body, encoding: encoding).whenComplete(() => client.close());
}

Future<original_http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
  final client = SecureClient.getClient();
  return client.put(url, headers: headers, body: body, encoding: encoding).whenComplete(() => client.close());
}

Future<original_http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
  final client = SecureClient.getClient();
  return client.patch(url, headers: headers, body: body, encoding: encoding).whenComplete(() => client.close());
}

Future<original_http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
  final client = SecureClient.getClient();
  return client.delete(url, headers: headers, body: body, encoding: encoding).whenComplete(() => client.close());
}
