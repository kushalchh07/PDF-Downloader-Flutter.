import 'package:flutter/material.dart';

import 'downloaded_video_screen.dart';
import 'video_downloader.dart';

class VideoListScreen extends StatelessWidget {
  final List<Map<String, String>> videos = [
    {
      'name': 'Video 1',
      'url':
          'https://iframe.mediadelivery.net/embed/341588/18e1ca88-c982-4420-885b-354a11c1a56a'
    },
    {
      'name': 'Video 2',
      'url':
          'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4'
    },
    {
      'name': 'Video 3',
      'url':
          'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_10mb.mp4'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final downloadManager = DownloadManager();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Video List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_done),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DownloadedVideosListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return ListTile(
            title: Text(video['name']!),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                final filePath = await downloadManager.downloadVideo(
                    video['url']!, video['name']!);

                if (filePath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Downloaded: ${video['name']}")),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
