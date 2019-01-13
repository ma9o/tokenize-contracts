pragma solidity ^ 0.4.24;

import "../converter/TokenizeConverter.sol";
import "../converter/interfaces/ITokenizeConverter.sol";
import "../token/SmartToken.sol";
import "../token/interfaces/ISmartToken.sol";
import "../utils/Utils.sol";
import "../utils/Owned.sol";
import "../utils/interfaces/IRegistry.sol";

contract StoreBase is Owned, Utils {

    uint private constant DEF_DISCOUNT = 300000; 
    uint private constant INIT_PRICE = 1;
    
    // SET TO CONSTANT IN PRODUCTION
    uint32 private DEF_WEIGHT = 100; 
    uint private MIN_STAKE = 10000000000000000; 
    uint private MAX_STAKE = 1000000000000000000; 
    uint32 private FEE = 10000;
    // SET TO CONSTANT IN PRODUCTION

    mapping(bytes32 => Product) public products; // appid -> relative token address
    bytes32[] public productsList;  // useful for off-chain iteration

    IRegistry public registry;
    bytes32 public name;

    struct Product{
        address publisher;
        ITokenizeConverter converter;
        uint256 price;
        uint256 creationBlock;
        uint256 discountFactor;
        bool exists;
        mapping(address => uint) stakes;
        address[] stakers;
        uint totalStake;
    }

    event NewConverter(address _converterAddress, address indexed _creator);

    constructor(address _registry, string _storeName) public{
        registry = IRegistry(_registry);
        name = strToBytes32(_storeName);
    }

    function getProduct(bytes32 _appId) public view returns (address, address, uint256, uint256, bytes32, uint256) {
        return (products[_appId].publisher,products[_appId].converter,products[_appId].price,products[_appId].creationBlock,name, products[_appId].discountFactor);
    }

    function productsCount() public view returns (uint) {
        return productsList.length;
    }

    function updateDiscountFactor(uint _percentage, bytes32 _appId) public {
        require(msg.sender == owner);
        products[_appId].discountFactor = _percentage;
    }

    function addStake(bytes32 _appId) public payable {
        Product storage p = products[_appId];
        require(!p.exists,"Product already exists");
        require(p.totalStake + msg.value <= MAX_STAKE, "Total stake exceeds max stake");

        p.totalStake += msg.value;
        p.stakes[msg.sender] += msg.value;
        p.stakers.push(msg.sender);
        
        if (p.totalStake >= MIN_STAKE && msg.sender == owner) {
            
            // generate a name for the new token ie. TKZ493570steam
            string memory t = strConcat("T", bytes32ToString(_appId), bytes32ToString(name));

            ISmartToken token = new SmartToken(t, t, 18);

            // add some tokens to compute the initial price and send them to the creator
            for(uint i = 0; i < p.stakers.length; i++){
                address a = p.stakers[i];
                token.issue(a, p.stakes[a] * INIT_PRICE * 1000000 / DEF_WEIGHT);
            }

            ITokenizeConverter converter = new TokenizeConverter(registry, DEF_WEIGHT, FEE);

            // NB: the converter becomes the only owner of the token!
            token.transferOwnership(address(converter));
            converter.assignToken(token);

            // store product data
            productsList.push(_appId);
            p.creationBlock = block.number;
            p.converter = converter;
            p.publisher = msg.sender;
            p.discountFactor = DEF_DISCOUNT;
            p.exists = true;

            // send the inital balance to the connector
            converter.pay.value(p.totalStake)();
            emit NewConverter(address(converter), msg.sender);
        }
    }

    // TESTING ONLY
    function changeWeight(uint32 _percentage) public {
        require(msg.sender == owner);
        DEF_WEIGHT = _percentage;
    }
    
    function changeMaxStake(uint _val) public {
        require(msg.sender == owner);
        MAX_STAKE = _val;
    }
    
    function changeMinStake(uint _val) public {
        require(msg.sender == owner);
        MIN_STAKE = _val;
    }

    function removeProduct(bytes32 _appId) public {
        require(msg.sender == owner);
        delete products[_appId];
        for(uint i = 0; i<productsList.length; i++){
            if(productsList[i] == _appId){
                productsList[i] = productsList[productsList.length-1];
            }
        }
        productsList.length--;
    }
    // TESTING ONLY


}
