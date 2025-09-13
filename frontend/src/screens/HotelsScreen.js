import React, { useState, useEffect } from 'react';
import { View, StyleSheet, FlatList, Alert } from 'react-native';
import { Text, Card, ActivityIndicator } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { hotelsAPI } from '../services/api';

const HotelsScreen = ({ navigation }) => {
  const { theme } = useTheme();
  const [hotels, setHotels] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadHotels();
  }, []);

  const loadHotels = async () => {
    try {
      setLoading(true);
      const response = await hotelsAPI.getAll();
      setHotels(response.data.hotels);
    } catch (error) {
      console.error('Error loading hotels:', error);
      Alert.alert('Error', 'Failed to load hotels');
    } finally {
      setLoading(false);
    }
  };

  const renderHotelCard = ({ item }) => (
    <Card
      style={[styles.hotelCard, { backgroundColor: theme.colors.surface }]}
      onPress={() => navigation.navigate('HotelDetail', { hotelId: item.id })}
    >
      <Card.Cover
        source={{ uri: item.primary_image || 'https://via.placeholder.com/300x200' }}
        style={styles.hotelImage}
      />
      <Card.Content>
        <Text style={[styles.hotelName, { color: theme.colors.text }]}>
          {item.name}
        </Text>
        <Text style={[styles.hotelLocation, { color: theme.colors.placeholder }]}>
          {item.location}
        </Text>
        <Text style={[styles.hotelPrice, { color: theme.colors.primary }]}>
          {item.price_range} • Rating: {item.rating}
        </Text>
      </Card.Content>
    </Card>
  );

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { backgroundColor: theme.colors.background }]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={[styles.loadingText, { color: theme.colors.text }]}>
          Loading hotels...
        </Text>
      </View>
    );
  }

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <FlatList
        data={hotels}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderHotelCard}
        contentContainerStyle={styles.listContainer}
        showsVerticalScrollIndicator={false}
      />
    </View>
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
  listContainer: {
    padding: 16,
  },
  hotelCard: {
    marginBottom: 16,
    elevation: 2,
  },
  hotelImage: {
    height: 200,
  },
  hotelName: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  hotelLocation: {
    fontSize: 14,
    marginBottom: 4,
  },
  hotelPrice: {
    fontSize: 16,
    fontWeight: '600',
  },
});

export default HotelsScreen;