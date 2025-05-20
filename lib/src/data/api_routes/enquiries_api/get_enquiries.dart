import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:itcc/src/data/globals.dart';
import 'package:itcc/src/data/models/enquiries_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:itcc/src/data/services/snackbar_service.dart';
import 'package:itcc/src/interface/components/loading_indicator/loading_indicator.dart';

part 'get_enquiries.g.dart';

class EnquiriesApiService {
  static final _baseUrl = Uri.parse('$baseUrl/user/enquiry');

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      };

  /// Fetch Enquiries
  static Future<List<EnquiriesModel>> fetchEnquiries() async {
    try {
      log('Fetching enquiries from: $_baseUrl');
      final response = await http.get(_baseUrl, headers: _headers());

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List data = jsonResponse['data'];
        return data.map((data) => EnquiriesModel.fromJson(data)).toList();
      } else {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Failed to fetch enquiries');
      }
    } catch (e) {
      log('Error fetching enquiries: $e');
      throw Exception('Error: $e');
    }
  }

  Future<String?> downloadAndSaveExcel({BuildContext? context}) async {
    final snackbarService = SnackbarService();

    OverlayEntry? loadingOverlay;
    if (context != null) {
      loadingOverlay = _createLoadingOverlay();
      Overlay.of(context).insert(loadingOverlay);
    }

    try {
      final apiUrl = "$baseUrl/user/enquiry-list";
      final response = await http.get(Uri.parse(apiUrl), headers: _headers());

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final headers = jsonData['data']['headers'];
        final body = jsonData['data']['body'];

        final excel = Excel.createExcel();
        final sheet = excel['Enquiries Report'];

        List<CellValue> headerRow = headers
            .map<CellValue>(
                (header) => TextCellValue(header['label'].toString()))
            .toList();
        sheet.appendRow(headerRow);

        for (var entry in body) {
          List<CellValue> row = headers.map<CellValue>((header) {
            String key = header['key'];
            var value = entry[key] ?? '';
            return TextCellValue(value.toString());
          }).toList();

          sheet.appendRow(row);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'enquiries_report_$timestamp.xlsx';

        String? filePath;

        if (Platform.isAndroid) {
          Directory? downloadsDir;
          try {
            downloadsDir = await getExternalStorageDirectory();
            final pathParts = downloadsDir!.path.split('/');
            final downloadPathParts =
                pathParts.sublist(0, pathParts.length - 4);
            downloadPathParts.add('Download');
            final downloadPath = downloadPathParts.join('/');

            final downloadDir = Directory(downloadPath);
            if (!await downloadDir.exists()) {
              await downloadDir.create(recursive: true);
            }

            filePath = '$downloadPath/$fileName';
          } catch (e) {
            log("Error accessing Downloads directory: $e");
            downloadsDir = await getExternalStorageDirectory();
            filePath = '${downloadsDir!.path}/$fileName';
          }
        } else if (Platform.isIOS) {
          final documentsDir = await getApplicationDocumentsDirectory();
          filePath = '${documentsDir.path}/$fileName';
        } else {
          throw PlatformException(
              code: 'UNSUPPORTED_PLATFORM',
              message: 'This platform is not supported');
        }

        List<int> bytes = excel.encode()!;
        File file = File(filePath);
        await file.writeAsBytes(bytes);

        loadingOverlay?.remove();

        snackbarService
            .showSnackBar('Enquiries report downloaded to Downloads folder');
        return filePath;
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Unknown error';
        log("Error ${response.statusCode}: $errorMessage");

        loadingOverlay?.remove();

        snackbarService.showSnackBar('Download Failed: $errorMessage');
        return null;
      }
    } catch (e) {
      log("Download error: $e");

      loadingOverlay?.remove();

      snackbarService.showSnackBar('Download Failed: ${e.toString()}');
      return null;
    }
  }

  OverlayEntry _createLoadingOverlay() {
    return OverlayEntry(
      builder: (context) => Container(
          color: Colors.black.withOpacity(0.5), child: LoadingAnimation()),
    );
  }
}

@riverpod
Future<List<EnquiriesModel>> getEnquiries(Ref ref) {
  return EnquiriesApiService.fetchEnquiries();
}
