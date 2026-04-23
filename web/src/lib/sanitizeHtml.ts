import { sanitize } from 'isomorphic-dompurify'

/**
 * Strips active content (script, on* handlers, javascript: URLs) from HTML produced
 * by the markdown pipeline before it is passed to the DOM. `marked` forwards raw
 * HTML in user notes, which would otherwise be XSS when rendered in the preview.
 */
export function sanitizePreviewHtml(html: string): string {
  return sanitize(html, {
    // Wikilink links use `data-wikilink-path` for the app click handler.
    ADD_ATTR: ['data-wikilink-path'],
  })
}
