async function main() {
  const farmFactory = await ethers.getContractFactory("Farm");
  const farm = await upgrades.deployProxy(farmFactory);
  await farm.deployed();
  console.log("Deployed to:", farm.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
