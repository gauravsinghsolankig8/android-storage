import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { Text, Card, ActivityIndicator } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { parikramaAPI } from '../services/api';

const ParikramaDetailScreen = ({ navigation, route }) => {
  const { theme } = useTheme();
  const { routeId } = route.params;
  const [route, setRoute] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadRouteDetails();
  }, [routeId]);

  const loadRouteDetails = async () => {
    try {
      setLoading(true);
      const response = await parikramaAPI.getRouteById(routeId);
      setRoute(response.data);
    } catch (error) {
      console.error('Error loading route details:', error);
      Alert.alert('Error', 'Failed to load route details');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { backgroundColor: theme.colors.background }]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={[styles.loadingText, { color: theme.colors.text }]}>
          Loading route details...
        </Text>
      </View>
    );
  }

  if (!route) {
    return (
      <View style={[styles.errorContainer, { backgroundColor: theme.colors.background }]}>
        <Ionicons name="alert-circle-outline" size={64} color={theme.colors.error} />
        <Text style={[styles.errorText, { color: theme.colors.text }]}>
          Route not found
        </Text>
      </View>
    );
  }

  return (
    <ScrollView style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <Card style={[styles.routeCard, { backgroundColor: theme.colors.surface }]}>
        <Card.Content>
          <Text style={[styles.routeName, { color: theme.colors.text }]}>
            {route.name}
          </Text>
          <Text style={[styles.routeDescription, { color: theme.colors.text }]}>
            {route.description}
          </Text>
          <Text style={[styles.routeDistance, { color: theme.colors.primary }]}>
            Distance: {route.total_distance} km
          </Text>
          <Text style={[styles.routeTime, { color: theme.colors.primary }]}>
            Estimated Time: {route.estimated_time} minutes
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
  routeCard: {
    margin: 16,
    elevation: 2,
  },
  routeName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  routeDescription: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 16,
  },
  routeDistance: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  routeTime: {
    fontSize: 16,
    fontWeight: '600',
  },
});

export default ParikramaDetailScreen;