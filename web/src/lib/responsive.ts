export const SIDEBAR_BREAKPOINT = 800
export const PREVIEW_BREAKPOINT = 1250

export function defaultSidebarVisible(width: number): boolean {
  return width >= SIDEBAR_BREAKPOINT
}

export function defaultPreviewVisible(width: number): boolean {
  return width >= PREVIEW_BREAKPOINT
}

type Side = 'above' | 'below'

function sideRelativeTo(width: number, breakpoint: number): Side {
  return width >= breakpoint ? 'above' : 'below'
}

export function crossedBreakpoint(
  prevWidth: number,
  nextWidth: number,
  breakpoint: number,
): boolean {
  return sideRelativeTo(prevWidth, breakpoint) !== sideRelativeTo(nextWidth, breakpoint)
}

export function resolveVisible(
  width: number,
  breakpoint: number,
  override: boolean | null,
): boolean {
  if (override === null) return width >= breakpoint
  return override
}
