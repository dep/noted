import { describe, expect, it } from 'vitest'
import {
  formatRoute,
  parseRoute,
  routeFile,
  routeFolder,
  routeRepo,
} from '../route'

describe('parseRoute', () => {
  it('treats empty path as picker', () => {
    expect(parseRoute('/')).toEqual({ kind: 'picker' })
    expect(parseRoute('')).toEqual({ kind: 'picker' })
  })
  it('treats single segment as picker', () => {
    expect(parseRoute('/owner')).toEqual({ kind: 'picker' })
  })
  it('recognizes repo root without mode', () => {
    expect(parseRoute('/o/r')).toEqual({ kind: 'repo', owner: 'o', repo: 'r' })
  })
  it('recognizes tree with nested folder', () => {
    expect(parseRoute('/o/r/tree/notes/deep')).toEqual({
      kind: 'folder',
      owner: 'o',
      repo: 'r',
      folder: 'notes/deep',
    })
  })
  it('falls back to repo root for /tree with no folder', () => {
    expect(parseRoute('/o/r/tree')).toEqual({ kind: 'repo', owner: 'o', repo: 'r' })
  })
  it('recognizes blob with nested file', () => {
    expect(parseRoute('/o/r/blob/notes/deep/x.md')).toEqual({
      kind: 'file',
      owner: 'o',
      repo: 'r',
      file: 'notes/deep/x.md',
    })
  })
  it('decodes percent-encoded segments', () => {
    expect(parseRoute('/o/r/blob/a%20b/c.md')).toEqual({
      kind: 'file',
      owner: 'o',
      repo: 'r',
      file: 'a b/c.md',
    })
  })
  it('ignores trailing slashes', () => {
    expect(parseRoute('/o/r/tree/notes/')).toEqual({
      kind: 'folder',
      owner: 'o',
      repo: 'r',
      folder: 'notes',
    })
  })
})

describe('formatRoute', () => {
  it('encodes slashes as path separators, not %2F', () => {
    expect(
      formatRoute({ kind: 'file', owner: 'o', repo: 'r', file: 'a/b c.md' }),
    ).toBe('/o/r/blob/a/b%20c.md')
  })
  it('picker is /', () => {
    expect(formatRoute({ kind: 'picker' })).toBe('/')
  })
  it('repo root has no trailing tree', () => {
    expect(formatRoute({ kind: 'repo', owner: 'o', repo: 'r' })).toBe('/o/r')
  })
  it('folder route uses tree', () => {
    expect(
      formatRoute({ kind: 'folder', owner: 'o', repo: 'r', folder: 'notes' }),
    ).toBe('/o/r/tree/notes')
  })
  it('folder with empty string collapses to repo root', () => {
    expect(
      formatRoute({ kind: 'folder', owner: 'o', repo: 'r', folder: '' }),
    ).toBe('/o/r')
  })
})

describe('parse/format round trip', () => {
  it('folder route', () => {
    const r = parseRoute('/o/r/tree/a/b')
    expect(parseRoute(formatRoute(r))).toEqual(r)
  })
  it('file route with spaces', () => {
    const r = parseRoute('/o/r/blob/a%20b/c.md')
    expect(parseRoute(formatRoute(r))).toEqual(r)
  })
})

describe('derived helpers', () => {
  it('routeRepo returns null for picker', () => {
    expect(routeRepo({ kind: 'picker' })).toBeNull()
  })
  it('routeFolder strips filename from a file route', () => {
    expect(routeFolder({
      kind: 'file',
      owner: 'o',
      repo: 'r',
      file: 'notes/a.md',
    })).toBe('notes')
    expect(routeFolder({
      kind: 'file',
      owner: 'o',
      repo: 'r',
      file: 'a.md',
    })).toBe('')
  })
  it('routeFile is only set for file kind', () => {
    expect(
      routeFile({ kind: 'folder', owner: 'o', repo: 'r', folder: 'a' }),
    ).toBeNull()
    expect(
      routeFile({ kind: 'file', owner: 'o', repo: 'r', file: 'a.md' }),
    ).toBe('a.md')
  })
})
