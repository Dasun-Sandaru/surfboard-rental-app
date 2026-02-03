import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../controllers/settings_controller.dart';

class InventoryConfigView extends StatelessWidget {
  const InventoryConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AAppBar(
          showbackArrow: true,
          centerTitle: true,
          title: Text(
            "Inventory Config",
            style: TextStyle(color: colorScheme.onSurface, fontSize: 18.sp),
          ),
          bottom: TabBar(
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(text: "Brands"),
              Tab(text: "Board Types"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            /// 1. Brands Tab
            _buildListManager(
              context,
              items: controller.brands,
              onAdd: () => controller.addItem("Brand", controller.brands),
              onRemove: (item) =>
                  controller.removeItem(item, controller.brands),
            ),

            /// 2. Board Types Tab
            _buildListManager(context, items: controller.boardTypes),
          ],
        ),
      ),
    );
  }

  Widget _buildListManager(
    BuildContext context, {
    required RxList<dynamic> items,
    VoidCallback? onAdd,
    Function(dynamic)? onRemove,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Obx(
          () => ListView.separated(
            padding: EdgeInsets.all(ASizes.defaultPadding),
            itemCount: items.length,
            separatorBuilder: (c, i) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final item = items[index];
              final title = item is String
                  ? item
                  : (item as SurfBoardType).name;
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: onRemove != null
                      ? IconButton(
                          icon: Icon(
                            Iconsax.trash,
                            color: colorScheme.error,
                            size: 20.w,
                          ),
                          onPressed: () => onRemove(item),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        if (onAdd != null)
          Positioned(
            bottom: 24.h,
            right: 24.w,
            child: FloatingActionButton(
              onPressed: onAdd,
              backgroundColor: colorScheme.primary,
              child: Icon(Iconsax.add, color: colorScheme.onPrimary),
            ),
          ),
      ],
    );
  }
}