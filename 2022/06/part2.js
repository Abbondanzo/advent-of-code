const fs = require("fs");
const data = fs.readFileSync("input").toString();
const lines = data.split("\n").filter(Boolean);
