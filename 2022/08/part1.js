const fs = require("fs");
const data = fs.readFileSync("input").toString();
const lines = data.split("\n").filter(Boolean);

const trees = lines.map((row) => row.trim().split("").map(Number));

const outsideVisible = trees.length * 2 + trees[0].length * 2;

let insideVisible = new Set();

for (let rowIdx = 1; rowIdx < trees.length - 2; rowIdx++) {
  const row = trees[rowIdx];

  // Scan left to right
  let minHeight = row[0];
  for (let colIdx = 1; colIdx < row.length - 2; colIdx++) {
    const tree = row[colIdx];
    if (tree > minHeight) {
      if (rowIdx === 1 && colIdx === 65) {
        throw new Error("stop");
      }
      insideVisible.add(`${rowIdx}-${colIdx}-${tree}`);
      minHeight = tree;
    }
  }

  // Scan right to left
  const maxHeight = minHeight;
  minHeight = row[row.length - 1];
  for (let colIdx = row.length - 2; colIdx > 0; colIdx--) {
    const tree = row[colIdx];
    if (tree > minHeight) {
      if (rowIdx === 1 && colIdx === 65) {
        throw new Error("stop");
      }
      insideVisible.add(`${rowIdx}-${colIdx}-${tree}`);
      minHeight = tree;
    }
    // Avoid looping over the rest
    if (tree === maxHeight) {
      break;
    }
  }
}

for (let colIdx = 1; colIdx < trees[0].length - 2; colIdx++) {
  // Scan top to bottom
  let minHeight = trees[0][colIdx];
  for (let rowIdx = 1; rowIdx < trees.length - 2; rowIdx++) {
    const tree = trees[rowIdx][colIdx];
    if (tree > minHeight) {
      insideVisible.add(`${rowIdx}-${colIdx}-${tree}`);
      minHeight = tree;
    }
  }

  // Scan bottom to top
  const maxHeight = minHeight;
  minHeight = trees[trees.length - 1][colIdx];
  for (let rowIdx = trees.length - 2; rowIdx > 0; rowIdx--) {
    const tree = trees[rowIdx][colIdx];
    if (tree > minHeight) {
      if (rowIdx === 1 && colIdx === 65) {
        throw new Error("stop");
      }
      insideVisible.add(`${rowIdx}-${colIdx}-${tree}`);
      minHeight = tree;
    }
    // Avoid looping over the rest
    if (tree === maxHeight) {
      break;
    }
  }
}

// console.log(insideVisible);
console.log(outsideVisible + insideVisible.size);
