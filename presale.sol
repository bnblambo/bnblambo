/**                                      
//              BNB Lambo Token 
//  Drive Lambo by participating the BNBLambo Lottery 
//  $BNBLAMBO is used to Participate Decentralized Lotteries 
//  on the Binance Smart Chain using cutting edge Smart Contract feature.                            
//   
//  https://bnblambo.com      
//                                                                                                                                                                                                                     
//  BNBLambo automatically burns 4% of the total supply and
//  applies a 4% tax upon each transaction. This tax is
//  immediately distributed between holders of the token.
//                                                                        
*/

pragma solidity ^0.4.17;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

interface Token {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external returns (uint256 balance);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract BNBLAMBOPRESALE {
  using SafeMath for uint256;
  Token token;
  event BoughtTokens(address indexed _to, uint256 _value, uint16 _ticketID);
  event LotteryRewardPaid(address indexed _winner, uint64 _ticketID, uint256 _amount);
  bytes32 private sealedSeed;
  uint256 public rate = 1000000000000000000; 
  uint256 public refrate = 200000000000000000; 
  uint256 public raisedAmount = 0;
  uint256 public price = 100000000000000000;
  uint256 public reward = 50000000000000000;
  uint64 public ticketMax = 20000;
  uint256 public rewardpool = 0;
  uint256 public ticketsBought = 0;
  address public LamboWinner;
  bool public isStarted = false;
  address fund = 0x953eA15800772E49D1372F1dbE411F9C02d22C4f;
  address[20001] public ticketMapping;
  mapping (address => uint256) public bought;    
  mapping (address => address) public referrer; 
    // Prevent potential locked funds by checking greater than
    modifier allTicketsSold() {
      require(ticketsBought >= ticketMax);
      _;
}
  
function Start (Token _token,bytes32 _seed) public payable {
	require(isStarted == false, "Started already.");
    token = _token;
	sealedSeed = _seed;
	isStarted = true;
    }

    function() payable public {
      revert();
    }
	
  /**
   * buyTokens
   * @dev function that sells available tokens
   **/
  function buyTokens(uint16 _ticket,address upline) payable public {
    require(msg.value == price, "Please send 0.1 BNB in each transaction");
    require(_ticket > 0 && _ticket < 20001, "Please type a ticket number between 1 and 20000");
    require(ticketMapping[_ticket] == address(0), "The ticket is sold already.");
    require(ticketsBought < ticketMax);
    emit BoughtTokens(msg.sender, rate, _ticket);
    address purchaser = msg.sender;
    ticketsBought += 1;
    ticketMapping[_ticket] = purchaser;
	bought[msg.sender] += 1;
    raisedAmount = raisedAmount.add(msg.value); 
	rewardpool = rewardpool.add(reward);
    token.transfer(msg.sender, rate);
	fund.transfer(reward);
	if (referrer[purchaser] != address(0)) {
      token.transfer(referrer[purchaser], refrate);
    } else if (upline != address(0)) {
      token.transfer(upline, refrate);
	  referrer[purchaser] = upline;
    }
	
  /** Placing the "burden" of sendReward() on the last ticket
   * buyer is okay, because the refund from destroying the
   * arrays decreases net gas cost
   **/
      if (ticketsBought>=ticketMax) {
        sendReward();
      }     
  }
      /**
      * @dev Send lottery winner their reward
      * @return address of winner
      */
    function sendReward() private allTicketsSold returns (address) {
      uint64 winningNumber = lotteryPicker();
      address winner = ticketMapping[winningNumber];

      // Prevent locked funds by sending to bad address
      require(winner != address(0), "Please try again.");
      LamboWinner = winner;
      // Prevent reentrancy
	  winner.transfer(rewardpool);
	  emit LotteryRewardPaid(winner, winningNumber, rewardpool);
      return winner;
    }

    /* @return a random number based off of current block information */
    function lotteryPicker() private view allTicketsSold returns (uint64) {
      bytes memory entropy = abi.encodePacked(block.timestamp, sealedSeed, block.number);
      bytes32 hash = sha256(entropy);
      return uint64(hash) % ticketMax;
    }

    /** @dev Returns ticket map array for front-end access.
      * Using a getter method is ineffective since it allows
      * only element-level access
      */
    function getTicketsPurchased() public view returns(address[20001]) {
      return ticketMapping;
    }  
}
