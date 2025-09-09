import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { Text, Card, ActivityIndicator } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { saintsAPI } from '../services/api';

const SaintDetailScreen = ({ navigation, route }) => {
  const { theme } = useTheme();
  const { saintId } = route.params;
  const [saint, setSaint] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadSaintDetails();
  }, [saintId]);

  const loadSaintDetails = async () => {
    try {
      setLoading(true);
      const response = await saintsAPI.getById(saintId);
      setSaint(response.data);
    } catch (error) {
      console.error('Error loading saint details:', error);
      Alert.alert('Error', 'Failed to load saint details');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { backgroundColor: theme.colors.background }]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={[styles.loadingText, { color: theme.colors.text }]}>
          Loading saint details...
        </Text>
      </View>
    );
  }

  if (!saint) {
    return (
      <View style={[styles.errorContainer, { backgroundColor: theme.colors.background }]}>
        <Ionicons name="alert-circle-outline" size={64} color={theme.colors.error} />
        <Text style={[styles.errorText, { color: theme.colors.text }]}>
          Saint not found
        </Text>
      </View>
    );
  }

  return (
    <ScrollView style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <Card style={[styles.saintCard, { backgroundColor: theme.colors.surface }]}>
        <Card.Content>
          <Text style={[styles.saintName, { color: theme.colors.text }]}>
            {saint.name}
          </Text>
          {saint.sect && (
            <Text style={[styles.saintSect, { color: theme.colors.placeholder }]}>
              {saint.sect}
            </Text>
          )}
          {saint.bio && (
            <Text style={[styles.saintBio, { color: theme.colors.text }]}>
              {saint.bio}
            </Text>
          )}
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
  saintCard: {
    margin: 16,
    elevation: 2,
  },
  saintName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  saintSect: {
    fontSize: 16,
    marginBottom: 16,
  },
  saintBio: {
    fontSize: 16,
    lineHeight: 24,
  },
});

export default SaintDetailScreen;