const fs = require("fs");

// const fakeInput = `199
// 200
// 208
// 210
// 200
// 207
// 240
// 269
// 260
// 263`;

const fileInput = fs.readFileSync("input").toString();
const depths = fileInput.split("\n").map(Number);
const windowSize = 3;

/**
 * Given an index in `depths`, takes the total sum of that element and N following elements where N
 * is `windowSize`.
 *
 * @param {number} index
 * @returns sum of that window
 */
const windowSum = (index) => {
  let sum = 0;
  for (let w = 0; w < windowSize; w++) {
    sum += depths[index + w];
  }
  return sum;
};

let numLarger = 0;
let previousWindowSum = Infinity;

for (let i = 0; i < depths.length - windowSize + 1; i++) {
  const sum = windowSum(i);
  if (previousWindowSum < sum) {
    numLarger++;
  }
  previousWindowSum = sum;
}

// Consider sums of a three-measurement sliding window. How many sums are larger than the previous sum?
console.log("Number of window depths larger than previous:", numLarger);
