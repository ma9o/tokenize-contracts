pragma solidity ^ 0.4.24;

import "../OffchainTokenizer.sol";
import "./chainlink/Chainlinked.sol";

contract ChainlinkedTokenizer is OffchainTokenizer, Chainlinked {

    bytes32 constant BYTES32 = bytes32("ae18a03a2f5746ca967c403cf53e1318");

    constructor(address _LINK, address _LINK_ORACLE) public OffchainTokenizer(){
        setLinkToken(_LINK);
        setOracle(_LINK_ORACLE);
    }

    function buildQuery(Query memory q) internal view returns(string[]) {

        IOffchainStore s = IOffchainStore(stores[q.store]);
        uint size = s.pricePathLength();

        string[] memory path = new string[](size);

        for(uint i = 0; i < size; i++){
            path[i] = s.getPricePathAt(i,q.appId);
        }

        return path;

    }

    function queryCallback(bytes32 _queryId, bytes32 _result) public checkChainlinkFulfillment(_queryId) {

        // retrieve and store query object for convenience
        Query memory q = queries[_queryId];

        if (q.queryType == 1) {

            finalizePurchase(q,bytes32ToString(_result));

        } else if (q.queryType == 2) {

            //store ether price as global variable
            ethPrice = parseInt(bytes32ToString(_result));

            //prepare next query for the product price
            ChainlinkLib.Run memory run = newRun(BYTES32, this, "queryCallback(bytes32,bytes32)");
            run.add("url", IOffchainStore(stores[q.store]).getPriceURL(q.appId));
            run.addStringArray("path", buildQuery(q));

            // run the query and save for later referencing
            bytes32 queryId = chainlinkRequest(run, LINK(1));
            queries[queryId] = Query(1, q.appId, q.store, q.buyer, q.amount);
        }
    }

    function buy(bytes32 _appId, bytes32 _storeName) public payable {
        require(msg.value > 0, "Send some ETH");

        // prepare the query to check ether price
        ChainlinkLib.Run memory run = newRun(BYTES32, this, "queryCallback(bytes32,bytes32)");
        string memory url = strConcat("https://min-api.cryptocompare.com/data/dayAvg?fsym=ETH&tsym=USD&toTs=", uint2str(block.timestamp-86400));
        run.add("url", url);
        string[] memory path = new string[](1);
        path[0] = "USD";
        run.addStringArray("path", path);

        // run the query and save for later referencing
        bytes32 id = chainlinkRequest(run, LINK(1));
        queries[id] = Query(2,_appId,_storeName,msg.sender,msg.value);
    }

}
