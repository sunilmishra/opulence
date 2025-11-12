class EleganceDto {
  EleganceDto({required this.url});
  final String url;

  factory EleganceDto.fromJson(Map<String, dynamic> json) {
    return EleganceDto(url: json['url'] as String);
  }
}
