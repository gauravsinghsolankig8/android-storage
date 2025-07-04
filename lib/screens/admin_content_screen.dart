import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/mood_model.dart';
import '../models/outfit_model.dart';
import '../models/secret_command_model.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.mood), text: 'Moods'),
            Tab(icon: Icon(Icons.style), text: 'Outfits'),
            Tab(icon: Icon(Icons.code), text: 'Commands'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshContent,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'backup',
                child: ListTile(
                  leading: Icon(Icons.backup),
                  title: Text('Backup Content'),
                ),
              ),
              const PopupMenuItem(
                value: 'restore',
                child: ListTile(
                  leading: Icon(Icons.restore),
                  title: Text('Restore Content'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMoodsTab(),
          _buildOutfitsTab(),
          _buildCommandsTab(),
        ],
      ),
    );
  }

  Widget _buildMoodsTab() {
    final moods = MoodModel.defaultMoods;
    
    return Column(
      children: [
        // Moods Summary
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Moods',
                  '${moods.length}',
                  Icons.mood,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Premium Moods',
                  '${moods.where((m) => m.isPro).length}',
                  Icons.star,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Free Moods',
                  '${moods.where((m) => !m.isPro).length}',
                  Icons.free_breakfast,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),
        
        // Moods List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              return _buildMoodCard(mood);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOutfitsTab() {
    final outfits = OutfitModel.defaultOutfits;
    
    return Column(
      children: [
        // Outfits Summary
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Outfits',
                  '${outfits.length}',
                  Icons.style,
                  Colors.purple,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Premium Outfits',
                  '${outfits.where((o) => o.isPro).length}',
                  Icons.star,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Categories',
                  '${outfits.map((o) => o.category).toSet().length}',
                  Icons.category,
                  Colors.teal,
                ),
              ),
            ],
          ),
        ),
        
        // Outfits List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              return _buildOutfitCard(outfit);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommandsTab() {
    final commands = SecretCommandModel.defaultCommands;
    
    return Column(
      children: [
        // Commands Summary
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Commands',
                  '${commands.length}',
                  Icons.code,
                  Colors.indigo,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Active Commands',
                  '${commands.where((c) => c.isActive).length}',
                  Icons.play_circle,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Hidden Commands',
                  '${commands.where((c) => c.isHidden).length}',
                  Icons.visibility_off,
                  Colors.red,
                ),
              ),
            ],
          ),
        ),
        
        // Commands List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: commands.length,
            itemBuilder: (context, index) {
              final command = commands[index];
              return _buildCommandCard(command);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(MoodModel mood) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: mood.color,
          child: Icon(
            _getMoodIcon(mood.name),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                mood.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (mood.isPro)
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
            Text(mood.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.monetization_on, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${mood.unlockCost} coins',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.thermostat, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  'Temp: ${mood.aiTemperature}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleMoodAction(action, mood),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Duplicate'),
              ),
            ),
            const PopupMenuItem(
              value: 'toggle',
              child: ListTile(
                leading: Icon(Icons.toggle_on),
                title: Text('Toggle Status'),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GPT Prompt
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Prompt:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood.gptPrompt,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Animations and Voice Styles
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Animations:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 4,
                            children: mood.animations.map((anim) => Chip(
                              label: Text(anim, style: const TextStyle(fontSize: 10)),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Voice Styles:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 4,
                            children: mood.voiceStyles.map((voice) => Chip(
                              label: Text(voice, style: const TextStyle(fontSize: 10)),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Welcome Messages
                const Text(
                  'Welcome Messages:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...mood.welcomeMessages.map((msg) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('• $msg', style: const TextStyle(fontSize: 12)),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitCard(OutfitModel outfit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: outfit.color,
          child: Icon(
            _getOutfitIcon(outfit.category),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                outfit.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getCategoryColor(outfit.category),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                outfit.category.toUpperCase(),
                style: const TextStyle(
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
            Text(outfit.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.monetization_on, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${outfit.unlockCost} coins',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.star, size: 14, color: outfit.isPro ? Colors.orange : Colors.grey),
                const SizedBox(width: 4),
                Text(
                  outfit.isPro ? 'Premium' : 'Free',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleOutfitAction(action, outfit),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'preview',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Preview'),
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Duplicate'),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Asset Paths
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Asset Files:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Model: ${outfit.assets.modelPath}'),
                      Text('Textures: ${outfit.assets.texturePaths.join(', ')}'),
                      Text('Animations: ${outfit.assets.animationPaths.join(', ')}'),
                      if (outfit.assets.thumbnailPath != null)
                        Text('Thumbnail: ${outfit.assets.thumbnailPath}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Tags
                if (outfit.tags.isNotEmpty) ...[
                  const Text(
                    'Tags:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: outfit.tags.map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 10)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCard(SecretCommandModel command) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: command.isActive ? Colors.green : Colors.grey,
          child: Icon(
            _getCommandIcon(command.type),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                command.command,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            if (command.isHidden)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'HIDDEN',
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
            Text(command.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  command.isActive ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: command.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  command.isActive ? 'Active' : 'Inactive',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  command.type.name,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleCommandAction(action, command),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'test',
              child: ListTile(
                leading: Icon(Icons.play_arrow),
                title: Text('Test Command'),
              ),
            ),
            const PopupMenuItem(
              value: 'toggle',
              child: ListTile(
                leading: Icon(Icons.toggle_on),
                title: Text('Toggle Active'),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Response
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Response:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(command.response),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Effects
                if (command.effects.isNotEmpty) ...[
                  const Text(
                    'Effects:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...command.effects.map((effect) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${effect.type.name} Effect',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        if (effect.animation != null)
                          Text('Animation: ${effect.animation}', style: const TextStyle(fontSize: 11)),
                        if (effect.sound != null)
                          Text('Sound: ${effect.sound}', style: const TextStyle(fontSize: 11)),
                        if (effect.coins != null)
                          Text('Coins: ${effect.coins}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMoodIcon(String moodName) {
    switch (moodName.toLowerCase()) {
      case 'happy': return Icons.sentiment_very_satisfied;
      case 'romantic': return Icons.favorite;
      case 'villain': return Icons.whatshot;
      case 'sleepy': return Icons.bedtime;
      case 'joker': return Icons.emoji_emotions;
      default: return Icons.mood;
    }
  }

  IconData _getOutfitIcon(String category) {
    switch (category.toLowerCase()) {
      case 'casual': return Icons.checkroom;
      case 'formal': return Icons.business_center;
      case 'fantasy': return Icons.auto_awesome;
      case 'seasonal': return Icons.ac_unit;
      default: return Icons.style;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'casual': return Colors.blue;
      case 'formal': return Colors.purple;
      case 'fantasy': return Colors.pink;
      case 'seasonal': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getCommandIcon(CommandType type) {
    switch (type) {
      case CommandType.easter_egg: return Icons.egg;
      case CommandType.admin: return Icons.admin_panel_settings;
      case CommandType.debug: return Icons.bug_report;
      case CommandType.fun: return Icons.celebration;
      case CommandType.utility: return Icons.build;
    }
  }

  void _refreshContent() {
    setState(() {
      // Refresh content from backend
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'backup':
        Get.snackbar('Backup', 'Creating content backup...');
        break;
      case 'restore':
        Get.snackbar('Restore', 'Restoring from backup...');
        break;
    }
  }

  void _handleMoodAction(String action, MoodModel mood) {
    switch (action) {
      case 'edit':
        Get.snackbar('Edit Mood', 'Edit mood: ${mood.displayName}');
        break;
      case 'duplicate':
        Get.snackbar('Duplicate', 'Duplicating mood: ${mood.displayName}');
        break;
      case 'toggle':
        Get.snackbar('Toggle', 'Toggling mood status: ${mood.displayName}');
        break;
    }
  }

  void _handleOutfitAction(String action, OutfitModel outfit) {
    switch (action) {
      case 'edit':
        Get.snackbar('Edit Outfit', 'Edit outfit: ${outfit.displayName}');
        break;
      case 'preview':
        Get.toNamed('/outfit-preview', arguments: {'outfitId': outfit.id});
        break;
      case 'duplicate':
        Get.snackbar('Duplicate', 'Duplicating outfit: ${outfit.displayName}');
        break;
    }
  }

  void _handleCommandAction(String action, SecretCommandModel command) {
    switch (action) {
      case 'edit':
        Get.snackbar('Edit Command', 'Edit command: ${command.command}');
        break;
      case 'test':
        Get.snackbar('Test Command', 'Testing: ${command.command}');
        break;
      case 'toggle':
        Get.snackbar('Toggle', 'Toggling command: ${command.command}');
        break;
    }
  }
}