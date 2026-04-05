import { refreshApex } from "@salesforce/apex";
import { getListUi } from "lightning/uiListApi";
import { apex } from "./generated/apex-bindings.js";

export default class SfDataBridge {
  constructor({ emit } = {}) {
    this._emit = typeof emit === "function" ? emit : () => {};
    
    this._resources = new Map(); // name -> { state, subs:Set<fn>, refresh:fn }
    this._pending = new Set(); // names queued for notify
  }

  remove(name) {
    this._resources.delete(name);
    this._listUiRemove?.(name);
  }

  get(name) {
    return (
      this._resources.get(name)?.state || {
        loading: true,
        data: null,
        error: null
      }
    );
  }

  subscribe(name, cb) {
    const entry = this._ensure(name);
    entry.subs.add(cb);
    // Push current state immediately so the subscriber is “hot”
    cb(entry.state || { loading: true, data: null, error: null });
    return () => entry.subs.delete(cb);
  }

  refresh(name) {
    const entry = this._resources.get(name);
    return entry?.refresh?.();
  }

  emit(type, detail) {
    this._emit(type, detail);
  }

  async apexQuery(apexClassName, methodName, args = {}) {
    console.log("apexQuery", apexClassName, methodName, args);

    const key = `${apexClassName}.${methodName}`;
    const fn = _getApexMethod(key);

    const e = this._ensure(key);
    e.state = { loading: true, data: null, error: null };
    this._notify(key);

    e.refresh = () => this.apexQuery(apexClassName, methodName, args);

    try {
      const data = await fn(args);
      e.state = { loading: false, data, error: null };
    } catch (error) {
      e.state = { loading: false, data: null, error };
    }
    this._notify(key);
  }

  async apexMutate(apexClassName, methodName, args = {}, { refresh } = {}) {
    // Example apexMutate("AccountController", "createAccount", {"name": "Tzach"}, {refresh: ["getAccounts"]})
    console.log("apexMutate", apexClassName, methodName, args, refresh);
    const key = `${apexClassName}.${methodName}`;
    const fn = _getApexMethod(key);
    
    // Update state to loading and notify subscribers
    const e = this._ensure(key);
    e.state = { loading: true, data: null, error: null };
    this._notify(key);
    
    try {
      const result = await fn(args);
      // Update state with result and notify subscribers
      e.state = { loading: false, data: result, error: null };
      this._notify(key);
      
      // Refresh other methods if specified
      const targets = Array.isArray(refresh) ? refresh : refresh ? [refresh] : [];
      await Promise.all(
        targets.map((r) => this.refresh(`${apexClassName}.${r}`))
      );
      return result;
    } catch (error) {
      // Update state with error and notify subscribers
      e.state = { loading: false, data: null, error };
      this._notify(key);
      throw error;
    }
  }

  destroy() {
    this._resources.clear();
    this._pending.clear();
  }

  _ensure(name) {
    if (!this._resources.has(name)) {
      this._resources.set(name, {
        state: { loading: true, data: null, error: null },
        subs: new Set(),
        refresh: null
      });
    }
    return this._resources.get(name);
  }

  _notify(name) {
    const e = this._resources.get(name);
    if (!e) {
      return;
    }
    for (const cb of e.subs) {
      cb(e.state);
    }
  }
}

function _getApexMethod(key) {
  const fn = apex[key];
  if (!fn) {
    throw new Error(`Unknown Apex method: ${key}`);
  }
  return fn;
}
