import '../../data/remote/dtos/character_dto.dart';

enum CharacterStatus { alive, dead, unknown }

class Character {
  final int id;
  final String name;
  final CharacterStatus status;
  final String species;
  final String imageUrl;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.imageUrl,
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
    );
  }
}
