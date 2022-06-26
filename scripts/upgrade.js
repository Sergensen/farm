
async function main() {
  const newFarmFactory = await ethers.getContractFactory("FarmV2");
  await upgrades.upgradeProxy("0xc09dacc3eb1eb2f129656f747c68465a8e16062b", newFarmFactory);
  console.log("farm upgraded");
}

main();