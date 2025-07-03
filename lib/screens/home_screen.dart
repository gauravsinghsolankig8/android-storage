import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/conversation_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().initialize();
      context.read<MoodProvider>().initialize();
      context.read<ConversationProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildChatTab(),
          _buildARTab(),
          _buildShopTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: 'AR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer2<UserProvider, MoodProvider>(
      builder: (context, userProvider, moodProvider, child) {
        if (userProvider.isLoading || moodProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userProvider.currentUser;
        final currentMood = moodProvider.currentMood;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user?.name ?? 'Friend'}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coins: ${user?.coins ?? 0}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Current mood display
              if (currentMood != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Current Mood: ${currentMood.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentMood.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/mood-selector'),
                        child: const Text('Change Mood'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
              
              // Quick actions
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildQuickActionCard(
                      context,
                      'Start Chat',
                      Icons.chat,
                      () => setState(() => _currentIndex = 1),
                    ),
                    _buildQuickActionCard(
                      context,
                      'AR Mode',
                      Icons.view_in_ar,
                      () => Navigator.pushNamed(context, '/ar-lobby'),
                    ),
                    _buildQuickActionCard(
                      context,
                      'Shop',
                      Icons.shopping_bag,
                      () => setState(() => _currentIndex = 3),
                    ),
                    _buildQuickActionCard(
                      context,
                      'Stats',
                      Icons.bar_chart,
                      () => Navigator.pushNamed(context, '/stats'),
                    ),
                    _buildQuickActionCard(
                      context,
                      'Memories',
                      Icons.photo_album,
                      () => Navigator.pushNamed(context, '/memory'),
                    ),
                    _buildQuickActionCard(
                      context,
                      'Quiz',
                      Icons.quiz,
                      () => Navigator.pushNamed(context, '/quiz'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return const Center(
      child: Text('Chat functionality will be implemented'),
    );
  }

  Widget _buildARTab() {
    return const Center(
      child: Text('AR functionality will be implemented'),
    );
  }

  Widget _buildShopTab() {
    return const Center(
      child: Text('Shop functionality will be implemented'),
    );
  }

  Widget _buildProfileTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'Friend',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Coins: ${user?.coins ?? 0}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // Profile actions
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Stats'),
                onTap: () => Navigator.pushNamed(context, '/stats'),
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Inventory'),
                onTap: () => Navigator.pushNamed(context, '/inventory'),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Subscription'),
                onTap: () => Navigator.pushNamed(context, '/subscription'),
              ),
            ],
          ),
        );
      },
    );
  }
}