pragma solidity ^0.4.24;

/*
    Utilities & Common Modifiers
*/
contract Utils {

  // verifies that an amount is greater than zero
  modifier greaterThanZero(uint256 _amount) {
    require(_amount > 0);
    _;
  }

  // validates an address - currently only checks that it isn't null
  modifier validAddress(address _address) {
    require(_address != address(0));
    _;
  }

  // verifies that the address is different than this contract address
  modifier notThis(address _address) {
    require(_address != address(this));
    _;
  }

  function strToBytes32(string memory _source) internal pure returns (bytes32) {
    bytes32 result;
    assembly {
        result := mload(add(_source, 32))
    }
    return result;
}

  function uint2str(uint i) internal pure returns (string){
    if (i == 0) return "0";
    uint j = i;
    uint length;
    while (j != 0){
        length++;
        j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint k = length - 1;
    while (i != 0){
        bstr[k--] = byte(48 + i % 10);
        i /= 10;
    }
    return string(bstr);
}

  // concatenate two bytes32 trimming the second one if necessary
  function bytes32Concat(bytes32 _a, bytes32 _b) internal pure returns(bytes32) {
    bytes32 out;
    uint k = 0;
    while (_a[k] != 0x00 && k < 32) {
      out |= bytes32(_a[k] & 0xFF) >> (k * 8);
      k++;
    }
    uint i = 0;
    while (k < 32) {
      out |= bytes32(_b[i] & 0xFF) >> (k * 8);
      k++;
      i++;
    }
    return out;
  }

  function bytes32ToString(bytes32 _bytes) internal pure returns(string) {
    uint i=0;
    while(_bytes[i] != 0x00 && i<32){
        i++;
    }
    bytes memory byteArray = new bytes(i);
    uint j=0;
    while(j<i){
        byteArray[j] = _bytes[j];
        j++;
    }

    return string(byteArray);
  }

  function address2Ascii(address x) internal pure returns(string) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
      byte b = byte(uint8(uint(x) / (2 ** (8 * (19 - i)))));
      byte hi = byte(uint8(b) / 16);
      byte lo = byte(uint8(b) - 16 * uint8(hi));
      s[2 * i] = char(hi);
      s[2 * i + 1] = char(lo);
    }
    return string(s);
  }

  function char(byte b) internal pure returns(byte c) {
    if (b < 10) return byte(uint8(b) + 0x30);
    else return byte(uint8(b) + 0x57);
  }

  // Overflow protected math functions

  /**
      @dev returns the sum of _x and _y, asserts if the calculation overflows

      @param _x   value 1
      @param _y   value 2

      @return sum
  */
  function safeAdd(uint256 _x, uint256 _y) internal pure returns(uint256) {
    uint256 z = _x + _y;
    assert(z >= _x);
    return z;
  }

  /**
      @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number

      @param _x   minuend
      @param _y   subtrahend

      @return difference
  */
  function safeSub(uint256 _x, uint256 _y) internal pure returns(uint256) {
    assert(_x >= _y);
    return _x - _y;
  }

  /**
      @dev returns the product of multiplying _x by _y, asserts if the calculation overflows

      @param _x   factor 1
      @param _y   factor 2

      @return product
  */
  function safeMul(uint256 _x, uint256 _y) internal pure returns(uint256) {
    uint256 z = _x * _y;
    assert(_x == 0 || z / _x == _y);
    return z;
  }

  // parseInt
  function parseInt(string _a) internal pure returns (uint) {
      return parseInt(_a, 0);
  }

  // parseInt(parseFloat*10^_b)
  function parseInt(string _a, uint _b) internal pure returns (uint) {
      bytes memory bresult = bytes(_a);
      uint mint = 0;
      bool decimals = false;
      for (uint i=0; i<bresult.length; i++){
          if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
              if (decimals){
                 if (_b == 0) break;
                  else _b--;
              }
              mint *= 10;
              mint += uint(bresult[i]) - 48;
          } else if (bresult[i] == 46) decimals = true;
      }
      if (_b > 0) mint *= 10**_b;
      return mint;
  }


    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

      function strConcat(string _a, string _b, string _c, string _d, string _e, string _f) internal pure returns(string) {
    return strConcat(strConcat(_a, _b, _c, _d, _e), _f);
  }

}
