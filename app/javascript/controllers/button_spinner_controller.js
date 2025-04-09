import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "spinner", "text"]

  start() {
    if (!this.hasButtonTarget) {
      console.error("Missing button target")
    }

    this.buttonTarget.disabled = true
    this.spinnerTarget.classList.remove("hidden")
    this.textTarget.classList.add("invisible")
  }

  reset() {
    this.buttonTarget.disabled = false
    this.spinnerTarget.classList.add("hidden")
    this.textTarget.classList.remove("invisible")
  }
}
