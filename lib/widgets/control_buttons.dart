import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class ControlButtons extends StatefulWidget {
  final Room room;
  const ControlButtons({super.key, required this.room});

  @override
  State<ControlButtons> createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  bool _cameraEnabled = true;
  bool _micEnabled = true;

  @override
  void initState() {
    super.initState();
    final p = widget.room.localParticipant;
    _cameraEnabled = (p?.isCameraEnabled as bool?) ?? true;
    _micEnabled = (p?.isMicrophoneEnabled as bool?) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToggleButton(
            iconOn: Icons.videocam,
            iconOff: Icons.videocam_off,
            isOn: _cameraEnabled,
            onToggle: () async {
              await widget.room.localParticipant?.setCameraEnabled(!_cameraEnabled);
              setState(() => _cameraEnabled = !_cameraEnabled);
            },
          ),
          _buildToggleButton(
            iconOn: Icons.mic,
            iconOff: Icons.mic_off,
            isOn: _micEnabled,
            onToggle: () async {
              await widget.room.localParticipant?.setMicrophoneEnabled(!_micEnabled);
              setState(() => _micEnabled = !_micEnabled);
            },
          ),
          _buildActionButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: () {
              widget.room.disconnect();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData iconOn,
    required IconData iconOff,
    required bool isOn,
    required VoidCallback onToggle,
  }) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: Colors.white10,
      child: IconButton(
        icon: Icon(isOn ? iconOn : iconOff,
            color: isOn ? Colors.white : Colors.redAccent),
        iconSize: 28,
        onPressed: onToggle,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: Colors.white10,
      child: IconButton(
        icon: Icon(icon, color: color),
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }
}
