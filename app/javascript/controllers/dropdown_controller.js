import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];

  toggle() {
    this.menuTarget.classList.toggle("hidden");
  }

  // Close dropdown when clicking outside
  connect() {
    document.addEventListener("click", this.closeDropdown);
  }

  disconnect() {
    document.removeEventListener("click", this.closeDropdown);
  }

  closeDropdown = (event) => {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden");
    }
  };
}
