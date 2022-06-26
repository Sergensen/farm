require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  solidity: "0.8.15",
  networks: {
    hardhat: {
    },
    rinkeby: {
        url: process.env.RINKEBY_RPC_URL,
        accounts: [process.env.PRIVATE_KEY]
    },
    arbitrum: {
        url: process.env.ARBITRUM_RPC_URL,
        accounts: [process.env.ARBITRUM_PRIVATE_KEY]
    }
  },
  etherscan: {
      apiKey: process.env.ETHERSCAN_API_KEY
  }
};
