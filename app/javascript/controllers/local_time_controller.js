import { Controller } from "@hotwired/stimulus"

// The undefined locale means "use the reader's own region", so both the
// timezone and the 12/24-hour convention come from their settings. The output
// the server sent stays put as the no-JS fallback. New elements streamed into
// the transcript connect on their own, so no extra event wiring is needed.
const shortTime = new Intl.DateTimeFormat(undefined, { timeStyle: "short" })
const fullTime = new Intl.DateTimeFormat(undefined, { dateStyle: "medium", timeStyle: "short" })

export default class extends Controller {
  connect() {
    const time = new Date(this.element.getAttribute("datetime"))
    if (Number.isNaN(time.getTime())) return

    this.element.textContent = shortTime.format(time)
    this.element.title = fullTime.format(time)
  }
}
