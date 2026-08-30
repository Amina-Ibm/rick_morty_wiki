class CharacterDto {
  final int id;
  final String name;
  final String status;
  final String species;
  final String image;

  CharacterDto({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.image,
  });

  factory CharacterDto.fromJson(Map<String, dynamic> json) {
    return CharacterDto(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      image: json['image'] as String,
    );
  }
}
