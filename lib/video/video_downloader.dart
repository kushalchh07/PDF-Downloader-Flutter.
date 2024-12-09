import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';


class DownloadManager {
  Future<String?> downloadVideo(String url, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.mp4';

      // Create ReceivePort to communicate with Isolate
      final receivePort = ReceivePort();

      // Start Isolate
      await Isolate.spawn(
        _downloadTask,
        _DownloadParams(
          url: url,
          filePath: filePath,
          sendPort: receivePort.sendPort,
        ),
      );

      // Wait for Isolate to send back the result
      final result = await receivePort.first;

      if (result is String) {
        log("Download Completed: $result");
        Fluttertoast.showToast(msg: "Download Complete!");
        return filePath;
      } else if (result is Exception) {
        Fluttertoast.showToast(msg: "Download Failed: ${result.toString()}");
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      return null;
    }
  }

  // Function to handle downloading in the Isolate
  static Future<void> _downloadTask(_DownloadParams params) async {
    final dio = Dio();
    try {
      await dio.download(
        params.url,
        params.filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;
            log("Progress: $progress%");
          }
        },
      );
      params.sendPort.send(params.filePath); // Success: send file path
    } catch (e) {
      params.sendPort.send(Exception("Download error: $e")); // Error
    }
  }
}

class _DownloadParams {
  final String url;
  final String filePath;
  final SendPort sendPort;

  _DownloadParams({
    required this.url,
    required this.filePath,
    required this.sendPort,
  });
}




class DownloadedVideosManager {
  /// Retrieve the list of all downloaded videos
  Future<List<File>> getDownloadedVideos() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync(); // List all files in the directory

    return files
        .whereType<File>() // Filter for files only
        .where((file) => file.path.endsWith(".mp4")) // Only MP4 files
        .toList();
  }
}
