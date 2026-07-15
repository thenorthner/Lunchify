import 'dart:io';
import 'dart:convert';
void main() async {
  var socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  socket.broadcastEnabled = true;
  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      Datagram? dg = socket.receive();
      if (dg != null) {
        print('Client got: ${utf8.decode(dg.data)} from ${dg.address.address}:${dg.port}');
        exit(0);
      }
    }
  });
  socket.send(utf8.encode('DISCOVER'), InternetAddress('255.255.255.255'), 4000);
  print('Broadcast sent');
}
