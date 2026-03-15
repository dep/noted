import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Modal,
  FlatList,
  TextInput,
} from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useTheme } from '../theme/ThemeContext';
import { TemplateStorage, FileNode } from '../services';

interface TemplatePickerProps {
  isVisible: boolean;
  onClose: () => void;
  onSelectTemplate: (templatePath: string | null, noteName: string) => void;
  vaultPath: string;
}

export function TemplatePicker({ isVisible, onClose, onSelectTemplate, vaultPath }: TemplatePickerProps) {
  const { theme } = useTheme();
  const [templates, setTemplates] = useState<FileNode[]>([]);
  const [noteName, setNoteName] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    if (isVisible) {
      loadTemplates();
      setNoteName('');
    }
  }, [isVisible, vaultPath]);

  const loadTemplates = async () => {
    setIsLoading(true);
    try {
      const availableTemplates = await TemplateStorage.getAvailableTemplates(vaultPath);
      setTemplates(availableTemplates);
    } catch (error) {
      console.error('[TemplatePicker] Failed to load templates:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSelectBlank = () => {
    onSelectTemplate(null, noteName.trim() || 'Untitled');
  };

  const handleSelectTemplate = (templatePath: string) => {
    onSelectTemplate(templatePath, noteName.trim() || 'Untitled');
  };

  const getTemplateDisplayName = (template: FileNode): string => {
    // Remove .md or .markdown extension and parent folder path for display
    let displayName = template.name;
    if (displayName.toLowerCase().endsWith('.md')) {
      displayName = displayName.slice(0, -3);
    } else if (displayName.toLowerCase().endsWith('.markdown')) {
      displayName = displayName.slice(0, -9);
    }
    return displayName;
  };

  const renderTemplateItem = ({ item }: { item: FileNode }) => (
    <TouchableOpacity
      style={[styles.templateItem, { backgroundColor: theme.colors.card }]}
      onPress={() => handleSelectTemplate(item.path)}
    >
      <MaterialIcons
        name="description"
        size={20}
        color={theme.colors.primary}
        style={styles.templateIcon}
      />
      <View style={styles.templateInfo}>
        <Text style={[styles.templateName, { color: theme.colors.text }]}>
          {getTemplateDisplayName(item)}
        </Text>
        <Text style={[styles.templatePath, { color: theme.colors.text + '60' }]} numberOfLines={1}>
          {item.path.replace(vaultPath, '').replace(/^\/+/, '')}
        </Text>
      </View>
    </TouchableOpacity>
  );

  return (
    <Modal
      visible={isVisible}
      transparent={true}
      animationType="slide"
      onRequestClose={onClose}
    >
      <View style={[styles.modalContainer, { backgroundColor: 'rgba(0, 0, 0, 0.5)' }]}>
        <View style={[styles.modalContent, { backgroundColor: theme.colors.background }]}>
          <View style={[styles.header, { borderBottomColor: theme.colors.border }]}>
            <Text style={[styles.headerTitle, { color: theme.colors.text }]}>
              Choose Template
            </Text>
            <TouchableOpacity onPress={onClose} style={styles.closeButton}>
              <MaterialIcons name="close" size={24} color={theme.colors.text} />
            </TouchableOpacity>
          </View>

          <View style={styles.nameInputContainer}>
            <Text style={[styles.label, { color: theme.colors.text + '80' }]}>
              Note Name (optional)
            </Text>
            <TextInput
              style={[
                styles.nameInput,
                { 
                  backgroundColor: theme.colors.card,
                  color: theme.colors.text,
                  borderColor: theme.colors.border,
                },
              ]}
              value={noteName}
              onChangeText={setNoteName}
              placeholder="Untitled"
              placeholderTextColor={theme.colors.text + '40'}
              autoFocus={true}
            />
          </View>

          <TouchableOpacity
            style={[styles.blankOption, { backgroundColor: theme.colors.card }]}
            onPress={handleSelectBlank}
          >
            <MaterialIcons
              name="note-add"
              size={20}
              color={theme.colors.text + '80'}
              style={styles.templateIcon}
            />
            <Text style={[styles.blankText, { color: theme.colors.text }]}>
              Blank Note
            </Text>
          </TouchableOpacity>

          {templates.length > 0 && (
            <>
              <Text style={[styles.sectionTitle, { color: theme.colors.text + '60' }]}>
                Templates
              </Text>
              <FlatList
                data={templates}
                renderItem={renderTemplateItem}
                keyExtractor={(item) => item.path}
                style={styles.templateList}
                showsVerticalScrollIndicator={false}
              />
            </>
          )}

          {templates.length === 0 && !isLoading && (
            <View style={styles.emptyState}>
              <Text style={[styles.emptyText, { color: theme.colors.text + '60' }]}>
                No templates found
              </Text>
              <Text style={[styles.emptySubtext, { color: theme.colors.text + '40' }]}>
                Create templates in the templates folder
              </Text>
            </View>
          )}
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  modalContainer: {
    flex: 1,
    justifyContent: 'flex-end',
  },
  modalContent: {
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    maxHeight: '80%',
    paddingBottom: 24,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    borderBottomWidth: 1,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '700',
  },
  closeButton: {
    padding: 4,
  },
  nameInputContainer: {
    paddingHorizontal: 20,
    paddingVertical: 16,
  },
  label: {
    fontSize: 13,
    fontWeight: '600',
    marginBottom: 8,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  nameInput: {
    height: 48,
    borderRadius: 12,
    paddingHorizontal: 16,
    fontSize: 16,
    borderWidth: 1,
  },
  blankOption: {
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: 20,
    marginBottom: 16,
    padding: 16,
    borderRadius: 12,
  },
  templateIcon: {
    marginRight: 12,
  },
  blankText: {
    fontSize: 16,
    fontWeight: '500',
  },
  sectionTitle: {
    fontSize: 11,
    fontWeight: '700',
    marginHorizontal: 20,
    marginBottom: 8,
    textTransform: 'uppercase',
    letterSpacing: 0.8,
  },
  templateList: {
    maxHeight: 300,
  },
  templateItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: 20,
    marginBottom: 8,
    padding: 16,
    borderRadius: 12,
  },
  templateInfo: {
    flex: 1,
  },
  templateName: {
    fontSize: 15,
    fontWeight: '500',
    marginBottom: 2,
  },
  templatePath: {
    fontSize: 12,
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 40,
  },
  emptyText: {
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 4,
  },
  emptySubtext: {
    fontSize: 13,
  },
});
