import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'orders.dart';
import 'manage_books.dart';
import 'admin_profile.dart';
import 'manage_orders.dart';
import 'user_admin.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer Menu
      drawer: Drawer(
        child: Container(
          color: const Color.fromARGB(255, 253, 253, 253),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Color.fromARGB(255, 79, 6, 92)),
                title: const Text('Home'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.menu_book, color: Color(0xFF4B0857)),
                title: const Text('Books'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageBooks()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long, color: Color(0xFF4B0857)),
                title: const Text('Orders'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.group, color: Color(0xFF4B0857)),
                title: const Text('Users'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.account_circle, color: Color(0xFF4B0857), size: 28),
                title: const Text('Profile'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
                ),
              ),
            ],
          ),
        ),
      ),

      // AppBar
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Book Hive',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
            ),
          ),
        ],
      ),

      // Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E24AA), Color(0xFFBA68C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome Back, Admin 👋',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Here’s an overview of your store performance today.',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Quick Stats
            const Text('Quick Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 12),

            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('books').snapshots(),
              builder: (context, bookSnapshot) {
                int bookCount = bookSnapshot.hasData ? bookSnapshot.data!.docs.length : 0;

                return StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                  builder: (context, orderSnapshot) {
                    int orderCount = orderSnapshot.hasData ? orderSnapshot.data!.docs.length : 0;
                    double totalRevenue = 0;

                    Map<String, double> revenuePerDay = {};
                    Map<String, int> ordersPerDay = {};

                    if (orderSnapshot.hasData) {
                      for (var doc in orderSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        var total = data['totalPrice'] ?? 0;
                        if (total is int) totalRevenue += total.toDouble();
                        else if (total is double) totalRevenue += total;
                        else if (total is String) totalRevenue += double.tryParse(total) ?? 0;

                        // Daily stats
                        final timestamp = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                        final dayKey = "${timestamp.month}/${timestamp.day}";
                        revenuePerDay[dayKey] = (revenuePerDay[dayKey] ?? 0) + (total is num ? total.toDouble() : 0);
                        ordersPerDay[dayKey] = (ordersPerDay[dayKey] ?? 0) + 1;
                      }
                    }

                    return StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('users').snapshots(),
                      builder: (context, userSnapshot) {
                        int userCount = userSnapshot.hasData ? userSnapshot.data!.docs.length : 0;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _statCard(Icons.book, 'Total Books', bookCount.toString()),
                                _statCard(Icons.shopping_cart, 'Orders', orderCount.toString()),
                                _statCard(Icons.people, 'Users', userCount.toString()),
                                _statCard(Icons.attach_money, 'Revenue', '\$${totalRevenue.toStringAsFixed(2)}'),
                              ],
                            ),
                            const SizedBox(height: 25),
                              // Chart Heading
const Text(
  'Revenue & Daily Orders Trends',
  style: TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
),
                            // Combined Chart
                            _buildCombinedChart(revenuePerDay, ordersPerDay),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 25),

            // Quick Actions
            const Text('Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 10),

            _actionButton(Icons.book_outlined, 'Manage Books', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageBooks()));
            }),
            _actionButton(Icons.shopping_bag_outlined, 'View Orders', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderManagementScreen()));
            }),
            _actionButton(Icons.supervisor_account_outlined, 'Manage Users', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.purple[700], size: 30),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCombinedChart(Map<String, double> revenue, Map<String, int> orders) {
    if (revenue.isEmpty || orders.isEmpty) return const Text('No data for chart');

    List<FlSpot> revenueSpots = [];
    List<FlSpot> orderSpots = [];
    List<String> days = revenue.keys.toList();

    for (int i = 0; i < days.length; i++) {
      revenueSpots.add(FlSpot(i.toDouble(), revenue[days[i]]!));
      orderSpots.add(FlSpot(i.toDouble(), orders[days[i]]!.toDouble()));
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: revenueSpots,
              isCurved: true,
              color: Colors.deepPurple,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withOpacity(0.2)),
            ),
            LineChartBarData(
              spots: orderSpots,
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.2)),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Text(days[index], style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(6),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((t) {
                  final day = days[t.x.toInt()];
                  final value = t.barIndex == 0
                      ? '\$${t.y.toStringAsFixed(2)}'
                      : t.y.toInt().toString();
                  final label = t.barIndex == 0 ? 'Revenue' : 'Orders';
                  return LineTooltipItem('$day\n$label: $value',
                      const TextStyle(color: Colors.white));
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
