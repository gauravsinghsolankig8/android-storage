import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../core/app_config.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  
  // Mock admin data - in real app, this would come from backend
  final Map<String, dynamic> _dashboardData = {
    'totalUsers': 15420,
    'activeUsers': 8765,
    'totalRevenue': 245680.50,
    'monthlyRevenue': 45230.25,
    'totalChats': 892341,
    'premiumUsers': 3456,
    'averageSessionTime': '24m 33s',
    'retentionRate': 78.5,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EchoBuddy Admin'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshDashboard(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Admin Profile'),
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('System Settings'),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              
              // Key Metrics Row
              _buildKeyMetrics(),
              const SizedBox(height: 24),
              
              // Charts and Analytics
              _buildAnalyticsSection(),
              const SizedBox(height: 24),
              
              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 24),
              
              // Recent Activity
              _buildRecentActivity(),
              const SizedBox(height: 24),
              
              // System Status
              _buildSystemStatus(),
            ],
          ),
        ),
      ),
      drawer: _buildAdminDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/admin/users'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.people),
        label: const Text('Manage Users'),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back, Admin!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'EchoBuddy Dashboard - ${DateTime.now().toString().split(' ')[0]}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickStat('Online Users', '${_dashboardData['activeUsers']}'),
              const SizedBox(width: 24),
              _buildQuickStat('Revenue Today', '₹${(_dashboardData['monthlyRevenue'] / 30).toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMetricCard(
          'Total Users',
          '${_dashboardData['totalUsers']}',
          Icons.people,
          Colors.blue,
          '+12%',
        ),
        _buildMetricCard(
          'Monthly Revenue',
          '₹${_dashboardData['monthlyRevenue']}',
          Icons.monetization_on,
          Colors.green,
          '+8.5%',
        ),
        _buildMetricCard(
          'Total Chats',
          '${_dashboardData['totalChats']}',
          Icons.chat,
          Colors.orange,
          '+15%',
        ),
        _buildMetricCard(
          'Premium Users',
          '${_dashboardData['premiumUsers']}',
          Icons.star,
          Colors.purple,
          '+25%',
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'User Activity Chart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Chart visualization would be implemented here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildActionCard('Users', Icons.people, '/admin/users'),
            _buildActionCard('Content', Icons.library_books, '/admin/content'),
            _buildActionCard('Analytics', Icons.analytics, '/admin/analytics'),
            _buildActionCard('Support', Icons.support_agent, '/admin/support'),
            _buildActionCard('Settings', Icons.settings, '/admin/settings'),
            _buildActionCard('Reports', Icons.assessment, '/admin/reports'),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                'New user registration',
                'user@example.com joined EchoBuddy',
                '2 minutes ago',
                Icons.person_add,
                Colors.green,
              ),
              _buildActivityItem(
                'Premium subscription',
                'User upgraded to Pro plan',
                '15 minutes ago',
                Icons.star,
                Colors.orange,
              ),
              _buildActivityItem(
                'Bug report submitted',
                'Critical issue reported in chat feature',
                '1 hour ago',
                Icons.bug_report,
                Colors.red,
              ),
              _buildActivityItem(
                'Content updated',
                'New mood "Excited" added to system',
                '3 hours ago',
                Icons.update,
                Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(description),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Status',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildStatusItem('API Server', 'Online', Colors.green),
              _buildStatusItem('Database', 'Online', Colors.green),
              _buildStatusItem('AI Service', 'Online', Colors.green),
              _buildStatusItem('Payment Gateway', 'Online', Colors.green),
              _buildStatusItem('Push Notifications', 'Maintenance', Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(String service, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            service,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, size: 35, color: Colors.deepPurple),
                ),
                SizedBox(height: 12),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'EchoBuddy Management',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () => Get.back()),
          _buildDrawerItem(Icons.people, 'User Management', () => Get.toNamed('/admin/users')),
          _buildDrawerItem(Icons.library_books, 'Content Management', () => Get.toNamed('/admin/content')),
          _buildDrawerItem(Icons.analytics, 'Analytics', () => Get.toNamed('/admin/analytics')),
          _buildDrawerItem(Icons.support_agent, 'Support', () => Get.toNamed('/admin/support')),
          _buildDrawerItem(Icons.payment, 'Financial Reports', () => Get.toNamed('/admin/finance')),
          _buildDrawerItem(Icons.settings, 'System Settings', () => Get.toNamed('/admin/settings')),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', () => _handleLogout()),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Future<void> _refreshDashboard() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Update dashboard data
    });
  }

  void _showNotifications() {
    Get.snackbar(
      'Notifications',
      '3 new notifications available',
      snackPosition: SnackPosition.TOP,
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        // Navigate to admin profile
        break;
      case 'settings':
        Get.toNamed('/admin/settings');
        break;
      case 'logout':
        _handleLogout();
        break;
    }
  }

  void _handleLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}