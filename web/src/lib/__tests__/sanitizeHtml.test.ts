import { describe, expect, it } from 'vitest'
import { marked } from 'marked'
import { applyWikilinks } from '../wikilinksHtml'
import { sanitizePreviewHtml } from '../sanitizeHtml'

describe('sanitizePreviewHtml', () => {
  it('strips script tags and event handlers from raw HTML in markdown', () => {
    const md = '<img src=x onerror=alert(1)>\n\n# hi'
    const raw = marked.parse(md) as string
    const clean = sanitizePreviewHtml(raw)
    expect(clean).not.toMatch(/<script/i)
    expect(clean).not.toMatch(/onerror/i)
    expect(clean).toMatch(/<h1>hi<\/h1>/)
  })

  it('preserves wikilink anchors after applyWikilinks', () => {
    const raw = marked.parse('text [[Target]] more') as string
    const withLinks = applyWikilinks(
      raw,
      new Map([['target', 'notes/T.md']]),
    )
    const clean = sanitizePreviewHtml(withLinks)
    expect(clean).toMatch(/data-wikilink-path="notes\/T\.md"/)
    expect(clean).toMatch(/wikilink-resolved/)
  })
})
