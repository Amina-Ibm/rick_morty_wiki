import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  final DateTime? cachedAt;

  const OfflineBanner({super.key, this.cachedAt});

  String _getTimeAgo() {
    if (cachedAt == null) return 'Offline — showing cached data';
    final diff = DateTime.now().difference(cachedAt!);
    if (diff.inMinutes < 1) return 'Offline — showing data from just now';
    if (diff.inHours < 1) return 'Offline — showing data from ${diff.inMinutes} minutes ago';
    if (diff.inDays < 1) return 'Offline — showing data from ${diff.inHours} hours ago';
    return 'Offline — showing data from ${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      color: Colors.orange.shade800,
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      child: Text(
        _getTimeAgo(),
        style: TextStyle(
          color: AppTheme.creamText,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
