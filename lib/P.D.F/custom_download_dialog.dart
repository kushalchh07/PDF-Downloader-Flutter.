import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomDownloadDialog extends StatefulWidget {
  final ValueNotifier<double> progressNotifier;
  final String title;

  final VoidCallback onCancel;

  const CustomDownloadDialog({
    Key? key,
    required this.progressNotifier,
    required this.title,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<CustomDownloadDialog> createState() => _CustomDownloadDialogState();
}

class _CustomDownloadDialogState extends State<CustomDownloadDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Custom border radius
      ),
      child: SizedBox(
        height: 170,
        child: Card(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                  child: SvgPicture.asset(
                                "assets/base_icons/download.svg",
                                color: Colors.white,
                                colorFilter: ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                              ))),
                          SizedBox(width: 10),
                          Text(
                            "Downloading.....",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'inter'),
                          )
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          "assets/custom_icons/pdf_icon.svg",
                          height: 35,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.title,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        widget.onCancel();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 60.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              ValueListenableBuilder<double>(
                valueListenable: widget.progressNotifier,
                builder: (context, progress, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor: Colors.grey[300],
                          borderRadius: BorderRadius.circular(0),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${progress.toStringAsFixed(0)}% Completed',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'inter',
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
