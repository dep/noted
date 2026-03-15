import AsyncStorage from '@react-native-async-storage/async-storage';
import { FileSystemService, FileNode } from './FileSystemService';

const STORAGE_KEYS = {
  TEMPLATES_DIRECTORY: 'templatesDirectory',
  DAILY_NOTES_TEMPLATE: 'dailyNotesTemplate',
};

const DEFAULT_TEMPLATES_DIRECTORY = 'templates';

export interface TemplateVariableResult {
  content: string;
  cursorPosition: number | null;
}

export class TemplateStorage {
  // Get templates directory setting
  static async getTemplatesDirectory(): Promise<string> {
    const value = await AsyncStorage.getItem(STORAGE_KEYS.TEMPLATES_DIRECTORY);
    return value ?? DEFAULT_TEMPLATES_DIRECTORY;
  }

  static async setTemplatesDirectory(directory: string): Promise<void> {
    await AsyncStorage.setItem(STORAGE_KEYS.TEMPLATES_DIRECTORY, directory);
  }

  // Get daily notes template setting
  static async getDailyNotesTemplate(): Promise<string> {
    const value = await AsyncStorage.getItem(STORAGE_KEYS.DAILY_NOTES_TEMPLATE);
    return value ?? '';
  }

  static async setDailyNotesTemplate(templateName: string): Promise<void> {
    await AsyncStorage.setItem(STORAGE_KEYS.DAILY_NOTES_TEMPLATE, templateName);
  }

  // Get full templates directory path
  static async getTemplatesDirectoryPath(vaultPath: string): Promise<string> {
    const templatesDir = await this.getTemplatesDirectory();
    const normalizedDir = templatesDir
      .trim()
      .replace(/^[\/]+|[\/]+$/g, ''); // Remove leading/trailing slashes
    
    if (normalizedDir === '') {
      return `${vaultPath}/${DEFAULT_TEMPLATES_DIRECTORY}`;
    }
    
    return `${vaultPath}/${normalizedDir}`;
  }

  // Discover all available templates
  static async getAvailableTemplates(vaultPath: string): Promise<FileNode[]> {
    try {
      const templatesDir = await this.getTemplatesDirectoryPath(vaultPath);
      const exists = await FileSystemService.exists(templatesDir);
      
      if (!exists) {
        return [];
      }

      const allFiles = await FileSystemService.getFlatFileList(templatesDir);
      
      // Filter only markdown files
      return allFiles.filter(file => {
        const name = file.name.toLowerCase();
        return name.endsWith('.md') || name.endsWith('.markdown');
      });
    } catch (error) {
      console.error('[TemplateStorage] Failed to get templates:', error);
      return [];
    }
  }

  // Read template content
  static async readTemplate(templatePath: string): Promise<string> {
    try {
      const content = await FileSystemService.readFile(templatePath, 'utf8');
      return content as string;
    } catch (error) {
      console.error('[TemplateStorage] Failed to read template:', error);
      throw error;
    }
  }

  // Apply template variables
  static applyTemplateVariables(content: string, date: Date = new Date()): TemplateVariableResult {
    const year = date.getFullYear().toString().padStart(4, '0');
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    
    const hour24 = date.getHours();
    const hour12 = hour24 % 12 === 0 ? 12 : hour24 % 12;
    const hour = hour12.toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    const ampm = hour24 < 12 ? 'AM' : 'PM';

    let result = content
      .replace(/\{\{year\}\}/g, year)
      .replace(/\{\{month\}\}/g, month)
      .replace(/\{\{day\}\}/g, day)
      .replace(/\{\{hour\}\}/g, hour)
      .replace(/\{\{minute\}\}/g, minute)
      .replace(/\{\{ampm\}\}/g, ampm);

    // Find cursor position
    const cursorMatch = result.match(/\{\{cursor\}\}/);
    const cursorPosition = cursorMatch ? cursorMatch.index ?? null : null;
    
    // Remove {{cursor}} marker
    result = result.replace(/\{\{cursor\}\}/g, '');

    return { content: result, cursorPosition };
  }

  // Create note from template
  static async createNoteFromTemplate(
    templatePath: string,
    targetDirectory: string,
    noteName?: string
  ): Promise<{ filePath: string; cursorPosition: number | null }> {
    try {
      // Read template
      const templateContent = await this.readTemplate(templatePath);
      
      // Apply variables
      const { content, cursorPosition } = this.applyTemplateVariables(templateContent);
      
      // Generate filename
      let fileName: string;
      if (noteName) {
        fileName = noteName.endsWith('.md') ? noteName : `${noteName}.md`;
      } else {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        fileName = `Untitled-${timestamp}.md`;
      }
      
      const filePath = `${targetDirectory}/${fileName}`;
      
      // Write file
      await FileSystemService.writeFile(filePath, content);
      
      return { filePath, cursorPosition };
    } catch (error) {
      console.error('[TemplateStorage] Failed to create note from template:', error);
      throw error;
    }
  }

  // Create blank note
  static async createBlankNote(
    targetDirectory: string,
    noteName?: string
  ): Promise<string> {
    try {
      let fileName: string;
      if (noteName) {
        fileName = noteName.endsWith('.md') ? noteName : `${noteName}.md`;
      } else {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        fileName = `Untitled-${timestamp}.md`;
      }
      
      const filePath = `${targetDirectory}/${fileName}`;
      await FileSystemService.writeFile(filePath, '');
      
      return filePath;
    } catch (error) {
      console.error('[TemplateStorage] Failed to create blank note:', error);
      throw error;
    }
  }
}
