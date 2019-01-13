pragma solidity ^ 0.4 .24;

import "../OffchainTokenizer.sol";
import "./oraclize/oraclizeAPI_0.5.sol";

// ready for production

contract OraclizedTokenizer is OffchainTokenizer, usingOraclize {
    
  constructor(address _oracle) public OffchainTokenizer() {
    OAR = OraclizeAddrResolverI(_oracle);
  }

  function buildQuery(Query memory q) internal returns(string) {
    IOffchainStore s = IOffchainStore(stores[q.store]);
    string memory url = strConcat("json(",s.getPriceURL(q.appId),")");

    for(uint i=0;i<s.pricePathLength();i++){
      url = strConcat(url, ".", s.getPricePathAt(i,q.appId));
    }
    return url;

  }

  function __callback(bytes32 _queryId, string _result) public {
    require(msg.sender == oraclize_cbAddress(), 'Not called by oracle');
    // retrieve and store query object for convenience
    Query memory q = queries[_queryId]; 

    if (q.queryType == 1) {
        
      finalizePurchase(q, _result);

    } else if (q.queryType == 2) {

      //store ether price as global variable
      ethPrice = parseInt(_result);

      //prepare next query for the product price
      string memory queryString = buildQuery(q);

      // run the query and save for later referencing
      bytes32 queryId = oraclize_query("URL", queryString);
 
      queries[queryId] = Query(1, q.appId, q.store, q.buyer, q.amount);
  
    }
    
  }

  function buy(bytes32 _appId, bytes32 _storeName) public payable {

    require(msg.value > 0, "Send some ETH");

    // prepare query for ether price
    string memory url = strConcat("json(https://min-api.cryptocompare.com/data/dayAvg?fsym=ETH&tsym=USD&toTs=",uint2str(block.timestamp-86400),").USD");
    bytes32 queryId = oraclize_query("URL", url, "", 600000); // add GASLIMIT e PRICE

    // run the query and save for later referencing
    queries[queryId] = Query(2, _appId, _storeName, msg.sender, msg.value);
  }

}
