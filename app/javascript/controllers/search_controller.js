import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  initialize() {
    this.debouncedSearch = this.debounce(this.performSearch.bind(this), 500);
  }

  search() {
    this.debouncedSearch();
  }

  performSearch() {
    var searchStyle = document.getElementById("search-style");

    if (!this.element.value) {
      searchStyle.innerHTML = "";
      return;
    }

    searchStyle.innerHTML = ".searchable:not([data-index*=\"" + this.element.value.toLowerCase() + "\"]) { display: none; }";
  }

  debounce(func, wait) {
    let timeout;

    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };

      clearTimeout(timeout);

      timeout = setTimeout(later, wait);
    };
  }
}
