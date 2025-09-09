import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { Text, Card, ActivityIndicator, Button } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { storeAPI } from '../services/api';

const ProductDetailScreen = ({ navigation, route }) => {
  const { theme } = useTheme();
  const { productId } = route.params;
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadProductDetails();
  }, [productId]);

  const loadProductDetails = async () => {
    try {
      setLoading(true);
      const response = await storeAPI.getProductById(productId);
      setProduct(response.data);
    } catch (error) {
      console.error('Error loading product details:', error);
      Alert.alert('Error', 'Failed to load product details');
    } finally {
      setLoading(false);
    }
  };

  const handleAddToCart = () => {
    Alert.alert('Success', 'Product added to cart');
  };

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { backgroundColor: theme.colors.background }]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={[styles.loadingText, { color: theme.colors.text }]}>
          Loading product details...
        </Text>
      </View>
    );
  }

  if (!product) {
    return (
      <View style={[styles.errorContainer, { backgroundColor: theme.colors.background }]}>
        <Ionicons name="alert-circle-outline" size={64} color={theme.colors.error} />
        <Text style={[styles.errorText, { color: theme.colors.text }]}>
          Product not found
        </Text>
      </View>
    );
  }

  return (
    <ScrollView style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <Card style={[styles.productCard, { backgroundColor: theme.colors.surface }]}>
        <Card.Cover
          source={{ uri: product.primary_image || 'https://via.placeholder.com/300x300' }}
          style={styles.productImage}
        />
        <Card.Content>
          <Text style={[styles.productName, { color: theme.colors.text }]}>
            {product.name}
          </Text>
          <Text style={[styles.productPrice, { color: theme.colors.primary }]}>
            ₹{product.price}
          </Text>
          {product.description && (
            <Text style={[styles.productDescription, { color: theme.colors.text }]}>
              {product.description}
            </Text>
          )}
          <Text style={[styles.productCategory, { color: theme.colors.placeholder }]}>
            Category: {product.category}
          </Text>
          <Text style={[styles.productStock, { color: theme.colors.placeholder }]}>
            Stock: {product.stock}
          </Text>
        </Card.Content>
      </Card>
      
      <View style={styles.actionContainer}>
        <Button
          mode="contained"
          onPress={handleAddToCart}
          style={[styles.addToCartButton, { backgroundColor: theme.colors.primary }]}
          icon="shopping-cart"
        >
          Add to Cart
        </Button>
      </View>
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
  productCard: {
    margin: 16,
    elevation: 2,
  },
  productImage: {
    height: 300,
  },
  productName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  productPrice: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  productDescription: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 16,
  },
  productCategory: {
    fontSize: 14,
    marginBottom: 4,
  },
  productStock: {
    fontSize: 14,
    marginBottom: 16,
  },
  actionContainer: {
    padding: 16,
  },
  addToCartButton: {
    paddingVertical: 8,
  },
});

export default ProductDetailScreen;