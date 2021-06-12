import * as AxeLive from "../dist/axe-live.js";

AxeLive.watch();

window.AxeLive = AxeLive;

const toggleContainer = document.getElementById("dynamic");
const toggleButton = document.getElementById("toggle");

toggleButton.addEventListener("click", toggleMarkup);

function toggleMarkup() {
  if (toggleContainer.children.length > 0) {
    toggleContainer.innerHTML = "";
  } else {
    toggleContainer.innerHTML = toggledContent;
  }
}

const toggledContent = `
<div class="row mb-3">
    <label for="nolabel">
       Here's a label
    </label>
</div>
<div class="row mb-3">
   This checkbox has problems
   <input type="checkbox" class="form-check-input" />
</div>
`;
