require("@nomiclabs/hardhat-waffle");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.0",
  networks: {
    rinkeby: {
      url: 'https://eth-rinkeby.alchemyapi.io/v2/h9Lker04wWHPvaWNx-ofixm6LJvfRF9S',
      accounts: ['7f4f6e90f7f1f51a42b4f1b4e3abb1a7fc3e0a031b1b7b75b974787a916eb75c'],
    },
  },
};
