import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="category"
export default class extends Controller {
  static targets = ["level", "levelForm"]

  initialize() {
    this.initChangeEvents()
  }

  levelTargetConnected(){
    console.log("Targets connected:",this.levelTargets)
    this.initChangeEvents()
  }

  initChangeEvents() {
    this.levelTargets.forEach(element => {
      element.onchange = () => {
        console.log("heelo from:", element)

        let categoryId = element.value
        let level = element.dataset.level

        console.log("Value selected: ", categoryId)
        console.log("With Level:", level)

        fetch(`/new_selected?id=${categoryId}&level=${level}`, {
          method: 'GET', // or 'POST', depending on your needs
          headers: {
            'Accept': 'text/vnd.turbo-stream.html',
            // You can add other headers if needed
          }
        }).then(res => res.text())
          .then(turboResponse => Turbo.renderStreamMessage(turboResponse))
          .catch(err => console.log("Error turboing in:", err))
        // fetch("/category/subcategory?id=)
      }
    });
  }

}
