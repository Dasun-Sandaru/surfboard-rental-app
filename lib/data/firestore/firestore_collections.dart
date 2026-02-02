class FirestoreCollections {
  static const shops = 'shops';
  static const users = 'users';

  // Sub-collections under shops
  static const boards = 'boards'; // or inventory?
  static const customers = 'customers';
  static const inventory = 'inventory';
  static const rentals = 'rentals';
  static const agreementTemplates = 'agreement_templates';
  static const payments = 'payments';
  static const activityLogs = 'activity_logs';
  static const damageReports = 'damage_reports';

  /// Sub-collection under inventory items (shops/{shopId}/inventory/{itemId}/damage_fees)
  static const damageFees = 'damage_fees';
  static const members = 'members';

  /// Sub-collection under damage_reports (shops/{shopId}/rentals/{rentalId}/damage_reports/{reportId}/photos)
  static const photos = 'photos';
}
