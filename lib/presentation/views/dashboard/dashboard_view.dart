// lib/presentation/views/dashboard/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gesten/data/models/sale.dart';
import 'package:intl/intl.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/sale_controller.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final clientsAsync = ref.watch(clientsProvider);
    final usersAsync = ref.watch(usersProvider);
    final salesAsync = ref.watch(saleNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Produits',
                    value: productsAsync.when(
                      data: (products) => products.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Clients',
                    value: clientsAsync.when(
                      data: (clients) => clients.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    icon: Icons.people,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Utilisateurs',
                    value: usersAsync.when(
                      data: (users) => users.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    icon: Icons.person,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Ventes du jour',
                    value: salesAsync.when(
                      data: (sales) {
                        final today = DateTime.now();
                        final todaysSales = sales.where((s) =>
                          s.createdAt.year == today.year &&
                          s.createdAt.month == today.month &&
                          s.createdAt.day == today.day
                        ).length;
                        return todaysSales.toString();
                      },
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    icon: Icons.shopping_cart,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'CA d\'aujourd\'hui',
                    value: salesAsync.when(
                      data: (sales) {
                        final today = DateTime.now();
                        final todaysTotal = sales
                          .where((s) =>
                            s.createdAt.year == today.year &&
                            s.createdAt.month == today.month &&
                            s.createdAt.day == today.day
                          )
                          .fold<double>(0.0, (sum, s) => sum + s.montantTtc);
                        return '${todaysTotal.toStringAsFixed(2)} €';
                      },
                      loading: () => '...',
                      error: (_, __) => '0 €',
                    ),
                    icon: Icons.euro,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ventes sur les 7 derniers jours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: salesAsync.when(
                                data: (sales) => _SalesChart7Days(sales: sales),
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (_, __) => const Center(child: Text('Erreur')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alertes stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: productsAsync.when(
                                data: (products) {
                                  final lowStock = products.where((p) => p.stockActuel <= p.stockMin).toList();
                                  if (lowStock.isEmpty) {
                                    return const Center(child: Text('✅ Aucune alerte'));
                                  }
                                  return ListView.builder(
                                    itemCount: lowStock.length,
                                    itemBuilder: (context, index) {
                                      final product = lowStock[index];
                                      return ListTile(
                                        leading: const Icon(Icons.warning, color: Colors.orange),
                                        title: Text(product.nom, overflow: TextOverflow.ellipsis),
                                        subtitle: Text('Stock: ${product.stockActuel}'),
                                      );
                                    },
                                  );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (_, __) => const Center(child: Text('Erreur')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _SalesChart7Days extends StatelessWidget {
  final List<Sale> sales;

  const _SalesChart7Days({required this.sales});

  @override
  Widget build(BuildContext context) {
    // Calculer les ventes des 7 derniers jours
    final now = DateTime.now();
    final salesByDay = <DateTime, double>{};
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateTime(date.year, date.month, date.day);
      salesByDay[key] = 0.0;
    }

    for (final sale in sales) {
      final date = DateTime(sale.createdAt.year, sale.createdAt.month, sale.createdAt.day);
      if (salesByDay.containsKey(date)) {
        salesByDay[date] = salesByDay[date]! + sale.montantTtc;
      }
    }

    final entries = salesByDay.entries.toList();
    final spots = List.generate(entries.length, (i) {
      return FlSpot(i.toDouble(), entries[i].value);
    });

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= salesByDay.length) return const SizedBox();
                final date = salesByDay.keys.toList()[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()} €', style: const TextStyle(fontSize: 10));
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}