import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as original_http;
import 'package:http/io_client.dart';

class SecureClient {
  static original_http.Client getClient() {
    if (kIsWeb) {
      return original_http.Client();
    }

    SecurityContext context = SecurityContext(withTrustedRoots: true);

    // SSL Pinning Implementation
    // TODO: Replace with the actual certificate hash of your backend server
    HttpClient httpClient = HttpClient(context: context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Enforce strict certificate verification
        // BUT FOR PRODUCTION: MUST return false to reject unpinned certificates
        return false; 
      };

    return IOClient(httpClient);
  }
}
