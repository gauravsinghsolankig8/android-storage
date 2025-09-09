import { DefaultTheme, DarkTheme } from 'react-native-paper';

export const lightTheme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: '#2c3e50',
    accent: '#3498db',
    background: '#ffffff',
    surface: '#f8f9fa',
    text: '#2c3e50',
    placeholder: '#7f8c8d',
    backdrop: 'rgba(0, 0, 0, 0.5)',
    onSurface: '#2c3e50',
    notification: '#e74c3c',
    // Custom colors
    spiritual: '#8e44ad',
    temple: '#f39c12',
    saint: '#27ae60',
    event: '#e67e22',
    parikrama: '#16a085',
    hotel: '#34495e',
    store: '#9b59b6',
    success: '#27ae60',
    warning: '#f39c12',
    error: '#e74c3c',
    info: '#3498db',
  },
  fonts: {
    ...DefaultTheme.fonts,
    regular: {
      fontFamily: 'Roboto',
      fontWeight: '400',
    },
    medium: {
      fontFamily: 'Roboto',
      fontWeight: '500',
    },
    light: {
      fontFamily: 'Roboto-Light',
      fontWeight: '300',
    },
    thin: {
      fontFamily: 'Roboto-Light',
      fontWeight: '100',
    },
  },
  roundness: 8,
};

export const darkTheme = {
  ...DarkTheme,
  colors: {
    ...DarkTheme.colors,
    primary: '#3498db',
    accent: '#2c3e50',
    background: '#1a1a1a',
    surface: '#2d2d2d',
    text: '#ffffff',
    placeholder: '#95a5a6',
    backdrop: 'rgba(0, 0, 0, 0.8)',
    onSurface: '#ffffff',
    notification: '#e74c3c',
    // Custom colors
    spiritual: '#9b59b6',
    temple: '#f39c12',
    saint: '#2ecc71',
    event: '#e67e22',
    parikrama: '#1abc9c',
    hotel: '#34495e',
    store: '#8e44ad',
    success: '#2ecc71',
    warning: '#f39c12',
    error: '#e74c3c',
    info: '#3498db',
  },
  fonts: {
    ...DefaultTheme.fonts,
    regular: {
      fontFamily: 'Roboto',
      fontWeight: '400',
    },
    medium: {
      fontFamily: 'Roboto',
      fontWeight: '500',
    },
    light: {
      fontFamily: 'Roboto-Light',
      fontWeight: '300',
    },
    thin: {
      fontFamily: 'Roboto-Light',
      fontWeight: '100',
    },
  },
  roundness: 8,
};

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
};

export const typography = {
  h1: {
    fontSize: 32,
    fontWeight: 'bold',
    lineHeight: 40,
  },
  h2: {
    fontSize: 28,
    fontWeight: 'bold',
    lineHeight: 36,
  },
  h3: {
    fontSize: 24,
    fontWeight: 'bold',
    lineHeight: 32,
  },
  h4: {
    fontSize: 20,
    fontWeight: '600',
    lineHeight: 28,
  },
  h5: {
    fontSize: 18,
    fontWeight: '600',
    lineHeight: 24,
  },
  h6: {
    fontSize: 16,
    fontWeight: '600',
    lineHeight: 22,
  },
  body1: {
    fontSize: 16,
    lineHeight: 24,
  },
  body2: {
    fontSize: 14,
    lineHeight: 20,
  },
  caption: {
    fontSize: 12,
    lineHeight: 16,
  },
  overline: {
    fontSize: 10,
    fontWeight: '500',
    lineHeight: 16,
    textTransform: 'uppercase',
  },
};