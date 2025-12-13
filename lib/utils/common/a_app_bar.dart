import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../helper/a_device_utils.dart';

class AAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AAppBar({
    super.key,
    this.title,
    this.showbackArrow = false,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    this.bottom, // Add bottom widget
    required this.centerTitle,
    this.popupMenuItems, // Optional: Customizable menu items
    this.onPopupMenuSelected, // Optional: Handle menu item selection
  });

  final Widget? title;
  final bool showbackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final PreferredSizeWidget? bottom; // Add bottom as a property
  final bool centerTitle;

  // Optional parameters for PopupMenu
  final List<PopupMenuEntry>? popupMenuItems;
  final void Function(dynamic)? onPopupMenuSelected;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: showbackArrow
          ? IconButton(
              onPressed: () {
                Get.back(result: true);
              },
              icon: Icon(
                Iconsax.back_square,
                // color: isDark ? Colors.white : Colors.black,
                size: 25.w,
              ),
            )
          : leadingIcon != null
          ? IconButton(
              onPressed: leadingOnPressed,
              icon: Icon(
                leadingIcon,
                // color: isDark ? DColors.white : DColors.black,
                size: 25.w,
              ),
            )
          : null,
      title: title,
      actions: [
        ...?actions, // Include any custom actions passed in
        // Add PopupMenuButton if menu items are provided
        if (popupMenuItems != null)
          PopupMenuButton(
            onSelected: onPopupMenuSelected,
            itemBuilder: (context) => popupMenuItems!,
          ),
      ],
      bottom: bottom, // Use bottom widget if provided
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    ADeviceUtils.getAppbarHeight() + (bottom?.preferredSize.height ?? 0.0),
  );
}

//  popupMenuItems: [
//             PopupMenuItem(
//               value: 1,
//               child: Row(
//                 children: [
//                   Icon(Icons.settings),
//                   SizedBox(width: 10),
//                   Text('Settings'),
//                 ],
//               ),
//             ),
//             PopupMenuItem(
//               value: 2,
//               child: Row(
//                 children: [
//                   Icon(Icons.logout),
//                   SizedBox(width: 10),
//                   Text('Logout'),
//                 ],
//               ),
//             ),
//           ],
//           onPopupMenuSelected: (value) {
//             if (value == 1) {
//               // Handle Settings action
//               print('Settings clicked');
//             } else if (value == 2) {
//               // Handle Logout action
//               print('Logout clicked');
//             }
//           },
