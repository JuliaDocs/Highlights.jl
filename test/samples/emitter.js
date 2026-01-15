// Event emitter class
class EventEmitter {
  constructor() {
    this.events = {};
  }

  on(event, callback) {
    this.events[event] ??= [];
    this.events[event].push(callback);
    return this;
  }

  emit(event, ...args) {
    const callbacks = this.events[event] || [];
    callbacks.forEach(cb => cb(...args));
  }
}

const emitter = new EventEmitter();
emitter.on("data", (x) => console.log(`Received: ${x}`));
emitter.emit("data", 42);
