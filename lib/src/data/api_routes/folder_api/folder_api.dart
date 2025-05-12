import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:itcc/src/data/globals.dart';
import 'package:itcc/src/data/models/folder_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folder_api.g.dart';


class FolderApiService {
  static final _baseUrl = Uri.parse('$baseUrl/folder');

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      };

  static Future<List<Folder>> getFolders({
    required String eventId,
    int? pageNo,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (pageNo != null) queryParams['pageNo'] = pageNo.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final url = Uri.parse('$baseUrl/folder/list/$eventId')
        .replace(queryParameters: queryParams);

    final response = await http.get(url, headers: _headers());
    final decoded = json.decode(response.body);

    if (response.statusCode == 200) {
      final List data = decoded['data'];
      return data.map((item) => Folder.fromJson(item)).toList();
    } else {
      throw Exception(decoded['message'] ?? 'Failed to fetch folders');
    }
  }

  static Future<Folder> getFiles({
    required String folderId,
    String? type,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;

    final url = Uri.parse('$baseUrl/folder/files/$folderId')
        .replace(queryParameters: queryParams);
    log('Requesting URL:$url');
    final response = await http.get(url, headers: _headers());
    final decoded = json.decode(response.body);

    if (response.statusCode == 200) {
      return Folder.fromJson(decoded['data']);
    } else {
      throw Exception(decoded['message'] ?? 'Failed to fetch files');
    }
  }

  static Future<Folder> addFilesToPublicFolder({
    required String eventId,
    required List<Map<String, dynamic>> files,
  }) async {
    final url = Uri.parse('$baseUrl/folder/user/file/add');
    final body = jsonEncode({
      'eventId': eventId,
      'files': files,
    });

    final response = await http.post(url, headers: _headers(), body: body);
    final decoded = json.decode(response.body);

    if (response.statusCode == 200) {
      return Folder.fromJson(decoded['data']);
    } else {
      throw Exception(decoded['message'] ?? 'Failed to add files');
    }
  }

  static Future<Folder> deleteFilesFromPublicFolder({
    required String eventId,
    required List<String> fileIds,
  }) async {
    final url = Uri.parse('$baseUrl/folder/user/file/delete');
    final body = jsonEncode({
      'eventId': eventId,
      'fileIds': fileIds,
    });

    final response = await http.post(url, headers: _headers(), body: body);
    final decoded = json.decode(response.body);

    if (response.statusCode == 200) {
      return Folder.fromJson(decoded['data']);
    } else {
      throw Exception(decoded['message'] ?? 'Failed to delete files');
    }
  }
}

@riverpod
Future<List<Folder>> getFolders(
  Ref ref, {
  required String eventId,
  int? pageNo,
  int? limit,
}) {
  return FolderApiService.getFolders(
    eventId: eventId,
    pageNo: pageNo,
    limit: limit,
  );
}

@riverpod
Future<Folder> getFiles(
  Ref ref, {
  required String folderId,
  String? type,
}) {
  return FolderApiService.getFiles(
    folderId: folderId,
    type: type,
  );
}
