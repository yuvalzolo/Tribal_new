import SfDataBridge from "./SfDataBridge";

import { LightningElement, api, track } from "lwc";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import REACT from "@salesforce/resourceUrl/react";
import REACT_APP from "@salesforce/resourceUrl/chessDashboard_app";

const LOAD_FAILED_TITLE = "Failed loading component";

export default class ReactHost extends LightningElement {
  _root = null;

  constructor() {
    super();

    try {
      this._bridge = new SfDataBridge({
        emit: (type, detail) =>
          this.dispatchEvent(
            new CustomEvent(type, { detail, bubbles: true, composed: true })
          )
      });
    } catch (e) {
      console.error("Failed initializing data bridge: ", e);
      this.showErrorToast(LOAD_FAILED_TITLE, e.message);
    }
  }

  renderedCallback() {
    if (this._root) {
      return;
    }

    this._loadReact()
      .then(() => {
        this._loadApp()
          .then(() => {
            this._mountApp();
          })
          .catch((e) => {
            console.error("Failed loading app: ", e);
            this.showErrorToast(LOAD_FAILED_TITLE, e.message);
          });
      })
      .catch((e) => {
        console.error("Failed loading React: ", e);
        this.showErrorToast(LOAD_FAILED_TITLE, e.message);
      });
  }

  _loadReact() {
    console.log("Loading React from ", REACT);
    return Promise.all([
      loadScript(this, REACT + "/react.production.min.js"),
      loadScript(this, REACT + "/react-dom.production.min.js")
    ]).then(() => {
      console.log("React loaded!");
    });
  }

  _loadApp() {
    console.log("Loading app...");
    return Promise.all([
      loadScript(this, REACT_APP + "/app.js"),
      loadStyle(this, REACT_APP + "/app.css")
    ]).then(() => {
      console.log("App loaded!");
    });
  }

  _mountApp() {
    console.log("Mounting app...");
    const mount = this.template.querySelector(".mount");

    if (!window.ReactDOM) {
      console.error("ReactDOM unavailable");
      this.showErrorToast(LOAD_FAILED_TITLE, "Please reload the page.");
      // TODO: retry loadScript (is it safe?)
      return;
    }

    console.log("Creating React root at", mount);
    this._root = window.ReactDOM.createRoot(mount);
    this._renderReact();
  }

  _renderReact() {
    console.log("Rendering app...");
    if (!this._root || !window.__reactApp) {
      console.error(
        "Render prerequisites failed",
        !!this._root,
        !!window.__reactApp
      );
      this.showErrorToast(LOAD_FAILED_TITLE, "Please reload the page.");
      return;
    }

    const props = {
      bridge: this._bridge
    };
    const reactElement = window.React.createElement(window.__reactApp, props);
    this._root.render(reactElement);
  }

  disconnectedCallback() {
    // Tear down React tree when LWC is destroyed
    this.root?.unmount();
    this.root = undefined;
  }

  showErrorToast(title, message) {
    this.dispatchEvent(
      new ShowToastEvent({
        title,
        message,
        variant: "error"
      })
    );
  }
}
