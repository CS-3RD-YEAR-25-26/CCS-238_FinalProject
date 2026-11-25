// CommonJS require loads Node's path helper. Destructuring picks resolve.
const { resolve } = require("node:path");

// Array destructuring binds the arguments after the executable and script.
const [file, moduleName] = process.argv.slice(2);
// The || guard treats either missing argument as invalid.
if (!file || !moduleName) {
    // Throwing an Error ends startup with a usage message.
    throw new Error("Usage: node run.cjs <compiled-file.js> <Elm-module>");
// End the argument guard before loading the compiled module.
}

// Resolve from the working directory and read the module's Elm export.
const { Elm } = require(resolve(file));
// Bracket access selects the Elm module named on the command line.
const app = Elm[moduleName].init();
// Schedule a timeout in case the Elm report port never responds.
const timer = setTimeout(() => {
    // console.error writes the failure message to standard error.
    console.error("The Elm worker did not report any output.");
    // exitCode marks failure while allowing outstanding I/O to finish.
    process.exitCode = 1;
// The timer delay is expressed in milliseconds.
}, 5000);
// Register an outgoing-port callback before triggering the worker.
app.ports.report.subscribe((lines) => {
    // Receiving the expected report cancels the fallback timer.
    clearTimeout(timer);
    // Join the port's string array and write the lines to standard output.
    process.stdout.write(lines.join("\n") + "\n");
// End the subscription callback after writing the report.
});
// Send null through the incoming port to represent Elm's unit value.
app.ports.start.send(null);
