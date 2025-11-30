import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["segment", "button", "icon", "sortDropdown"];

  connect() {
    this.iconTarget.setAttribute("fill", "none");
    if (this.hasSortDropdownTarget) {
      this.updateSortButtonState();
    }
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
          window.history.replaceState({}, "", url.toString());
        }
      });
  }

  toggleUnread(event) {
    const isChecked = event.currentTarget.checked;
    const readParam = isChecked ? "false" : "true";
    const feedId = new URLSearchParams(window.location.search).get("feed_id");

    const url = new URL(window.location);
    url.searchParams.set("read", readParam);
    if (feedId) {
      url.searchParams.set("feed_id", feedId);
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

  filterToday(event) {
    const isChecked = event.currentTarget.checked;
    const feedId = new URLSearchParams(window.location.search).get("feed_id");
    const readParam =
      new URLSearchParams(window.location.search).get("read") || "false";

    const url = new URL(window.location);
    url.searchParams.set("read", readParam);

    if (isChecked) {
      url.searchParams.set("date", new Date().toISOString().split("T")[0]);
    } else {
      url.searchParams.delete("date");
    }

    if (feedId) {
      url.searchParams.set("feed_id", feedId);
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
          window.history.replaceState({}, "", url.toString());
        }
      });
  }

  toggleSort() {
    const dropdown = document.querySelector(
      '[data-filter-segment-target="sort-dropdown"]',
    );
    if (dropdown) {
      dropdown.classList.toggle("hidden");
      if (!dropdown.classList.contains("hidden")) {
        this.updateSortButtonState();
      }
    }
  }

  selectSort(event) {
    const sortValue = event.currentTarget.getAttribute("data-sort-value");
    const feedId = new URLSearchParams(window.location.search).get("feed_id");
    const dateParam = new URLSearchParams(window.location.search).get("date");

    // Get actual checkbox state
    const unreadCheckbox =
      document.querySelector("#unread-checkbox") ||
      document.querySelector("#unread-checkbox-desktop");
    const isUnreadChecked = unreadCheckbox ? unreadCheckbox.checked : false;
    const readParam = isUnreadChecked ? "false" : "true";

    const url = new URL(window.location);
    url.searchParams.set("read", readParam);

    if (sortValue !== "default") {
      url.searchParams.set("sort", sortValue);
    } else {
      url.searchParams.delete("sort");
    }

    if (feedId) {
      url.searchParams.set("feed_id", feedId);
    }

    if (dateParam) {
      url.searchParams.set("date", dateParam);
    }

    // Close dropdown
    const dropdown = document.querySelector(
      '[data-filter-segment-target="sort-dropdown"]',
    );
    if (dropdown) {
      dropdown.classList.add("hidden");
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
          window.history.replaceState({}, "", url.toString());
          if (this.hasSortDropdownTarget) {
            this.updateSortButtonState();
          }
        }
      });
  }

  updateSortButtonState() {
    const dropdown = document.querySelector(
      '[data-filter-segment-target="sort-dropdown"]',
    );
    if (!dropdown) return;

    const currentSort =
      new URLSearchParams(window.location.search).get("sort") || "default";
    const sortOptions = dropdown.querySelectorAll(".sort-option");

    sortOptions.forEach((option) => {
      const optionValue = option.getAttribute("data-sort-value");
      const checkmark = option.querySelector("span");

      if (optionValue === currentSort) {
        if (checkmark) {
          checkmark.textContent = "✓";
        }
      } else {
        if (checkmark) {
          checkmark.textContent = "";
        }
      }
    });
  }
}
