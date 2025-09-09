import React, { useState, useEffect } from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  Alert,
  Switch,
} from 'react-native';
import {
  Text,
  Card,
  Button,
  Avatar,
  List,
  Divider,
  ActivityIndicator,
  Badge,
} from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import { userAPI, notificationsAPI } from '../services/api';

const ProfileScreen = ({ navigation }) => {
  const { theme, isDarkMode, toggleTheme } = useTheme();
  const { user, logout, isLoading } = useAuth();
  const [userStats, setUserStats] = useState(null);
  const [unreadNotifications, setUnreadNotifications] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadUserData();
  }, []);

  const loadUserData = async () => {
    try {
      setLoading(true);
      const [statsResponse, notificationsResponse] = await Promise.all([
        userAPI.getStats(),
        notificationsAPI.getUnreadCount(),
      ]);
      
      setUserStats(statsResponse.data);
      setUnreadNotifications(notificationsResponse.data.unreadCount);
    } catch (error) {
      console.error('Error loading user data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    Alert.alert(
      'Logout',
      'Are you sure you want to logout?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Logout', style: 'destructive', onPress: logout },
      ]
    );
  };

  const handleDeleteAccount = () => {
    Alert.alert(
      'Delete Account',
      'This action cannot be undone. Are you sure you want to delete your account?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () => {
            // Navigate to delete account screen or show confirmation
            navigation.navigate('Settings', { showDeleteAccount: true });
          },
        },
      ]
    );
  };

  const renderProfileHeader = () => (
    <Card style={[styles.profileCard, { backgroundColor: theme.colors.surface }]}>
      <Card.Content style={styles.profileContent}>
        <View style={styles.avatarContainer}>
          <Avatar.Image
            size={80}
            source={user?.profileImageUrl ? { uri: user.profileImageUrl } : undefined}
            style={[styles.avatar, { backgroundColor: theme.colors.primary }]}
          />
          {!user?.profileImageUrl && (
            <Avatar.Text
              size={80}
              label={user?.name?.charAt(0) || 'U'}
              style={[styles.avatar, { backgroundColor: theme.colors.primary }]}
            />
          )}
        </View>
        
        <Text style={[styles.userName, { color: theme.colors.text }]}>
          {user?.name || 'User'}
        </Text>
        
        <Text style={[styles.userEmail, { color: theme.colors.placeholder }]}>
          {user?.email || user?.phone || 'No contact info'}
        </Text>

        <View style={styles.statsContainer}>
          <View style={styles.statItem}>
            <Text style={[styles.statNumber, { color: theme.colors.primary }]}>
              {userStats?.favoritesCount || 0}
            </Text>
            <Text style={[styles.statLabel, { color: theme.colors.text }]}>
              Favorites
            </Text>
          </View>
          
          <View style={styles.statItem}>
            <Text style={[styles.statNumber, { color: theme.colors.primary }]}>
              {userStats?.badgesCount || 0}
            </Text>
            <Text style={[styles.statLabel, { color: theme.colors.text }]}>
              Badges
            </Text>
          </View>
          
          <View style={styles.statItem}>
            <Text style={[styles.statNumber, { color: theme.colors.primary }]}>
              {userStats?.ordersCount || 0}
            </Text>
            <Text style={[styles.statLabel, { color: theme.colors.text }]}>
              Orders
            </Text>
          </View>
        </View>
      </Card.Content>
    </Card>
  );

  const renderMenuSection = () => (
    <Card style={[styles.menuCard, { backgroundColor: theme.colors.surface }]}>
      <List.Item
        title="Favorites"
        description="Your saved temples, saints, and events"
        left={(props) => <List.Icon {...props} icon="heart" color={theme.colors.primary} />}
        right={(props) => <List.Icon {...props} icon="chevron-right" />}
        onPress={() => navigation.navigate('Favorites')}
        style={styles.menuItem}
      />
      
      <Divider />
      
      <List.Item
        title="Orders"
        description="Your spiritual store orders"
        left={(props) => <List.Icon {...props} icon="shopping" color={theme.colors.primary} />}
        right={(props) => <List.Icon {...props} icon="chevron-right" />}
        onPress={() => navigation.navigate('Orders')}
        style={styles.menuItem}
      />
      
      <Divider />
      
      <List.Item
        title="Notifications"
        description="Updates and reminders"
        left={(props) => <List.Icon {...props} icon="bell" color={theme.colors.primary} />}
        right={(props) => (
          <View style={styles.notificationBadge}>
            {unreadNotifications > 0 && (
              <Badge size={20} style={{ backgroundColor: theme.colors.error }}>
                {unreadNotifications}
              </Badge>
            )}
            <List.Icon icon="chevron-right" />
          </View>
        )}
        onPress={() => navigation.navigate('Notifications')}
        style={styles.menuItem}
      />
      
      <Divider />
      
      <List.Item
        title="Settings"
        description="App preferences and account settings"
        left={(props) => <List.Icon {...props} icon="cog" color={theme.colors.primary} />}
        right={(props) => <List.Icon {...props} icon="chevron-right" />}
        onPress={() => navigation.navigate('Settings')}
        style={styles.menuItem}
      />
    </Card>
  );

  const renderQuickSettings = () => (
    <Card style={[styles.settingsCard, { backgroundColor: theme.colors.surface }]}>
      <Card.Content>
        <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
          Quick Settings
        </Text>
        
        <View style={styles.settingRow}>
          <View style={styles.settingInfo}>
            <Ionicons name="moon" size={24} color={theme.colors.primary} />
            <View style={styles.settingText}>
              <Text style={[styles.settingTitle, { color: theme.colors.text }]}>
                Dark Mode
              </Text>
              <Text style={[styles.settingDescription, { color: theme.colors.placeholder }]}>
                Switch between light and dark themes
              </Text>
            </View>
          </View>
          <Switch
            value={isDarkMode}
            onValueChange={toggleTheme}
            color={theme.colors.primary}
          />
        </View>
      </Card.Content>
    </Card>
  );

  const renderAccountActions = () => (
    <Card style={[styles.actionsCard, { backgroundColor: theme.colors.surface }]}>
      <Card.Content>
        <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
          Account Actions
        </Text>
        
        <Button
          mode="outlined"
          onPress={() => navigation.navigate('Settings')}
          style={[styles.actionButton, { borderColor: theme.colors.primary }]}
          icon="account-edit"
        >
          Edit Profile
        </Button>
        
        <Button
          mode="outlined"
          onPress={handleLogout}
          style={[styles.actionButton, { borderColor: theme.colors.error }]}
          icon="logout"
          textColor={theme.colors.error}
        >
          Logout
        </Button>
        
        <Button
          mode="text"
          onPress={handleDeleteAccount}
          style={styles.actionButton}
          icon="delete"
          textColor={theme.colors.error}
        >
          Delete Account
        </Button>
      </Card.Content>
    </Card>
  );

  const renderAppInfo = () => (
    <Card style={[styles.infoCard, { backgroundColor: theme.colors.surface }]}>
      <Card.Content>
        <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
          App Information
        </Text>
        
        <View style={styles.infoRow}>
          <Text style={[styles.infoLabel, { color: theme.colors.placeholder }]}>
            Version
          </Text>
          <Text style={[styles.infoValue, { color: theme.colors.text }]}>
            1.0.0
          </Text>
        </View>
        
        <View style={styles.infoRow}>
          <Text style={[styles.infoLabel, { color: theme.colors.placeholder }]}>
            Account Age
          </Text>
          <Text style={[styles.infoValue, { color: theme.colors.text }]}>
            {userStats?.accountAge || 0} days
          </Text>
        </View>
        
        <Button
          mode="text"
          onPress={() => {
            // Open support or feedback
            Alert.alert('Support', 'Contact us at support@saranam.app');
          }}
          style={styles.actionButton}
          icon="help-circle"
        >
          Help & Support
        </Button>
      </Card.Content>
    </Card>
  );

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { backgroundColor: theme.colors.background }]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={[styles.loadingText, { color: theme.colors.text }]}>
          Loading profile...
        </Text>
      </View>
    );
  }

  return (
    <ScrollView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      showsVerticalScrollIndicator={false}
    >
      {renderProfileHeader()}
      {renderMenuSection()}
      {renderQuickSettings()}
      {renderAccountActions()}
      {renderAppInfo()}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
  },
  profileCard: {
    margin: 16,
    elevation: 4,
  },
  profileContent: {
    alignItems: 'center',
    padding: 20,
  },
  avatarContainer: {
    marginBottom: 16,
  },
  avatar: {
    elevation: 4,
  },
  userName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  userEmail: {
    fontSize: 16,
    marginBottom: 20,
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '100%',
  },
  statItem: {
    alignItems: 'center',
  },
  statNumber: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  statLabel: {
    fontSize: 14,
    marginTop: 4,
  },
  menuCard: {
    margin: 16,
    marginTop: 0,
    elevation: 2,
  },
  menuItem: {
    paddingVertical: 8,
  },
  notificationBadge: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingsCard: {
    margin: 16,
    marginTop: 0,
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  settingInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  settingText: {
    marginLeft: 16,
    flex: 1,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '500',
  },
  settingDescription: {
    fontSize: 14,
    marginTop: 2,
  },
  actionsCard: {
    margin: 16,
    marginTop: 0,
    elevation: 2,
  },
  actionButton: {
    marginBottom: 8,
  },
  infoCard: {
    margin: 16,
    marginTop: 0,
    marginBottom: 32,
    elevation: 2,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
  },
  infoLabel: {
    fontSize: 16,
  },
  infoValue: {
    fontSize: 16,
    fontWeight: '500',
  },
});

export default ProfileScreen;