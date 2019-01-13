pragma solidity ^0.4.24;

import "./IStoreBase.sol";

contract IOnchainStore is IStoreBase {
    function setProductPrice(bytes32 _appId, uint _price) public;
}