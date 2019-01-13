pragma solidity ^ 0.4 .24;

import './interfaces/IBancorFormula.sol';
import '../utils/Utils.sol';
import '../utils/Owned.sol';
import '../token/interfaces/ISmartToken.sol';
import './interfaces/ITokenizeConverter.sol';
import "../utils/interfaces/IRegistry.sol";

contract TokenizeConverter is ITokenizeConverter, Owned, Utils {

  uint32 private constant MAX_WEIGHT = 1000000;
  uint64 private constant MAX_CONVERSION_FEE = 1000000;

  mapping(address => Allowance) private allowances;
  uint32 private tx_counter = 0;
  bool private hasToken = false;

  ISmartToken public token;
  ITokenizeConverter public tkzconverter;
  IBancorFormula public formula;
  IRegistry public registry;
  
  uint32 public conversionFee; 
  uint32 public weight;


  struct Allowance {
    uint limit;
    uint current;
  }

  event Conversion(string _fromToken, string _toToken, address indexed _trader, uint256 _amount, uint256 _return, uint256 _conversionFee);
  event PriceDataUpdate(uint256 _tokenSupply, uint256 _connectorBalance, uint32 _connectorWeight);

  constructor(address _registry, uint32 _weight, uint32 _tkzFee) public {
    require(_weight < MAX_WEIGHT, "Weight must be between 0-1000000");
    registry = IRegistry(_registry);
    conversionFee = _tkzFee;
    weight = _weight;
    formula = IBancorFormula(registry.formula());
    tkzconverter = ITokenizeConverter(registry.TKZETH());
  }

  modifier noToken {
    assert(!hasToken);
    _;
  }

  function assignToken(ISmartToken _token) public ownerOnly noToken {
    token = _token;
    hasToken = true;
  }

  function getPrice() public view returns(uint,uint,uint){
    return (token.totalSupply(), address(this).balance ,weight);
  }

  function getFinalAmount(uint256 _amount) public view returns(uint256) {
    return safeMul(_amount, MAX_CONVERSION_FEE - conversionFee) / MAX_CONVERSION_FEE;
  }

  function getReturn(uint256 _amount, bool _buying) public view returns(uint256) {
    uint256 tokenSupply = token.totalSupply();
    uint256 connectorBalance = address(this).balance;
    uint256 amount;

    if (_buying) {
      amount = formula.calculatePurchaseReturn(tokenSupply, connectorBalance, weight, _amount);
    } else {
      amount = formula.calculateSaleReturn(tokenSupply, connectorBalance, weight, _amount);
    }
    // return the amount minus the conversion fee
    return getFinalAmount(amount);
  }

    // increase connector supply, thus token price
  function pay() public payable {
    emit PriceDataUpdate(token.totalSupply(), address(this).balance, weight);
    emit Conversion("ETH", token.symbol(), tx.origin, msg.value, token.totalSupply(), 0);
  }

  function buy(address _trader) public payable returns(uint256) {
    require(hasToken);

    // validate input
    bool tokenized = false;
    for (uint i = 0; i < registry.tokenizersCount(); i++) {
      if (msg.sender == registry.tokenizersAddresses(i)) {
        tokenized = true;
      }
    }
    require(tokenized, "Tokenize converters allow purchases only from tokenizer contracts");
    
    uint256 amount = getReturn(msg.value, true);
    require(amount != 0, "Amount must be non-zero");

    // the sent Ether is stored in the contract and new appreciated SmartTokens are issued to the caller
    token.issue(_trader, amount);

    // random allowance mechanism to avoid dumping tokens to just buy tokenized products cheaper
    if(allowances[_trader].limit == 0){
        allowances[_trader].current = tx_counter;
        allowances[_trader].limit = tx_counter + 3 + (block.number % 7);
        tx_counter++;
    }

    emit Conversion("ETH", token.symbol(), _trader, msg.value, amount, conversionFee);
    emit PriceDataUpdate(token.totalSupply(), address(this).balance, weight);
    return amount;
  }

  function sell(uint256 _sellAmount) public returns(uint256) {
    address trader = msg.sender;
    require(allowances[trader].current > allowances[trader].limit, "Not enough previous transactions");
    require(_sellAmount < token.balanceOf(trader)); // validate input
    uint256 amount = getReturn(_sellAmount, false);
    require(amount != 0, "Amount must be non-zero");

    // ensure that the trade will only deplete the connector balance if the total supply is depleted as well
    uint256 tokenSupply = token.totalSupply();
    uint256 connectorBalance = address(this).balance;
    assert(amount < connectorBalance || (amount == connectorBalance && _sellAmount == tokenSupply));

    // destroy the given SmartToken amount
    token.destroy(trader, _sellAmount);

    // transfer ETH to the caller
    assert(trader.send(amount));

    // pay TKZ some ETH as fee
    uint256 feeAmount = safeSub(amount, getFinalAmount(amount));
    if (feeAmount > 0 && feeAmount < address(this).balance) {
      tkzconverter.pay.value(feeAmount)();
    }

    emit Conversion(token.symbol(), "ETH", trader, _sellAmount, amount, feeAmount);
    emit PriceDataUpdate(token.totalSupply(), address(this).balance, weight);
    return amount;
  }
}
