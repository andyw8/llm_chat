import { Controller } from "@hotwired/stimulus"

// poetry's mobile sidebar sheet ships demo copy in its sr-only header
// ("Sidebar" / "Displays the mobile sidebar.") and exposes no option to
// replace it, so a screen reader announces the library's sample text instead
// of this app's navigation. Swap in the app's own wording; drop this
// controller once the sidebar component takes the strings.
export default class extends Controller {
  static values = { title: String, description: String }

  connect() {
    const dialog = this.element.querySelector('dialog[data-slot="sidebar-mobile"]')
    if (!dialog) return

    const title = dialog.querySelector("h2")
    const description = dialog.querySelector("p")

    if (title && this.hasTitleValue) title.replaceChildren(this.titleValue)
    if (description && this.hasDescriptionValue) description.replaceChildren(this.descriptionValue)
  }
}
