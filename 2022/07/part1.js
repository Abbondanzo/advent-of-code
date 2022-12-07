const fs = require("fs");
const data = fs.readFileSync("input").toString();
const lines = data.split("\n").filter(Boolean);

const { parseTree } = require("./shared");
const fileTree = parseTree(lines);

let total = 0;

const applyTotal = (node) => {
  if (node.children) {
    if (node.size <= 100000) {
      total += node.size;
    }
    node.children.forEach((childNode) => {
      applyTotal(childNode);
    });
  }
};

applyTotal(fileTree);

console.log(total);
