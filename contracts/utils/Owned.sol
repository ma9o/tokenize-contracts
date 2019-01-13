pragma solidity ^0.4.24;
import "./interfaces/IOwned.sol";

/*
    Provides support and utilities for contract ownership
*/
contract Owned is IOwned {
    address public owner;

    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    /**
        @dev constructor
    */
    constructor() public {
        owner = msg.sender;
    }

    // allows execution by the owner only
    modifier ownerOnly {
        assert(msg.sender == owner);
        _;
    }

    /**
        @dev allows transferring the contract ownership
        the new owner still needs to accept the transfer
        can only be called by the contract owner

        @param _newOwner    new contract owner
    */
    function transferOwnership(address _newOwner) public ownerOnly {
        emit OwnerUpdate(owner,_newOwner);
        owner = _newOwner;

    }


}
