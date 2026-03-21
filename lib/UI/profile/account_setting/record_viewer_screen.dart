import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class RecordViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String title;

  const RecordViewerScreen({
    super.key,
    required this.fileUrl,
    required this.title,
  });

  @override
  State<RecordViewerScreen> createState() => _RecordViewerScreenState();
}

class _RecordViewerScreenState extends State<RecordViewerScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _localPdfPath;

  // PDF page tracking
  int _totalPages = 0;
  int _currentPage = 0;

  bool get _isPdf {
    final url = widget.fileUrl.toLowerCase().split('?').first;
    return url.endsWith('.pdf');
  }

  @override
  void initState() {
    super.initState();
    if (_isPdf) {
      _downloadPdf();
    }
  }

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.fileUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/health_record_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          setState(() {
            _localPdfPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to download file (status ${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading file: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1a1111) : const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xff2d1f1f) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          overflow: TextOverflow.ellipsis,
        ),
        // PDF page counter shown in AppBar
        actions: [
          if (_isPdf && _totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildContent(isDarkMode, primaryColor),
    );
  }

  Widget _buildContent(bool isDarkMode, Color primaryColor) {
    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!, primaryColor);
    }

    if (_isPdf) {
      if (_isLoading || _localPdfPath == null) {
        return _buildLoadingState(isDarkMode, primaryColor);
      }
      return _buildPdfView(isDarkMode);
    }

    // Image viewer with pinch-to-zoom
    return _buildImageView(isDarkMode, primaryColor);
  }

  Widget _buildLoadingState(bool isDarkMode, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading document…',
            style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: primaryColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageView(bool isDarkMode, Color primaryColor) {
    return Center(
      child: InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 5.0,
        child: Image.network(
          widget.fileUrl,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            final percent = loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: percent,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    percent != null ? '${(percent * 100).toStringAsFixed(0)}%' : 'Loading…',
                    style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorState('Could not load image.', primaryColor);
          },
        ),
      ),
    );
  }

  Widget _buildPdfView(bool isDarkMode) {
    return PDFView(
      filePath: _localPdfPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      backgroundColor: isDarkMode ? const Color(0xff1a1111) : const Color(0xfff5f5f5),
      onRender: (pages) {
        if (mounted) setState(() => _totalPages = pages ?? 0);
      },
      onPageChanged: (page, total) {
        if (mounted) setState(() => _currentPage = page ?? 0);
      },
      onError: (error) {
        if (mounted) setState(() => _errorMessage = error.toString());
      },
    );
  }
}
