const fs = require("fs");
const path = require("path");
const { checkMagnitude, add, fullyReduce } = require("./part1");

const fileInput = fs.readFileSync(path.join(__dirname, "input")).toString();
const lines = fileInput.split("\n");

let largestMagnitude = 0;
for (let i = 0; i < lines.length; i++) {
  for (let j = 0; j < lines.length; j++) {
    // Key takeaway: mutation is bad
    const bigTuple = add(JSON.parse(lines[i]), JSON.parse(lines[j]));
    fullyReduce(bigTuple);
    const magnitude = checkMagnitude(bigTuple);
    if (magnitude > largestMagnitude) {
      largestMagnitude = magnitude;
    }
  }
}
