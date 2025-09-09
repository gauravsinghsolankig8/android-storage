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
} from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import { eventsAPI } from '../services/api';

const EventsScreen = ({ navigation }) => {
  const { theme } = useTheme();
  const { isAuthenticated } = useAuth();
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedFilter, setSelectedFilter] = useState('upcoming');
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);

  const filters = [
    { id: 'upcoming', label: 'Upcoming' },
    { id: 'all', label: 'All Events' },
    { id: 'festivals', label: 'Festivals' },
  ];

  useEffect(() => {
    loadEvents();
  }, [searchQuery, selectedFilter]);

  const loadEvents = async (pageNum = 1, isRefresh = false) => {
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
        upcoming: selectedFilter === 'upcoming',
        event_type: selectedFilter === 'festivals' ? 'festival' : undefined,
      };

      const response = await eventsAPI.getAll(params);
      const newEvents = response.data.events;

      if (pageNum === 1) {
        setEvents(newEvents);
      } else {
        setEvents(prev => [...prev, ...newEvents]);
      }

      setHasMore(newEvents.length === 20);
      setPage(pageNum);
    } catch (error) {
      console.error('Error loading events:', error);
      Alert.alert('Error', 'Failed to load events. Please try again.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setPage(1);
    loadEvents(1, true);
  };

  const loadMore = () => {
    if (hasMore && !loading) {
      loadEvents(page + 1);
    }
  };

  const handleSearch = (query) => {
    setSearchQuery(query);
    setPage(1);
  };

  const handleEventPress = (event) => {
    navigation.navigate('EventDetail', { eventId: event.id });
  };

  const handleFavorite = async (eventId) => {
    if (!isAuthenticated) {
      Alert.alert('Login Required', 'Please login to add favorites');
      return;
    }

    try {
      await eventsAPI.addFavorite(eventId);
      Alert.alert('Success', 'Event added to favorites');
    } catch (error) {
      console.error('Error adding favorite:', error);
      Alert.alert('Error', 'Failed to add to favorites');
    }
  };

  const renderEventCard = ({ item }) => (
    <Card
      style={[styles.eventCard, { backgroundColor: theme.colors.surface }]}
      onPress={() => handleEventPress(item)}
    >
      <Card.Cover
        source={{ uri: item.primary_image || 'https://via.placeholder.com/300x200' }}
        style={styles.eventImage}
      />
      <Card.Content style={styles.eventContent}>
        <View style={styles.eventHeader}>
          <Text style={[styles.eventName, { color: theme.colors.text }]}>
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
        
        <Text style={[styles.eventDate, { color: theme.colors.placeholder }]}>
          <Ionicons name="calendar-outline" size={16} /> 
          {new Date(item.start_date).toLocaleDateString()}
          {item.end_date && ` - ${new Date(item.end_date).toLocaleDateString()}`}
        </Text>
        
        {item.location && (
          <Text style={[styles.eventLocation, { color: theme.colors.placeholder }]}>
            <Ionicons name="location-outline" size={16} /> {item.location}
          </Text>
        )}
        
        {item.description && (
          <Text style={[styles.eventDescription, { color: theme.colors.text }]}>
            {item.description.substring(0, 100)}...
          </Text>
        )}
        
        <View style={styles.eventFooter}>
          <Chip
            icon="calendar"
            style={[styles.typeChip, { backgroundColor: theme.colors.event + '20' }]}
            textStyle={{ color: theme.colors.event }}
          >
            {item.event_type}
          </Chip>
        </View>
      </Card.Content>
    </Card>
  );

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Ionicons name="calendar-outline" size={64} color={theme.colors.placeholder} />
      <Text style={[styles.emptyTitle, { color: theme.colors.text }]}>
        No Events Found
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
          placeholder="Search events..."
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

      {/* Events List */}
      <FlatList
        data={events}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderEventCard}
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
    paddingBottom: 20,
  },
  eventCard: {
    marginBottom: 16,
    elevation: 2,
  },
  eventImage: {
    height: 200,
  },
  eventContent: {
    padding: 16,
  },
  eventHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  eventName: {
    fontSize: 18,
    fontWeight: 'bold',
    flex: 1,
    marginRight: 8,
  },
  favoriteIcon: {
    padding: 4,
  },
  eventDate: {
    fontSize: 14,
    marginBottom: 4,
    flexDirection: 'row',
    alignItems: 'center',
  },
  eventLocation: {
    fontSize: 14,
    marginBottom: 8,
    flexDirection: 'row',
    alignItems: 'center',
  },
  eventDescription: {
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 12,
  },
  eventFooter: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
  },
  typeChip: {
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
});

export default EventsScreen;