pragma solidity ^0.4.24;

import "./IStoreBase.sol";

contract IOffchainStore is IStoreBase {

    function pricePathLength() public view returns(uint) {}

    function parsePrice (string _rawPrice) public pure returns (uint256);
    function getPriceURL(bytes32 _appId) public pure returns (string);
    function getPricePathAt(uint _pos, bytes32 _appId) public pure returns (string);
}