const fs = require("fs");
const solc = require("solc");

const input = fs.readFileSync("Voting.sol", "utf8");

const output = solc.compile(
  JSON.stringify({
    language: "Solidity",
    sources: {
      "Voting.sol": {
        content: input,
      },
    },
    settings: {
      outputSelection: {
        "*": {
          "*": ["*"],
        },
      },
    },
  })
);

const { Voting } = JSON.parse(output).contracts["Voting.sol"];
fs.writeFileSync("Voting.abi", JSON.stringify(Voting.abi));
fs.writeFileSync("Voting.bin", Voting.evm.bytecode.object);
