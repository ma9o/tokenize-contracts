pragma solidity ^0.4.24;

import "../../token/interfaces/ISmartToken.sol";

contract ITokenizeConverter{

  event Conversion(string _fromToken, string _toToken, address indexed _trader, uint256 _amount, uint256 _return, uint256 _conversionFee);
  event PriceDataUpdate(uint256 _tokenSupply, uint256 _connectorBalance, uint32 _connectorWeight);

  function token() public view returns(address){}
  function formula() public view returns(address){}
  function tkzconverter() public view returns(address){}
  function conversionFee() public view returns(uint32){}
  function weight() public view returns (uint32) {}

  function getPrice() public view returns(uint,uint,uint);
  function buy(address _trader) public payable returns (uint256);
  function sell(uint256 _sellAmount) public returns (uint256);
  function getReturn(uint256 _amount, bool _buying) public view returns (uint256);
  function getFinalAmount(uint256 _amount) public view returns (uint256);
  function assignToken(ISmartToken _token) public;
  function pay() public payable;

}
