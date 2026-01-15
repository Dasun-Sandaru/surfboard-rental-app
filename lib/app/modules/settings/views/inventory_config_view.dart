import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../controllers/settings_controller.dart';

class InventoryConfigView extends StatelessWidget {
  const InventoryConfigView({super.key});

  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgDark,
        appBar: AAppBar(
          showbackArrow: true,
          centerTitle: true,
          title: Text("Inventory Config", style: TextStyle(color: textWhite, fontSize: 18.sp)),
          bottom: TabBar(
            indicatorColor: primaryBlue,
            labelColor: primaryBlue,
            unselectedLabelColor: textGrey,
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
              items: controller.brands, 
              onAdd: () => controller.addItem("Brand", controller.brands),
              onRemove: (item) => controller.removeItem(item, controller.brands),
            ),

            /// 2. Board Types Tab
            _buildListManager(
              items: controller.boardTypes, 
              onAdd: () => controller.addItem("Board Type", controller.boardTypes),
              onRemove: (item) => controller.removeItem(item, controller.boardTypes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListManager({
    required RxList<String> items,
    required VoidCallback onAdd,
    required Function(String) onRemove,
  }) {
    return Stack(
      children: [
        Obx(() => ListView.separated(
          padding: EdgeInsets.all(ASizes.defaultPadding),
          itemCount: items.length,
          separatorBuilder: (c, i) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderDark),
              ),
              child: ListTile(
                title: Text(item, style: TextStyle(color: textWhite, fontWeight: FontWeight.w500)),
                trailing: IconButton(
                  icon: Icon(Iconsax.trash, color: Colors.redAccent, size: 20.w),
                  onPressed: () => onRemove(item),
                ),
              ),
            );
          },
        )),
        
        Positioned(
          bottom: 24.h,
          right: 24.w,
          child: FloatingActionButton(
            onPressed: onAdd,
            backgroundColor: primaryBlue,
            child: const Icon(Iconsax.add, color: Colors.white),
          ),
        )
      ],
    );
  }
}