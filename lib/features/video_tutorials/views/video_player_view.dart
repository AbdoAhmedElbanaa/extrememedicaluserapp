import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class VideoPlayerView extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String description;

  const VideoPlayerView({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.description,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _controller;
  YoutubePlayerController? _ytController;
  bool _isYoutube = false;
  bool _initialized = false;
  bool _showControls = true;
  bool _hasError = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _isYoutube = true;
      _ytController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      );
      _initialized = true;
    } else {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();
      setState(() {
        _initialized = true;
        _hasError = false;
      });
      _controller.play();
      _startHideTimer();
    } catch (e) {
      setState(() {
        _hasError = true;
        _initialized = false;
      });
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isYoutube && _controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    if (_isYoutube) {
      _ytController?.dispose();
    } else {
      _controller.dispose();
    }
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isYoutube && _ytController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _ytController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primary,
          progressColors: const ProgressBarColors(
            playedColor: AppColors.primary,
            handleColor: AppColors.primary,
            bufferedColor: Colors.white24,
            backgroundColor: Colors.white10,
          ),
        ),
        builder: (context, player) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  // Top Custom Navigation Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Video Box
                  Expanded(
                    child: Center(
                      child: player,
                    ),
                  ),

                  // Description Pane
                  _buildDescriptionPane(),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Custom Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Video Box
            Expanded(
              child: Center(
                child: _hasError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load video tutorial.',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _initialized = false;
                                _hasError = false;
                              });
                              _initializePlayer();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Text('Retry'),
                          )
                        ],
                      )
                    : !_initialized
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : GestureDetector(
                            onTap: _toggleControls,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(_controller),
                                ),
                                
                                // Controls Overlay
                                AnimatedOpacity(
                                  opacity: _showControls ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 250),
                                  child: IgnorePointer(
                                    ignoring: !_showControls,
                                    child: Stack(
                                      children: [
                                        // Dark gradient shade overlay
                                        Positioned.fill(
                                          child: Container(
                                            color: Colors.black38,
                                          ),
                                        ),
                                        
                                        // Center Play/Pause button
                                        Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (_controller.value.isPlaying) {
                                                  _controller.pause();
                                                } else {
                                                  _controller.play();
                                                  _startHideTimer();
                                                }
                                              });
                                            },
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white24, width: 1.5),
                                              ),
                                              child: Icon(
                                                _controller.value.isPlaying
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Bottom Control Bar
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.transparent, Colors.black54],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Slider
                                                VideoProgressIndicator(
                                                  _controller,
                                                  allowScrubbing: true,
                                                  colors: const VideoProgressColors(
                                                    playedColor: AppColors.primary,
                                                    bufferedColor: Colors.white24,
                                                    backgroundColor: Colors.white10,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                // Timestamps & Controls
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    ValueListenableBuilder(
                                                      valueListenable: _controller,
                                                      builder: (context, VideoPlayerValue value, child) {
                                                        return Text(
                                                          '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                                          style: const TextStyle(
                                                            color: Colors.white70,
                                                            fontSize: 12,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        _controller.value.volume == 0
                                                            ? Icons.volume_off_rounded
                                                            : Icons.volume_up_rounded,
                                                        color: Colors.white70,
                                                        size: 20,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _controller.setVolume(_controller.value.volume == 0 ? 1.0 : 0.0);
                                                        });
                                                      },
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
              ),
            ),

            // Description Pane
            _buildDescriptionPane(),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionPane() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0C21), // AppColors.surfaceDark
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'About this tutorial',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
