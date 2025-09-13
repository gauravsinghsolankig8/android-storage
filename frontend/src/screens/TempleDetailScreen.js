import React, { useState, useEffect } from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  Dimensions,
  Alert,
  Share,
} from 'react-native';
import {
  Text,
  Card,
  Button,
  Chip,
  ActivityIndicator,
  Divider,
  IconButton,
} from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import { templesAPI } from '../services/api';
import ImageViewer from 'react-native-image-zoom-viewer';

const { width } = Dimensions.get('window');

const TempleDetailScreen = ({ navigation, route }) => {
  const { theme } = useTheme();
  const { isAuthenticated } = useAuth();
  const { templeId } = route.params;
  
  const [temple, setTemple] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isFavorite, setIsFavorite] = useState(false);
  const [showImageViewer, setShowImageViewer] = useState(false);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  useEffect(() => {
    loadTempleDetails();
  }, [templeId]);

  const loadTempleDetails = async () => {
    try {
      setLoading(true);
      const response = await templesAPI.getById(templeId);
      setTemple(response.data);
    } catch (error) {
      console.error('Error loading temple details:', error);
      Alert.alert('Error', 'Failed to load temple details');
    } finally {
      setLoading(false);
    }
  };

  const handleFavorite = async () => {
    if (!isAuthenticated) {
      Alert.alert('Login Required', 'Please login to add favorites');
      return;
    }

    try {
      if (isFavorite) {
        await templesAPI.removeFavorite(templeId);
        setIsFavorite(false);
        Alert.alert('Success', 'Removed from favorites');
      } else {
        await templesAPI.addFavorite(templeId);
        setIsFavorite(true);
        Alert.alert('Success', 'Added to favorites');
      }
    } catch (error) {
      console.error('Error toggling favorite:', error);
      Alert.alert('Error', 'Failed to update favorites');
    }
  };

  const handleShare = async () => {
    try {
      await Share.share({
        message: `Check out ${temple.name} in Vrindavan! Download Saranam app to explore more temples.`,
        url: 'https://saranam.app', // Replace with your app store URL
      });
    } catch (error) {
      console.error('Error sharing:', error);
    }
  };

  const handleImagePress = (index) => {
    setCurrentImageIndex(index);
    setShowImageViewer(true);
  };

  const renderHeader = () => (
    <View style={styles.header}>
      <IconButton
        icon="arrow-left"
        size={24}
        onPress={() => navigation.goBack()}
        style={styles.backButton}
      />
      <View style={styles.headerActions}>
        <IconButton
          icon={isFavorite ? "heart" : "heart-outline"}
          size={24}
          onPress={handleFavorite}
          style={styles.favoriteButton}
        />
        <IconButton
          icon="share"
          size={24}
          onPress={handleShare}
          style={styles.shareButton}
        />
      </View>
    </View>
  );

  const renderImageGallery = () => {
    if (!temple.images || temple.images.length === 0) {
      return (
        <View style={styles.noImageContainer}>
          <Ionicons name="image-outline" size={64} color={theme.colors.placeholder} />
          <Text style={[styles.noImageText, { color: theme.colors.placeholder }]}>
            No images available
          </Text>
        </View>
      );
    }

    return (
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        style={styles.imageGallery}
        contentContainerStyle={styles.imageGalleryContent}
      >
        {temple.images.map((image, index) => (
          <Card
            key={image.id}
            style={[styles.imageCard, { backgroundColor: theme.colors.surface }]}
            onPress={() => handleImagePress(index)}
          >
            <Card.Cover
              source={{ uri: image.image_url }}
              style={styles.galleryImage}
            />
            {image.caption && (
              <Card.Content style={styles.imageCaption}>
                <Text style={[styles.captionText, { color: theme.colors.text }]}>
                  {image.caption}
                </Text>
              </Card.Content>
            )}
          </Card>
        ))}
      </ScrollView>
    );
  };

  const renderTempleInfo = () => (
    <Card style={[styles.infoCard, { backgroundColor: theme.colors.surface }]}>
      <Card.Content>
        <Text style={[styles.templeName, { color: theme.colors.text }]}>
          {temple.name}
        </Text>
        
        <View style={styles.locationContainer}>
          <Ionicons name="location-outline" size={20} color={theme.colors.placeholder} />
          <Text style={[styles.location, { color: theme.colors.placeholder }]}>
            {temple.location}
          </Text>
        </View>

        {temple.description && (
          <Text style={[styles.description, { color: theme.colors.text }]}>
            {temple.description}
          </Text>
        )}

        {temple.history && (
          <View style={styles.section}>
            <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
              History
            </Text>
            <Text style={[styles.sectionContent, { color: theme.colors.text }]}>
              {temple.history}
            </Text>
          </View>
        )}
      </Card.Content>
    </Card>
  );

  const renderTimings = () => {
    if (!temple.timings) return null;

    const timings = typeof temple.timings === 'string' 
      ? JSON.parse(temple.timings) 
      : temple.timings;

    return (
      <Card style={[styles.timingsCard, { backgroundColor: theme.colors.surface }]}>
        <Card.Content>
          <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
            Temple Timings
          </Text>
          
          {Object.entries(timings).map(([key, value]) => (
            <View key={key} style={styles.timingRow}>
              <Text style={[styles.timingLabel, { color: theme.colors.text }]}>
                {key.charAt(0).toUpperCase() + key.slice(1)}:
              </Text>
              <Text style={[styles.timingValue, { color: theme.colors.primary }]}>
                {value}
              </Text>
            </View>
          ))}
        </Card.Content>
      </Card>
    );
  };

  const renderAmenities = () => {
    if (!temple.amenities) return null;

    const amenities = typeof temple.amenities === 'string' 
      ? JSON.parse(temple.amenities) 
      : temple.amenities;

    return (
      <Card style={[styles.amenitiesCard, { backgroundColor: theme.colors.surface }]}>
        <Card.Content>
          <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
            Amenities
          </Text>
          
          <View style={styles.amenitiesContainer}>
            {amenities.map((amenity, index) => (
              <Chip
                key={index}
                icon="check"
                style={[styles.amenityChip, { backgroundColor: theme.colors.success + '20' }]}
                textStyle={{ color: theme.colors.success }}
              >
                {amenity.replace('_', ' ').toUpperCase()}
              </Chip>
            ))}
          </View>
        </Card.Content>
      </Card>
    );
  };

  const renderRituals = () => {
    if (!temple.rituals) return null;

    const rituals = typeof temple.rituals === 'string' 
      ? JSON.parse(temple.rituals) 
      : temple.rituals;

    return (
      <Card style={[styles.ritualsCard, { backgroundColor: theme.colors.surface }]}>
        <Card.Content>
          <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
            Daily Rituals
          </Text>
          
          {rituals.map((ritual, index) => (
            <View key={index} style={styles.ritualRow}>
              <Ionicons name="time-outline" size={16} color={theme.colors.primary} />
              <Text style={[styles.ritualText, { color: theme.colors.text }]}>
                {ritual.replace('_', ' ').toUpperCase()}
              </Text>
            </View>
          ))}
        </Card.Content>
      </Card>
    );
  };

  const renderNearbyTemples = () => {
    if (!temple.nearbyTemples || temple.nearbyTemples.length === 0) return null;

    return (
      <Card style={[styles.nearbyCard, { backgroundColor: theme.colors.surface }]}>
        <Card.Content>
          <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
            Nearby Temples
          </Text>
          
          {temple.nearbyTemples.map((nearbyTemple) => (
            <Button
              key={nearbyTemple.id}
              mode="outlined"
              onPress={() => navigation.navigate('TempleDetail', { templeId: nearbyTemple.id })}
              style={[styles.nearbyButton, { borderColor: theme.colors.primary }]}
              contentStyle={styles.nearbyButtonContent}
            >
              {nearbyTemple.name}
            </Button>
          ))}
        </Card.Content>
      </Card>
    );
  };

  const renderActionButtons = () => (
    <View style={styles.actionButtons}>
      <Button
        mode="contained"
        onPress={() => {
          // Navigate to directions
          Alert.alert('Directions', 'Opening in maps app...');
        }}
        style={[styles.actionButton, { backgroundColor: theme.colors.primary }]}
        icon="directions"
      >
        Get Directions
      </Button>
      
      <Button
        mode="outlined"
        onPress={() => {
          // Navigate to darshan
          navigation.navigate('Temples', { templeId, showDarshan: true });
        }}
        style={[styles.actionButton, { borderColor: theme.colors.primary }]}
        icon="eye"
      >
        View Darshan
      </Button>
    </View>
  );

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { backgroundColor: theme.colors.background }]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={[styles.loadingText, { color: theme.colors.text }]}>
          Loading temple details...
        </Text>
      </View>
    );
  }

  if (!temple) {
    return (
      <View style={[styles.errorContainer, { backgroundColor: theme.colors.background }]}>
        <Ionicons name="alert-circle-outline" size={64} color={theme.colors.error} />
        <Text style={[styles.errorText, { color: theme.colors.text }]}>
          Temple not found
        </Text>
        <Button
          mode="contained"
          onPress={() => navigation.goBack()}
          style={{ backgroundColor: theme.colors.primary }}
        >
          Go Back
        </Button>
      </View>
    );
  }

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      {renderHeader()}
      
      <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
        {renderImageGallery()}
        {renderTempleInfo()}
        {renderTimings()}
        {renderAmenities()}
        {renderRituals()}
        {renderNearbyTemples()}
        {renderActionButtons()}
      </ScrollView>

      {/* Image Viewer Modal */}
      {showImageViewer && (
        <ImageViewer
          imageUrls={temple.images.map(img => ({ url: img.image_url }))}
          index={currentImageIndex}
          onCancel={() => setShowImageViewer(false)}
          enableSwipeDown
          onSwipeDown={() => setShowImageViewer(false)}
        />
      )}
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
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  errorText: {
    fontSize: 18,
    marginVertical: 16,
    textAlign: 'center',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingTop: 8,
    zIndex: 1,
  },
  backButton: {
    margin: 0,
  },
  headerActions: {
    flexDirection: 'row',
  },
  favoriteButton: {
    margin: 0,
  },
  shareButton: {
    margin: 0,
  },
  scrollView: {
    flex: 1,
  },
  noImageContainer: {
    height: 200,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  noImageText: {
    marginTop: 8,
    fontSize: 16,
  },
  imageGallery: {
    marginBottom: 16,
  },
  imageGalleryContent: {
    paddingHorizontal: 16,
  },
  imageCard: {
    width: 200,
    marginRight: 12,
    elevation: 2,
  },
  galleryImage: {
    height: 120,
  },
  imageCaption: {
    padding: 8,
  },
  captionText: {
    fontSize: 12,
    textAlign: 'center',
  },
  infoCard: {
    margin: 16,
    marginTop: 0,
    elevation: 2,
  },
  templeName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  locationContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  location: {
    fontSize: 16,
    marginLeft: 8,
    flex: 1,
  },
  description: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 16,
  },
  section: {
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  sectionContent: {
    fontSize: 16,
    lineHeight: 24,
  },
  timingsCard: {
    margin: 16,
    marginTop: 0,
    elevation: 2,
  },
  timingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
  },
  timingLabel: {
    fontSize: 16,
    fontWeight: '500',
  },
  timingValue: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  amenitiesCard: {
    margin: 16,
    marginTop: 0,
    elevation: 2,
  },
  amenitiesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  amenityChip: {
    marginRight: 8,
    marginBottom: 8,
  },
  ritualsCard: {
    margin: 16,
    marginTop: 0,
    elevation: 2,
  },
  ritualRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 4,
  },
  ritualText: {
    fontSize: 16,
    marginLeft: 8,
  },
  nearbyCard: {
    margin: 16,
    marginTop: 0,
    elevation: 2,
  },
  nearbyButton: {
    marginBottom: 8,
  },
  nearbyButtonContent: {
    paddingVertical: 4,
  },
  actionButtons: {
    flexDirection: 'row',
    padding: 16,
    paddingTop: 0,
  },
  actionButton: {
    flex: 1,
    marginHorizontal: 4,
  },
});

export default TempleDetailScreen;