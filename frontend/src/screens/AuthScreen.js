import React, { useState } from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  Alert,
} from 'react-native';
import {
  Text,
  TextInput,
  Button,
  Card,
  Divider,
  ActivityIndicator,
} from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import PhoneAuthModal from '../components/PhoneAuthModal';

const AuthScreen = ({ navigation }) => {
  const { theme } = useTheme();
  const { login, register, googleLogin, isLoading } = useAuth();
  
  const [isLogin, setIsLogin] = useState(true);
  const [showPhoneAuth, setShowPhoneAuth] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
  });
  const [errors, setErrors] = useState({});

  // Configure Google Sign-In
  React.useEffect(() => {
    GoogleSignin.configure({
      webClientId: 'your-google-web-client-id', // Replace with your actual client ID
    });
  }, []);

  const validateForm = () => {
    const newErrors = {};

    if (!isLogin && !formData.name.trim()) {
      newErrors.name = 'Name is required';
    }

    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Email is invalid';
    }

    if (!formData.password) {
      newErrors.password = 'Password is required';
    } else if (formData.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters';
    }

    if (!isLogin && formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    if (!validateForm()) return;

    try {
      let result;
      if (isLogin) {
        result = await login(formData.email, formData.password);
      } else {
        result = await register(formData.name, formData.email, formData.password);
      }

      if (result.success) {
        if (isLogin) {
          navigation.replace('MainTabs');
        } else {
          Alert.alert(
            'Registration Successful',
            'Please check your email for verification link.',
            [{ text: 'OK', onPress: () => setIsLogin(true) }]
          );
        }
      } else {
        Alert.alert('Error', result.error);
      }
    } catch (error) {
      Alert.alert('Error', 'Something went wrong. Please try again.');
    }
  };

  const handleGoogleSignIn = async () => {
    try {
      await GoogleSignin.hasPlayServices();
      const userInfo = await GoogleSignin.signIn();
      const result = await googleLogin(userInfo.idToken);
      
      if (result.success) {
        navigation.replace('MainTabs');
      } else {
        Alert.alert('Error', result.error);
      }
    } catch (error) {
      console.error('Google Sign-In Error:', error);
      Alert.alert('Error', 'Google Sign-In failed. Please try again.');
    }
  };

  const handlePhoneAuth = () => {
    setShowPhoneAuth(true);
  };

  const handlePhoneAuthSuccess = () => {
    setShowPhoneAuth(false);
    navigation.replace('MainTabs');
  };

  return (
    <KeyboardAvoidingView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <Ionicons
            name="library"
            size={60}
            color={theme.colors.primary}
            style={styles.logo}
          />
          <Text style={[styles.title, { color: theme.colors.text }]}>
            {isLogin ? 'Welcome Back' : 'Create Account'}
          </Text>
          <Text style={[styles.subtitle, { color: theme.colors.text }]}>
            {isLogin
              ? 'Sign in to continue your spiritual journey'
              : 'Join us on your spiritual journey in Vrindavan'}
          </Text>
        </View>

        <Card style={[styles.card, { backgroundColor: theme.colors.surface }]}>
          <Card.Content style={styles.cardContent}>
            {!isLogin && (
              <TextInput
                label="Full Name"
                value={formData.name}
                onChangeText={(text) => setFormData({ ...formData, name: text })}
                error={!!errors.name}
                style={styles.input}
                mode="outlined"
                left={<TextInput.Icon icon="account" />}
              />
            )}

            <TextInput
              label="Email"
              value={formData.email}
              onChangeText={(text) => setFormData({ ...formData, email: text })}
              error={!!errors.email}
              style={styles.input}
              mode="outlined"
              keyboardType="email-address"
              autoCapitalize="none"
              left={<TextInput.Icon icon="email" />}
            />

            <TextInput
              label="Password"
              value={formData.password}
              onChangeText={(text) => setFormData({ ...formData, password: text })}
              error={!!errors.password}
              style={styles.input}
              mode="outlined"
              secureTextEntry
              left={<TextInput.Icon icon="lock" />}
            />

            {!isLogin && (
              <TextInput
                label="Confirm Password"
                value={formData.confirmPassword}
                onChangeText={(text) => setFormData({ ...formData, confirmPassword: text })}
                error={!!errors.confirmPassword}
                style={styles.input}
                mode="outlined"
                secureTextEntry
                left={<TextInput.Icon icon="lock-check" />}
              />
            )}

            <Button
              mode="contained"
              onPress={handleSubmit}
              style={[styles.submitButton, { backgroundColor: theme.colors.primary }]}
              contentStyle={styles.buttonContent}
              disabled={isLoading}
            >
              {isLoading ? (
                <ActivityIndicator color="white" />
              ) : (
                isLogin ? 'Sign In' : 'Create Account'
              )}
            </Button>

            <View style={styles.dividerContainer}>
              <Divider style={styles.divider} />
              <Text style={[styles.dividerText, { color: theme.colors.placeholder }]}>
                OR
              </Text>
              <Divider style={styles.divider} />
            </View>

            <Button
              mode="outlined"
              onPress={handleGoogleSignIn}
              style={[styles.googleButton, { borderColor: theme.colors.primary }]}
              contentStyle={styles.buttonContent}
              icon="google"
              disabled={isLoading}
            >
              Continue with Google
            </Button>

            <Button
              mode="outlined"
              onPress={handlePhoneAuth}
              style={[styles.phoneButton, { borderColor: theme.colors.primary }]}
              contentStyle={styles.buttonContent}
              icon="phone"
              disabled={isLoading}
            >
              Continue with Phone
            </Button>
          </Card.Content>
        </Card>

        <View style={styles.footer}>
          <Text style={[styles.footerText, { color: theme.colors.text }]}>
            {isLogin ? "Don't have an account? " : 'Already have an account? '}
          </Text>
          <Button
            mode="text"
            onPress={() => setIsLogin(!isLogin)}
            style={styles.toggleButton}
            labelStyle={{ color: theme.colors.primary }}
          >
            {isLogin ? 'Sign Up' : 'Sign In'}
          </Button>
        </View>
      </ScrollView>

      <PhoneAuthModal
        visible={showPhoneAuth}
        onClose={() => setShowPhoneAuth(false)}
        onSuccess={handlePhoneAuthSuccess}
      />
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
    paddingHorizontal: 20,
  },
  header: {
    alignItems: 'center',
    marginBottom: 30,
  },
  logo: {
    marginBottom: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 8,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    textAlign: 'center',
    opacity: 0.7,
    lineHeight: 22,
  },
  card: {
    elevation: 4,
    marginBottom: 20,
  },
  cardContent: {
    padding: 20,
  },
  input: {
    marginBottom: 16,
  },
  submitButton: {
    marginTop: 8,
    marginBottom: 20,
  },
  buttonContent: {
    paddingVertical: 8,
  },
  dividerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 20,
  },
  divider: {
    flex: 1,
  },
  dividerText: {
    marginHorizontal: 16,
    fontSize: 14,
  },
  googleButton: {
    marginBottom: 12,
  },
  phoneButton: {
    marginBottom: 8,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  footerText: {
    fontSize: 16,
  },
  toggleButton: {
    marginLeft: -8,
  },
});

export default AuthScreen;