import 'package:get/get.dart';

import '../../utils/constants/a_enums.dart';
import '../middleware/access_control_middleware.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/maintenance_middleware.dart';
import '../middleware/onboarding_middleware.dart';
import '../middleware/role_middleware.dart';
import '../modules/addEditCustomer/bindings/add_edit_customer_binding.dart';
import '../modules/addEditCustomer/views/add_edit_customer_view.dart';
import '../modules/billing/bindings/billing_binding.dart';
import '../modules/billing/views/billing_view.dart';
import '../modules/addInventory/bindings/add_inventory_binding.dart';
import '../modules/addInventory/views/add_inventory_view.dart';
import '../modules/adminHome/bindings/admin_home_binding.dart';
import '../modules/adminHome/views/admin_home_view.dart';
import '../modules/analytics/bindings/analytics_binding.dart';
import '../modules/analytics/views/analytics_view.dart';
import '../modules/agreement/bindings/agreement_binding.dart';
import '../modules/agreement/views/agreement_wizard_view.dart';
import '../modules/agreementTemplate/bindings/agreement_template_binding.dart';
import '../modules/agreementTemplate/views/agreement_template_view.dart';
import '../modules/alerts/bindings/alerts_binding.dart';
import '../modules/alerts/views/alerts_view.dart';
import '../modules/auth/bindings/forgot_password_binding.dart';
import '../modules/auth/bindings/verify_email_binding.dart';
import '../modules/auth/view/forgot_password_view.dart';
import '../modules/auth/view/verify_email_screen.dart';
import '../modules/authGate/bindings/auth_gate_binding.dart';
import '../modules/authGate/views/auth_gate_view.dart';
import '../modules/boardInspection/bindings/board_inspection_binding.dart';
import '../modules/boardInspection/views/board_inspection_view.dart';
import '../modules/customerDetails/bindings/customer_details_binding.dart';
import '../modules/customerDetails/views/customer_details_view.dart';
import '../modules/customerList/bindings/customer_list_binding.dart';
import '../modules/customerList/views/customer_list_view.dart';
import '../modules/damageFee/bindings/damage_fee_binding.dart';
import '../modules/damageFee/views/damage_fee_view.dart';
import '../modules/damageReport/bindings/damage_report_binding.dart';
import '../modules/damageReport/views/damage_report_view.dart';
import '../modules/damagesPending/bindings/damages_pending_binding.dart';
import '../modules/damagesPending/views/damages_pending_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/inventory/bindings/available_inventory_binding.dart';
import '../modules/inventory/bindings/inventory_binding.dart';
import '../modules/inventory/views/available_inventory_view.dart';
import '../modules/inventory/views/inventory_view.dart';
import '../modules/itemDetails/bindings/item_details_binding.dart';
import '../modules/itemDetails/views/item_details_view.dart';
import '../modules/maintenance/bindings/maintenance_binding.dart';
import '../modules/maintenance/views/maintenance_view.dart';
import '../modules/manageUsers/bindings/manage_users_binding.dart';
import '../modules/manageUsers/views/manage_users_view.dart';
import '../modules/newRental/bindings/new_rental_binding.dart';
import '../modules/newRental/views/new_rental_view.dart';
import '../modules/onboard/bindings/onboard_binding.dart';
import '../modules/onboard/views/onboard_view.dart';
import '../modules/qrScanner/bindings/qr_scanner_binding.dart';
import '../modules/qrScanner/views/qr_scanner_view.dart';
import '../modules/rentalDetail/bindings/rental_detail_binding.dart';
import '../modules/rentalDetail/views/rental_detail_view.dart';
import '../modules/rentalHistory/bindings/rental_history_binding.dart';
import '../modules/rentalHistory/views/rental_history_view.dart';
import '../modules/scheduledNotifications/bindings/scheduled_notifications_binding.dart';
import '../modules/scheduledNotifications/views/scheduled_notifications_view.dart';
import '../modules/rentalPayments/bindings/rental_payment_binding.dart';
import '../modules/rentalPayments/views/rental_payment_view.dart';
import '../modules/rentals/bindings/rentals_binding.dart';
import '../modules/rentals/views/rentals_view.dart';
import '../modules/reports/bindings/reports_binding.dart';
import '../modules/reports/views/reports_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/rental_config_view.dart';
import '../modules/settings/views/rental_pricing_logic_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/shopSetup/bindings/shop_setup_binding.dart';
import '../modules/shopSetup/views/shop_setup_view.dart';
import '../modules/signIn/bindings/sign_in_binding.dart';
import '../modules/signIn/views/sign_in_view.dart';
import '../modules/signUp/bindings/sign_up_binding.dart';
import '../modules/signUp/views/sign_up_view.dart';
import '../modules/signature/bindings/signature_binding.dart';
import '../modules/signature/views/signature_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/staffHome/bindings/staff_home_binding.dart';
import '../modules/staffHome/views/staff_home_view.dart';
import '../modules/userDetail/bindings/user_detail_binding.dart';
import '../modules/userDetail/views/user_detail_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

