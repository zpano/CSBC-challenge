pragma solidity >=0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLoanTokenReceiver {
    function execute() external;
}

contract DaoPool {

    mapping (address => uint256) private balances;
    IERC20 public token;
    
    constructor(address _token) public {
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        token.transfer(msg.sender, amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= amount, "Not enough ETH in balance");
        token.transfer(msg.sender, amount);
        IFlashLoanTokenReceiver(msg.sender).execute();

        require(token.balanceOf(address(this)) >= balanceBefore, "Flash loan hasn't been paid back");        
    }
}
