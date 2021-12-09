const fs = require("fs");

const fileInput = fs.readFileSync("input").toString();

let numLarger = 0;
let previousMeasurement = Infinity;

fileInput.split("\n").forEach((depth) => {
  const depthNum = Number(depth);
  if (previousMeasurement < depthNum) {
    numLarger++;
  }
  previousMeasurement = depthNum;
});

// How many measurements are larger than the previous measurement?
console.log("Number of depths larger than previous:", numLarger);
