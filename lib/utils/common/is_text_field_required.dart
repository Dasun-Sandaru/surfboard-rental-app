import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IsTextFieldRequired extends StatelessWidget {
  const IsTextFieldRequired({
    super.key,
    required this.fieldName,
    this.fieldNameStyle,
    this.isTextFieldRequired = true,
  });

  final String fieldName;
  final TextStyle? fieldNameStyle;
  final bool isTextFieldRequired; // Make this final

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: RichText(
        text: TextSpan(
          text: fieldName,
          style: fieldNameStyle ??
              Theme.of(context).textTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
          children: [
            if (isTextFieldRequired) // Conditionally show the asterisk
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
