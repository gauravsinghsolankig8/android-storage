import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  StyleSheet,
  Dimensions,
  ScrollView,
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
} from 'react-native-paper';
import MapView, { Marker, PROVIDER_GOOGLE } from 'react-native-maps';
import { Ionicons } from '@expo/vector-icons';
import * as Location from 'expo-location';
import { useTheme } from '../context/ThemeContext';
import { templesAPI, eventsAPI, darshanAPI } from '../services/api';

const { width, height } = Dimensions.get('window');

const HomeScreen = ({ navigation }) => {
  const { theme } = useTheme();
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [userLocation, setUserLocation] = useState(null);
  const [nearbyTemples, setNearbyTemples] = useState([]);
  const [upcomingEvents, setUpcomingEvents] = useState([]);
  const [todaysDarshan, setTodaysDarshan] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState('all');
  
  const mapRef = useRef(null);

  const categories = [
    { id: 'all', label: 'All', icon: 'apps' },
    { id: 'temples', label: 'Temples', icon: 'library' },
    { id: 'events', label: 'Events', icon: 'calendar' },
    { id: 'hotels', label: 'Hotels', icon: 'bed' },
  ];

  useEffect(() => {
    initializeLocation();
    loadData();
  }, []);

  const initializeLocation = async () => {
    try {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permission denied', 'Location permission is required to show nearby places');
        return;
      }

      const location = await Location.getCurrentPositionAsync({});
      setUserLocation({
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
        latitudeDelta: 0.01,
        longitudeDelta: 0.01,
      });
    } catch (error) {
      console.error('Error getting location:', error);
      // Default to Vrindavan coordinates
      setUserLocation({
        latitude: 27.5848,
        longitude: 77.6964,
        latitudeDelta: 0.01,
        longitudeDelta: 0.01,
      });
    }
  };

  const loadData = async () => {
    try {
      setLoading(true);
      await Promise.all([
        loadNearbyTemples(),
        loadUpcomingEvents(),
        loadTodaysDarshan(),
      ]);
    } catch (error) {
      console.error('Error loading data:', error);
      Alert.alert('Error', 'Failed to load data. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const loadNearbyTemples = async () => {
    try {
      if (userLocation) {
        const response = await templesAPI.getNearby(
          userLocation.latitude,
          userLocation.longitude,
          5
        );
        setNearbyTemples(response.data.temples);
      }
    } catch (error) {
      console.error('Error loading nearby temples:', error);
    }
  };

  const loadUpcomingEvents = async () => {
    try {
      const response = await eventsAPI.getUpcoming(5);
      setUpcomingEvents(response.data.events);
    } catch (error) {
      console.error('Error loading upcoming events:', error);
    }
  };

  const loadTodaysDarshan = async () => {
    try {
      const response = await darshanAPI.getToday();
      setTodaysDarshan(response.data.darshan);
    } catch (error) {
      console.error('Error loading today\'s darshan:', error);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const handleSearch = () => {
    if (searchQuery.trim()) {
      // Navigate to search results
      navigation.navigate('Temples', { search: searchQuery });
    }
  };

  const handleMarkerPress = (item, type) => {
    if (type === 'temple') {
      navigation.navigate('TempleDetail', { templeId: item.id });
    } else if (type === 'event') {
      navigation.navigate('EventDetail', { eventId: item.id });
    }
  };

  const renderMap = () => (
    <View style={styles.mapContainer}>
      <MapView
        ref={mapRef}
        style={styles.map}
        provider={PROVIDER_GOOGLE}
        initialRegion={userLocation}
        showsUserLocation
        showsMyLocationButton
      >
        {nearbyTemples.map((temple) => (
          <Marker
            key={`temple-${temple.id}`}
            coordinate={{
              latitude: parseFloat(temple.lat),
              longitude: parseFloat(temple.lng),
            }}
            title={temple.name}
            description={temple.location}
            onPress={() => handleMarkerPress(temple, 'temple')}
          >
            <View style={[styles.marker, { backgroundColor: theme.colors.temple }]}>
              <Ionicons name="library" size={20} color="white" />
            </View>
          </Marker>
        ))}
      </MapView>
    </View>
  );

  const renderQuickActions = () => (
    <View style={styles.quickActions}>
      <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
        Quick Actions
      </Text>
      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        <View style={styles.actionButtons}>
          <Button
            mode="contained"
            onPress={() => navigation.navigate('Parikrama')}
            style={[styles.actionButton, { backgroundColor: theme.colors.parikrama }]}
            icon="walk"
          >
            Parikrama
          </Button>
          <Button
            mode="contained"
            onPress={() => navigation.navigate('Store')}
            style={[styles.actionButton, { backgroundColor: theme.colors.store }]}
            icon="storefront"
          >
            Store
          </Button>
          <Button
            mode="contained"
            onPress={() => navigation.navigate('Hotels')}
            style={[styles.actionButton, { backgroundColor: theme.colors.hotel }]}
            icon="bed"
          >
            Hotels
          </Button>
          <Button
            mode="contained"
            onPress={() => navigation.navigate('Notifications')}
            style={[styles.actionButton, { backgroundColor: theme.colors.info }]}
            icon="bell"
          >
            Notifications
          </Button>
        </View>
      </ScrollView>
    </View>
  );

  const renderCategories = () => (
    <View style={styles.categories}>
      <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
        Categories
      </Text>
      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        <View style={styles.categoryChips}>
          {categories.map((category) => (
            <Chip
              key={category.id}
              selected={selectedCategory === category.id}
              onPress={() => setSelectedCategory(category.id)}
              style={[
                styles.categoryChip,
                selectedCategory === category.id && {
                  backgroundColor: theme.colors.primary,
                },
              ]}
              textStyle={{
                color: selectedCategory === category.id ? 'white' : theme.colors.text,
              }}
              icon={category.icon}
            >
              {category.label}
            </Chip>
          ))}
        </View>
      </ScrollView>
    </View>
  );

  const renderUpcomingEvents = () => (
    <View style={styles.eventsSection}>
      <View style={styles.sectionHeader}>
        <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
          Upcoming Events
        </Text>
        <Button
          mode="text"
          onPress={() => navigation.navigate('Events')}
          compact
        >
          View All
        </Button>
      </View>
      
      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        <View style={styles.eventCards}>
          {upcomingEvents.map((event) => (
            <Card
              key={event.id}
              style={[styles.eventCard, { backgroundColor: theme.colors.surface }]}
              onPress={() => handleMarkerPress(event, 'event')}
            >
              <Card.Content style={styles.eventCardContent}>
                <Text style={[styles.eventTitle, { color: theme.colors.text }]}>
                  {event.name}
                </Text>
                <Text style={[styles.eventDate, { color: theme.colors.placeholder }]}>
                  {new Date(event.start_date).toLocaleDateString()}
                </Text>
                <Text style={[styles.eventDescription, { color: theme.colors.text }]}>
                  {event.description?.substring(0, 80)}...
                </Text>
              </Card.Content>
            </Card>
          ))}
        </View>
      </ScrollView>
    </View>
  );

  const renderTodaysDarshan = () => (
    <View style={styles.darshanSection}>
      <View style={styles.sectionHeader}>
        <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
          Today's Darshan
        </Text>
        <Button
          mode="text"
          onPress={() => navigation.navigate('Temples')}
          compact
        >
          View All
        </Button>
      </View>
      
      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        <View style={styles.darshanCards}>
          {todaysDarshan.map((darshan) => (
            <Card
              key={darshan.id}
              style={[styles.darshanCard, { backgroundColor: theme.colors.surface }]}
              onPress={() => navigation.navigate('TempleDetail', { templeId: darshan.temple_id })}
            >
              <Card.Cover
                source={{ uri: darshan.image_url }}
                style={styles.darshanImage}
              />
              <Card.Content style={styles.darshanCardContent}>
                <Text style={[styles.darshanTemple, { color: theme.colors.text }]}>
                  {darshan.temple_name}
                </Text>
                <Text style={[styles.darshanCaption, { color: theme.colors.placeholder }]}>
                  {darshan.caption}
                </Text>
              </Card.Content>
            </Card>
          ))}
        </View>
      </ScrollView>
    </View>
  );

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { backgroundColor: theme.colors.background }]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={[styles.loadingText, { color: theme.colors.text }]}>
          Loading...
        </Text>
      </View>
    );
  }

  return (
    <ScrollView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <Searchbar
          placeholder="Search temples, events, hotels..."
          onChangeText={setSearchQuery}
          value={searchQuery}
          onSubmitEditing={handleSearch}
          style={styles.searchBar}
        />
      </View>

      {/* Map */}
      {userLocation && renderMap()}

      {/* Quick Actions */}
      {renderQuickActions()}

      {/* Categories */}
      {renderCategories()}

      {/* Upcoming Events */}
      {renderUpcomingEvents()}

      {/* Today's Darshan */}
      {renderTodaysDarshan()}
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
  searchContainer: {
    padding: 16,
  },
  searchBar: {
    elevation: 2,
  },
  mapContainer: {
    height: 250,
    marginHorizontal: 16,
    marginBottom: 16,
    borderRadius: 12,
    overflow: 'hidden',
  },
  map: {
    flex: 1,
  },
  marker: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  quickActions: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginHorizontal: 16,
    marginBottom: 12,
  },
  actionButtons: {
    flexDirection: 'row',
    paddingHorizontal: 16,
  },
  actionButton: {
    marginRight: 12,
    borderRadius: 20,
  },
  categories: {
    marginBottom: 20,
  },
  categoryChips: {
    flexDirection: 'row',
    paddingHorizontal: 16,
  },
  categoryChip: {
    marginRight: 8,
  },
  eventsSection: {
    marginBottom: 20,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    marginBottom: 12,
  },
  eventCards: {
    flexDirection: 'row',
    paddingHorizontal: 16,
  },
  eventCard: {
    width: 200,
    marginRight: 12,
    elevation: 2,
  },
  eventCardContent: {
    padding: 12,
  },
  eventTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  eventDate: {
    fontSize: 12,
    marginBottom: 8,
  },
  eventDescription: {
    fontSize: 14,
    lineHeight: 18,
  },
  darshanSection: {
    marginBottom: 20,
  },
  darshanCards: {
    flexDirection: 'row',
    paddingHorizontal: 16,
  },
  darshanCard: {
    width: 150,
    marginRight: 12,
    elevation: 2,
  },
  darshanImage: {
    height: 100,
  },
  darshanCardContent: {
    padding: 8,
  },
  darshanTemple: {
    fontSize: 14,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  darshanCaption: {
    fontSize: 12,
    lineHeight: 16,
  },
});

export default HomeScreen;