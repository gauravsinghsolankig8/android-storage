import React, { useState, useEffect } from 'react';
import {
  View,
  StyleSheet,
  FlatList,
  RefreshControl,
  Alert,
} from 'react-native';
import {
  Text,
  Card,
  Button,
  Chip,
  ActivityIndicator,
  Searchbar,
  FAB,
} from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import { saintsAPI } from '../services/api';

const SaintsScreen = ({ navigation }) => {
  const { theme } = useTheme();
  const { isAuthenticated } = useAuth();
  const [saints, setSaints] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedFilter, setSelectedFilter] = useState('all');
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);

  const filters = [
    { id: 'all', label: 'All Saints' },
    { id: 'current', label: 'Current' },
    { id: 'past', label: 'Past' },
    { id: 'popular', label: 'Popular' },
  ];

  useEffect(() => {
    loadSaints();
  }, [searchQuery, selectedFilter]);

  const loadSaints = async (pageNum = 1, isRefresh = false) => {
    try {
      if (isRefresh) {
        setRefreshing(true);
      } else {
        setLoading(true);
      }

      const params = {
        page: pageNum,
        limit: 20,
        search: searchQuery,
        filter: selectedFilter,
      };

      const response = await saintsAPI.getAll(params);
      const newSaints = response.data.saints;

      if (pageNum === 1) {
        setSaints(newSaints);
      } else {
        setSaints(prev => [...prev, ...newSaints]);
      }

      setHasMore(newSaints.length === 20);
      setPage(pageNum);
    } catch (error) {
      console.error('Error loading saints:', error);
      Alert.alert('Error', 'Failed to load saints. Please try again.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setPage(1);
    loadSaints(1, true);
  };

  const loadMore = () => {
    if (hasMore && !loading) {
      loadSaints(page + 1);
    }
  };

  const handleSearch = (query) => {
    setSearchQuery(query);
    setPage(1);
  };

  const handleSaintPress = (saint) => {
    navigation.navigate('SaintDetail', { saintId: saint.id });
  };

  const handleFavorite = async (saintId) => {
    if (!isAuthenticated) {
      Alert.alert('Login Required', 'Please login to add favorites');
      return;
    }

    try {
      await saintsAPI.addFavorite(saintId);
      Alert.alert('Success', 'Saint added to favorites');
    } catch (error) {
      console.error('Error adding favorite:', error);
      Alert.alert('Error', 'Failed to add to favorites');
    }
  };

  const renderSaintCard = ({ item }) => (
    <Card
      style={[styles.saintCard, { backgroundColor: theme.colors.surface }]}
      onPress={() => handleSaintPress(item)}
    >
      <Card.Cover
        source={{ uri: item.primary_image || 'https://via.placeholder.com/300x200' }}
        style={styles.saintImage}
      />
      <Card.Content style={styles.saintContent}>
        <View style={styles.saintHeader}>
          <Text style={[styles.saintName, { color: theme.colors.text }]}>
            {item.name}
          </Text>
          <Ionicons
            name="heart-outline"
            size={24}
            color={theme.colors.primary}
            onPress={() => handleFavorite(item.id)}
            style={styles.favoriteIcon}
          />
        </View>
        
        <View style={styles.saintInfo}>
          <Chip
            icon="account-group"
            style={[styles.sectChip, { backgroundColor: theme.colors.primary + '20' }]}
            textStyle={{ color: theme.colors.primary }}
          >
            {item.sect || 'Spiritual Leader'}
          </Chip>
          
          <Chip
            icon={item.is_current ? "account-check" : "account-clock"}
            style={[
              styles.statusChip, 
              { backgroundColor: item.is_current ? theme.colors.success + '20' : theme.colors.warning + '20' }
            ]}
            textStyle={{ 
              color: item.is_current ? theme.colors.success : theme.colors.warning 
            }}
          >
            {item.is_current ? 'Current' : 'Past'}
          </Chip>
        </View>
        
        {item.bio && (
          <Text style={[styles.saintBio, { color: theme.colors.text }]}>
            {item.bio.substring(0, 120)}...
          </Text>
        )}
        
        <View style={styles.saintFooter}>
          <View style={styles.lifeSpan}>
            {item.birth_date && (
              <Text style={[styles.lifeSpanText, { color: theme.colors.placeholder }]}>
                Born: {new Date(item.birth_date).getFullYear()}
              </Text>
            )}
            {item.death_date && (
              <Text style={[styles.lifeSpanText, { color: theme.colors.placeholder }]}>
                - {new Date(item.death_date).getFullYear()}
              </Text>
            )}
          </View>
          
          <Button
            mode="outlined"
            compact
            onPress={() => handleSaintPress(item)}
            style={[styles.viewButton, { borderColor: theme.colors.primary }]}
          >
            View Details
          </Button>
        </View>
      </Card.Content>
    </Card>
  );

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Ionicons name="person-outline" size={64} color={theme.colors.placeholder} />
      <Text style={[styles.emptyTitle, { color: theme.colors.text }]}>
        No Saints Found
      </Text>
      <Text style={[styles.emptyDescription, { color: theme.colors.placeholder }]}>
        Try adjusting your search or filters
      </Text>
    </View>
  );

  const renderFooter = () => {
    if (!loading) return null;
    return (
      <View style={styles.footerLoader}>
        <ActivityIndicator size="small" color={theme.colors.primary} />
      </View>
    );
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <Searchbar
          placeholder="Search saints..."
          onChangeText={handleSearch}
          value={searchQuery}
          style={styles.searchBar}
        />
      </View>

      {/* Filters */}
      <View style={styles.filtersContainer}>
        <FlatList
          horizontal
          showsHorizontalScrollIndicator={false}
          data={filters}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <Chip
              selected={selectedFilter === item.id}
              onPress={() => setSelectedFilter(item.id)}
              style={[
                styles.filterChip,
                selectedFilter === item.id && {
                  backgroundColor: theme.colors.primary,
                },
              ]}
              textStyle={{
                color: selectedFilter === item.id ? 'white' : theme.colors.text,
              }}
            >
              {item.label}
            </Chip>
          )}
          contentContainerStyle={styles.filtersList}
        />
      </View>

      {/* Saints List */}
      <FlatList
        data={saints}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderSaintCard}
        contentContainerStyle={styles.listContainer}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        onEndReached={loadMore}
        onEndReachedThreshold={0.5}
        ListEmptyComponent={!loading ? renderEmptyState : null}
        ListFooterComponent={renderFooter}
        showsVerticalScrollIndicator={false}
      />

      {/* FAB for Add Saint (Admin only) */}
      {isAuthenticated && (
        <FAB
          icon="plus"
          style={[styles.fab, { backgroundColor: theme.colors.primary }]}
          onPress={() => {
            // Navigate to add saint form (admin only)
            Alert.alert('Admin Feature', 'Add saint functionality for admin users');
          }}
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  searchContainer: {
    padding: 16,
    paddingBottom: 8,
  },
  searchBar: {
    elevation: 2,
  },
  filtersContainer: {
    paddingBottom: 16,
  },
  filtersList: {
    paddingHorizontal: 16,
  },
  filterChip: {
    marginRight: 8,
  },
  listContainer: {
    paddingHorizontal: 16,
    paddingBottom: 80,
  },
  saintCard: {
    marginBottom: 16,
    elevation: 2,
  },
  saintImage: {
    height: 200,
  },
  saintContent: {
    padding: 16,
  },
  saintHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  saintName: {
    fontSize: 20,
    fontWeight: 'bold',
    flex: 1,
    marginRight: 8,
  },
  favoriteIcon: {
    padding: 4,
  },
  saintInfo: {
    flexDirection: 'row',
    marginBottom: 12,
  },
  sectChip: {
    marginRight: 8,
    height: 32,
  },
  statusChip: {
    height: 32,
  },
  saintBio: {
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 12,
  },
  saintFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  lifeSpan: {
    flexDirection: 'row',
    flex: 1,
  },
  lifeSpanText: {
    fontSize: 12,
    marginRight: 4,
  },
  viewButton: {
    height: 32,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 60,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginTop: 16,
    marginBottom: 8,
  },
  emptyDescription: {
    fontSize: 16,
    textAlign: 'center',
  },
  footerLoader: {
    paddingVertical: 20,
    alignItems: 'center',
  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
  },
});

export default SaintsScreen;