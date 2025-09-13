import React, { useState, useEffect } from 'react';
import { View, StyleSheet, FlatList, Alert } from 'react-native';
import { Text, Card, ActivityIndicator } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { parikramaAPI } from '../services/api';

const ParikramaScreen = ({ navigation }) => {
  const { theme } = useTheme();
  const [routes, setRoutes] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadRoutes();
  }, []);

  const loadRoutes = async () => {
    try {
      setLoading(true);
      const response = await parikramaAPI.getRoutes();
      setRoutes(response.data.routes);
    } catch (error) {
      console.error('Error loading routes:', error);
      Alert.alert('Error', 'Failed to load parikrama routes');
    } finally {
      setLoading(false);
    }
  };

  const renderRouteCard = ({ item }) => (
    <Card
      style={[styles.routeCard, { backgroundColor: theme.colors.surface }]}
      onPress={() => navigation.navigate('ParikramaDetail', { routeId: item.id })}
    >
      <Card.Content>
        <Text style={[styles.routeName, { color: theme.colors.text }]}>
          {item.name}
        </Text>
        <Text style={[styles.routeDescription, { color: theme.colors.placeholder }]}>
          {item.description}
        </Text>
        <View style={styles.routeInfo}>
          <Text style={[styles.routeDistance, { color: theme.colors.primary }]}>
            {item.total_distance} km
          </Text>
          <Text style={[styles.routeTime, { color: theme.colors.primary }]}>
            {item.estimated_time} min
          </Text>
        </View>
      </Card.Content>
    </Card>
  );

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { backgroundColor: theme.colors.background }]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={[styles.loadingText, { color: theme.colors.text }]}>
          Loading parikrama routes...
        </Text>
      </View>
    );
  }

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <FlatList
        data={routes}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderRouteCard}
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
  routeCard: {
    marginBottom: 16,
    elevation: 2,
  },
  routeName: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  routeDescription: {
    fontSize: 16,
    lineHeight: 22,
    marginBottom: 12,
  },
  routeInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  routeDistance: {
    fontSize: 16,
    fontWeight: '600',
  },
  routeTime: {
    fontSize: 16,
    fontWeight: '600',
  },
});

export default ParikramaScreen;