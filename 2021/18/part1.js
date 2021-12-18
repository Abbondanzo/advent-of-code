const fs = require("fs");
const path = require("path");
const fileInput = fs.readFileSync(path.join(__dirname, "demo")).toString();

const flattenTuple = (tuple, depth) => {
  const [left, right] = tuple;
  const flattened = [];
  if (Array.isArray(left)) {
    flattened.push(...flattenTuple(left, depth + 1));
  } else {
    flattened.push([left, depth]);
  }
  if (Array.isArray(right)) {
    flattened.push(...flattenTuple(right, depth + 1));
  } else {
    flattened.push([right, depth]);
  }
  return flattened;
};

const lines = fileInput.split("\n").map((line) => {
  const nums = [];
  let depth = 0;
  const tuples = JSON.parse(line);
  return flattenTuple(tuples, 0);
});

const shouldExplode = (input, index) => {
  return input[index][1] >= 4;
};

const shouldSplit = (input, index) => {
  return input[index][0] >= 10;
};

const isFirst = (input, index) => {
  if (index == 0) {
    return true;
  } else {
    return input[index - 1][1] < input[index][1];
  }
};

const reduce = (input) => {
  const newNums = [];
  let shouldRunAgain = false;
  for (let index = 0; index < input.length; index++) {
    // Explode on first element
    if (shouldExplode(input, index)) {
      shouldRunAgain = true;
      const firstValue = input[index][0];
      const secondValue = input[index + 1][0];
      // Mutate prev
      if (index > 0) {
        const [prevNum, prevDepth] = input[index - 1];
        newNums[index - 1] = [prevNum + firstValue, prevDepth];
        newNums.push([0, prevDepth]);
      }
      // Mutate next
      if (input.length > index + 2) {
        const [nextNum, nextDepth] = input[index + 2];
        newNums.push([nextNum + secondValue, nextDepth]);
      }
      index += 2;
    } else if (shouldSplit(input, index)) {
      shouldRunAgain = true;
      const depth = input[index][1];
      const left = Math.floor(input[index][0] / 2);
      const right = Math.ceil(input[index][0] / 2);
      newNums.push([left, depth + 1]);
      newNums.push([right, depth + 1]);
    } else {
      newNums.push(input[index]);
    }
  }
  console.log(shouldRunAgain);
  return newNums;
};

const add = (tupleA, tupleB) => {
  return [
    tupleA.map(([value, depth]) => [value, depth + 1]),
    tupleB.map(([value, depth]) => [value, depth + 1]),
  ];
};

console.log(lines[0]);
console.log(reduce(lines[0]));

// const reduceHelper = (tuple, depth) => {
//   // Explode pairs
//   if (depth >= 4) {
//     return tuple;
//   }
//   // Split pairs
//   const [left, right] = tuple;
//   const checkNum = (item) => {
//     if (typeof item === "number" && item >= 10) {
//       return [Math.floor(item / 2), Math.ceil(item / 2)];
//     }
//   };
//   const checkNums = checkNum(left) || checkNum(right);
//   if (checkNums) return checkNums;
//   const checkTuples = (item) => {
//     if (Array.isArray(item)) {
//       return reduceHelper(item, depth + 1);
//     }
//   };
//   return checkTuples(left) || checkTuples(right);
// };

// const reduce = (tuple) => {
//   let f = reduceHelper(tuple, 0);
//   console.log(f);
// };

// reduce(lines[0]);
