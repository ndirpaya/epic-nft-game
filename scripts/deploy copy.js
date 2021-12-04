const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
        ["Naruto", "Deku", "Goku"], // Names
        // ["https://rb.gy/arjyi4",    // Images
        //  "https://rb.gy/stekh0",
        //  "https://rb.gy/7fnsyx"],
        ["https://static.wikia.nocookie.net/naruto/images/7/7d/Naruto_Part_II.png/revision/latest/scale-to-width-down/300?cb=20210811111154",
         "https://static.wikia.nocookie.net/bokunoheroacademia/images/6/66/Izuku_Midoriya_headshot.png/revision/latest/scale-to-width-down/185?cb=20170928002152",
         "https://static.wikia.nocookie.net/dragonball/images/3/35/DPg_w17VwAAzaWy.jpg/revision/latest/scale-to-width-down/1000?cb=20171126005209"],
        [100, 100, 100],            // HP values
        [100, 80, 120],            // Attack damage values
        "Caped Baldy", // Boss name
        "https://cdn.anisearch.com/images/character/cover/full/53/53000.webp", 
        100000,
        500
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    let txn;
    // NFT with the character at index 2 of the array.
    txn = await gameContract.mintCharacterNFT(0);
    await txn.wait();
    console.log("Minted NFT #1");

    txn = await gameContract.mintCharacterNFT(1);
    await txn.wait();
    console.log("Minted NFT #2");

    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();
    console.log("Minted NFT #3");

    console.log("Done deploying and minting!");
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();