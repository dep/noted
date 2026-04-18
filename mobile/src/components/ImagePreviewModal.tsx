import React, { useState } from 'react';
import {
  Modal,
  View,
  TouchableOpacity,
  Image,
  StyleSheet,
  Dimensions,
} from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useTheme } from '../theme/ThemeContext';

interface ImagePreviewModalProps {
  isVisible: boolean;
  imageUri: string;
  onClose: () => void;
}

export function ImagePreviewModal({ isVisible, imageUri, onClose }: ImagePreviewModalProps) {
  const { theme } = useTheme();
  const windowDim = Dimensions.get('window');

  if (!isVisible) {
    return null;
  }

  return (
    <Modal
      testID="image-preview-modal"
      visible={isVisible}
      transparent={true}
      animationType="fade"
      onRequestClose={onClose}
    >
      <View
        testID="preview-backdrop"
        style={[styles.backdrop, { backgroundColor: 'rgba(0, 0, 0, 0.9)' }]}
        onTouchEnd={onClose}
      >
        <View style={styles.container} onTouchEnd={(e) => e.stopPropagation()}>
          <TouchableOpacity
            testID="close-preview-button"
            style={styles.closeButton}
            onPress={onClose}
          >
            <MaterialIcons name="close" size={28} color="white" />
          </TouchableOpacity>

          <View style={styles.imageContainer}>
            <Image
              testID="preview-image"
              source={{ uri: imageUri }}
              style={[
                styles.previewImage,
                {
                  width: windowDim.width,
                  height: windowDim.height * 0.8,
                },
              ]}
              resizeMode="contain"
            />
          </View>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  backdrop: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  container: {
    flex: 1,
    width: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  closeButton: {
    position: 'absolute',
    top: 50,
    right: 20,
    zIndex: 1000,
    padding: 8,
  },
  imageContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  previewImage: {
    width: '100%',
    height: '100%',
  },
});
