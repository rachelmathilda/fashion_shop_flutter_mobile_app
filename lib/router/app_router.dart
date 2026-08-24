import 'package:go_router/go_router.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/catalog/filter_screen.dart';
import '../screens/catalog/try_on_screen.dart';
import '../screens/bag/bag_screen.dart';
import '../screens/order/order_screen.dart';
import '../screens/order/shipping_screen.dart';
import '../screens/order/payment_screen.dart';
import '../screens/order/payment_success_screen.dart';
import '../screens/order/payment_fail_screen.dart';
import '../screens/order/transactions_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/language_screen.dart';
import '../screens/profile/address_detail_screen.dart';
import '../screens/profile/recovery_screen.dart';
import '../screens/profile/otp_screen.dart';
import '../screens/profile/reset_password_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../widgets/main_scaffold.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/recovery', builder: (_, __) => const RecoveryScreen()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (_, __) => const ResetPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/catalog', builder: (_, __) => const CatalogScreen()),
          GoRoute(path: '/bag', builder: (_, __) => const BagScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/filter', builder: (_, __) => const FilterScreen()),
      GoRoute(path: '/try-on', builder: (_, __) => const TryOnScreen()),
      GoRoute(path: '/order', builder: (_, __) => const OrderScreen()),
      GoRoute(path: '/shipping', builder: (_, __) => const ShippingScreen()),
      GoRoute(path: '/payment', builder: (_, __) => const PaymentScreen()),
      GoRoute(
        path: '/payment-success',
        builder: (_, __) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        path: '/payment-fail',
        builder: (_, __) => const PaymentFailScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (_, __) => const TransactionsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(path: '/language', builder: (_, __) => const LanguageScreen()),
      GoRoute(
        path: '/address-detail',
        builder: (_, __) => const AddressDetailScreen(),
      ),
      GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
    ],
  );
}
