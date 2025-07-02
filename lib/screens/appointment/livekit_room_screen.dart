import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../services/livekit_service.dart';
import '../../widgets/video_grid.dart';
import '../../widgets/control_buttons.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveKitRoomScreen extends StatefulWidget {
  final String name;
  final String room;

  const LiveKitRoomScreen({super.key, required this.name, required this.room});

  @override
  State<LiveKitRoomScreen> createState() => _LiveKitRoomScreenState();
}

class _LiveKitRoomScreenState extends State<LiveKitRoomScreen> {
  Room? _room;
  bool _connecting = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connectToRoom();
  }

  Future<void> _connectToRoom() async {
    try {
      // ✅ Xin quyền camera & mic
      await Permission.camera.request();
      await Permission.microphone.request();

      final token = await fetchLivekitToken(widget.room, widget.name);
      if (token == null) {
        setState(() => _error = 'Không lấy được token');
        return;
      }

      final room = Room();

      // ✅ Kết nối tới LiveKit
      await room.connect(
        'wss://tele-oovrxt5d.livekit.cloud',
        token,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultVideoPublishOptions: VideoPublishOptions(simulcast: false),
        ),
      );

      // ✅ Bật camera & mic ngay sau khi kết nối
      await room.localParticipant?.setCameraEnabled(true);
      await room.localParticipant?.setMicrophoneEnabled(true);

      setState(() {
        _room = room;
        _connecting = false;
      });
    } catch (e) {
      setState(() => _error = 'Lỗi kết nối: $e');
    }
  }

  @override
  void dispose() {
    _room?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(child: Text(_error!)),
      );
    }

    if (_connecting || _room == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: VideoGrid(room: _room!)),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: ControlButtons(room: _room!),
          ),
        ],
      ),
    );
  }
}
