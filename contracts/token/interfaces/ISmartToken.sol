pragma solidity ^0.4.24;
import './IERC20Token.sol';
import '../../utils/interfaces/IOwned.sol';

/*
    Smart Token interface
*/
contract ISmartToken is IOwned, IERC20Token {
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}
