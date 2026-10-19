import { Controller } from "@hotwired/stimulus"

// Rewrites a server-rendered <time> in the reader's timezone. The output the
// server sent stays put as the no-JS fallback. New elements streamed into the
// transcript connect on their own, so no extra event wiring is needed.
export default class extends Controller {
  connect() {
    const time = new Date(this.element.getAttribute("datetime"))
    if (Number.isNaN(time.getTime())) return

    this.element.textContent = time.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })
    this.element.title = time.toLocaleString()
  }
}
