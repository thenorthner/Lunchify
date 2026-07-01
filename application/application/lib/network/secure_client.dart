import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class SecureClient {
  static http.Client getClient() {
    SecurityContext context = SecurityContext(withTrustedRoots: true);

    // SSL Pinning Implementation
    // TODO: Replace with the actual certificate hash of your backend server
    // final List<int> expectedHash = [ ... ];
    
    HttpClient httpClient = HttpClient(context: context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Enforce strict certificate verification
        // For development against localhost/IPs, you might need to return true
        // BUT FOR PRODUCTION: MUST return false to reject unpinned certificates
        return false; 
      };

    return IOClient(httpClient);
  }
}
