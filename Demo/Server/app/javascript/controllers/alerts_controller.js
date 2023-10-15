import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  showAlert(event) {
    event.preventDefault()
    alert(event.currentTarget.dataset["title"])
  }

  showConfirm(event) {
    event.preventDefault()
    const result = confirm(event.currentTarget.dataset["title"])
    alert(`You ${result ? "confirmed" : "cancelled"} the dialog.`)
  }
}
