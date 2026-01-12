import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../helper/a_device_utils.dart'; // Ensure this path is correct

class AAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AAppBar({
    super.key,
    this.title,
    this.showbackArrow = false,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    this.bottom,
    this.centerTitle = true,
    this.popupMenuItems,
    this.onPopupMenuSelected,
    this.backgroundColor,
  });

  final Widget? title;
  final bool showbackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final Color? backgroundColor;

  // Optional parameters for PopupMenu
  final List<PopupMenuEntry<dynamic>>? popupMenuItems;
  final void Function(dynamic)? onPopupMenuSelected;

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color cardDark = const Color(0xFF182c30);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Add padding to avoid elements touching the screen edges too closely
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 50.w, // Fix alignment issues
        centerTitle: centerTitle,
        elevation: 0,
        scrolledUnderElevation:
            0, // Prevents color change on scroll (Material 3)
        backgroundColor: backgroundColor ?? bgDark,
        surfaceTintColor: Colors.transparent, // Removes tint
        // -- 1. Leading Icon Logic --
        leading: showbackArrow
            ? IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Iconsax.arrow_left, size: 24.w, color: textWhite),
              )
            : leadingIcon != null
            ? IconButton(
                onPressed: leadingOnPressed,
                icon: Icon(leadingIcon, size: 24.w, color: textWhite),
              )
            : null,

        // -- 2. Title --
        title: title,

        // -- 3. Actions & Popup Menu --
        actions: [
          ...?actions, // Spread operator to include custom actions

          if (popupMenuItems != null)
            Theme(
              // Override theme to make Popup Menu Dark
              data: Theme.of(context).copyWith(
                cardColor: cardDark,
                iconTheme: IconThemeData(color: textWhite),
              ),
              child: PopupMenuButton(
                icon: Icon(Iconsax.more, color: textWhite),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: onPopupMenuSelected,
                itemBuilder: (context) => popupMenuItems!,
                // Style the text inside the popup
                // textStyle: TextStyle(
                //   color: textWhite,
                //   fontWeight: FontWeight.w500,
                // ),
              ),
            ),
        ],

        // -- 4. Bottom Widget (TabBar etc) --
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    ADeviceUtils.getAppbarHeight() + (bottom?.preferredSize.height ?? 0.0),
  );
}
