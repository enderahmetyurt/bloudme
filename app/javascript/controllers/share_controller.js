import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu", "copyButton"];

  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this);
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside);
  }

  toggleMenu(event) {
    event.preventDefault();
    event.stopPropagation();

    const isHidden = this.menuTarget.classList.contains("hidden");

    if (isHidden) {
      this.menuTarget.classList.remove("hidden");
      document.addEventListener("click", this.handleClickOutside);
    } else {
      this.closeMenu();
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.closeMenu();
      document.removeEventListener("click", this.handleClickOutside);
    }
  }

  closeMenu() {
    this.menuTarget.classList.add("hidden");
    document.removeEventListener("click", this.handleClickOutside);
  }

  copyToClipboard(event) {
    event.preventDefault();

    const link = this.element.dataset.articleLink;

    navigator.clipboard
      .writeText(link)
      .then(() => {
        this.showCopyNotification();
        this.closeMenu();
      })
      .catch((err) => {
        console.error("Failed to copy:", err);
      });
  }

  shareOnX(event) {
    event.preventDefault();
    const url = event.currentTarget.href;
    window.open(url, "_blank", "width=550,height=420");
    this.closeMenu();
  }

  shareOnBsky(event) {
    event.preventDefault();
    const url = event.currentTarget.href;
    window.open(url, "_blank", "width=550,height=650");
    this.closeMenu();
  }

  shareOnLinkedin(event) {
    event.preventDefault();
    const url = event.currentTarget.href;
    window.open(url, "_blank", "width=550,height=420");
    this.closeMenu();
  }

  showCopyNotification() {
    const notification = document.createElement("div");
    notification.className =
      "fixed top-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg flex items-center gap-2 z-50 animate-in fade-in slide-in-from-top-2 duration-300";
    notification.innerHTML = `
      <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
      </svg>
      <span class="font-medium">Link copied to clipboard!</span>
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
      notification.classList.remove(
        "animate-in",
        "fade-in",
        "slide-in-from-top-2",
      );
      notification.classList.add(
        "animate-out",
        "fade-out",
        "slide-out-to-top-2",
        "duration-300",
      );
      setTimeout(() => {
        notification.remove();
      }, 300);
    }, 2500);
  }
}
