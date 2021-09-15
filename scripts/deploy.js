async function main() {
    const slots = await ethers.getContractFactory("slots");
    const newContract = await slots.deploy();
    console.log("Contract deployed to address: ", newContract.address);
}

main()
    .then(() => process.exit(0))
    .catch(error =>{
        console.error(error);
        process.exit(1);
    });

