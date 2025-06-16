import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/constants/style_constants.dart';
import 'package:itcc/src/data/models/learning_corner_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:itcc/src/interface/screens/main_pages/menuPages/learning_corner/video_player.dart';

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
  final yt = YoutubeExplode();
  Map<String, String> videoTitles = {};
  List<String> validVideoUrls = [];
  // Add a key to force widget rebuild
  Key _playerKey = UniqueKey();

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
    _initializeValidVideos();
    _fetchVideoTitles();
  }

  void _initializeValidVideos() {
    validVideoUrls = widget.learningCorner.files
        .where((url) =>
            _extractVideoId(url) != null && _extractVideoId(url)!.isNotEmpty)
        .toList();
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
    yt.close();
    super.dispose();
  }

  void _changeMainVideo(int index) {
    if (index >= 0 && index < validVideoUrls.length) {
      setState(() {
        mainVideoIndex = index;
        // Generate a new key to force the player widget to rebuild
        _playerKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: validVideoUrls.isEmpty
          ? const Center(child: Text('No valid videos available.'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.learningCorner.name,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.learningCorner.description ?? '',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add the key to force rebuild when video changes
                  YouTubePlayerWidget(
                    key: _playerKey,
                    videoId: _extractVideoId(validVideoUrls[mainVideoIndex])!,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      videoTitles[validVideoUrls[mainVideoIndex]] ?? '',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  // Replace Expanded with Column and ListView.builder with shrinkWrap
                  Column(
                    children: List.generate(
                      validVideoUrls.length,
                      (index) {
                        if (index == mainVideoIndex)
                          return const SizedBox.shrink();
                        final fileUrl = validVideoUrls[index];
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
            ),
    );
  }
}