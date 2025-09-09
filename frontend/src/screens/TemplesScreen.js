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
  Searchbar,
  Chip,
  ActivityIndicator,
  FAB,
} from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import { templesAPI } from '../services/api';

const TemplesScreen = ({ navigation, route }) => {
  const { theme } = useTheme();
  const { isAuthenticated } = useAuth();
  const [temples, setTemples] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState(route?.params?.search || '');
  const [selectedFilter, setSelectedFilter] = useState('all');
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);

  const filters = [
    { id: 'all', label: 'All' },
    { id: 'nearby', label: 'Nearby' },
    { id: 'popular', label: 'Popular' },
  ];

  useEffect(() => {
    loadTemples();
  }, [searchQuery, selectedFilter]);

  const loadTemples = async (pageNum = 1, isRefresh = false) => {
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
      };

      const response = await templesAPI.getAll(params);
      const newTemples = response.data.temples;

      if (pageNum === 1) {
        setTemples(newTemples);
      } else {
        setTemples(prev => [...prev, ...newTemples]);
      }

      setHasMore(newTemples.length === 20);
      setPage(pageNum);
    } catch (error) {
      console.error('Error loading temples:', error);
      Alert.alert('Error', 'Failed to load temples. Please try again.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setPage(1);
    loadTemples(1, true);
  };

  const loadMore = () => {
    if (hasMore && !loading) {
      loadTemples(page + 1);
    }
  };

  const handleSearch = (query) => {
    setSearchQuery(query);
    setPage(1);
  };

  const handleTemplePress = (temple) => {
    navigation.navigate('TempleDetail', { templeId: temple.id });
  };

  const handleFavorite = async (templeId) => {
    if (!isAuthenticated) {
      Alert.alert('Login Required', 'Please login to add favorites');
      return;
    }

    try {
      // Toggle favorite - you might want to check current state first
      await templesAPI.addFavorite(templeId);
      Alert.alert('Success', 'Temple added to favorites');
    } catch (error) {
      console.error('Error adding favorite:', error);
      Alert.alert('Error', 'Failed to add to favorites');
    }
  };

  const renderTempleCard = ({ item }) => (
    <Card
      style={[styles.templeCard, { backgroundColor: theme.colors.surface }]}
      onPress={() => handleTemplePress(item)}
    >
      <Card.Cover
        source={{ uri: item.primary_image || 'https://via.placeholder.com/300x200' }}
        style={styles.templeImage}
      />
      <Card.Content style={styles.templeContent}>
        <View style={styles.templeHeader}>
          <Text style={[styles.templeName, { color: theme.colors.text }]}>
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
        
        <Text style={[styles.templeLocation, { color: theme.colors.placeholder }]}>
          <Ionicons name="location-outline" size={16} /> {item.location}
        </Text>
        
        {item.history && (
          <Text style={[styles.templeDescription, { color: theme.colors.text }]}>
            {item.history.substring(0, 100)}...
          </Text>
        )}
        
        <View style={styles.templeFooter}>
          <Chip
            icon="clock-outline"
            style={[styles.timingChip, { backgroundColor: theme.colors.primary + '20' }]}
            textStyle={{ color: theme.colors.primary }}
          >
            Open
          </Chip>
          <Chip
            icon="star"
            style={[styles.ratingChip, { backgroundColor: theme.colors.temple + '20' }]}
            textStyle={{ color: theme.colors.temple }}
          >
            4.5
          </Chip>
        </View>
      </Card.Content>
    </Card>
  );

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Ionicons name="library-outline" size={64} color={theme.colors.placeholder} />
      <Text style={[styles.emptyTitle, { color: theme.colors.text }]}>
        No Temples Found
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
          placeholder="Search temples..."
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

      {/* Temples List */}
      <FlatList
        data={temples}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderTempleCard}
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

      {/* FAB for Map View */}
      <FAB
        icon="map"
        style={[styles.fab, { backgroundColor: theme.colors.primary }]}
        onPress={() => {
          // Navigate to map view
          navigation.navigate('Home');
        }}
      />
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
  templeCard: {
    marginBottom: 16,
    elevation: 2,
  },
  templeImage: {
    height: 200,
  },
  templeContent: {
    padding: 16,
  },
  templeHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  templeName: {
    fontSize: 18,
    fontWeight: 'bold',
    flex: 1,
    marginRight: 8,
  },
  favoriteIcon: {
    padding: 4,
  },
  templeLocation: {
    fontSize: 14,
    marginBottom: 8,
    flexDirection: 'row',
    alignItems: 'center',
  },
  templeDescription: {
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 12,
  },
  templeFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  timingChip: {
    height: 32,
  },
  ratingChip: {
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

export default TemplesScreen;