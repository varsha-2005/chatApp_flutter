import 'package:chat_app/status/providers/status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/status_model.dart';

class StatusViewScreen extends ConsumerStatefulWidget {
  final List<StatusModel> statuses; // all statuses of that user
  final int initialIndex; // which one to start from
  final String currentUserId;

  const StatusViewScreen({
    super.key,
    required this.statuses,
    required this.initialIndex,
    required this.currentUserId,
  });

  @override
  ConsumerState<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends ConsumerState<StatusViewScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  late int _currentIndex;

  StatusModel get _currentStatus => widget.statuses[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _setupForCurrentStatus();
  }

  void _setupForCurrentStatus() {
    final st = _currentStatus;

    // Mark as viewed (if not already)
    if (!st.isViewedBy(widget.currentUserId)) {
      Future.microtask(() {
        ref
            .read(statusControllerProvider.notifier)
            .markViewed(statusId: st.id, viewerUid: widget.currentUserId);
      });
    }

    // Reset any previous video
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;

    // If it's a video status, set up the video player
    if (st.isVideo && st.mediaUrl.isNotEmpty) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(st.mediaUrl))
            ..initialize().then((_) {
              if (!mounted) return;
              setState(() {
                _isVideoInitialized = true;
              });
              _videoController!.play();
            });
    }
  }

  void _showNext() {
    if (_currentIndex < widget.statuses.length - 1) {
      setState(() {
        _currentIndex++;
        _setupForCurrentStatus();
      });
    } else {
      // last status → close like WhatsApp
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildMedia() {
    final st = _currentStatus;

    final hasText = st.text != null && st.text!.trim().isNotEmpty;
    final hasMedia = st.mediaUrl.isNotEmpty;

    // ✅ TEXT-ONLY STATUS (no mediaUrl)
    if (hasText && !hasMedia) {
      return GestureDetector(
        onTap: _showNext, // tap to go next status
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF128C7E), Color(0xFF25D366)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              st.text!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // ✅ VIDEO STATUS
    if (st.isVideo) {
      if (!_isVideoInitialized || _videoController == null) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      return GestureDetector(
        // tap toggles play/pause (video style)
        onTap: () {
          if (_videoController!.value.isPlaying) {
            _videoController!.pause();
          } else {
            _videoController!.play();
          }
          setState(() {});
        },
        // double tap to go next
        onDoubleTap: _showNext,
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    }

    // ✅ IMAGE STATUS (or media + text together)
    if (hasMedia) {
      return GestureDetector(
        onTap: _showNext, // tap image to go next status
        child: Center(
          child: Image.network(
            st.mediaUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      );
    }

    // Fallback (no media, no text – shouldn't normally happen)
    return const Center(
      child: Text(
        'No content',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = _currentStatus;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Media (text / image / video)
            Positioned.fill(child: _buildMedia()),

            // Top bar (back + avatar + name + time)
            Positioned(
              left: 8,
              right: 8,
              top: 8,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(backgroundImage: NetworkImage(st.userImage)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        st.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        TimeOfDay.fromDateTime(st.timestamp).format(context),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (st.isVideo && _videoController != null)
                    IconButton(
                      icon: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
