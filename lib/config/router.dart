// lib/config/router.dart
// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/views/auth/login_view.dart';
import '../presentation/views/dashboard/dashboard_view.dart';
import '../presentation/views/products/products_view.dart';
import '../presentation/views/clients/clients_view.dart';
import '../presentation/views/sales/sales_view.dart';
import '../presentation/views/pos/pos_view.dart';
import '../presentation/views/invoices/invoices_view.dart';
import '../presentation/views/admin/admin_view.dart';
import '../presentation/views/layout/main_layout.dart';
import '../presentation/controllers/auth_controller.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // Rediriger vers login si pas d'utilisateur connecté, sauf pour la page login
      final user = ref.read(currentUserProvider);
      final isLoggingIn = state.uri.path == '/login';
      
      if (user == null && !isLoggingIn) {
        return '/login';
      }
      
      if (user != null && isLoggingIn) {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardView(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductsView(),
          ),
          GoRoute(
            path: '/clients',
            builder: (context, state) => const ClientsView(),
          ),
          GoRoute(
            path: '/sales',
            builder: (context, state) => const SalesView(),
          ),
          GoRoute(
            path: '/pos',
            builder: (context, state) => const PosView(),
          ),
          GoRoute(
            path: '/invoices',
            builder: (context, state) => const InvoicesView(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminView(),
          ),
        ],
      ),
    ],
  );
});