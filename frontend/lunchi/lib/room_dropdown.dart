import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lunchi/network/http_wrapper.dart' as http;
import './config.dart'; // adjust path if needed
import './auth_service.dart';

class RoomDropdown extends StatefulWidget {
  final Function(int) onSelected;

  const RoomDropdown({super.key, required this.onSelected});

  @override
  State<RoomDropdown> createState() => _RoomDropdownState();
}

class _RoomDropdownState extends State<RoomDropdown> {
  List rooms = [];
  int? selectedRoomId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final res = await http.get(
      Uri.parse(AppConfig.rooms),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );

    setState(() {
      rooms = jsonDecode(res.body);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CircularProgressIndicator();
    }

    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: "Room Number",
        border: OutlineInputBorder(),
      ),
      value: selectedRoomId,
      items: rooms.map<DropdownMenuItem<int>>((room) {
        return DropdownMenuItem<int>(
          value: room['id'],
          child: Text(room['room_number']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => selectedRoomId = value);
        widget.onSelected(value!);
      },
    );
  }
}
