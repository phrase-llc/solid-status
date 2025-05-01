import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["firstName", "lastName", "displayName"];

  connect() {
    this.updateDisplayName();
  }

  updateDisplayName() {
    const firstName = this.firstNameTarget.value.trim();
    const lastName = this.lastNameTarget.value.trim();
    this.displayNameTarget.value = `${lastName} ${firstName}`.trim();
  }
}
