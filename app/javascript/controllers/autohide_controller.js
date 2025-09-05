import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autohide"
export default class extends Controller {
  dismiss() {
    this.element.remove()
  }
}
