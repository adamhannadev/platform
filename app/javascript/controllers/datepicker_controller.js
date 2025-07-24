import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    flatpickr(this.element, {
      enable: JSON.parse(this.element.dataset.enabledDates),
      dateFormat: "Y-m-d"
    })
  }
}