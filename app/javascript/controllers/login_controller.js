import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="login"
export default class extends Controller {
  static targets = ["login_dropdown", "login_btn"];

  connect() {
    // this.startup() is not needed here as we call it in initialize
  }

  initialize() {
    this.startup();
  }

  startup() {
    // Check if login_btnTarget exists before proceeding
    if (this.hasLoginBtnTarget) {
      this.login_btnTarget.onclick = () => {
        // Check if login_dropdownTarget exists before accessing it
        if (this.hasLoginDropdownTarget) {
          console.log(this.login_dropdownTarget);
          this.login_dropdownTarget.classList.toggle("hidden");
        } else {
          console.warn('login_dropdown target not found');
        }
      };
    } else {
      console.warn('login_btn target not found');
    }
  }
}
