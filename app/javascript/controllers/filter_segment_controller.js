import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["segment", "button", "icon"];

  connect() {
    this.iconTarget.setAttribute("fill", "none");
  }

  toggle() {
    const isDesktop = window.innerWidth >= 1024;
    const segmentSelector = isDesktop
      ? '[data-filter-segment-target="segment-desktop"]'
      : '[data-filter-segment-target="segment"]';
    const segment = this.element.querySelector(segmentSelector);

    if (!segment) {
      console.error("Segment bulunamadı");
      return;
    }

    const isHidden = segment.classList.contains("hidden");

    if (isHidden) {
      segment.classList.remove("hidden");
      if (isDesktop) {
        segment.style.width = "0";
      } else {
        segment.style.height = "0";
      }
      this.iconTarget.setAttribute("fill", "currentColor");
      requestAnimationFrame(() => {
        if (isDesktop) {
          segment.style.width = "16rem";
        } else {
          segment.style.height = "auto";
        }
      });
    } else {
      if (isDesktop) {
        segment.style.width = "0";
      } else {
        segment.style.height = "0";
      }
      this.iconTarget.setAttribute("fill", "none");
      setTimeout(() => {
        segment.classList.add("hidden");
      }, 300);
    }
  }

  selectFeed(event) {
    const feedId = event.currentTarget.value;
    const readParam =
      new URLSearchParams(window.location.search).get("read") || "false";

    const url = new URL(window.location);
    url.searchParams.set("read", readParam);

    if (feedId) {
      url.searchParams.set("feed_id", feedId);
    } else {
      url.searchParams.delete("feed_id");
    }

    fetch(url.toString())
      .then((response) => response.text())
      .then((html) => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, "text/html");
        const newFrame = doc.querySelector('[id="articles-list"]');
        const oldFrame = document.querySelector('[id="articles-list"]');

        if (newFrame && oldFrame) {
          oldFrame.innerHTML = newFrame.innerHTML;
        }
      });
  }
}
