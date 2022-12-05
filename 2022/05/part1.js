const fs = require("fs");
const data = fs.readFileSync("input").toString();
const lines = data.split("\n").filter(Boolean);

const NUM_CRATES = 9;

/**
 * Top of crate is at back
 * @type {Array<Array<string>>}
 */
const crates = [];

// Full index
let i = 0;

// Parse initial crate stacks
for (; i < lines.length; i++) {
  const line = lines[i];
  if (!line.trim().startsWith("[")) {
    break;
  }

  for (let j = 0; j < NUM_CRATES; j++) {
    const charOffset = j * 4 + 1;
    const maybeChar = line[charOffset].trim();
    if (maybeChar) {
      if (!crates[j]) {
        crates[j] = [];
      }
      crates[j].unshift(maybeChar);
    }
  }
}

// Skip space
i++;

const regexp = new RegExp(/move (\d+) from (\d+) to (\d+)/);
for (; i < lines.length; i++) {
  const match = regexp.exec(lines[i]);
  const count = Number(match[1]);
  const from = Number(match[2]);
  const to = Number(match[3]);

  // Pop and push, although it's slow /shrug
  const fromArray = crates[from - 1];
  const toArray = crates[to - 1];

  for (let j = 0; j < count; j++) {
    toArray.push(fromArray.pop());
  }
}

// After the rearrangement procedure completes, what crate ends up on top of each stack?
const tops = crates.map((crate) => crate[crate.length - 1]);
console.log(tops.join(""));
