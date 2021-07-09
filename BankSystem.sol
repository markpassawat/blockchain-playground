pragma solidity ^0.5.0;

contract Bank {
    //Dictionary that maps address to balances
    mapping(address => uint256) private balances;
    
    //User in the system
    address[] accounts;
    
    //Interest rate
    uint256 rate = 3;
    
    //system owner
    address public owner;
    
    //Events
    event DepositMade(address indexed account, uint amount);
    event WithdrawMade(address indexed account, uint amount);
    
    constructor() public {
        owner = msg.sender;
    }
    
    //User can deposit any amount to the system
    function deposit() public payable returns(uint256){
        // Record account into array
        if (0 == balances[msg.sender]){
            accounts.push(msg.sender);
        }
        
         balances[msg.sender] = balances[msg.sender] + msg.value;
    
         emit DepositMade(msg.sender, msg.value);
    
         return balances[msg.sender];

    }
    
    function withdraw(uint amount)public returns (uint256){
        require(balances[msg.sender] >= amount, "Balance is not enought");
        balances[msg.sender] -= amount;
        
        // Send monet back to user
        msg.sender.transfer(amount);
        
        // broadcast event
        emit WithdrawMade(msg.sender, amount);
        
        return balances[msg.sender];
    }
    
    function systemBalance() public view returns (uint256){
        return address(this).balance;
    }
    
    function userBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    
    event systemWithdrawMade(address indexed account, uint256 amount);
    event systemDepositMade(address indexed account, uint256 amount);
   
   function systemWithdraw(uint amount) public returns (uint256){
       require(owner == msg.sender, "Your are not authorized");
       require(systemBalance() >= amount, "System balance is not enought");
   
        msg.sender.transfer(amount);
        
        // broadcast event
        emit systemWithdrawMade(msg.sender, amount);
        
        return systemBalance();   
   }
   
   function systemDeposit() public payable returns (uint256){
       require(owner == msg.sender, "You are not authorized");
       
        // broadcast event
        emit systemDepositMade(msg.sender, msg.value);
        
        return systemBalance();
   }
    
    
    function calculateInterest(address user, uint256 _rate)private view returns (uint256){
        uint256 interest = balances[user] * _rate / 100;
        return interest;
    }
    
    function totalInterestPerYear() external view returns (uint256){
        uint256 total = 0;
        for(uint256 i = 0; i < accounts.length; i++){
            address account = accounts[i];
            uint256 interest = calculateInterest(account, rate);
            total += interest;
        }
        
        return total;
    }
    
    function payDividendsPerYear() payable public{
        require(owner == msg.sender, "You are not authorized");
        
        uint256 totalInterest = 0;
        for(uint256 i=0; i < accounts.length ; i++){
            address account = accounts[i];
            uint256 interest = calculateInterest(account, rate);
            balances[account] += interest;
            totalInterest += interest;
        }
        require(msg.value == totalInterest, "Not enought interest to pay!!");
    }
}