import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class VideoGrid extends StatelessWidget {
  final Room room;
  const VideoGrid({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final participants = <Participant>[
      if (room.localParticipant != null) room.localParticipant!,
      ...room.remoteParticipants.values,
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Sửa số cột tùy theo kích thước màn hình nếu muốn
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        final videoTrack = participant.videoTrackPublications.isNotEmpty
            ? participant.videoTrackPublications.first.track
            : null;

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: videoTrack != null
                      ? VideoTrackRenderer(videoTrack as VideoTrack)
                      : const Center(
                          child: Text(
                            'Không có video',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      participant.identity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
