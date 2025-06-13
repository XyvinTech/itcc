import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class YouTubePlayerWidget extends StatefulWidget {
  final String videoId;
  
  const YouTubePlayerWidget({Key? key, required this.videoId}) : super(key: key);

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  InAppWebViewController? webViewController;
  bool isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('https://www.youtube.com/embed/${widget.videoId}?playsinline=1&enablejsapi=1'),
        ),
        initialSettings: InAppWebViewSettings(iframeAllowFullscreen: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          useOnDownloadStart: true,
          useOnLoadResource: true,
          useShouldOverrideUrlLoading: true,
          javaScriptEnabled: true,
          domStorageEnabled: true,

        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
          
          // Add JavaScript to handle fullscreen
          controller.addJavaScriptHandler(
            handlerName: 'fullscreenHandler',
            callback: (args) {
              setState(() {
                isFullscreen = !isFullscreen;
              });
              
              if (isFullscreen) {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
              } else {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
                  overlays: SystemUiOverlay.values);
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              }
            },
          );
        },
        onLoadStop: (controller, url) async {
          // Inject JavaScript to detect fullscreen changes
          await controller.evaluateJavascript(source: '''
            document.addEventListener('fullscreenchange', function() {
              window.flutter_inappwebview.callHandler('fullscreenHandler');
            });
            
            document.addEventListener('webkitfullscreenchange', function() {
              window.flutter_inappwebview.callHandler('fullscreenHandler');
            });
          ''');
        },
        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
      overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
}