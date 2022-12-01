const fs = require("fs");

const input = fs.readFileSync("input").toString();
const elves = input.split("\n\n");

const totals = elves.map((elf) => {
  const calCounts = elf.split("\n").map(Number);
  return calCounts.reduce((prev, cur) => prev + cur, 0);
});

totals.sort((a, b) => b - a);

console.log(totals[0] + totals[1] + totals[2]);
