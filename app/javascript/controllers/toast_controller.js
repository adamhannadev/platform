import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => this.close(), 4000) // auto-close after 4s
  }
  close() {
    this.element.remove()
  }
}