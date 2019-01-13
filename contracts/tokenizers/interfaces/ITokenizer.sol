pragma solidity ^0.4.24;

contract ITokenizer {
    function stores(bytes32 _storeName) public view returns(address) {}
    function storesList(uint _index) public view returns(bytes32) {}

    function getStore(bytes32 _name) public view returns(address);
    function storesCount() public view returns(uint);
    function addStore(address _storeContract) public;
    function buy(bytes32 _appId, bytes32 _store) public payable;

}