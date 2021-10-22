// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

contract DVT8 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    uint public maxSupply;
    address public owner;
    uint private lastAirdropBlock;
    mapping (address => uint256) public balances;
    mapping (address => bool) public minters;
    mapping (address => bool) public isGetAirDrop;
    mapping (address => bool) public isComplete;
 
    modifier onlyMinter {
        require(minters[msg.sender]);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint senderValue = balances[sender];
        uint recipientValue = balances[recipient];
        require(senderValue >= amount,"ERC20: exceeded balance");
        balances[sender] = senderValue - amount;
        balances[recipient] = recipientValue + amount;
    }
    function _mint(address account, uint256 amount) internal {
        if(amount + totalSupply >= maxSupply){
            amount = maxSupply - totalSupply;
        }
        if(amount == 0){
            return;
        }
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply = totalSupply + amount;
        balances[account] = balances[account] + amount;
    }

    function mint(address account, uint256 amount) external onlyMinter {
        _mint(account, amount);
    }

    function addMinter(address newMinter) public onlyOwner {
        require(!minters[newMinter],"ERC20: minter already exist");
        require(newMinter!=address(0));
        minters[newMinter] = true;
    }

    function removeMinter(address Minter) public onlyOwner {
        require(minters[Minter],"ERC20: minter not exist");
        minters[Minter] = false;
    }
    constructor() public {
      name = 'DVT8';
      symbol = 'DVT8';
      decimals = 18;
      maxSupply = 10000*10**18;
      owner = msg.sender;
    }

    function getAirdrop() public {
        require(lastAirdropBlock<block.number);
        require(!isGetAirDrop[msg.sender]);
        _mint(msg.sender, 1*10**18);
        isGetAirDrop[msg.sender] = true;
        lastAirdropBlock = block.number;
    }

    function complete() public {
        require(balances[msg.sender]>5000*10**18);
        isComplete[msg.sender] = true;
        balances[msg.sender] = 0;
    }
}