import 'package:get/get.dart';

import '../modules/addEditCustomer/bindings/add_edit_customer_binding.dart';
import '../modules/addEditCustomer/views/add_edit_customer_view.dart';
import '../modules/addInventory/bindings/add_inventory_binding.dart';
import '../modules/addInventory/views/add_inventory_view.dart';
import '../modules/adminHome/bindings/admin_home_binding.dart';
import '../modules/adminHome/views/admin_home_view.dart';
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
import '../modules/customerDetails/bindings/customer_details_binding.dart';
import '../modules/customerDetails/views/customer_details_view.dart';
import '../modules/customerList/bindings/customer_list_binding.dart';
import '../modules/customerList/views/customer_list_view.dart';
import '../modules/damageFee/bindings/damage_fee_binding.dart';
import '../modules/damageFee/views/damage_fee_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/inventory/bindings/inventory_binding.dart';
import '../modules/inventory/views/inventory_view.dart';
import '../modules/itemDetails/bindings/item_details_binding.dart';
import '../modules/itemDetails/views/item_details_view.dart';
import '../modules/manageUsers/bindings/manage_users_binding.dart';
import '../modules/manageUsers/views/manage_users_view.dart';
import '../modules/newRental/bindings/new_rental_binding.dart';
import '../modules/newRental/views/new_rental_view.dart';
import '../modules/onboard/bindings/onboard_binding.dart';
import '../modules/onboard/views/onboard_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
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

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
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
    ),
    GetPage(
      name: _Paths.STAFF_HOME,
      page: () => const StaffHomeView(),
      binding: StaffHomeBinding(),
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
    ),
    GetPage(
      name: _Paths.ALERTS,
      page: () => const AlertsView(),
      binding: AlertsBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_USERS,
      page: () => const ManageUsersView(),
      binding: ManageUsersBinding(),
    ),
    GetPage(
      name: _Paths.USER_DETAIL,
      page: () => const UserDetailView(),
      binding: UserDetailBinding(),
    ),
    GetPage(
      name: _Paths.INVENTORY,
      page: () => const InventoryListView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: _Paths.ADD_INVENTORY,
      page: () => const AddInventoryView(),
      binding: AddInventoryBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.ITEM_DETAILS,
      page: () => const ItemDetailsView(),
      binding: ItemDetailsBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMER_LIST,
      page: () => const CustomerListView(),
      binding: CustomerListBinding(),
    ),
    GetPage(
      name: _Paths.ADD_EDIT_CUSTOMER,
      page: () => const AddEditCustomerView(),
      binding: AddEditCustomerBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMER_DETAILS,
      page: () => const CustomerDetailsView(),
      binding: CustomerDetailsBinding(),
    ),
    GetPage(
      name: _Paths.DAMAGE_FEE,
      page: () => const DamageFeeView(),
      binding: DamageFeeBinding(),
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
    ),
  ];
}
