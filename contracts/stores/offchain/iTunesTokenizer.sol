pragma solidity ^0.4.24;

import "../interfaces/IOffchainStore.sol";
import "../StoreBase.sol";

contract iTunesTokenizer is IOffchainStore, StoreBase {

    uint public pricePathLength = 3;

    constructor(address _registry) public StoreBase(_registry, "iTunes") {}

    function getPricePathAt(uint _pos, bytes32 _appId) public pure returns(string){
        string memory ret;
        if(_pos == 0){
            ret = "results";
        }else if(_pos == 1){
            ret = "0";
        }else if(_pos == 2){
            ret = "price";
        }
        return ret;

    }

    function getPriceURL(bytes32 _appId) public pure returns (string) {
        return strConcat("https://itunes.apple.com/lookup?id=",bytes32ToString(_appId));
    }

    function parsePrice (string _price) public pure returns (uint256) {
        return parseInt(_price,2) * 10000000000000000;
    }

}

