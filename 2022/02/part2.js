const fs = require("fs");
const data = fs.readFileSync("input").toString();
const parsedData = data
  .split("\n")
  .filter(Boolean)
  .map((row) => row.split(" "));

const RPS = ["A", "B", "C"]; // rock, paper, scissors
const scoreRow = ([player, outcome]) => {
  let totalScore = 0;
  const theirChoice = RPS.indexOf(player);
  let yourChoice;

  if (outcome === "X") {
    yourChoice = (theirChoice + 2) % 3;
  } else if (outcome === "Y") {
    totalScore += 3;
    yourChoice = theirChoice;
  } else if (outcome === "Z") {
    totalScore += 6;
    yourChoice = (theirChoice + 1) % 3;
  }

  return totalScore + yourChoice + 1;
};

// what would your total score be if everything goes exactly according to your strategy guide?
const result = parsedData.map(scoreRow).reduce((prev, cur) => prev + cur, 0);
console.log(result);
