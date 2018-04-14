// Allows us to use ES6 in our migrations and tests.
require('babel-register')
var HDWalletProvider = require("truffle-hdwallet-provider");

var infura_apikey = "";
var mnemonic = "d";

module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*' // Match any network id
    },
    mainnet: {
      provider: new HDWalletProvider(mnemonic, "https://mainnet.infura.io/"+infura_apikey),
      gas: 6712390,
      gasPrice: "20000000000",   // 20gwei
      network_id: 1
    },
  }
}