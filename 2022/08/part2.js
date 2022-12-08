const fs = require("fs");
const data = fs.readFileSync("input").toString();
const lines = data.split("\n").filter(Boolean);
const trees = lines.map((row) => row.trim().split("").map(Number));

const evaluateScenicScore = (rowIdx, colIdx) => {
  let r;
  let c;
  const height = trees[rowIdx][colIdx];

  if (rowIdx === 0 || rowIdx === trees.length - 1) {
    return 0;
  }

  if (colIdx === 0 || colIdx === trees[0].length - 1) {
    return 0;
  }

  // Look left
  c = colIdx - 1;
  while (c > 0 && trees[rowIdx][c] < height) {
    c--;
  }
  const left = colIdx - c;

  // Look right
  c = colIdx + 1;
  while (c < trees[0].length - 1 && trees[rowIdx][c] < height) {
    c++;
  }
  const right = c - colIdx;

  // Look up
  r = rowIdx - 1;
  while (r > 0 && trees[r][colIdx] < height) {
    if (r === 0) {
      break;
    }
    r--;
  }
  const up = rowIdx - r;

  // Look down
  r = rowIdx + 1;
  while (r < trees.length - 1 && trees[r][colIdx] < height) {
    r++;
  }
  const down = r - rowIdx;

  return left * right * up * down;
};

let max = 0;
for (let rowIdx = 0; rowIdx < trees.length; rowIdx++) {
  const row = trees[rowIdx];
  for (let colIdx = 0; colIdx < row.length; colIdx++) {
    max = Math.max(max, evaluateScenicScore(rowIdx, colIdx));
  }
}

console.log(max);
