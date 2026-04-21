export type Route =
  | { kind: 'picker' }
  | { kind: 'repo'; owner: string; repo: string }
  | { kind: 'folder'; owner: string; repo: string; folder: string }
  | { kind: 'file'; owner: string; repo: string; file: string }

function stripSlashes(s: string): string {
  return s.replace(/^\/+|\/+$/g, '')
}

function splitSegments(pathname: string): string[] {
  const clean = stripSlashes(pathname)
  if (!clean) return []
  return clean.split('/').map(decodeURIComponent).filter(Boolean)
}

export function parseRoute(pathname: string): Route {
  const parts = splitSegments(pathname)
  if (parts.length < 2) return { kind: 'picker' }
  const [owner, repo, maybeKind, ...rest] = parts
  if (!owner || !repo) return { kind: 'picker' }
  if (maybeKind === 'tree') {
    if (rest.length === 0) return { kind: 'repo', owner, repo }
    return { kind: 'folder', owner, repo, folder: rest.join('/') }
  }
  if (maybeKind === 'blob') {
    if (rest.length === 0) return { kind: 'repo', owner, repo }
    return { kind: 'file', owner, repo, file: rest.join('/') }
  }
  return { kind: 'repo', owner, repo }
}

function encodeSegments(path: string): string {
  return path.split('/').filter(Boolean).map(encodeURIComponent).join('/')
}

export function formatRoute(route: Route): string {
  switch (route.kind) {
    case 'picker':
      return '/'
    case 'repo':
      return `/${encodeURIComponent(route.owner)}/${encodeURIComponent(route.repo)}`
    case 'folder': {
      const base = `/${encodeURIComponent(route.owner)}/${encodeURIComponent(route.repo)}`
      if (!route.folder) return base
      return `${base}/tree/${encodeSegments(route.folder)}`
    }
    case 'file':
      return `/${encodeURIComponent(route.owner)}/${encodeURIComponent(route.repo)}/blob/${encodeSegments(route.file)}`
  }
}

export function routeRepo(route: Route): { owner: string; repo: string } | null {
  if (route.kind === 'picker') return null
  return { owner: route.owner, repo: route.repo }
}

export function routeFolder(route: Route): string {
  if (route.kind === 'folder') return route.folder
  if (route.kind === 'file') {
    const slash = route.file.lastIndexOf('/')
    return slash >= 0 ? route.file.slice(0, slash) : ''
  }
  return ''
}

export function routeFile(route: Route): string | null {
  return route.kind === 'file' ? route.file : null
}
