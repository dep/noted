import React from 'react';
import { render } from '@testing-library/react-native';
import { parseImageEmbeds } from '../src/screens/EditorScreen';

describe('Image embed rendering', () => {
  it('renders images at full width in preview mode', () => {
    const content = '![test](file:///path/to/image.png)';
    const prepared = parseImageEmbeds(content, '/vault/test.md');

    expect(prepared).toContain('file:///path/to/image.png');
  });

  it('resolves relative image paths from document location', () => {
    const content = '![test](./images/photo.png)';
    const prepared = parseImageEmbeds(content, '/vault/notes/test.md');

    expect(prepared).toContain('synapse-local:///vault/notes/./images/photo.png');
  });

  it('handles wiki-style image embeds', () => {
    const content = '![[images/photo.png]]';
    const prepared = parseImageEmbeds(content, '/vault/notes/test.md');

    expect(prepared).toContain('![images/photo.png]');
  });

  it('preserves remote image URLs', () => {
    const content = '![test](https://example.com/image.png)';
    const prepared = parseImageEmbeds(content, '/vault/test.md');

    expect(prepared).toContain('https://example.com/image.png');
  });

  it('preserves data URIs', () => {
    const content = '![test](data:image/png;base64,abc123)';
    const prepared = parseImageEmbeds(content, '/vault/test.md');

    expect(prepared).toContain('data:image/png;base64,abc123');
  });
});
