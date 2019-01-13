pragma solidity ^ 0.4 .24;

import '../token/interfaces/ISmartToken.sol';
import './interfaces/IBancorFormula.sol';
import '../utils/Utils.sol';
import '../utils/Owned.sol';

contract TKZETH is Owned, Utils {

  uint32 private constant WEIGHT = 500000;

  ISmartToken public token;
  IBancorFormula public formula;

  event PriceDataUpdate(uint256 _tokenSupply, uint256 _connectorBalance, uint32 _connectorWeight);

  constructor(address _token, address _formula) public {
    formula = IBancorFormula(_formula);
    token = ISmartToken(_token);
  }

  function getPrice() public view returns(uint,uint,uint){
    return (token.totalSupply(), address(this).balance ,WEIGHT);
  }

  function getReturn(uint256 _amount, bool _buying) public view returns(uint256) {
    uint256 tokenSupply = token.totalSupply();
    uint256 connectorBalance = address(this).balance;
    uint256 amount;

    if (_buying) {
      amount = formula.calculatePurchaseReturn(tokenSupply, connectorBalance, WEIGHT, _amount);
    } else {
      amount = formula.calculateSaleReturn(tokenSupply, connectorBalance, WEIGHT, _amount);
    }
    return amount;
  }

  // increase connector supply, thus token price
  function pay() public payable {}

  function buy(address _trader) public payable returns(uint256) {
    require(_trader == msg.sender, "Must buy tokens on own behalf");
    uint256 amount = getReturn(msg.value, true);
    require(amount != 0, "Amount must be non-zero");

    // the sent Ether is stored in the contract and new appreciated SmartTokens are issued to the caller
    token.issue(_trader, amount);

    emit PriceDataUpdate(token.totalSupply(), address(this).balance, WEIGHT);
    return amount;
  }

  function sell(uint256 _sellAmount) public returns(uint256) {
    require(_sellAmount <= token.balanceOf(msg.sender), "Noth enough TKZ"); // validate input
    uint256 amount = getReturn(_sellAmount, false);
    require(amount != 0, "Amount must be non-zero");

    // ensure that the trade will only deplete the connector balance if the total supply is depleted as well
    assert(amount < address(this).balance || (amount == address(this).balance && _sellAmount == token.totalSupply()));

    // destroy the given SmartToken amount
    token.destroy(msg.sender, _sellAmount);

    // transfer ETH to the caller
    assert(msg.sender.send(amount));

    emit PriceDataUpdate(token.totalSupply(), address(this).balance, WEIGHT);
    return amount;
  }
}
