const fs = require("fs");
const path = require("path");
const fileInput = fs.readFileSync(path.join(__dirname, "demo")).toString();

const lines = fileInput.split("\n").map((line) => {
  return JSON.parse(line);
});

const addExplodeLeft = (tuple, amount) => {
  let leftTuple = tuple;
  while (true) {
    if (Array.isArray(leftTuple[1])) {
      leftTuple = leftTuple[1];
    } else {
      leftTuple[1] += amount;
      break;
    }
  }
};

const addExplodeRight = (tuple, amount) => {
  let rightTuple = tuple;
  while (true) {
    if (Array.isArray(rightTuple[0])) {
      rightTuple = rightTuple[0];
    } else {
      rightTuple[0] += amount;
      break;
    }
  }
};

const attemptExplode = (tuple) => {
  const [left, right] = tuple;
  if (Array.isArray(left)) {
    // Save left/right values before exploding
    const [applyLeft, applyRight] = left;
    // Explode by replacing with 0
    tuple[0] = 0;
    // Apply the right value to the right of this tuple
    if (!Array.isArray(right)) {
      tuple[1] += applyRight;
    } else {
      addExplodeRight(right, applyRight);
    }
    return [applyLeft, null];
  }
  if (Array.isArray(right)) {
    // Save left/right values before exploding
    const [applyLeft, applyRight] = right;
    // Explode by replacing with 0
    tuple[1] = 0;
    // Apply the left value to the left of this tuple
    tuple[0] += applyLeft;

    return [null, applyRight];
  }
  return [null, null];
};

// Performs mutation, returns if an explosion occurred or if a split occurred
const reduce = (tuple, depth = 0) => {
  // Check if inner values should explode
  if (depth === 3) {
    const [applyLeft, applyRight] = attemptExplode(tuple);
    if (applyLeft !== null || applyRight !== null) {
      return [applyLeft, applyRight];
    }
  }
  // Check if left/right values need to split
  const [left, right] = tuple;
  if (!Array.isArray(left) && left >= 10) {
    tuple[0] = [Math.floor(left / 2), Math.ceil(left / 2)];
    return true;
  }
  if (!Array.isArray(right) && right >= 10) {
    tuple[1] = [Math.floor(right / 2), Math.ceil(right / 2)];
    return true;
  }
  // Finally, reduce left/right
  if (Array.isArray(left)) {
    const nextReduce = reduce(left, depth + 1);
    if (nextReduce) {
      // If explode, perform explode
      if (Array.isArray(nextReduce)) {
        const [applyLeft, applyRight] = nextReduce;
        if (applyLeft) {
          return [applyLeft, applyRight];
        }
        if (applyRight) {
          if (!Array.isArray(right)) {
            tuple[1] += applyRight;
          } else {
            addExplodeRight(right, applyRight);
          }
        }
      }
      return true;
    }
  }
  if (Array.isArray(right)) {
    const nextReduce = reduce(right, depth + 1);
    if (nextReduce) {
      // If explode, perform explode
      if (Array.isArray(nextReduce)) {
        const [applyLeft, applyRight] = nextReduce;
        if (applyLeft) {
          if (!Array.isArray(left)) {
            tuple[0] += applyLeft;
          } else {
            addExplodeLeft(left, applyLeft);
          }
        }
        if (applyRight) {
          return [applyLeft, applyRight];
        }
      }
      return true;
    }
  }
  return false;
};

const checkMagnitude = (tuple) => {
  const [left, right] = tuple;
  const leftValue = Array.isArray(left) ? checkMagnitude(left) : left;
  const rightValue = Array.isArray(right) ? checkMagnitude(right) : right;
  return 3 * leftValue + 2 * rightValue;
};

const fullyReduce = (tuple) => {
  while (true) {
    if (!reduce(tuple)) {
      break;
    }
  }
};

console.log(JSON.stringify(lines[0]));
fullyReduce(lines[0]);

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
