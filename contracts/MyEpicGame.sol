// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// Hlper we wrote to encode in Base64
import "./libraries/Base64.sol";

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


import "hardhat/console.sol";

contract MyEpicGame is ERC721 {

    // Hold charcter attributes in this struct
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    // The tokenId is the NFTS unique identifier, it's just a number that goes 0,1,2 etc.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // An array to help hold the default data for the characters.
    // Helpful when we mint new charcters and need to know things like their HP, AD, etc.
    CharacterAttributes[] defaultCharacters;

    // Create a mapping from the nft's tokenId => that NFTs attributes
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    struct BigBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    BigBoss public bigBoss;

    // A mapping from an address => the NFTs tokenID. Gives an easy way 
    // to store the owner of the NFT and reference it later.
    mapping(address => uint256) public nftHolders;

    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint256 newBossHp, uint newPlayerHp);

    // Data passed in to the contract when it's first created initializing the characters.
    // Values will be passed in from run.js
    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,

        string memory bossName, // new variables to be passed via run.js or deploy.js
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage

        // Below, added special identier symbol for our NFT.
        // This is the name and symbol for the token, e.g Ethereum and ETH.
    )
        ERC721("SaikyouHero", "SAIKYOU")
    {
        // Initialize the boss. Save it to the global "bigBoss" state variable.
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log("Done initializing boss %s  w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);


        // Loop through all the characters, and save their values in the contract so
        // they can be used later when NFTs are minted.
        for(uint i = 0; i<characterNames.length; i += 1) {
            defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHp[i],
                maxHp: characterHp[i],
                attackDamage: characterAttackDmg[i]
            }));

            CharacterAttributes memory c = defaultCharacters[i];
            console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
        }

        // Increment tokenIds here so that the first NFT has ID of 1.
        _tokenIds.increment();
    }


    // Users would be able to hit this function and get their NFT based on the
    // characterId they send in.
    function mintCharacterNFT(uint _characterIndex) external {
        // Get current tokenId (starts at 1 since we incremented in the constructor)
        uint256 newItemId = _tokenIds.current();

        // Assigns the tokenId to the caller's wallet address
        _safeMint(msg.sender, newItemId);

        // Map the tokenId => their character attributes.
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log("Minted NFT w/ tokenId %s and characterId %s", newItemId, _characterIndex);

        // Keep an easy way to see who owns what NFT.
        nftHolders[msg.sender] = newItemId;

        // Increment the tokenId for the next person that uses it.
        _tokenIds.increment();

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function attackBoss() public {
        // Get the state of the player's NFT
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

        console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
        console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

        require (
            player.hp > 0,
            "Error: charcter must have HP to attack boss."
        );

        require (
            bigBoss.hp > 0,
            "Error: boss must have HP to attack boss."
        );

        // Allow player to attack boss.
        if (bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }

        // Allow boss to attack player.
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }

        console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
        console.log("Boss attacked player. New player hp: %s", player.hp);

        emit AttackComplete(bigBoss.hp, player.hp);
    }

    function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
        // Get the tokenId for the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];
        // If the user has a tokenId in the map, return their character
        if (userNftTokenId > 0 ) {
            return nftHolderAttributes[userNftTokenId];
        }
        // else return an empty charcter
        else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }


    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        ' -- NFT #: ',
                        Strings.toString(_tokenId),
                        '", "description": "Saikyou Hero is a turn-based NFT game where you take turns to attack the Strongest in order to claim the mantle of STRONGEST HERO!", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ {"trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, {"trait_type": "Attack Damage", "value": ',
                        strAttackDamage,'} ]}'
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}