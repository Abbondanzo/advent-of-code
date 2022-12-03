const fs = require("fs");
const data = fs.readFileSync("input").toString();

const priorityVal = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

let total = 0;
data
  .split("\n")
  .filter(Boolean)
  .forEach((line) => {
    const mid = line.length / 2;
    const start = line.slice(0, mid);
    const end = line.slice(mid);
    for (let i = 0; i < end.length; i++) {
      const char = end[i];
      if (start.includes(char)) {
        total += 1 + priorityVal.indexOf(char);
        break;
      }
    }
  });

// What is the sum of the priorities of those item types?
console.log(total);
