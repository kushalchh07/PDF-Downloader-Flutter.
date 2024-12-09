import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'video_downloader.dart';
import 'video_view.dart';


class DownloadedVideosListScreen extends StatefulWidget {
  @override
  _DownloadedVideosListScreenState createState() =>
      _DownloadedVideosListScreenState();
}

class _DownloadedVideosListScreenState
    extends State<DownloadedVideosListScreen> {
  final DownloadedVideosManager _manager = DownloadedVideosManager();
  late Future<List<File>> _downloadedVideos;

  @override
  void initState() {
    super.initState();
    _loadDownloadedVideos();
  }

  void _loadDownloadedVideos() {
    setState(() {
      _downloadedVideos = _manager.getDownloadedVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloaded Videos"),
      ),
      body: FutureBuilder<List<File>>(
        future: _downloadedVideos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading videos."),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No videos downloaded."),
            );
          }

          final videos = snapshot.data!;
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final file = videos[index];
              final fileName = file.path.split('/').last;

              return ListTile(
                title: Text(fileName),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(filePath: file.path),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
