import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'pdf_list_screen.dart';

class PDFDownloader extends StatefulWidget {
  @override
  _PDFDownloaderState createState() => _PDFDownloaderState();
}

class _PDFDownloaderState extends State<PDFDownloader> {
  Dio dio = Dio();
  bool isDownloading = false;
  bool isProgressing = false; // Flag to track if the progress toast is showing

  // Method to download the PDF file
  Future<void> downloadPDF() async {
    // Request permissions to access storage
    // if (await Permission.storage.request().isGranted) {
    // Show Toast that download has started
    Fluttertoast.showToast(msg: "Download started...");

    try {
      // Getting the directory to store the PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/my_downloaded_file.pdf';

      // Start the download with progress
      await dio.download(
        'https://drive.google.com/uc?id=13NZyM0o2DEbeh3F8SoOdU7RMKREHBOy7&export=download', // The PDF file URL
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Calculate the download progress
            double progress = (received / total) * 100;
            log("Progress: ${progress.toStringAsFixed(0)}%");

            // If the progress has changed and is not 100%, show the Toast
            if (progress < 100 && !isProgressing) {
              setState(() {
                isProgressing = true;
              });
              Fluttertoast.showToast(
                msg: "Downloading: ${progress.toStringAsFixed(0)}%",
                toastLength: Toast.LENGTH_SHORT,
              );
            }

            // If the progress reaches 100%, show the completion message and stop progress Toast
            if (progress == 100 && isProgressing) {
              Fluttertoast.cancel(); // Cancel the ongoing toast
              Fluttertoast.showToast(msg: "Download Complete!");
              setState(() {
                isProgressing = false;
              });
            }
          }
        },
      );
    } catch (e) {
      // In case of error, show a toast with an error message
      Fluttertoast.showToast(msg: "Error downloading PDF: $e");
      log("Error downloading PDF: $e");
    }
    // } else {
    //   // If the storage permission is not granted, show a Toast
    //   Fluttertoast.showToast(msg: "Storage permission denied");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Downloader")),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                downloadPDF();
              },
              child: const Text('Download PDF'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PDFListScreen()));
              },
              child: const Text('Downloaded PDFs'),
            ),
          )
        ],
      ),
    );
  }
}