// Middlewares

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      middlewares: [MaintenanceMiddleware()],
    ),
    GetPage(
      name: _Paths.ONBOARD,
      page: () => const OnboardView(),
      binding: OnboardBinding(),
    ),
    GetPage(
      name: _Paths.SHOP_SETUP,
      page: () => const ShopSetupView(),
      binding: ShopSetupBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'shop_setup')],
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_IN,
      page: () => const SignInView(),
      binding: SignInBinding(),
      middlewares: [MaintenanceMiddleware(), OnboardingMiddleware()],
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_HOME,
      page: () => const AdminHomeView(),
      binding: AdminHomeBinding(),
      middlewares: [
        MaintenanceMiddleware(),
        OnboardingMiddleware(),
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: [UserRole.admin]),
      ],
    ),
    GetPage(
      name: _Paths.STAFF_HOME,
      page: () => const StaffHomeView(),
      binding: StaffHomeBinding(),
      middlewares: [
        MaintenanceMiddleware(),
        OnboardingMiddleware(),
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: [UserRole.staff, UserRole.admin]),
      ],
    ),
    GetPage(
      name: _Paths.VERIFY_EMAIL,
      page: () => const VerifyEmailScreen(),
      binding: VerifyEmailBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_GATE,
      page: () => const AuthGateView(),
      binding: AuthGateBinding(),
    ),
    GetPage(
      name: _Paths.NEW_RENTAL,
      page: () => const NewRentalView(),
      binding: NewRentalBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'new_rental')],
    ),
    GetPage(
      name: _Paths.ALERTS,
      page: () => const AlertsView(),
      binding: AlertsBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'alerts')],
    ),
    GetPage(
      name: _Paths.MANAGE_USERS,
      page: () => const ManageUsersView(),
      binding: ManageUsersBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'manage_users')],
    ),
    GetPage(
      name: _Paths.USER_DETAIL,
      page: () => const UserDetailView(),
      binding: UserDetailBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'manage_users')],
    ),
    GetPage(
      name: _Paths.INVENTORY,
      page: () => InventoryListView(),
      binding: InventoryBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'inventory_view')],
    ),
    GetPage(
      name: _Paths.AVAILABLE_INVENTORY,
      page: () => const AvailableInventoryView(),
      binding: AvailableInventoryBinding(),
      middlewares: [
        AccessControlMiddleware(routeKey: 'inventory_view'),
      ], // Using same permission as inventory
    ),
    GetPage(
      name: _Paths.ADD_INVENTORY,
      page: () => const AddInventoryView(),
      binding: AddInventoryBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'inventory_add')],
    ),
    GetPage(
      name: _Paths.DAMAGES_PENDING,
      page: () => const DamagesPendingView(),
      binding: DamagesPendingBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'rentals')],
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [
        MaintenanceMiddleware(),
        OnboardingMiddleware(),
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.ITEM_DETAILS,
      page: () => ItemDetailsView(),
      binding: ItemDetailsBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'inventory_view')],
    ),
    GetPage(
      name: _Paths.CUSTOMER_LIST,
      page: () => CustomerListView(),
      binding: CustomerListBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'customers_view')],
    ),
    GetPage(
      name: _Paths.ADD_EDIT_CUSTOMER,
      page: () => const AddEditCustomerView(),
      binding: AddEditCustomerBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'customers_add')],
    ),
    GetPage(
      name: _Paths.CUSTOMER_DETAILS,
      page: () => CustomerDetailsView(),
      binding: CustomerDetailsBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'customers_view')],
    ),
    GetPage(
      name: _Paths.DAMAGE_FEE,
      page: () => DamageFeeView(),
      binding: DamageFeeBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'inventory_view_damage_fees')],
    ),
    GetPage(
      name: _Paths.AGREEMENT_WIZARD,
      // page: () => const AgreementView(),
      page: () => const AgreementWizardView(),
      binding: AgreementBinding(),
    ),
    GetPage(
      name: _Paths.SIGNATURE,
      page: () => const SignaturePadView(),
      binding: SignatureBinding(),
    ),
    GetPage(
      name: _Paths.AGREEMENT_TEMPLATE,
      page: () => const AgreementTemplateListView(),
      binding: AgreementTemplateBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'agreement_template')],
    ),
    GetPage(
      name: _Paths.RENTALS,
      page: () => const RentalsView(),
      binding: RentalsBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'rentals')],
    ),
    GetPage(
      name: _Paths.RENTAL_DETAIL,
      page: () => const RentalDetailView(),
      binding: RentalDetailBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'rentals')],
    ),
    GetPage(
      name: _Paths.BOARD_INSPECTION,
      page: () => const BoardInspectionView(),
      binding: BoardInspectionBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENTS,
      page: () => const RentalPaymentView(),
      binding: RentalPaymentBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'payments')],
    ),
    GetPage(
      name: _Paths.DAMAGE_REPORT,
      page: () => const DamageReportView(),
      binding: DamageReportBinding(),
    ),
    GetPage(
      name: _Paths.MAINTENANCE,
      page: () => const MaintenanceView(),
      binding: MaintenanceBinding(),
    ),
    GetPage(
      name: _Paths.QR_SCANNER,
      page: () => const QrScannerView(),
      binding: QrScannerBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'qr_scanner')],
    ),
    GetPage(
      name: _Paths.RENTAL_HISTORY,
      page: () => const RentalHistoryView(),
      binding: RentalHistoryBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'rental_history')],
    ),
    GetPage(
      name: _Paths.RENTAL_PRICING_LOGIC,
      page: () => const RentalPricingLogicView(),
      binding: SettingsBinding(), // Re-use SettingsBinding
    ),
    GetPage(
      name: _Paths.RENTAL_CONFIG,
      page: () => const RentalConfigView(),
      binding: SettingsBinding(), // Re-use SettingsBinding
      middlewares: [
        AccessControlMiddleware(routeKey: 'settings_edit_rental_logic'),
      ],
    ),
    GetPage(
      name: _Paths.REPORTS,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'reports')],
    ),
    GetPage(
      name: _Paths.ANALYTICS,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
      middlewares: [
        AccessControlMiddleware(
          routeKey: 'reports',
        ), // Same permission key as reports
      ],
    ),
    GetPage(
      name: _Paths.SCHEDULED_NOTIFICATIONS,
      page: () => const ScheduledNotificationsView(),
      binding: ScheduledNotificationsBinding(),
      middlewares: [AccessControlMiddleware(routeKey: 'alerts')],
    ),
    GetPage(
      name: _Paths.BILLING,
      page: () => const BillingView(),
      binding: BillingBinding(),
      middlewares: [
        AccessControlMiddleware(
          routeKey: 'shop_setup',
        ), // Reuse shop_setup for Admin-only access
      ],
    ),
  ];
}
