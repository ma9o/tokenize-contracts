pragma solidity ^ 0.4.24;

import "../TokenizerBase.sol";
import "../../stores/interfaces/IOnchainStore.sol";

contract OnchainTokenizer is TokenizerBase {

    constructor() public TokenizerBase() {}

    function buy(bytes32 _appId, bytes32 _store) public payable {
        
        IOnchainStore s = IOnchainStore(stores[_store]);

        (,address converter,uint itemPrice,,,) = s.getProduct(_appId);

        // ensure there's enough ether to buy the product
        require(msg.value >= itemPrice, "Not enough funds provided");
        require(itemPrice > 0, "Wait for the owner to set the product's price");

        //send ether to tokenize for the purchase
        owner.transfer(itemPrice);

        // buy the token with the ether left
        ITokenizeConverter(converter).buy.value(msg.value - itemPrice)(msg.sender);

        emit Purchase(_store,_appId,msg.sender);
    }

}
