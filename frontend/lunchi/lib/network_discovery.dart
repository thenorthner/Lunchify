import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

class NetworkDiscovery {
  static const int port = 4000;
  static const String discoveryMessage = 'DISCOVER_LUNCHIFY_SERVER';

  /// Broadcasts a UDP message to find the backend server on the local network.
  /// Returns the IP address and port string (e.g. "192.168.1.10:3001") if found,
  /// or null if the discovery timed out.
  static Future<String?> discoverServer({Duration timeout = const Duration(seconds: 3)}) async {
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      Completer<String?> completer = Completer<String?>();

      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = socket!.receive();
          if (dg != null) {
            String message = utf8.decode(dg.data);
            if (message.startsWith('LUNCHIFY_SERVER:')) {
              String serverPort = message.split(':')[1];
              String serverIp = dg.address.address;
              if (!completer.isCompleted) {
                completer.complete('$serverIp:$serverPort');
              }
            }
          }
        }
      });

      // Broadcast to standard broadcast address
      socket.send(utf8.encode(discoveryMessage), InternetAddress('255.255.255.255'), port);

      // Return the result with a timeout
      return await completer.future.timeout(timeout, onTimeout: () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
        return null;
      });
    } catch (e) {
      debugPrint('Error during network discovery: $e');
      return null;
    } finally {
      socket?.close();
    }
  }
}
