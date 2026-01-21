import 'package:flutter/material.dart';
import '../../utils/constants/a_enums.dart';
import 'customer_model.dart';
import 'inventory_model.dart';

class InitRentalModel {
  final CustomerModel customer;
  final List<InventoryModel> items;
  final DateTime startDate;
  final TimeOfDay startTime;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final RentType rentType;
  final double? estimatedTotal;

  InitRentalModel({
    required this.customer,
    required this.items,
    required this.startDate,
    required this.startTime,
    required this.dueDate,
    required this.dueTime,
    required this.rentType,
    this.estimatedTotal,
  });

  /// Convert to Map for passing via arguments
  Map<String, dynamic> toMap() {
    return {
      'customer': customer.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'startDate': startDate,
      'startTime': startTime,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'rentType': rentType.name,
      'estimatedTotal': estimatedTotal,
    };
  }

  /// Reconstruct from Map
  factory InitRentalModel.fromMap(Map<String, dynamic> data) {
    return InitRentalModel(
      customer: CustomerModel.fromJson(
        data['customer'] as Map<String, dynamic>,
      ),
      items: (data['items'] as List<dynamic>)
          .map((item) => InventoryModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      startDate: data['startDate'] as DateTime,
      startTime: data['startTime'] as TimeOfDay,
      dueDate: data['dueDate'] as DateTime,
      dueTime: data['dueTime'] as TimeOfDay,
      rentType: enumFromString(
        RentType.values,
        data['rentType'],
        RentType.hourly,
      ),
      estimatedTotal: data['estimatedTotal'] as double?,
    );
  }

  /// Format dates and times for display
  String get startDateTimeString =>
      "${startDate.day}/${startDate.month}/${startDate.year} ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";

  String get dueDateTimeString =>
      "${dueDate.day}/${dueDate.month}/${dueDate.year} ${dueTime.hour.toString().padLeft(2, '0')}:${dueTime.minute.toString().padLeft(2, '0')}";

  /// Calculate rental duration in hours
  int get rentalDurationHours {
    final startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );
    final dueDateTime = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueTime.hour,
      dueTime.minute,
    );
    return dueDateTime.difference(startDateTime).inHours;
  }

  /// Calculate rental duration in days
  double get rentalDurationDays => rentalDurationHours / 24;
}
