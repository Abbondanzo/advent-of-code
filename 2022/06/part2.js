const fs = require("fs");
const data = fs.readFileSync("input").toString();

const BUFFER_SIZE = 14;

let i = BUFFER_SIZE;
while (i < data.length) {
  const str = data.slice(i - BUFFER_SIZE, i);
  const set = new Set(str.split(""));
  if (set.size === BUFFER_SIZE) {
    break;
  }
  i++;
}

console.log(i);
