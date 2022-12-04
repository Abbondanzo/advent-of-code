const fs = require("fs");
const data = fs.readFileSync("input").toString();
const lines = data.split("\n").filter(Boolean);

let total = 0;

lines.forEach((line) => {
  const [a, b] = line.split(",");
  const aRange = a.split("-").map(Number);
  const bRange = b.split("-").map(Number);

  const bEndInA = aRange[1] >= bRange[0] && bRange[0] >= aRange[0];
  const aEndInB = bRange[1] >= aRange[0] && aRange[0] >= bRange[0];

  if (bEndInA || aEndInB) {
    total++;
  }
});

// In how many assignment pairs do the ranges overlap?
console.log(total);
