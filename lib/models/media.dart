class Media {
  final String id;
  final String title;
  final String image;
  final String music;

  Media({
    required this.id,
    required this.title,
    required this.image,
    required this.music,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['_id'],
      title: json['title'],
      image: json['image'],
      music: json['music'],
    );
  }
}