import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { Text, Card, ActivityIndicator } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { hotelsAPI } from '../services/api';

const HotelDetailScreen = ({ navigation, route }) => {
  const { theme } = useTheme();
  const { hotelId } = route.params;
  const [hotel, setHotel] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadHotelDetails();
  }, [hotelId]);

  const loadHotelDetails = async () => {
    try {
      setLoading(true);
      const response = await hotelsAPI.getById(hotelId);
      setHotel(response.data);
    } catch (error) {
      console.error('Error loading hotel details:', error);
      Alert.alert('Error', 'Failed to load hotel details');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { backgroundColor: theme.colors.background }]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={[styles.loadingText, { color: theme.colors.text }]}>
          Loading hotel details...
        </Text>
      </View>
    );
  }

  if (!hotel) {
    return (
      <View style={[styles.errorContainer, { backgroundColor: theme.colors.background }]}>
        <Ionicons name="alert-circle-outline" size={64} color={theme.colors.error} />
        <Text style={[styles.errorText, { color: theme.colors.text }]}>
          Hotel not found
        </Text>
      </View>
    );
  }

  return (
    <ScrollView style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <Card style={[styles.hotelCard, { backgroundColor: theme.colors.surface }]}>
        <Card.Content>
          <Text style={[styles.hotelName, { color: theme.colors.text }]}>
            {hotel.name}
          </Text>
          <Text style={[styles.hotelLocation, { color: theme.colors.placeholder }]}>
            {hotel.location}
          </Text>
          <Text style={[styles.hotelPrice, { color: theme.colors.primary }]}>
            Price Range: {hotel.price_range}
          </Text>
          <Text style={[styles.hotelRating, { color: theme.colors.primary }]}>
            Rating: {hotel.rating}
          </Text>
        </Card.Content>
      </Card>
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
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  errorText: {
    fontSize: 18,
    marginTop: 16,
    textAlign: 'center',
  },
  hotelCard: {
    margin: 16,
    elevation: 2,
  },
  hotelName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  hotelLocation: {
    fontSize: 16,
    marginBottom: 8,
  },
  hotelPrice: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  hotelRating: {
    fontSize: 16,
    fontWeight: '600',
  },
});

export default HotelDetailScreen;