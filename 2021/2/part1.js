const fs = require("fs");
const fileInput = fs.readFileSync("input").toString();

let depth = 0;
let forward = 0;

fileInput.split("\n").forEach((line) => {
  if (!line) {
    return;
  }
  const [direction, distanceStr] = line.split(" ");
  const distance = Number(distanceStr);
  switch (direction) {
    case "forward":
      forward += distance;
      break;
    case "down":
      depth += distance;
      break;
    case "up":
      depth -= distance;
      break;
    default:
      throw new Error(`Received unknown instruction ${direction}`);
  }
});

// What do you get if you multiply your final horizontal position by your final depth?
console.log("Final multiplication:", forward * depth);
