pragma solidity ^0.4.24;

import "../interfaces/IOnchainStore.sol";
import "../StoreBase.sol";

contract TokenizeTokenizer is IOnchainStore, StoreBase {

    constructor(address _registry) public StoreBase(_registry, "Tokenize") {}

    function setProductPrice(bytes32 _appId, uint _price) public{
        require(msg.sender == products[_appId].publisher, "Not called by publisher");
        products[_appId].price = _price;
    }

}
