import { FileSystemService, FileNode } from '../../src/services/FileSystemService';
import LightningFS from '@isomorphic-git/lightning-fs';

// Mock LightningFS
jest.mock('@isomorphic-git/lightning-fs');

describe('FileSystemService', () => {
  let mockPfs: any;

  beforeEach(() => {
    jest.clearAllMocks();

    // Setup mock filesystem promises
    mockPfs = {
      mkdir: jest.fn(() => Promise.resolve()),
      readdir: jest.fn(() => Promise.resolve([])),
      readFile: jest.fn(() => Promise.resolve('')),
      writeFile: jest.fn(() => Promise.resolve()),
      unlink: jest.fn(() => Promise.resolve()),
      rmdir: jest.fn(() => Promise.resolve()),
      stat: jest.fn(() => Promise.resolve({ type: 'file' })),
      lstat: jest.fn(() => Promise.resolve({ type: 'file' })),
    };

    (LightningFS as jest.MockedClass<typeof LightningFS>).mockImplementation(() => ({
      promises: mockPfs,
    }) as any);
  });

  afterEach(() => {
    FileSystemService.clearInstance();
  });

  describe('listFiles', () => {
    it('should list all files recursively and return structured tree', async () => {
      const rootPath = '/vault';

      // Mock readdir to return different results for different paths
      mockPfs.readdir.mockImplementation((path: string) => {
        if (path === rootPath) {
          return Promise.resolve(['file1.md', 'file2.md', 'folder1']);
        }
        if (path === `${rootPath}/folder1`) {
          return Promise.resolve(['nested-file.md']);
        }
        return Promise.resolve([]);
      });

      // Mock stat to identify directories
      mockPfs.stat.mockImplementation((path: string) => {
        if (path.endsWith('folder1')) {
          return Promise.resolve({ type: 'directory' });
        }
        return Promise.resolve({ type: 'file' });
      });

      const result = await FileSystemService.listFiles(rootPath);

      expect(result).toHaveLength(3);
      expect(result[0]).toMatchObject({ name: 'file1.md', path: '/vault/file1.md', isDirectory: false });
      expect(result[1]).toMatchObject({ name: 'file2.md', path: '/vault/file2.md', isDirectory: false });
      expect(result[2]).toMatchObject({ name: 'folder1', path: '/vault/folder1', isDirectory: true });
      expect(result[2].children).toHaveLength(1);
      expect(result[2].children![0]).toMatchObject({
        name: 'nested-file.md',
        path: '/vault/folder1/nested-file.md',
        isDirectory: false,
      });
    });

    it('should return empty array for empty directory', async () => {
      mockPfs.readdir.mockResolvedValueOnce([]);

      const result = await FileSystemService.listFiles('/empty-vault');

      expect(result).toEqual([]);
    });

    it('should handle errors gracefully', async () => {
      mockPfs.readdir.mockRejectedValueOnce(new Error('Permission denied'));

      await expect(FileSystemService.listFiles('/vault')).rejects.toThrow('Permission denied');
    });
  });

  describe('readFile', () => {
    it('should read file contents as string', async () => {
      const filePath = '/vault/note.md';
      const content = '# Hello World\n\nThis is a test note.';

      mockPfs.readFile.mockResolvedValueOnce(content);

      const result = await FileSystemService.readFile(filePath);

      expect(result).toBe(content);
      expect(mockPfs.readFile).toHaveBeenCalledWith(filePath, 'utf8');
    });

    it('should throw error if file does not exist', async () => {
      mockPfs.readFile.mockRejectedValueOnce(new Error('ENOENT: no such file or directory'));

      await expect(FileSystemService.readFile('/vault/missing.md')).rejects.toThrow('ENOENT');
    });
  });

  describe('writeFile', () => {
    it('should write content to file', async () => {
      const filePath = '/vault/note.md';
      const content = '# New Note\n\nContent here.';

      await FileSystemService.writeFile(filePath, content);

      expect(mockPfs.writeFile).toHaveBeenCalledWith(filePath, content, 'utf8');
    });

    it('should create parent directories if they do not exist', async () => {
      const filePath = '/vault/folder/subfolder/note.md';
      const content = '# New Note';

      mockPfs.writeFile.mockRejectedValueOnce(new Error('ENOENT'));

      await FileSystemService.writeFile(filePath, content);

      expect(mockPfs.mkdir).toHaveBeenCalledWith('/vault/folder/subfolder', { recursive: true });
      expect(mockPfs.writeFile).toHaveBeenCalledWith(filePath, content, 'utf8');
    });
  });

  describe('deleteFile', () => {
    it('should delete file by path', async () => {
      const filePath = '/vault/note.md';

      await FileSystemService.deleteFile(filePath);

      expect(mockPfs.unlink).toHaveBeenCalledWith(filePath);
    });

    it('should throw error if file does not exist', async () => {
      mockPfs.unlink.mockRejectedValueOnce(new Error('ENOENT'));

      await expect(FileSystemService.deleteFile('/vault/missing.md')).rejects.toThrow('ENOENT');
    });
  });

  describe('createDirectory', () => {
    it('should create directory', async () => {
      const dirPath = '/vault/new-folder';

      await FileSystemService.createDirectory(dirPath);

      expect(mockPfs.mkdir).toHaveBeenCalledWith(dirPath, { recursive: true });
    });

    it('should not throw if directory already exists', async () => {
      mockPfs.mkdir.mockRejectedValueOnce(new Error('EEXIST'));

      await expect(FileSystemService.createDirectory('/vault/existing')).rejects.toThrow('EEXIST');
    });
  });

  describe('getFlatFileList', () => {
    it('should return flat list of all files sorted alphabetically', async () => {
      const rootPath = '/vault';

      mockPfs.readdir.mockImplementation((path: string) => {
        if (path === rootPath) {
          return Promise.resolve(['z-file.md', 'folder1', 'a-file.md']);
        }
        if (path === `${rootPath}/folder1`) {
          return Promise.resolve(['nested-b.md', 'nested-a.md']);
        }
        return Promise.resolve([]);
      });

      mockPfs.stat.mockImplementation((path: string) => {
        if (path.endsWith('folder1')) {
          return Promise.resolve({ type: 'directory' });
        }
        return Promise.resolve({ type: 'file' });
      });

      const result = await FileSystemService.getFlatFileList(rootPath);

      expect(result).toHaveLength(4);
      // Should be sorted alphabetically
      expect(result[0].name).toBe('a-file.md');
      expect(result[1].name).toBe('nested-a.md');
      expect(result[2].name).toBe('nested-b.md');
      expect(result[3].name).toBe('z-file.md');
    });

    it('should return empty array for empty directory', async () => {
      mockPfs.readdir.mockResolvedValueOnce([]);

      const result = await FileSystemService.getFlatFileList('/empty');

      expect(result).toEqual([]);
    });
  });

  describe('Singleton pattern', () => {
    it('should return same instance', () => {
      const instance1 = FileSystemService.getInstance();
      const instance2 = FileSystemService.getInstance();

      expect(instance1).toBe(instance2);
    });

    it('should create new instance after clearInstance', () => {
      const instance1 = FileSystemService.getInstance();
      FileSystemService.clearInstance();
      const instance2 = FileSystemService.getInstance();

      expect(instance1).not.toBe(instance2);
    });
  });
});
