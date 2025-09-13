import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';

const FavoritesScreen = ({ navigation }) => {
  const { theme } = useTheme();

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <View style={styles.emptyState}>
        <Ionicons name="heart-outline" size={64} color={theme.colors.placeholder} />
        <Text style={[styles.emptyTitle, { color: theme.colors.text }]}>
          No Favorites Yet
        </Text>
        <Text style={[styles.emptyDescription, { color: theme.colors.placeholder }]}>
          Start exploring and add items to your favorites
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
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
});

export default FavoritesScreen;