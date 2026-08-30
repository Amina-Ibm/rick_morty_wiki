import 'package:rick_morty_wiki/data/remote/dtos/origin_dto.dart';

class CharacterDto {
  final int id;
  final String name;
  final String status;
  final String species;
  final String image;
  final String gender;
  final OriginDto origin;
  final String location;

  CharacterDto({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.image,
    required this.gender,
    required this.origin,
    required this.location,
  });

  factory CharacterDto.fromJson(Map<String, dynamic> json) {
    return CharacterDto(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      image: json['image'] as String,
      gender: json['gender'] ?? '',
      origin: OriginDto.fromJson(json['origin'] as Map<String, dynamic>),
      location: json['location']['name'] as String,
    );
  }
}
