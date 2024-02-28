import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_document_scanner/flutter_document_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

void main() {
  runApp(const MaterialApp(
    home: CustomPage(),
  ));
}

class CustomPage extends StatefulWidget {
  const CustomPage({Key? key}) : super(key: key);

  @override
  State<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  final _controller = DocumentScannerController();
  String _imagePath = '';

  @override
  Future<void> dispose() async {
    _controller.dispose();
    super.dispose();
  }

  Future<void> detectEdgesAndSaveAsPdf() async {
    try {
      // Detect edges and get the image path
      String imagePath = await edgedetection(); // Await the result here

      // Rotate the image if needed
      imagePath = await rotateImageIfNeeded(imagePath);

      // Generate PDF after edge detection
      final pdf = await generatePdf(File(imagePath));

      // Save the PDF to a file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/document.pdf');
      await file.writeAsBytes(await pdf.save());

      print('PDF saved at: ${file.path}');

      // Print the PDF
      await printPdf(await pdf.save());

      print('PDF saved and printed successfully');
    } catch (e) {
      print('Error while detecting edges or printing PDF: $e');
    }
  }

  Future<void> printPdf(Uint8List pdfBytes) async {
    try {
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
      );
      print('PDF printed successfully');
    } catch (e) {
      print('Error while printing PDF: $e');
    }
  }

  // ignore: await_only_futures
  edgedetection() async => (await EdgeDetection.detectEdge);

  Future<String> rotateImageIfNeeded(String imagePath) async {
    // Check device orientation
    var deviceOrientation = MediaQuery.of(context).orientation;

    // Rotate the image if the device orientation is landscape
    if (deviceOrientation == Orientation.landscape) {
      File rotatedImage = await FlutterExifRotation.rotateImage(path: imagePath);
      return rotatedImage.path;
    }

    return imagePath; // Return original path if no rotation is needed
  }

  Future<pw.Document> generatePdf(File imageFile) async {
    final pdf = pw.Document();

    final Uint8List imageBytes = await imageFile.readAsBytes();

    // Add image to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(PdfImage.file(
              pdf.document,
              bytes: imageBytes,
            ) as pw.ImageProvider),
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> rotateImage() async {
    if (_imagePath.isNotEmpty) {
      File rotatedImage = await FlutterExifRotation.rotateImage(path: _imagePath);
      setState(() {
        _imagePath = rotatedImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _imagePath.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.file(File(_imagePath)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: rotateImage,
                    child: const Text('Rotate Image'),
                  ),
                ],
              ),
            )
          : DocumentScanner(
              controller: _controller,
              generalStyles: const GeneralStyles(
                hideDefaultBottomNavigation: true,
                messageTakingPicture: 'Taking picture of document',
                messageCroppingPicture: 'Cropping picture of document',
                messageEditingPicture: 'Editing picture of document',
                messageSavingPicture: 'Saving picture of document',
                baseColor: Colors.teal,
              ),
              takePhotoDocumentStyle: TakePhotoDocumentStyle(
                top: MediaQuery.of(context).padding.top + 25,
                hideDefaultButtonTakePicture: true,
                onLoading: const CircularProgressIndicator(
                  color: Colors.white,
                ),
                children: [
                  // * AppBar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.teal,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 10,
                        bottom: 15,
                      ),
                      child: const Center(
                        child: Text(
                          'Take a picture of the document',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // * Button to take picture
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _controller.takePhoto();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text(
                          'Take picture',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              cropPhotoDocumentStyle: CropPhotoDocumentStyle(
                top: MediaQuery.of(context).padding.top,
                maskColor: Colors.teal.withOpacity(0.2),
              ),
              editPhotoDocumentStyle: EditPhotoDocumentStyle(
                top: MediaQuery.of(context).padding.top,
              ),
              resolutionCamera: ResolutionPreset.ultraHigh,
              pageTransitionBuilder: (child, animation) {
                final tween = Tween<double>(begin: 0, end: 1);

                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );

                return ScaleTransition(
                  scale: tween.animate(curvedAnimation),
                  child: child,
                );
              },
              onSave: (Uint8List imageBytes) {
                // Process the imageBytes further if needed
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          detectEdgesAndSaveAsPdf(); // Call edge detection, PDF generation, and printing when the save button is pressed
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
