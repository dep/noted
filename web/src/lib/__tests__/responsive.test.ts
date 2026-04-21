import { describe, expect, it } from 'vitest'
import {
  PREVIEW_BREAKPOINT,
  SIDEBAR_BREAKPOINT,
  crossedBreakpoint,
  defaultPreviewVisible,
  defaultSidebarVisible,
  resolveVisible,
} from '../responsive'

describe('breakpoint constants', () => {
  it('match the spec', () => {
    expect(SIDEBAR_BREAKPOINT).toBe(800)
    expect(PREVIEW_BREAKPOINT).toBe(1250)
  })
})

describe('default visibility', () => {
  it('sidebar hides below 800', () => {
    expect(defaultSidebarVisible(799)).toBe(false)
    expect(defaultSidebarVisible(800)).toBe(true)
  })
  it('preview hides below 1250', () => {
    expect(defaultPreviewVisible(1249)).toBe(false)
    expect(defaultPreviewVisible(1250)).toBe(true)
  })
})

describe('crossedBreakpoint', () => {
  it('returns false when both sides are on the same side', () => {
    expect(crossedBreakpoint(1000, 1100, 800)).toBe(false)
    expect(crossedBreakpoint(600, 700, 800)).toBe(false)
  })
  it('returns true when going from above to below', () => {
    expect(crossedBreakpoint(1000, 700, 800)).toBe(true)
  })
  it('returns true when going from below to above', () => {
    expect(crossedBreakpoint(700, 1000, 800)).toBe(true)
  })
  it('treats the exact breakpoint as "above" (inclusive)', () => {
    expect(crossedBreakpoint(799, 800, 800)).toBe(true)
    expect(crossedBreakpoint(800, 801, 800)).toBe(false)
  })
})

describe('resolveVisible', () => {
  it('falls back to default when override is null', () => {
    expect(resolveVisible(900, 800, null)).toBe(true)
    expect(resolveVisible(700, 800, null)).toBe(false)
  })
  it('respects an explicit override', () => {
    expect(resolveVisible(900, 800, false)).toBe(false) // user collapsed at wide
    expect(resolveVisible(700, 800, true)).toBe(true)   // user expanded at narrow
  })
})
