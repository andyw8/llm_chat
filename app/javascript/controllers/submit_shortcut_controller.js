import { Controller } from "@hotwired/stimulus"

// Submits the form on Cmd+Enter (macOS) or Ctrl+Enter, the usual chat
// composer shortcut. Plain Enter keeps inserting newlines in the textarea.
export default class extends Controller {
  submit(event) {
    if (event.key !== "Enter" || !(event.metaKey || event.ctrlKey) || event.isComposing) return

    event.preventDefault()
    this.element.requestSubmit()
  }
}
