import '../../data/remote/dtos/character_dto.dart';
import 'origin.dart';

enum CharacterStatus { alive, dead, unknown }

class Character {
  final int id;
  final String name;
  final CharacterStatus status;
  final String species;
  final String imageUrl;
  final String gender;
  final Origin origin;
  final String location;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.imageUrl,
    required this.gender,
    required this.origin,
    required this.location,
  });

  factory Character.fromDto(CharacterDto dto) {
    CharacterStatus parsedStatus;
    switch (dto.status.toLowerCase()) {
      case 'alive':
        parsedStatus = CharacterStatus.alive;
        break;
      case 'dead':
        parsedStatus = CharacterStatus.dead;
        break;
      default:
        parsedStatus = CharacterStatus.unknown;
    }

    return Character(
      id: dto.id,
      name: dto.name,
      status: parsedStatus,
      species: dto.species,
      imageUrl: dto.image,
      gender: dto.gender,
      origin: Origin(name: dto.origin.name, url: dto.origin.url),
      location: dto.location,
    );
  }
}
