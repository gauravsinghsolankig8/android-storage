import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _searchQuery = '';
  
  // Mock user data - in real app, this would come from backend
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _filteredUsers = _allUsers;
  }

  void _initializeMockData() {
    _allUsers = [
      UserModel(
        id: 'user_001',
        name: 'John Doe',
        email: 'john.doe@example.com',
        isProActive: true,
        coins: 250,
        currentMood: 'happy',
        currentOutfit: 'casual',
        unlockedMoods: ['happy', 'romantic', 'joker'],
        unlockedOutfits: ['default', 'casual', 'formal'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
        preferences: UserPreferences(),
        stats: UserStats(
          totalChats: 145,
          totalTimeSpent: 3600,
          totalCoinsEarned: 500,
          totalCoinsSpent: 250,
        ),
      ),
      UserModel(
        id: 'user_002',
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        isProActive: false,
        coins: 80,
        currentMood: 'sleepy',
        currentOutfit: 'default',
        unlockedMoods: ['happy', 'sleepy'],
        unlockedOutfits: ['default'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        lastLogin: DateTime.now().subtract(const Duration(minutes: 30)),
        preferences: UserPreferences(),
        stats: UserStats(
          totalChats: 45,
          totalTimeSpent: 1200,
          totalCoinsEarned: 120,
          totalCoinsSpent: 40,
        ),
      ),
      UserModel(
        id: 'user_003',
        name: 'Mike Johnson',
        email: 'mike.johnson@example.com',
        isProActive: true,
        coins: 450,
        currentMood: 'villain',
        currentOutfit: 'fantasy',
        unlockedMoods: ['happy', 'villain', 'joker', 'romantic'],
        unlockedOutfits: ['default', 'fantasy', 'formal'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
        preferences: UserPreferences(),
        stats: UserStats(
          totalChats: 320,
          totalTimeSpent: 7200,
          totalCoinsEarned: 800,
          totalCoinsSpent: 350,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Users'),
                ),
              ),
              const PopupMenuItem(
                value: 'analytics',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('User Analytics'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilter(),
          
          // User Stats Summary
          _buildUserStats(),
          
          // Users List
          Expanded(
            child: _buildUsersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users by name or email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _updateFilter('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _updateFilter,
          ),
          const SizedBox(height: 12),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Users', 'all'),
                _buildFilterChip('Pro Users', 'pro'),
                _buildFilterChip('Free Users', 'free'),
                _buildFilterChip('Active Today', 'active_today'),
                _buildFilterChip('Inactive', 'inactive'),
                _buildFilterChip('High Spenders', 'high_spenders'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
          _applyFilters();
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.deepPurple.withOpacity(0.2),
        checkmarkColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildUserStats() {
    final totalUsers = _allUsers.length;
    final proUsers = _allUsers.where((u) => u.isProActive).length;
    final activeToday = _allUsers.where((u) => 
      u.lastLogin.isAfter(DateTime.now().subtract(const Duration(days: 1)))
    ).length;
    final totalRevenue = _allUsers.fold<double>(0.0, (sum, user) => sum + user.stats.totalCoinsSpent * 0.1);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total Users', '$totalUsers', Icons.people, Colors.blue),
          ),
          Expanded(
            child: _buildStatCard('Pro Users', '$proUsers', Icons.star, Colors.orange),
          ),
          Expanded(
            child: _buildStatCard('Active Today', '$activeToday', Icons.online_prediction, Colors.green),
          ),
          Expanded(
            child: _buildStatCard('Revenue', '₹${totalRevenue.toStringAsFixed(0)}', Icons.monetization_on, Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Try adjusting your search or filter criteria',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    final daysSinceJoined = DateTime.now().difference(user.createdAt).inDays;
    final lastSeenText = _getLastSeenText(user.lastLogin);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: user.isProActive ? Colors.orange : Colors.blue,
          child: Text(
            user.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (user.isProActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 2),
            Text(
              'Joined $daysSinceJoined days ago • $lastSeenText',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleUserAction(action, user),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View Details'),
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit User'),
              ),
            ),
            const PopupMenuItem(
              value: 'suspend',
              child: ListTile(
                leading: Icon(Icons.block),
                title: Text('Suspend'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildUserStatItem(
                        'Coins',
                        '${user.coins}',
                        Icons.monetization_on,
                        Colors.amber,
                      ),
                    ),
                    Expanded(
                      child: _buildUserStatItem(
                        'Chats',
                        '${user.stats.totalChats}',
                        Icons.chat,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildUserStatItem(
                        'Time Spent',
                        '${(user.stats.totalTimeSpent / 3600).toStringAsFixed(1)}h',
                        Icons.access_time,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Current Status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Mood', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(user.currentMood.toUpperCase()),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Outfit', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(user.currentOutfit.toUpperCase()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleUserAction('view', user),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleUserAction('edit', user),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _getLastSeenText(DateTime lastLogin) {
    final difference = DateTime.now().difference(lastLogin);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _updateFilter(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        // Search filter
        bool matchesSearch = _searchQuery.isEmpty ||
            user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase());

        // Category filter
        bool matchesCategory = true;
        switch (_selectedFilter) {
          case 'pro':
            matchesCategory = user.isProActive;
            break;
          case 'free':
            matchesCategory = !user.isProActive;
            break;
          case 'active_today':
            matchesCategory = user.lastLogin.isAfter(
              DateTime.now().subtract(const Duration(days: 1)),
            );
            break;
          case 'inactive':
            matchesCategory = user.lastLogin.isBefore(
              DateTime.now().subtract(const Duration(days: 7)),
            );
            break;
          case 'high_spenders':
            matchesCategory = user.stats.totalCoinsSpent > 200;
            break;
        }

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _refreshUsers() {
    // Simulate API call
    setState(() {
      // In real app, fetch from backend
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        Get.snackbar('Export', 'Exporting user data...');
        break;
      case 'analytics':
        Get.toNamed('/admin/analytics');
        break;
    }
  }

  void _handleUserAction(String action, UserModel user) {
    switch (action) {
      case 'view':
        _showUserDetailsDialog(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'suspend':
        _showSuspendUserDialog(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
    }
  }

  void _showUserDetailsDialog(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: Text('${user.name} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', user.email),
              _buildDetailRow('User ID', user.id),
              _buildDetailRow('Status', user.isProActive ? 'Pro User' : 'Free User'),
              _buildDetailRow('Coins', '${user.coins}'),
              _buildDetailRow('Total Chats', '${user.stats.totalChats}'),
              _buildDetailRow('Time Spent', '${(user.stats.totalTimeSpent / 3600).toStringAsFixed(1)} hours'),
              _buildDetailRow('Coins Earned', '${user.stats.totalCoinsEarned}'),
              _buildDetailRow('Coins Spent', '${user.stats.totalCoinsSpent}'),
              _buildDetailRow('Joined', user.createdAt.toString().split(' ')[0]),
              _buildDetailRow('Last Login', _getLastSeenText(user.lastLogin)),
              _buildDetailRow('Unlocked Moods', user.unlockedMoods.join(', ')),
              _buildDetailRow('Unlocked Outfits', user.unlockedOutfits.join(', ')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    Get.snackbar('Edit User', 'Edit user functionality would be implemented here');
  }

  void _showSuspendUserDialog(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Suspend User'),
        content: Text('Are you sure you want to suspend ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Success', '${user.name} has been suspended');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Suspend', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to permanently delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              setState(() {
                _allUsers.remove(user);
                _applyFilters();
              });
              Get.snackbar('Success', '${user.name} has been deleted');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    Get.snackbar('Add User', 'Add user functionality would be implemented here');
  }
}