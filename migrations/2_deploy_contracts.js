const TKZETH = artifacts.require('TKZETH.sol');
const ChainlinkedTokenizer = artifacts.require('ChainlinkedTokenizer.sol');
const OraclizedTokenizer = artifacts.require('OraclizedTokenizer.sol');
const SmartToken = artifacts.require('SmartToken.sol');
const BancorFormula = artifacts.require('BancorFormula.sol');
const SteamTokenizer = artifacts.require('SteamTokenizer.sol');
const iTunesTokenizer = artifacts.require('iTunesTokenizer.sol');
const LinkToken = artifacts.require('LinkToken.sol');
const Oracle = artifacts.require('Oracle.sol');
const OnchainTokenizer = artifacts.require('OnchainTokenizer.sol');
const TokenizeTokenizer = artifacts.require('TokenizeTokenizer.sol');
const Registry = artifacts.require('Registry.sol');

module.exports = async (deployer, network) => {

  if(network === "development"){

    let ORACLIZE = 0x6f485c8bf6fc43ea212e93bbf8ce046c7f1cb475;

    deployer.deploy(LinkToken, web3.eth.accounts[0]).then(() => {
      return deployer.deploy(Oracle, LinkToken.address).then(() => {
        return deployer.deploy(BancorFormula).then(() => {
          return deployer.deploy(SmartToken, 'Tokenize', 'TKZ', 18).then(() => {
            return deployer.deploy(TKZETH, SmartToken.address, BancorFormula.address).then(() => {
              return deployer.deploy(Registry, BancorFormula.address, TKZETH.address).then(() => {
                return deployer.deploy(SteamTokenizer, Registry.address).then(() => {
                  return deployer.deploy(iTunesTokenizer, Registry.address).then(() => {
                    return deployer.deploy(TokenizeTokenizer, Registry.address).then(() => {
                      return deployer.deploy(ChainlinkedTokenizer, LinkToken.address, Oracle.address).then(() => {
                        return deployer.deploy(OraclizedTokenizer, ORACLIZE).then(() => {
                          return deployer.deploy(OnchainTokenizer).then(() => {

                            OnchainTokenizer.deployed().then((instance) => {
                              instance.addStore(TokenizeTokenizer.address);
                              instance.send(1000000000000000000, {from: web3.eth.accounts[0]});
                            })

                            ChainlinkedTokenizer.deployed().then((instance) => {
                              instance.addStore(SteamTokenizer.address);
                              instance.addStore(iTunesTokenizer.address);
                              instance.send(1000000000000000000, {from: web3.eth.accounts[0]});
                            })

                            OraclizedTokenizer.deployed().then((instance) => {
                              instance.addStore(SteamTokenizer.address);
                              instance.addStore(iTunesTokenizer.address);
                              instance.send(1000000000000000000, {from: web3.eth.accounts[0]});
                            })

                            Registry.deployed().then((instance) => {
                              instance.addTokenizer("Chainlinked", ChainlinkedTokenizer.address);
                              instance.addTokenizer("Onchain", OnchainTokenizer.address);
                              instance.addTokenizer("Oraclized", OraclizedTokenizer.address);
                            })

                            TKZETH.deployed().then((instance) => {
                              instance.send(1000000000000000000, {from: web3.eth.accounts[0]});
                            });

                            return SmartToken.deployed().then((instance) => {
                              instance.enableTransfers();
                              return instance.issue(web3.eth.accounts[0], 1000000000000000000).then(() => {
                                return instance.transferOwnership(TKZETH.address)
                              })
                            })
                          })
                        })
                      })
                    })
                  })
                })
              })
            })
          })
        })
      })
    })
  }else if(network === "ropsten"){

    let LINK = 0x20fE562d797A42Dcb3399062AE9546cd06f63280;
    let ORACLE = 0x261a3F70acdC85CfC2FFc8badE43b1D42bf75D69;
    let ORACLIZE = 0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1;

        deployer.deploy(BancorFormula).then(() => {
          return deployer.deploy(SmartToken, 'Tokenize', 'TKZ', 18).then(() => {
            return deployer.deploy(TKZETH, SmartToken.address, BancorFormula.address).then(() => {
              return deployer.deploy(Registry, BancorFormula.address, TKZETH.address).then(() => {
                return deployer.deploy(SteamTokenizer, Registry.address).then(() => {
                  return deployer.deploy(iTunesTokenizer, Registry.address).then(() => {
                    return deployer.deploy(TokenizeTokenizer, Registry.address).then(() => {
                      return deployer.deploy(ChainlinkedTokenizer, LINK, ORACLE).then(() => {
                        return deployer.deploy(OraclizedTokenizer, ORACLIZE).then(() => {
                          return deployer.deploy(OnchainTokenizer);
                        })
                      })
                    })
                  })
                })
              })
            })
          })
        })

  }
}