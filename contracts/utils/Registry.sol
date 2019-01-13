pragma solidity ^0.4.24;

import "./interfaces/IRegistry.sol";
import "./Owned.sol";

contract Registry is IRegistry, Owned {

    constructor (address _formula, address _TKZETH) public {
        TKZETH = _TKZETH;
        formula = _formula;
    }

    mapping(bytes32 => address) public tokenizers;
    bytes32[] public tokenizersList;
    address[] public tokenizersAddresses;

    address public TKZETH;
    address public formula;

    function addTokenizer(bytes32 _name, address _addr) public {
        require(msg.sender == owner);
        tokenizers[_name] = _addr; 
        tokenizersList.push(_name);
        tokenizersAddresses.push(_addr);
    }

    function tokenizersCount() public view returns (uint) {
        return tokenizersList.length;
    }

    //TESTING ONLY
    function removeTokenizer(bytes32 _name) public {
        require(msg.sender == owner);
        delete tokenizers[_name]; 
        for(uint i = 0; i<tokenizersList.length; i++){
            if(tokenizersList[i] == _name){
                tokenizersList[i] = tokenizersList[tokenizersList.length-1];
                tokenizersAddresses[i] = tokenizersAddresses[tokenizersAddresses.length-1];
            }
        }
        tokenizersList.length--;
        tokenizersAddresses.length--;
    } 
    // TESTING ONLY

}