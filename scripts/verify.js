async function main(args) {
    const contractAddress = "0x30ad963724c95a65f02ac773e5547dd101c0731b"
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
  