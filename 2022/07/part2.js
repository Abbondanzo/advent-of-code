const fs = require("fs");
const data = fs.readFileSync("input").toString();
const lines = data.split("\n").filter(Boolean);

const { parseTree } = require("./shared");
const fileTree = parseTree(lines);

const unusedSpace = 70_000_000 - fileTree.size;
const deleteRequired = 30_000_000 - unusedSpace;

const getSmallest = (node) => {
  if (node.size < deleteRequired) {
    return null;
  }
  if (!node.children) {
    return null;
  }

  let smallest = node;
  for (const childNode of node.children) {
    const childSmallest = getSmallest(childNode);
    if (childSmallest && childSmallest.size < smallest.size) {
      smallest = childSmallest;
    }
  }
  return smallest;
};

console.log(getSmallest(fileTree).size);
