const fs = require("fs");
const data = fs.readFileSync("input").toString();

const stratA = ["A", "B", "C"];
const stratB = ["X", "Y", "Z"]; // rock, paper, scissors

const scoreRow = (row) => {
  const [a, b] = row.split(" ");

  const firstPlayer = stratA.indexOf(a);
  const secondPlayer = stratB.indexOf(b) || 3; // default to larger score

  const scored = (secondPlayer - firstPlayer) % 3; // 0 -2, 2 - 0, 2 - 1

  let totalScore = 0;
  if (scored === 1) {
    totalScore += 6;
  } else if (scored === 0) {
    totalScore += 3;
  }

  totalScore += 1 + stratB.indexOf(b);

  return totalScore;
};

const result = data
  .split("\n")
  .filter(Boolean)
  .map(scoreRow)
  .reduce((prev, cur) => prev + cur, 0);

// What would your total score be if everything goes exactly according to your strategy guide?
console.log(result);
