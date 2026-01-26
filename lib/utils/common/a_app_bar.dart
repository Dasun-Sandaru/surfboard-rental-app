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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        backgroundColor: backgroundColor ?? colorScheme.surface,
        surfaceTintColor: Colors.transparent, // Removes tint
        iconTheme: IconThemeData(color: colorScheme.onSurface),

        // -- 1. Leading Icon Logic --
        leading: showbackArrow
            ? IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Iconsax.arrow_left,
                  size: 24.w,
                  color: colorScheme.onSurface,
                ),
              )
            : leadingIcon != null
            ? IconButton(
                onPressed: leadingOnPressed,
                icon: Icon(
                  leadingIcon,
                  size: 24.w,
                  color: colorScheme.onSurface,
                ),
              )
            : null,

        // -- 2. Title --
        title: title,

        // -- 3. Actions & Popup Menu --
        actions: [
          ...?actions, // Spread operator to include custom actions

          if (popupMenuItems != null)
            Theme(
              // Override theme for Popup Menu
              data: Theme.of(context).copyWith(
                colorScheme: colorScheme.copyWith(
                  surface: colorScheme.surfaceContainer,
                  onSurface: colorScheme.onSurface,
                ),
              ),
              child: PopupMenuButton(
                icon: Icon(Iconsax.more, color: colorScheme.onSurface),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: onPopupMenuSelected,
                itemBuilder: (context) => popupMenuItems!,
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
