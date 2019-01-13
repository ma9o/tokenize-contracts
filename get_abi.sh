#!/bin/sh
solc --abi contracts/utils/interfaces/IRegistry.sol contracts/stores/interfaces/IOffchainStore.sol contracts/stores/interfaces/IOnchainStore.sol contracts/converter/interfaces/ITokenizeConverter.sol contracts/tokenizers/interfaces/ITokenizer.sol -o build --allow-paths . --overwrite 
