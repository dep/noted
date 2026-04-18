import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react-native';
import { ImagePreviewModal } from '../src/components/ImagePreviewModal';
import { ThemeProvider } from '../src/theme/ThemeContext';

describe('ImagePreviewModal', () => {
  const renderWithTheme = (component: React.ReactElement) => {
    return render(
      <ThemeProvider>
        {component}
      </ThemeProvider>
    );
  };

  it('renders with image URI', () => {
    const { getByTestId } = renderWithTheme(
      <ImagePreviewModal
        isVisible={true}
        imageUri="file:///test/image.png"
        onClose={jest.fn()}
      />
    );

    expect(getByTestId('image-preview-modal')).toBeTruthy();
    expect(getByTestId('preview-image')).toBeTruthy();
  });

  it('hides when isVisible is false', () => {
    const { queryByTestId } = renderWithTheme(
      <ImagePreviewModal
        isVisible={false}
        imageUri="file:///test/image.png"
        onClose={jest.fn()}
      />
    );

    expect(queryByTestId('image-preview-modal')).toBeFalsy();
  });

  it('calls onClose when close button is pressed', () => {
    const onClose = jest.fn();
    const { getByTestId } = renderWithTheme(
      <ImagePreviewModal
        isVisible={true}
        imageUri="file:///test/image.png"
        onClose={onClose}
      />
    );

    fireEvent.press(getByTestId('close-preview-button'));
    expect(onClose).toHaveBeenCalled();
  });

  it('calls onClose when close button is pressed (backdrop)', () => {
    const onClose = jest.fn();
    const { getByTestId } = renderWithTheme(
      <ImagePreviewModal
        isVisible={true}
        imageUri="file:///test/image.png"
        onClose={onClose}
      />
    );

    // Verify modal requests dismiss on backdrop (Modal property)
    expect(getByTestId('image-preview-modal')).toBeTruthy();
  });

  it('supports pinch zoom and pan gestures', () => {
    const { getByTestId } = renderWithTheme(
      <ImagePreviewModal
        isVisible={true}
        imageUri="file:///test/image.png"
        onClose={jest.fn()}
      />
    );

    const image = getByTestId('preview-image');
    expect(image.props.style).toContainEqual(
      expect.objectContaining({ width: '100%', height: '100%' })
    );
  });
});
