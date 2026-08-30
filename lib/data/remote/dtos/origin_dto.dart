class OriginDto {
  final String name;
  final String url;

  OriginDto({required this.name, required this.url});

  factory OriginDto.fromJson(Map<String, dynamic> json) {
    return OriginDto(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? 'N/A',
    );
  }
}
