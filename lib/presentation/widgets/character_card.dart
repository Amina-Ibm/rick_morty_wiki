import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../domain/models/character.dart';
import '../theme/app_theme.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;
  final bool isFavourite;
  final VoidCallback onFavouriteToggle;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
    required this.isFavourite,
    required this.onFavouriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  character.imageUrl,
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 20.w,
                    height: 20.w,
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.creamText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${character.species} - ${character.status.name}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      character.gender,
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: isFavourite ? Colors.redAccent : Colors.white54,
                  size: 24.sp,
                ),
                onPressed: onFavouriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
