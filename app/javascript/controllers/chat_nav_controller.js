import { Controller } from "@hotwired/stimulus"

// The chat sidebar sits outside the detail Turbo Frame, so a frame
// navigation swaps the transcript without re-rendering the list. Keep the
// active highlight in step with the link the reader just followed.
export default class extends Controller {
  static targets = ["item"]

  select(event) {
    this.itemTargets.forEach((item) => {
      item.removeAttribute("data-active")
      item.removeAttribute("aria-current")
    })

    const link = event.currentTarget
    link.setAttribute("data-active", "")
    link.setAttribute("aria-current", "page")
  }
}
