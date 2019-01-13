pragma solidity ^0.4.24;

import "../interfaces/IOffchainStore.sol";
import "../StoreBase.sol";

contract SteamTokenizer is IOffchainStore, StoreBase {

    uint public pricePathLength = 4;

    constructor(address _registry) public StoreBase(_registry, "Steam") {}

    function getPricePathAt(uint _pos, bytes32 _appId) public pure returns(string){
        string memory ret;
        if(_pos == 0){
            ret = strConcat("'",bytes32ToString(_appId),"'");
        }else if(_pos == 1){
            ret = "data";
        }else if(_pos == 2){
            ret = "price_overview";
        }else if(_pos == 3){
            ret = "final";
        }
        return ret;

    }

    function getPriceURL(bytes32 _appId) public pure returns (string) {
        return strConcat("https://store.steampowered.com/api/appdetails?appids=",bytes32ToString(_appId),"&cc=us");
    }

    function parsePrice (string _price) public pure returns (uint256) {
        return parseInt(_price) * 10000000000000000;
    }

}
