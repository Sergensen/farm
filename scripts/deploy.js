const hre = require("hardhat");

async function main() {
  const farmFactory = await hre.ethers.getContractFactory("Farm");
  const farm = await farmFactory.deploy();
  await farm.deployed();
  console.log("Deployed to:", farm.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
