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
  FAB,
  Badge,
} from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import { storeAPI } from '../services/api';

const StoreScreen = ({ navigation }) => {
  const { theme } = useTheme();
  const { isAuthenticated } = useAuth();
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [cartCount, setCartCount] = useState(0);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);

  const categories = [
    { id: 'all', label: 'All', icon: 'apps' },
    { id: 'books', label: 'Books', icon: 'book' },
    { id: 'malas', label: 'Malas', icon: 'circle' },
    { id: 'prasad', label: 'Prasad', icon: 'food' },
    { id: 'clothing', label: 'Clothing', icon: 'shirt' },
    { id: 'accessories', label: 'Accessories', icon: 'star' },
  ];

  useEffect(() => {
    loadProducts();
  }, [searchQuery, selectedCategory]);

  const loadProducts = async (pageNum = 1, isRefresh = false) => {
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
        category: selectedCategory === 'all' ? undefined : selectedCategory,
        in_stock: true,
      };

      const response = await storeAPI.getProducts(params);
      const newProducts = response.data.products;

      if (pageNum === 1) {
        setProducts(newProducts);
      } else {
        setProducts(prev => [...prev, ...newProducts]);
      }

      setHasMore(newProducts.length === 20);
      setPage(pageNum);
    } catch (error) {
      console.error('Error loading products:', error);
      Alert.alert('Error', 'Failed to load products. Please try again.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setPage(1);
    loadProducts(1, true);
  };

  const loadMore = () => {
    if (hasMore && !loading) {
      loadProducts(page + 1);
    }
  };

  const handleSearch = (query) => {
    setSearchQuery(query);
    setPage(1);
  };

  const handleProductPress = (product) => {
    navigation.navigate('ProductDetail', { productId: product.id });
  };

  const handleAddToCart = async (product) => {
    if (!isAuthenticated) {
      Alert.alert('Login Required', 'Please login to add items to cart');
      return;
    }

    try {
      // Add to cart logic here
      setCartCount(prev => prev + 1);
      Alert.alert('Success', `${product.name} added to cart`);
    } catch (error) {
      console.error('Error adding to cart:', error);
      Alert.alert('Error', 'Failed to add to cart');
    }
  };

  const handleFavorite = async (productId) => {
    if (!isAuthenticated) {
      Alert.alert('Login Required', 'Please login to add favorites');
      return;
    }

    try {
      await storeAPI.addFavorite(productId);
      Alert.alert('Success', 'Product added to favorites');
    } catch (error) {
      console.error('Error adding favorite:', error);
      Alert.alert('Error', 'Failed to add to favorites');
    }
  };

  const renderProductCard = ({ item }) => (
    <Card
      style={[styles.productCard, { backgroundColor: theme.colors.surface }]}
      onPress={() => handleProductPress(item)}
    >
      <View style={styles.productImageContainer}>
        <Card.Cover
          source={{ uri: item.primary_image || 'https://via.placeholder.com/200x200' }}
          style={styles.productImage}
        />
        <View style={styles.productActions}>
          <Ionicons
            name="heart-outline"
            size={20}
            color={theme.colors.primary}
            onPress={() => handleFavorite(item.id)}
            style={styles.favoriteIcon}
          />
        </View>
      </View>
      
      <Card.Content style={styles.productContent}>
        <Text style={[styles.productName, { color: theme.colors.text }]}>
          {item.name}
        </Text>
        
        {item.description && (
          <Text style={[styles.productDescription, { color: theme.colors.placeholder }]}>
            {item.description.substring(0, 60)}...
          </Text>
        )}
        
        <View style={styles.productFooter}>
          <Text style={[styles.productPrice, { color: theme.colors.primary }]}>
            ₹{item.price}
          </Text>
          
          <Chip
            icon="shopping-cart"
            onPress={() => handleAddToCart(item)}
            style={[styles.addToCartChip, { backgroundColor: theme.colors.primary }]}
            textStyle={{ color: 'white' }}
          >
            Add
          </Chip>
        </View>
        
        <View style={styles.productMeta}>
          <Chip
            icon="tag"
            style={[styles.categoryChip, { backgroundColor: theme.colors.store + '20' }]}
            textStyle={{ color: theme.colors.store }}
          >
            {item.category}
          </Chip>
          
          {item.stock > 0 && (
            <Chip
              icon="check"
              style={[styles.stockChip, { backgroundColor: theme.colors.success + '20' }]}
              textStyle={{ color: theme.colors.success }}
            >
              In Stock
            </Chip>
          )}
        </View>
      </Card.Content>
    </Card>
  );

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Ionicons name="storefront-outline" size={64} color={theme.colors.placeholder} />
      <Text style={[styles.emptyTitle, { color: theme.colors.text }]}>
        No Products Found
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
          placeholder="Search products..."
          onChangeText={handleSearch}
          value={searchQuery}
          style={styles.searchBar}
        />
      </View>

      {/* Categories */}
      <View style={styles.categoriesContainer}>
        <FlatList
          horizontal
          showsHorizontalScrollIndicator={false}
          data={categories}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <Chip
              selected={selectedCategory === item.id}
              onPress={() => setSelectedCategory(item.id)}
              style={[
                styles.categoryChip,
                selectedCategory === item.id && {
                  backgroundColor: theme.colors.primary,
                },
              ]}
              textStyle={{
                color: selectedCategory === item.id ? 'white' : theme.colors.text,
              }}
              icon={item.icon}
            >
              {item.label}
            </Chip>
          )}
          contentContainerStyle={styles.categoriesList}
        />
      </View>

      {/* Products Grid */}
      <FlatList
        data={products}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderProductCard}
        numColumns={2}
        contentContainerStyle={styles.listContainer}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        onEndReached={loadMore}
        onEndReachedThreshold={0.5}
        ListEmptyComponent={!loading ? renderEmptyState : null}
        ListFooterComponent={renderFooter}
        showsVerticalScrollIndicator={false}
        columnWrapperStyle={styles.row}
      />

      {/* Cart FAB */}
      <FAB
        icon="shopping-cart"
        style={[styles.fab, { backgroundColor: theme.colors.primary }]}
        onPress={() => navigation.navigate('Cart')}
        label={cartCount > 0 ? cartCount.toString() : undefined}
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
  categoriesContainer: {
    paddingBottom: 16,
  },
  categoriesList: {
    paddingHorizontal: 16,
  },
  categoryChip: {
    marginRight: 8,
  },
  listContainer: {
    paddingHorizontal: 16,
    paddingBottom: 80,
  },
  row: {
    justifyContent: 'space-between',
  },
  productCard: {
    width: '48%',
    marginBottom: 16,
    elevation: 2,
  },
  productImageContainer: {
    position: 'relative',
  },
  productImage: {
    height: 150,
  },
  productActions: {
    position: 'absolute',
    top: 8,
    right: 8,
  },
  favoriteIcon: {
    padding: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.8)',
    borderRadius: 20,
  },
  productContent: {
    padding: 12,
  },
  productName: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  productDescription: {
    fontSize: 12,
    lineHeight: 16,
    marginBottom: 8,
  },
  productFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  productPrice: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  addToCartChip: {
    height: 32,
  },
  productMeta: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  stockChip: {
    height: 24,
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
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
  },
});

export default StoreScreen;