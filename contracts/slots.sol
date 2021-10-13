// References:
// https://docs.chain.link/docs/get-a-random-number/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract slots is VRFConsumerBase {
    
    bytes32 private keyHash;
    //Link Token Fee to get random number
    uint256 public fee;
    //Number Result from ChainLink
    uint256 public randomResult;
    //String Result
    string public result;
    //Address of user who called contract
    address payable userAddress;
    //Users bet 
    uint256 userBet;
    //Multiplier of Winner
    uint256 multiplier;
    //gameNumber
    uint256 gameNumber;
    //Owner of contract
    address public owner;
    
    //Struct to store information of each game
    struct gameInfo{
        uint256 gameNumber;
        address payable  gameUserAddress;
        uint256 gameUserBet;
        string gameStringResult;
        uint gameResult; 
    }
  
    //VRF Coordinator token address and LINK token address
    constructor() VRFConsumerBase(0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, 0x01BE23585060835E02B77ef475b0Cc51aA1e0709) public{
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        
        // 10**18 = 10^18
        fee = 0.1 * 10 ** 18; //0.1 Link 
        gameNumber = 0;
        multiplier = 2;
        
        owner = msg.sender;
        
        
    }
    mapping(uint256 => gameInfo) public gameInfoMapping;
    
    mapping(address => uint256) public addressToAmountSpentMapping;
    
    
    function playSlot(uint256 amount ) public payable{
        //Make sure the amount called by this function is the same as value of message
        require(msg.value == amount);
        gameNumber ++ ;
        //Amount stored in contract
        uint256 etherInContract = address(this).balance;
        
        userAddress = msg.sender;
        userBet = msg.value;
        
        //gameInfo.gameUserAddress = msg.sender;
        //gameInfo.gameUserBet = msg.value;
        
        //Not enough ether to payout. 
        if(etherInContract < multiplier * userBet){
            revert("Not enough Ether to pay out. Reverting transcation");
        }
    
        
        randomResult = 0;
        result = "Waiting for ChainLink...";
        
        
        getRandomNumber();
        
    }
    
    
    function getRandomNumber() internal returns (bytes32 requestID){
        return requestRandomness(keyHash, fee);
    }
    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness.mod(4).add(1);
        verdict(randomResult);
    }
    
    
    
    function verdict(uint256 finalResult) internal{
        
        //Increment Amount sent from user addresss
        addressToAmountSpentMapping[userAddress] += userBet;
        
        
        if(finalResult == 1){
            userAddress.transfer(multiplier * userBet);
            result = "Winner!";
            
        }
        else{
            result = "Loser!";
        }
        
        //Store info of this game into our gameInfo struct
        gameInfo memory info;
        info = gameInfo(gameNumber, userAddress, userBet, result, finalResult );
        gameInfoMapping[gameNumber] = info;
    }


    
    function displayWeiInContract() public view returns(uint256) {
        uint256 amount = address(this).balance;
        amount = amount;
        return amount;
    }
    
    
    //Only allow owner of contract to fund contract with ether and link
    function fund()public payable{
        if(owner != msg.sender){
            revert("Only owner of contract can fund it");
        }
        
        //addressToAmountSpent[msg.sender] += msg.value;
    }

    function getGameInfo(uint256 gameNum) public view returns (uint256, address , uint256, string memory, uint ){
        gameInfo memory info;
        info = gameInfoMapping[gameNum];
        return (info.gameNumber, info.gameUserAddress, info.gameUserBet, info.gameStringResult, info.gameResult );
    }
    
    fallback()external payable{ 
        if(owner != msg.sender){
            revert("Only owner of contract can fund it");
        }
        //addressToAmountSpent[msg.sender] += msg.value;
    }
    
    receive() external payable {
        if(owner != msg.sender){
            revert("Only owner of contract can fund it");
        }
        //addressToAmountSpent[msg.sender] += msg.value;
    }
}
