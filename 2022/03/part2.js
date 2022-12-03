const fs = require("fs");
const data = fs.readFileSync("input").toString();
const lines = data.split("\n").filter(Boolean);

const priorityVal = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

let total = 0;

for (let i = 0; i < lines.length; i += 3) {
  const [a, b, c] = lines.slice(i, i + 3);
  for (let j = 0; j < c.length; j++) {
    const char = c[j];
    if (a.includes(char) && b.includes(char)) {
      total += priorityVal.indexOf(char) + 1;
      break;
    }
  }
}

// What is the sum of the priorities of those item types?
console.log(total);
