import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class CustomDropdown extends StatefulWidget {
  final List<DropdownItem> items;
  final String? selectedValue;
  final Function(String) onChanged;
  final String hint;
  final Color bgColor;
  final Color textColor;
  final Color hintColor;
  final Color borderColor;

  const CustomDropdown({
    Key? key,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.hint = 'Select an option',
    this.bgColor = const Color(0xFF101f22),
    this.textColor = Colors.white,
    this.hintColor = const Color(0xFF94a3b8),
    this.borderColor = const Color(0xFF334155),
  }) : super(key: key);

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String? _selectedValue;
  late bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  String _getSelectedLabel() {
    if (_selectedValue == null) return widget.hint;
    try {
      return widget.items
          .firstWhere((item) => item.value == _selectedValue)
          .label;
    } catch (e) {
      return widget.hint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getSelectedLabel(),
                  style: TextStyle(
                    color: _selectedValue != null
                        ? widget.textColor
                        : widget.hintColor,
                    fontSize: 14.sp,
                  ),
                ),
                Icon(
                  _isOpen ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
                  color: widget.hintColor,
                  size: 18.w,
                ),
              ],
            ),
          ),
        ),
        // Dropdown Menu
        if (_isOpen)
          Container(
            margin: EdgeInsets.only(top: 4.h),
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.borderColor),
            ),
            child: Column(
              children: widget.items.asMap().entries.map((entry) {
                int index = entry.key;
                DropdownItem item = entry.value;
                bool isLast = index == widget.items.length - 1;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedValue = item.value;
                          _isOpen = false;
                        });
                        widget.onChanged(item.value);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        color: _selectedValue == item.value
                            ? const Color(0xFF4A90E2).withOpacity(0.2)
                            : Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: TextStyle(
                                color: widget.textColor,
                                fontSize: 14.sp,
                                fontWeight: _selectedValue == item.value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (item.description != null &&
                                item.description!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  item.description!,
                                  style: TextStyle(
                                    color: widget.hintColor.withOpacity(0.7),
                                    fontSize: 12.sp,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        color: widget.borderColor.withOpacity(0.5),
                        height: 0,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class DropdownItem {
  final String label;
  final String value;
  final String? description;

  DropdownItem({required this.label, required this.value, this.description});
}
