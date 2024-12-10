import 'dart:developer';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:path_provider/path_provider.dart';

import 'custom_download_dialog.dart';

class DownloadManager {
  bool isProgressing = false;

  /// Main download function
  Future<void> downloadPDF(
      BuildContext context, String url, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$name.pdf';
    final progressNotifier = ValueNotifier<double>(0.0);
    // Show the progress dialog using StatefulDialog
    log('Starting download with url :::::::::: $url');
    Fluttertoast.showToast(msg: "Download Starting!");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (context.findAncestorStateOfType<State>()?.mounted ?? false) {
          return CustomDownloadDialog(
            progressNotifier: progressNotifier,
            title: name,
            onCancel: () => Navigator.of(context).pop(),
          );
        } else {
          return Container(); // or return some other widget
        }
      },
    );

    // Create a ReceivePort to receive messages from the Isolate
    final receivePort = ReceivePort();

    // Spawn a new Isolate
    await Isolate.spawn(
      _downloadTask,
      _DownloadParams(
          url: url, filePath: filePath, sendPort: receivePort.sendPort),
    );

    // Listen for progress updates or completion from the Isolate
    receivePort.listen((message) {
      if (message is double) {
        // Update progress in the notifier
        progressNotifier.value = message;

        if (message == 100) {
          // Close the dialog and show completion Toast
          Navigator.of(context).pop();
          Fluttertoast.showToast(msg: "Download Complete!");
          log('Download completed');
        }
      } else if (message is String) {
        // Error message received from Isolate
        Navigator.of(context).pop(); // Close the dialog
        Fluttertoast.showToast(msg: message);
        log('Error downloading: $message');
      }
    });
  }
}

/// Function to handle the download task in the Isolate
Future<void> _downloadTask(_DownloadParams params) async {
  Dio dio = Dio();
  log('Download task started for URL: ${params.url}');
  try {
    await dio.download(
      params.url,
      params.filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          double progress = (received / total) * 100;
          log('Download progress: $progress%');
          params.sendPort.send(progress);
        }
      },
    );
    log('Download completed successfully');
    params.sendPort.send(100.0);
  } catch (e) {
    log('Error occurred during download: $e');
    params.sendPort.send("Error downloading PDF: $e");
  }
}

/// Class to hold parameters for the Isolate
class _DownloadParams {
  final String url;
  final String filePath;
  final SendPort sendPort;

  _DownloadParams(
      {required this.url, required this.filePath, required this.sendPort});
}

/// Progress Dialog Widget
