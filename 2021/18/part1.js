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
  const addRest = (index) => {
    newNums.push(...input.slice(index));
  };
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

      addRest(index + 1);
      break;
    } else if (shouldSplit(input, index)) {
      shouldRunAgain = true;
      const depth = input[index][1];
      const left = Math.floor(input[index][0] / 2);
      const right = Math.ceil(input[index][0] / 2);
      newNums.push([left, depth + 1]);
      newNums.push([right, depth + 1]);

      addRest(index + 1);
      break;
    } else {
      newNums.push(input[index]);
    }
  }
  console.log(shouldRunAgain);
  return newNums;
};

const add = (inputA, inputB) => {
  return [
    inputA.map(([value, depth]) => [value, depth + 1]),
    inputB.map(([value, depth]) => [value, depth + 1]),
  ];
};

const inputToTuple = (input) => {
  const tupleTime = [];

  for (let index = 0; index < input.length; index++) {
    const [value, depth] = input[index];
    // let prevTuple;
    // let curTuple = tupleTime;
    // let curDepth = depth;
    // while (curDepth > 0) {
    //   if (curTuple.length === 0) {
    //     curTuple.push([]);
    //     prevTuple = curTuple;
    //     curTuple = curTuple[0];
    //   } else {
    //     prevTuple = curTuple;
    //     curTuple = curTuple[curTuple.length - 1];
    //   }
    //   curDepth--;
    // }
    // if (curTuple.length === 0) {
    //   curTuple[0] = value;
    // } else if (curTuple.length === 1) {
    //   curTuple[1] = value;
    // } else if (prevTuple.length === 1) {
    //   prevTuple[1] = [value];
    //   //   prevTuple[prevTuple.length - 1] = value;
    // } else {
    //   console.log("shit", JSON.stringify(tupleTime));
    // }
  }
  return tupleTime;
};

const checkMagnitude = (tuple) => {
  const [left, right] = tuple;
  const leftValue = Array.isArray(left) ? checkMagnitude(left) : left;
  const rightValue = Array.isArray(right) ? checkMagnitude(right) : right;
  return 3 * leftValue + 2 * rightValue;
};

console.log(lines[0]);
console.log(reduce(lines[0]));

console.log(checkMagnitude(inputToTuple(lines[0])));

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
