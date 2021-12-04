const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
        ["Naruto", "Deku", "Goku"], // Names
        ["https://oyster.ignimgs.com/mediawiki/apis.ign.com/naruto-shippuden-ultimate-ninja-storm-3/9/93/SageNaruto.jpg",    // Images
         "https://rb.gy/stekh0",
         "https://rb.gy/7fnsyx"],
        [2500, 2000, 3000],            // HP values
        [100, 100, 200],              // Attack damage values
        "Caped Baldy", // Boss name
        "https://cdn.anisearch.com/images/character/cover/full/53/53000.webp", 
        100000,
        250
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    // let txn;
    // NFT with the character at index 2 of the array.
    // txn = await gameContract.mintCharacterNFT(0);
    // await txn.wait();
    // console.log("Minted NFT #1");

    // txn = await gameContract.attackBoss();
    // await txn.wait();

    // txn = await gameContract.attackBoss();
    // await txn.wait();

    // console.log("Done!");


    // Get the value of the NFT's URI.
    // let returnedTokenURI = await gameContract.tokenURI(1);
    // console.log("Token URI:", returnedTokenURI);
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