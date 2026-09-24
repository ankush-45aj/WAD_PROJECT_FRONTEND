import 'media.dart';

class MediaResponse {
  final List<String> process;
  final List<Media> data;

  MediaResponse({
    required this.process,
    required this.data,
  });

  factory MediaResponse.fromJson(Map<String, dynamic> json) {
    return MediaResponse(
      process: List<String>.from(
        json['process'] ?? [],
      ),

      data: (json['data'] as List)
          .map(
            (item) => Media.fromJson(item),
      )
          .toList(),
    );
  }
}