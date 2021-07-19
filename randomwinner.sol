pragma solidity ^0.4.17;

contract RandomWinner {
  bytes32 private sealedSeed;
  uint64 public ticketMax = 1000;
  
function ticketMax (uint64 _ticketMax) public payable {
	ticketMax = _ticketMax;
    } 
function Start (bytes32 _seed) public payable {
	sealedSeed = _seed;
    }

    function() payable public {
      revert();
    }
	
    /* @return a random number based off of current block information */
    function lotteryPicker() public view returns (uint64) {
      bytes memory entropy = abi.encodePacked(block.timestamp, sealedSeed, block.number);
      bytes32 hash = sha256(entropy);
      return uint64(hash) % ticketMax;
    }
}
