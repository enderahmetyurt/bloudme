import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.inputTarget.addEventListener("focus", this.scale.bind(this))
    this.inputTarget.addEventListener("blur", this.unscale.bind(this))
  }

  scale() {
    this.inputTarget.classList.add("scale-110", "transition-transform", "duration-200", "ease-in-out")
  }

  unscale() {
    this.inputTarget.classList.remove("scale-110")
  }
}