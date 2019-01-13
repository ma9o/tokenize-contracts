pragma solidity ^0.4.24;

import "./interfaces/ITokenizer.sol";
import "../stores/interfaces/IStoreBase.sol";
import "../converter/interfaces/ITokenizeConverter.sol";
import "../utils/Owned.sol";
import "../utils/Utils.sol";

contract TokenizerBase is ITokenizer, Owned, Utils{

    mapping(bytes32 => address) public stores;
    bytes32[] public storesList; // useful for off-chain iteration
    
    event Purchase(bytes32 _store, bytes32 _appid, address indexed _buyer);

    constructor () public {}

    function addStore(address _storeContract) public ownerOnly {
        IStoreBase store = IStoreBase(_storeContract);
        bytes32 name = store.name();
        stores[name] = store;
        storesList.push(name);
    }

    function getStore(bytes32 _storeName) public view returns(address) {
        return address(stores[_storeName]);
    }

    function storesCount() public view returns(uint) {
        return storesList.length;
    }
}