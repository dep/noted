// Mock react-native
export const View = 'View';
export const Text = 'Text';
export const TouchableOpacity = 'TouchableOpacity';
export const ScrollView = 'ScrollView';
export const Modal = 'Modal';
export const Animated = {
  Value: jest.fn(() => ({
    setValue: jest.fn(),
  })),
  timing: jest.fn(() => ({
    start: jest.fn(),
  })),
};
export const StyleSheet = {
  create: jest.fn((styles) => styles),
  flatten: jest.fn((style) => style),
  compose: jest.fn((style1, style2) => [style1, style2]),
  absoluteFill: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
  },
  hairlineWidth: 1,
};
export const Dimensions = {
  get: jest.fn(() => ({ width: 375, height: 812, scale: 2, fontScale: 1 })),
  addEventListener: jest.fn(() => ({ remove: jest.fn() })),
};
export const useColorScheme = jest.fn(() => 'light');

export default {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Modal,
  Animated,
  StyleSheet,
  Dimensions,
  useColorScheme,
};
