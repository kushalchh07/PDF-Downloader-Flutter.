import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'pdf_viewer_screen.dart';

class PDFListScreen extends StatefulWidget {
  @override
  _PDFListScreenState createState() => _PDFListScreenState();
}

class _PDFListScreenState extends State<PDFListScreen> {
  List<FileSystemEntity> files = [];

  Future<void> loadFiles() async {
    // Get the application documents directory
    Directory appDocDir = await getApplicationDocumentsDirectory();

    // Get all PDF files
    final pdfDir = Directory(appDocDir.path);
    final List<FileSystemEntity> fileList = pdfDir.listSync();
    setState(() {
      files = fileList.where((file) => file.path.endsWith('.pdf')).toList();
    });
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
      // Refresh the file list after deletion
      loadFiles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting file: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Downloaded PDFs")),
      body: files.isEmpty
          ? Center(child: Text("No PDFs available"))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(files[index].path.split('/').last),
                  onTap: () {
                    // Open PDF when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PDFViewerScreen(filePath: files[index].path),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Confirm before deletion
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Delete PDF"),
                          content: Text(
                            "Are you sure you want to delete this PDF?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteFile(files[index].path);
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
