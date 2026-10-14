import { Controller } from "@hotwired/stimulus"

// The chat sidebar sits outside the detail Turbo Frame, so a frame
// navigation swaps the transcript without re-rendering the list. This keeps
// the active highlight in step with the link the reader followed and updates
// the address bar (Turbo Frames don't touch the URL on their own).
//
// We deliberately avoid data-turbo-action on the frame links: Turbo's
// page-visit path for frames re-arms poetry's message-scroller opening hold
// (data-pending-scroll), leaving the transcript hidden.
export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.onPopState = () => this.restoreFromLocation()
    window.addEventListener("popstate", this.onPopState)
  }

  disconnect() {
    window.removeEventListener("popstate", this.onPopState)
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

  markActive(link) {
    this.itemTargets.forEach((item) => {
      item.removeAttribute("data-active")
      item.removeAttribute("aria-current")
    })

    link.setAttribute("data-active", "")
    link.setAttribute("aria-current", "page")
  }
}
