import 'package:flutter/material.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/constants/style_constants.dart';
import 'package:itcc/src/data/models/learning_corner_model.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class LearningCornerDetailPage extends StatefulWidget {
  final LearningCornerModel learningCorner;
  const LearningCornerDetailPage({Key? key, required this.learningCorner})
      : super(key: key);

  @override
  State<LearningCornerDetailPage> createState() =>
      _LearningCornerDetailPageState();
}

class _LearningCornerDetailPageState extends State<LearningCornerDetailPage> {
  late int mainVideoIndex;
  late PodPlayerController _controller;
  final yt = YoutubeExplode();
  Map<String, String> videoTitles = {};

  String? _extractVideoId(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    } else if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    }
    return null;
  }

  String? _getYoutubeThumbnail(String url) {
    final videoId = _extractVideoId(url);
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    mainVideoIndex = 0;
    final files = widget.learningCorner.files
        .where((url) =>
            _extractVideoId(url) != null && _extractVideoId(url)!.isNotEmpty)
        .toList();
    
    if (files.isEmpty) {
      _controller = PodPlayerController(
        playVideoFrom: PlayVideoFrom.network(''),
      );
    } else {
      final mainVideoUrl = files[mainVideoIndex];
      final mainVideoId = _extractVideoId(mainVideoUrl);
      if (mainVideoId != null && mainVideoId.isNotEmpty) {
        _controller = PodPlayerController(
          playVideoFrom: PlayVideoFrom.youtube(mainVideoUrl),
          podPlayerConfig: const PodPlayerConfig(
            videoQualityPriority: [720, 480, 360],
            autoPlay: true,
            isLooping: false,
          ),
        )..initialise();
      } else {
        _controller = PodPlayerController(
          playVideoFrom: PlayVideoFrom.network(''),
        );
      }
    }
    _fetchVideoTitles();
  }

  Future<void> _fetchVideoTitles() async {
    for (var videoUrl in widget.learningCorner.files) {
      try {
        final videoId = _extractVideoId(videoUrl);
        if (videoId != null) {
          final video = await yt.videos.get(videoId);
          setState(() {
            videoTitles[videoUrl] = video.title;
          });
        }
      } catch (e) {
        print('Error fetching video title: $e');
        setState(() {
          videoTitles[videoUrl] =
              'Video ${widget.learningCorner.files.indexOf(videoUrl) + 1}';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    yt.close();
    super.dispose();
  }

  void _changeMainVideo(int index) {
    final files = widget.learningCorner.files
        .where((url) =>
            _extractVideoId(url) != null && _extractVideoId(url)!.isNotEmpty)
        .toList();
    
    if (files.isEmpty || index >= files.length) return;
    
    setState(() {
      mainVideoIndex = index;
      _controller.changeVideo(
        playVideoFrom: PlayVideoFrom.youtube(files[index]),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter out invalid video URLs
    final files = widget.learningCorner.files
        .where((url) =>
            _extractVideoId(url) != null && _extractVideoId(url)!.isNotEmpty)
        .toList();
    final hasValidMainVideo = files.isNotEmpty &&
        _extractVideoId(files[mainVideoIndex]) != null &&
        _extractVideoId(files[mainVideoIndex])!.isNotEmpty;
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        scrolledUnderElevation: 0,
        title: Text(
          widget.learningCorner.name,
          style: kBodyTitleM,
        ),
        centerTitle: true,
      ),
      body: files.isEmpty
          ? const Center(child: Text('No valid videos available.'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.learningCorner.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.learningCorner.description ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                hasValidMainVideo
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: PodVideoPlayer(controller: _controller),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Invalid or missing video.'),
                      ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    files.isNotEmpty
                        ? (videoTitles[files[mainVideoIndex]] ?? '')
                        : '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      if (index == mainVideoIndex)
                        return const SizedBox.shrink();
                      final fileUrl = files[index];
                      final thumbnailUrl = _getYoutubeThumbnail(fileUrl);
                      return ListTile(
                        leading: thumbnailUrl != null
                            ? Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      thumbnailUrl,
                                      width: 80,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              )
                            : const Icon(Icons.play_circle_fill,
                                color: Colors.red),
                        title: Text(
                          videoTitles[fileUrl] ?? 'Video ${index + 1}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _changeMainVideo(index),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: kGreyLight,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
