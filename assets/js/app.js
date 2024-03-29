// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import JSConfetti from "js-confetti";

let Hooks = {};
Hooks.SetSession = {
  DEBOUNCE_MS: 200,

  // Called when a LiveView is mounted, if it includes an element that uses this hook.
  mounted() {
    // `this.el` is the form.
    this.el.addEventListener("input", (e) => {
      clearTimeout(this.timeout);
      this.timeout = setTimeout(() => {
        // Ajax request to update session.
        fetch(
          `/api/session?${e.target.name}=${encodeURIComponent(e.target.value)}`,
          { method: "post" }
        );

        // Optionally, include this so other LiveViews can be notified of changes.
        this.pushEventTo(
          ".phx-hook-subscribe-to-session",
          "updated_session_data",
          [e.target.name, e.target.value]
        );
      }, this.DEBOUNCE_MS);
    });
  },
};

Hooks.Confetti = {
  mounted() {
    const jsConfetti = new JSConfetti();
    window.confetti = jsConfetti;

    window.addEventListener(`phx:fire_confetti`, (e) => {
      let el = document.getElementById(e.detail.id);
      if (el) {
        liveSocket.execJS(
          jsConfetti.addConfetti({
            confettiRadius: 5,
            confettiNumber: 100,
            emojis: ["🌈", "✨", "💫", "🎉"],
          })
        );
      }
    });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
// Modifying this pre-existing code to include the hook.
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

window.addEventListener(`phx:bounce`, (e) => {
  let el = document.getElementById(e.detail.id);
  if (el) {
    liveSocket.execJS(el, el.getAttribute("data-bounce"));
  }
});

window.addEventListener(`phx:shake`, (e) => {
  let el = document.getElementById(e.detail.id);
  if (el) {
    liveSocket.execJS(el, el.getAttribute("data-shake"));
  }
});

window.addEventListener(`phx:win`, (e) => {
  let el = document.getElementById(e.detail.id);
  if (el) {
    liveSocket.execJS(el, el.getAttribute("data-win"));
  }
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
