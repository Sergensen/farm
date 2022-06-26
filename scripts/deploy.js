async function main() {
  const farmFactory = await ethers.getContractFactory("Farm");
  const farm = await upgrades.deployProxy(farmFactory);
  await farm.deployed();
  console.log("Deployed to:", farm.address);

  await verify(farm.address)
}

async function verify (contractAddress, args)  {
    console.log("Veryfing contract " +contractAddress)
    try {
        await run("verify:verify", {
          address: contractAddress,
          constructorArguments: args,
        });
        console.log("verified at "+contractAddress)
      } catch (e) {
        if (e.message.toLowerCase().includes("verified")) {
          console.log("Already Verified");
        } else console.log(e);
      }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
