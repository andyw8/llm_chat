import { Controller } from "@hotwired/stimulus"

// The chat sidebar sits outside the detail Turbo Frame, so a frame
// navigation swaps the transcript without re-rendering the list. This keeps
// the active highlight in step with the link the reader followed and updates
// the address bar (Turbo Frames don't touch the URL on their own).
//
// The document title and the header label live outside the frame too, so
// they would otherwise keep the previous page's values; syncChrome reads the
// freshly loaded frame and puts them right.
//
// We deliberately avoid data-turbo-action on the frame links: Turbo's
// page-visit path for frames re-arms poetry's message-scroller opening hold
// (data-pending-scroll), leaving the transcript hidden.
export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.onPopState = () => this.restoreFromLocation()
    this.onFrameLoad = (event) => this.syncChrome(event.target)
    window.addEventListener("popstate", this.onPopState)
    document.addEventListener("turbo:frame-load", this.onFrameLoad)
  }

  disconnect() {
    window.removeEventListener("popstate", this.onPopState)
    document.removeEventListener("turbo:frame-load", this.onFrameLoad)
  }

  select(event) {
    const link = event.currentTarget
    this.markActive(link)

    if (this.restoring) return

    const url = link.getAttribute("href")
    if (url && url !== window.location.pathname) {
      window.history.pushState({ chatNav: true }, "", url)
    }
  }

  restoreFromLocation() {
    const link = this.itemTargets.find((item) => item.getAttribute("href") === window.location.pathname)

    if (!link) {
      window.location.reload()
      return
    }

    this.restoring = true
    link.click()
    this.restoring = false
  }

  // The frame holds the page's h1 (a chat title, or "New chat"); the chat
  // list's empty state has none, so /chats falls back to the section name.
  syncChrome(frame) {
    if (!(frame instanceof HTMLElement) || frame.id !== "chat") return

    const heading = frame.querySelector("h1")
    document.title = heading ? heading.textContent.trim() : "Chats"

    const label = document.querySelector("[data-chat-nav-label]")
    if (label) label.textContent = window.location.pathname === "/chats/new" ? "New chat" : "Chats"
  }

  markActive(link) {
    this.itemTargets.forEach((item) => {
      item.removeAttribute("data-active")
      item.removeAttribute("aria-current")
    })

    link.setAttribute("data-active", "")
    link.setAttribute("aria-current", "page")
  }
}
