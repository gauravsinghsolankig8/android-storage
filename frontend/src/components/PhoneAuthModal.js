import React, { useState } from 'react';
import {
  View,
  StyleSheet,
  Modal,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import {
  Text,
  TextInput,
  Button,
  Card,
  ActivityIndicator,
} from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import PhoneInput from 'react-native-phone-number-input';

const PhoneAuthModal = ({ visible, onClose, onSuccess }) => {
  const { theme } = useTheme();
  const { sendOTP, phoneLogin } = useAuth();
  
  const [step, setStep] = useState(1); // 1: Phone, 2: OTP, 3: Name (if new user)
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [name, setName] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [phoneInput, setPhoneInput] = useState(null);

  const handleSendOTP = async () => {
    if (!phone.trim()) {
      Alert.alert('Error', 'Please enter your phone number');
      return;
    }

    try {
      setIsLoading(true);
      const result = await sendOTP(phone);
      
      if (result.success) {
        setStep(2);
        Alert.alert('OTP Sent', result.message);
      } else {
        Alert.alert('Error', result.error);
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to send OTP. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyOTP = async () => {
    if (!otp.trim()) {
      Alert.alert('Error', 'Please enter the OTP');
      return;
    }

    try {
      setIsLoading(true);
      const result = await phoneLogin(phone, otp, name);
      
      if (result.success) {
        onSuccess();
      } else {
        if (result.error.includes('Name is required')) {
          setStep(3);
        } else {
          Alert.alert('Error', result.error);
        }
      }
    } catch (error) {
      Alert.alert('Error', 'OTP verification failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleCompleteRegistration = async () => {
    if (!name.trim()) {
      Alert.alert('Error', 'Please enter your name');
      return;
    }

    await handleVerifyOTP();
  };

  const handleClose = () => {
    setStep(1);
    setPhone('');
    setOtp('');
    setName('');
    onClose();
  };

  const renderPhoneStep = () => (
    <View style={styles.stepContainer}>
      <View style={styles.iconContainer}>
        <Ionicons name="phone-portrait" size={48} color={theme.colors.primary} />
      </View>
      
      <Text style={[styles.title, { color: theme.colors.text }]}>
        Enter Phone Number
      </Text>
      
      <Text style={[styles.subtitle, { color: theme.colors.text }]}>
        We'll send you a verification code
      </Text>

      <PhoneInput
        ref={setPhoneInput}
        defaultValue={phone}
        defaultCode="IN"
        layout="first"
        onChangeText={setPhone}
        onChangeFormattedText={setPhone}
        withDarkTheme={theme.dark}
        withShadow
        autoFocus
        containerStyle={styles.phoneContainer}
        textContainerStyle={styles.phoneTextContainer}
        textInputStyle={styles.phoneTextInput}
      />

      <Button
        mode="contained"
        onPress={handleSendOTP}
        style={[styles.button, { backgroundColor: theme.colors.primary }]}
        contentStyle={styles.buttonContent}
        disabled={isLoading}
      >
        {isLoading ? <ActivityIndicator color="white" /> : 'Send OTP'}
      </Button>
    </View>
  );

  const renderOTPStep = () => (
    <View style={styles.stepContainer}>
      <View style={styles.iconContainer}>
        <Ionicons name="keypad" size={48} color={theme.colors.primary} />
      </View>
      
      <Text style={[styles.title, { color: theme.colors.text }]}>
        Enter Verification Code
      </Text>
      
      <Text style={[styles.subtitle, { color: theme.colors.text }]}>
        We sent a 6-digit code to {phone}
      </Text>

      <TextInput
        label="OTP"
        value={otp}
        onChangeText={setOtp}
        style={styles.input}
        mode="outlined"
        keyboardType="numeric"
        maxLength={6}
        autoFocus
        left={<TextInput.Icon icon="key" />}
      />

      <Button
        mode="contained"
        onPress={handleVerifyOTP}
        style={[styles.button, { backgroundColor: theme.colors.primary }]}
        contentStyle={styles.buttonContent}
        disabled={isLoading}
      >
        {isLoading ? <ActivityIndicator color="white" /> : 'Verify OTP'}
      </Button>

      <Button
        mode="text"
        onPress={() => setStep(1)}
        style={styles.backButton}
      >
        Change Phone Number
      </Button>
    </View>
  );

  const renderNameStep = () => (
    <View style={styles.stepContainer}>
      <View style={styles.iconContainer}>
        <Ionicons name="person-add" size={48} color={theme.colors.primary} />
      </View>
      
      <Text style={[styles.title, { color: theme.colors.text }]}>
        Complete Registration
      </Text>
      
      <Text style={[styles.subtitle, { color: theme.colors.text }]}>
        Please enter your name to complete the registration
      </Text>

      <TextInput
        label="Full Name"
        value={name}
        onChangeText={setName}
        style={styles.input}
        mode="outlined"
        autoFocus
        left={<TextInput.Icon icon="account" />}
      />

      <Button
        mode="contained"
        onPress={handleCompleteRegistration}
        style={[styles.button, { backgroundColor: theme.colors.primary }]}
        contentStyle={styles.buttonContent}
        disabled={isLoading}
      >
        {isLoading ? <ActivityIndicator color="white" /> : 'Complete Registration'}
      </Button>
    </View>
  );

  return (
    <Modal
      visible={visible}
      animationType="slide"
      presentationStyle="pageSheet"
      onRequestClose={handleClose}
    >
      <KeyboardAvoidingView
        style={[styles.container, { backgroundColor: theme.colors.background }]}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        <View style={styles.header}>
          <Button
            mode="text"
            onPress={handleClose}
            icon="close"
            style={styles.closeButton}
          >
            Close
          </Button>
        </View>

        <Card style={[styles.card, { backgroundColor: theme.colors.surface }]}>
          <Card.Content style={styles.cardContent}>
            {step === 1 && renderPhoneStep()}
            {step === 2 && renderOTPStep()}
            {step === 3 && renderNameStep()}
          </Card.Content>
        </Card>
      </KeyboardAvoidingView>
    </Modal>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    paddingHorizontal: 20,
    paddingTop: 20,
  },
  closeButton: {
    marginLeft: 'auto',
  },
  card: {
    flex: 1,
    margin: 20,
    elevation: 4,
  },
  cardContent: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
  },
  stepContainer: {
    alignItems: 'center',
  },
  iconContainer: {
    marginBottom: 24,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    textAlign: 'center',
    opacity: 0.7,
    marginBottom: 32,
    lineHeight: 22,
  },
  phoneContainer: {
    width: '100%',
    marginBottom: 24,
  },
  phoneTextContainer: {
    backgroundColor: 'transparent',
  },
  phoneTextInput: {
    fontSize: 16,
  },
  input: {
    width: '100%',
    marginBottom: 24,
  },
  button: {
    width: '100%',
    marginBottom: 16,
  },
  buttonContent: {
    paddingVertical: 8,
  },
  backButton: {
    marginTop: 8,
  },
});

export default PhoneAuthModal;