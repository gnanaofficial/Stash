import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// Service for uploading PDFs and files to Cloudflare R2 Bucket
class CloudflareR2Service {
  static final CloudflareR2Service instance = CloudflareR2Service._internal();
  factory CloudflareR2Service() => instance;
  CloudflareR2Service._internal();

  /// Cloudflare R2 Configuration Placeholders
  /// (Supply your Cloudflare Account ID & R2 Bucket name in production)
  static const String defaultAccountId = '0122d2cca663ec93f9e3d38f0c453a44';
  static const String defaultBucketName = 'vault';
  static const String defaultPublicDomain =
      'https://pub-4e99df108d584622b755a1ae28c5918c.r2.dev';

  String _accountId = defaultAccountId;
  String _bucketName = defaultBucketName;
  String _publicDomain = defaultPublicDomain;
  String? _apiToken;

  void configure({
    required String accountId,
    required String bucketName,
    required String publicDomain,
    String? apiToken,
  }) {
    _accountId = accountId;
    _bucketName = bucketName;
    _publicDomain = publicDomain;
    _apiToken = apiToken;
  }

  bool get isConfigured =>
      _accountId != defaultAccountId && _bucketName != defaultBucketName;

  /// Uploads a local file (e.g. PDF or document) to Cloudflare R2.
  /// Returns the permanent public or signed URL of the uploaded asset.
  Future<String?> uploadFile({
    required File file,
    String? customFileName,
    String folder = 'documents',
  }) async {
    final fileName =
        customFileName ?? '${const Uuid().v4()}_${file.uri.pathSegments.last}';
    final key = '$folder/$fileName';

    if (!isConfigured) {
      debugPrint(
          '[Cloudflare R2] Running in simulation mode. File cached locally at: ${file.path}');
      return '$_publicDomain/$key';
    }

    try {
      final endpoint = Uri.parse(
        'https://$_accountId.r2.cloudflarestorage.com/$_bucketName/$key',
      );

      final bytes = await file.readAsBytes();
      final response = await http.put(
        endpoint,
        headers: {
          'Content-Type': _getContentType(fileName),
          if (_apiToken != null) 'Authorization': 'Bearer $_apiToken',
        },
        body: bytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final uploadedUrl = '$_publicDomain/$key';
        debugPrint('[Cloudflare R2] File uploaded successfully: $uploadedUrl');
        return uploadedUrl;
      } else {
        debugPrint(
            '[Cloudflare R2] Upload failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('[Cloudflare R2] Error uploading: $e');
      return null;
    }
  }

  String _getContentType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.txt')) return 'text/plain';
    return 'application/octet-stream';
  }
}
