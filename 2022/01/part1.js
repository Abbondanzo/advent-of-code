const fs = require("fs");

const input = fs.readFileSync("input").toString();
const elves = input.split("\n\n");

const totals = elves.map((elf) => {
  const calCounts = elf.split("\n").map(Number);
  return calCounts.reduce((prev, cur) => prev + cur, 0);
});

console.log(Math.max(...totals));
