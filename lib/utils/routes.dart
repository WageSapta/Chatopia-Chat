import 'package:chatopia/pages/account_page.dart';
import 'package:chatopia/pages/activity_pages.dart';
import 'package:chatopia/pages/auth_page.dart';
import 'package:chatopia/pages/chats_page.dart';
import 'package:chatopia/pages/error_page.dart';
import 'package:chatopia/pages/forgot_password_page.dart';
import 'package:chatopia/pages/friends_page.dart';
import 'package:chatopia/pages/messages_page.dart';
import 'package:chatopia/pages/splash_page.dart';
import 'package:flutter/material.dart';

mixin Routes {
  // default
  static const String splash = '/';
  // auth
  static const String auth = '/auth';
  static const String reset = '/reset';
  // main
  static const String chats = '/chats';
  static const String messages = '/messages';
  // drawer
  static const String account = '/account';
  static const String friends = '/friends';
  static const String activity = '/activity';

  static Map<String, Widget Function(BuildContext)> get routes {
    return {
      splash: (_) => const SplashPage(),
      auth: (_) => const AuthPage(),
      reset: (_) => const ForgotPasswordPage(),
      chats: (_) => const ChatsPage(),
      messages: (_) => const MessagesPage(),
      account: (_) => const AccountPage(),
      friends: (_) => const FriendsPage(),
      activity: (_) => const ActivityPage(),
    };
  }

  static MaterialPageRoute onGenerateRoute(RouteSettings settings) {
    final String routeName = settings.name!;
    final Widget Function(BuildContext)? builder = routes[routeName];

    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }

    // Add any fallback or error handling logic here.
    // For example, you could navigate to an error page or return the HomeScreen.
    return MaterialPageRoute(
      builder: (_) => const ErrorPage(),
      settings: settings,
    );
  }
}
