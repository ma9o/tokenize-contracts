 const HDWalletProvider = require("truffle-hdwallet-provider");
 
 const infura = "API ENDPOINT";
 const mnemo = "WALLET MNEMONIC";

 module.exports = {
     networks: {
         development: {
             host: "localhost",
             port: 8545,
             network_id: "*",
             gas: 6721975,
             gasPrice: 20000000000
         },
         ropsten: {
            provider: new HDWalletProvider(mnemo, infura),
            network_id: "3",
            gas: 4700000
         }
     },
     solc: { optimizer: { enabled: true, runs: 200 } }
 };
