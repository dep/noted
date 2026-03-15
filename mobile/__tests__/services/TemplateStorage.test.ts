import AsyncStorage from '@react-native-async-storage/async-storage';
import { TemplateStorage } from '../../src/services/TemplateStorage';
import { FileSystemService } from '../../src/services/FileSystemService';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  setItem: jest.fn(),
  getItem: jest.fn(),
  removeItem: jest.fn(),
}));

// Mock FileSystemService
jest.mock('../../src/services/FileSystemService', () => ({
  FileSystemService: {
    exists: jest.fn(),
    getFlatFileList: jest.fn(),
    readFile: jest.fn(),
    writeFile: jest.fn(),
    join: jest.fn((...paths: string[]) => paths.join('/')),
  },
}));

const mockedSetItem = AsyncStorage.setItem as jest.Mock;
const mockedGetItem = AsyncStorage.getItem as jest.Mock;
const mockedExists = FileSystemService.exists as jest.Mock;
const mockedGetFlatFileList = FileSystemService.getFlatFileList as jest.Mock;
const mockedReadFile = FileSystemService.readFile as jest.Mock;
const mockedWriteFile = FileSystemService.writeFile as jest.Mock;

describe('TemplateStorage', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getTemplatesDirectory', () => {
    it('should return default value when no setting exists', async () => {
      mockedGetItem.mockResolvedValue(null);
      
      const result = await TemplateStorage.getTemplatesDirectory();
      
      expect(result).toBe('templates');
    });

    it('should return saved value', async () => {
      mockedGetItem.mockResolvedValue('custom-templates');
      
      const result = await TemplateStorage.getTemplatesDirectory();
      
      expect(result).toBe('custom-templates');
    });
  });

  describe('setTemplatesDirectory', () => {
    it('should save templates directory', async () => {
      await TemplateStorage.setTemplatesDirectory('my-templates');
      
      expect(mockedSetItem).toHaveBeenCalledWith('templatesDirectory', 'my-templates');
    });
  });

  describe('getTemplatesDirectoryPath', () => {
    it('should return default templates path', async () => {
      mockedGetItem.mockResolvedValue(null);
      
      const result = await TemplateStorage.getTemplatesDirectoryPath('file:///vault');
      
      expect(result).toBe('file:///vault/templates');
    });

    it('should handle custom directory with slashes', async () => {
      mockedGetItem.mockResolvedValue('/custom/folder/');
      
      const result = await TemplateStorage.getTemplatesDirectoryPath('file:///vault');
      
      expect(result).toBe('file:///vault/custom/folder');
    });

    it('should handle empty string by returning default', async () => {
      mockedGetItem.mockResolvedValue('');
      
      const result = await TemplateStorage.getTemplatesDirectoryPath('file:///vault');
      
      expect(result).toBe('file:///vault/templates');
    });
  });

  describe('getAvailableTemplates', () => {
    it('should return empty array if templates directory does not exist', async () => {
      mockedGetItem.mockResolvedValue('templates');
      mockedExists.mockResolvedValue(false);
      
      const result = await TemplateStorage.getAvailableTemplates('file:///vault');
      
      expect(result).toEqual([]);
    });

    it('should return only markdown files', async () => {
      mockedGetItem.mockResolvedValue('templates');
      mockedExists.mockResolvedValue(true);
      mockedGetFlatFileList.mockResolvedValue([
        { path: 'file:///vault/templates/note.md', name: 'note.md', isDirectory: false },
        { path: 'file:///vault/templates/readme.markdown', name: 'readme.markdown', isDirectory: false },
        { path: 'file:///vault/templates/script.js', name: 'script.js', isDirectory: false },
        { path: 'file:///vault/templates/folder', name: 'folder', isDirectory: true },
      ]);
      
      const result = await TemplateStorage.getAvailableTemplates('file:///vault');
      
      expect(result).toHaveLength(2);
      expect(result[0].name).toBe('note.md');
      expect(result[1].name).toBe('readme.markdown');
    });
  });

  describe('applyTemplateVariables', () => {
    it('should replace all date variables', () => {
      const date = new Date('2026-03-15T14:30:00');
      const template = '{{year}}-{{month}}-{{day}} {{hour}}:{{minute}} {{ampm}}';
      
      const result = TemplateStorage.applyTemplateVariables(template, date);
      
      expect(result.content).toBe('2026-03-15 02:30 PM');
    });

    it('should handle 12-hour format conversion', () => {
      const date = new Date('2026-03-15T09:30:00');
      const template = '{{hour}}:{{minute}} {{ampm}}';
      
      const result = TemplateStorage.applyTemplateVariables(template, date);
      
      expect(result.content).toBe('09:30 AM');
    });

    it('should handle midnight (12 AM)', () => {
      const date = new Date('2026-03-15T00:00:00');
      const template = '{{hour}}:{{minute}} {{ampm}}';
      
      const result = TemplateStorage.applyTemplateVariables(template, date);
      
      expect(result.content).toBe('12:00 AM');
    });

    it('should handle noon (12 PM)', () => {
      const date = new Date('2026-03-15T12:00:00');
      const template = '{{hour}}:{{minute}} {{ampm}}';
      
      const result = TemplateStorage.applyTemplateVariables(template, date);
      
      expect(result.content).toBe('12:00 PM');
    });

    it('should find and remove cursor marker', () => {
      const template = 'Start {{cursor}} End';
      
      const result = TemplateStorage.applyTemplateVariables(template);
      
      expect(result.content).toBe('Start  End');
      expect(result.cursorPosition).toBe(6);
    });

    it('should return null cursor position when no marker', () => {
      const template = 'No cursor here';
      
      const result = TemplateStorage.applyTemplateVariables(template);
      
      expect(result.cursorPosition).toBeNull();
    });
  });

  describe('createNoteFromTemplate', () => {
    it('should create note from template with variables applied', async () => {
      mockedReadFile.mockResolvedValue('# {{year}}-{{month}}-{{day}}');
      mockedWriteFile.mockResolvedValue(undefined);
      
      const result = await TemplateStorage.createNoteFromTemplate(
        'file:///vault/templates/daily.md',
        'file:///vault/notes',
        'My Note'
      );
      
      expect(mockedWriteFile).toHaveBeenCalled();
      expect(result.filePath).toContain('My Note.md');
      expect(result.cursorPosition).toBeNull();
    });

    it('should generate timestamped filename when no name provided', async () => {
      mockedReadFile.mockResolvedValue('Template content');
      mockedWriteFile.mockResolvedValue(undefined);
      
      const result = await TemplateStorage.createNoteFromTemplate(
        'file:///vault/templates/daily.md',
        'file:///vault/notes'
      );
      
      expect(result.filePath).toMatch(/Untitled-\d{4}-\d{2}-\d{2}/);
    });

    it('should handle .md extension in note name', async () => {
      mockedReadFile.mockResolvedValue('Template content');
      mockedWriteFile.mockResolvedValue(undefined);
      
      const result = await TemplateStorage.createNoteFromTemplate(
        'file:///vault/templates/daily.md',
        'file:///vault/notes',
        'Already Has Extension.md'
      );
      
      expect(result.filePath).toBe('file:///vault/notes/Already Has Extension.md');
    });
  });

  describe('createBlankNote', () => {
    it('should create blank note with given name', async () => {
      mockedWriteFile.mockResolvedValue(undefined);
      
      const result = await TemplateStorage.createBlankNote(
        'file:///vault/notes',
        'Blank Note'
      );
      
      expect(mockedWriteFile).toHaveBeenCalledWith(
        'file:///vault/notes/Blank Note.md',
        ''
      );
      expect(result).toBe('file:///vault/notes/Blank Note.md');
    });

    it('should generate timestamped filename when no name provided', async () => {
      mockedWriteFile.mockResolvedValue(undefined);
      
      const result = await TemplateStorage.createBlankNote('file:///vault/notes');
      
      expect(result).toMatch(/Untitled-\d{4}-\d{2}-\d{2}/);
    });
  });
});
