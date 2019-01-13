pragma solidity ^ 0.4 .24;

import "../TokenizerBase.sol";
import "../../stores/interfaces/IOffchainStore.sol";

contract OffchainTokenizer is TokenizerBase {

  uint256 public ethPrice;
  mapping(bytes32 => Query) internal queries; // used by oracles
  uint public discountFactor = 300000;

  constructor() public TokenizerBase() {}

  struct Query {
    uint32 queryType;
    bytes32 appId;
    bytes32 store;
    address buyer;
    uint256 amount;
  }

  function finalizePurchase(Query memory q, string _price) internal {

      IOffchainStore s = IOffchainStore(stores[q.store]);

      (,address converter,,,,uint discountFactor) = s.getProduct(q.appId);

      // item price in wei = (ether_in_wei * itemprice) / ethprice 
      uint256 itemPrice = (s.parsePrice(_price) / ethPrice);

      // ensure there's enough ether to buy the product
      if(q.amount < itemPrice || q.amount > itemPrice + 100){
        address(q.buyer).transfer(q.amount);
        require(q.amount > itemPrice || q.amount < itemPrice + 100, "Wrong payed amount");
      }

      //send ether to tokenize for the purchase
      itemPrice = (itemPrice * (1000000 - discountFactor))/1000000;
      owner.transfer(itemPrice);

      // buy the token with the ether left
      q.amount = q.amount - itemPrice;
      require(address(this).balance >= q.amount, "Tokenizer out of funds!");
      ITokenizeConverter(converter).buy.value(q.amount)(q.buyer);

      emit Purchase(q.store,q.appId,q.buyer);
  }

  function () payable {}

}