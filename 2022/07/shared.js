const parseTree = (lines) => {
  let fileTree = {
    name: "/",
    children: [],
    parent: null,
  };

  let i = 1;
  let printing = false;

  const FILE_REGEX = new RegExp(/(\d+) (\w.*)/);

  while (i < lines.length) {
    const line = lines[i];

    if (line.startsWith("$")) {
      printing = false;

      if (line.startsWith("$ cd")) {
        const dir = line.slice(4).trim();
        if (dir === "..") {
          fileTree = fileTree.parent;
        } else {
          fileTree = fileTree.children.find((node) => node.name === dir);
        }
      } else if (line.startsWith("$ ls")) {
        printing = true;
      }
    } else if (printing) {
      if (line.startsWith("dir")) {
        const child = {
          name: line.slice(4).trim(),
          parent: fileTree,
          children: [],
        };
        fileTree.children.push(child);
      } else {
        const [, size, name] = FILE_REGEX.exec(line);
        const file = {
          name,
          size: Number(size),
          parent: fileTree,
        };
        fileTree.children.push(file);
      }
    }

    i++;
  }

  while (fileTree.parent) {
    fileTree = fileTree.parent;
  }

  // Mutate, eh
  const applyFileSize = (node) => {
    if (node.size) {
      return node.size;
    } else if (node.children) {
      node.size = node.children.reduce(
        (prev, curNode) => applyFileSize(curNode) + prev,
        0
      );
      return node.size;
    } else {
      return 0;
    }
  };

  applyFileSize(fileTree);

  return fileTree;
};

module.exports = {
  parseTree,
};
