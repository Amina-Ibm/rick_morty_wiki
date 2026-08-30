import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      color: Colors.orange.shade800,
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      child: Text(
        'Offline — showing cached data',
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
