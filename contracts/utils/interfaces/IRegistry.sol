pragma solidity ^0.4.24;

contract IRegistry {

    function tokenizers(bytes32 _name) public view returns (address) {}
    function tokenizersList(uint _index) public view returns (bytes32 _name) {}
    function tokenizersAddresses(uint _index) public view returns (address) {}
    function TKZETH() public view returns (address) {}
    function formula() public view returns (address) {}

    function tokenizersCount() public view returns (uint);
    function addTokenizer(bytes32 _name, address _addr) public;

}