import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/resource.dart';

class LinkPreviewData {
  final String title;
  final String description;
  final String thumbnailUrl;
  final String source;
  final ResourceType type;

  const LinkPreviewData({
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.source,
    required this.type,
  });
}

class LinkPreviewService {
  static final LinkPreviewService _instance = LinkPreviewService._internal();
  factory LinkPreviewService() => _instance;
  LinkPreviewService._internal();

  Future<LinkPreviewData> fetchPreview(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(
        uri,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      ).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        String getMeta(String prop) {
          final el = document.querySelector('meta[property="$prop"]') ??
              document.querySelector('meta[name="$prop"]');
          return el?.attributes['content'] ?? '';
        }

        var title = getMeta('og:title');
        if (title.isEmpty) {
          title = document.querySelector('title')?.text ?? uri.host;
        }

        final desc = getMeta('og:description');
        final thumb = getMeta('og:image');

        return LinkPreviewData(
          title: title.trim(),
          description: desc.trim(),
          thumbnailUrl: thumb.trim(),
          source: ResourceModel.detectSource(url),
          type: ResourceModel.detectType(url),
        );
      }
    } catch (_) {}

    return LinkPreviewData(
      title: Uri.tryParse(url)?.host ?? url,
      description: '',
      thumbnailUrl: '',
      source: ResourceModel.detectSource(url),
      type: ResourceModel.detectType(url),
    );
  }
}

