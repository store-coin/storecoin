pragma solidity 0.8.9;

// ----------------------------------------------------------------------------
// 'STORE COIN' Token Contract
//
// Name        : STORE COIN
// Symbol      : SCOIN
// Total supply: 31557600
// Decimals    : 18
//
//
// (c) STORE SCOIN.
// SPDX-License-Identifier: MIT
// https://github.com/store-coin/storecoin
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Safe maths
// Math operations with safety checks that throw on error
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require (b > 0);
        uint256 c = a / b;
        return c;
    }
    
    function safeMod(uint256 a, uint256 b) internal pure returns (uint256){
        require(b != 0);
        return a % b;
    }
}

// ---------------------------------------------------------------------------------------
// ERC Token Standard #EIP-20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ---------------------------------------------------------------------------------------
abstract contract BEP20Interface {
    function approve(address spender, uint256 tokens) virtual public returns (bool success);
    function transfer(address to, uint256 tokens) virtual public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) virtual public returns (bool success);
    function balanceOf(address tokenOwner) virtual public view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) virtual public view returns (uint256 remaining);
    function totalSupply() virtual public view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// ----------------------------------------------------------------------------
abstract contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes calldata data) virtual public;
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        if(newOwner != address(0)) {
        newOwner = _newOwner;
        }
    }
    
    function acceptOwnership() public {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// ---------------------------------------------------------------------------------------
// STORE COIN Token Details: Symbol, Name, Decimals, Supply, Website, Whitepaper, Message
// ---------------------------------------------------------------------------------------
contract STORECOIN is BEP20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint256 public decimals;
    uint256 private _totalSupply;
    string private website;
    string private whitepaper;
    string private message;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
// ------------------------------------------------------------------------
// Constructor
// ------------------------------------------------------------------------
constructor () {
        symbol = "SCOIN";
        name = "STORE COIN";
        decimals = 18;
        website = "website";
        whitepaper = "whitepaper";
        message = "message";
        _totalSupply = 31557600 * 10 ** 18;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
// ------------------------------------------------------------------------
// Message: Information about project
// ------------------------------------------------------------------------
    function changeMessage(string memory newMessage) public onlyOwner {
        message = newMessage;
    }
    
    function Message() public view returns (string memory) {
        return message;
    }
     
    event NewMessage(string indexed message, string indexed newMessage);
    
// ------------------------------------------------------------------------
// Official Site
// ------------------------------------------------------------------------
    function changeWebsite(string memory newWebsite) public onlyOwner {
        website = newWebsite;
    }
    
    function Website() public view returns (string memory) {
        return website;
    }
    
    event WebsiteChanged(string indexed website, string indexed newWebsite);
    
// ------------------------------------------------------------------------
// Whitepaper
// ------------------------------------------------------------------------
    function changeWhitepaper(string memory newWhitepaper) public onlyOwner {
        whitepaper = newWhitepaper;
    }
    
    function Whitepaper() public view returns (string memory) {
        return whitepaper;
    }
    
    event WhitepaperChanged(string indexed whitepaper, string indexed newWhitepaper);
    
// ------------------------------------------------------------------------
// Total supply
// ------------------------------------------------------------------------
    function totalSupply() public override view returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

// ------------------------------------------------------------------------
// Get the token balance for account tokenOwner
// ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public override view returns (uint256 balance) {
        return balances[tokenOwner];
    }
    
// ------------------------------------------------------------------------
// Transfer the balance from token owner's account to account
// - Owner's account must have sufficient balance to transfer
// - 0 value transfers are allowed
// ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens) public override returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
// ------------------------------------------------------------------------
// Token owner can approve for spender to transferFrom(...) tokens
// from the token owner's account
// ------------------------------------------------------------------------
    function approve(address spender, uint256 tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
// ------------------------------------------------------------------------
// Transfer tokens from account to account
// 
// The calling account must already have sufficient tokens approve(...)
// for spending from the account
// - From account must have sufficient balance to transfer
// - Spender must have sufficient allowance to transfer
// - 0 value transfers are allowed
// ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
// ------------------------------------------------------------------------
// Returns the amount of tokens approved by the owner that can be
// transferred to the spender's account
// ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public override view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }

// ------------------------------------------------------------------------
// Token owner can approve for spender to transferFrom(...) tokens
// from the token owner's account. The spender contract function
// receiveApproval(...) is then executed
// ------------------------------------------------------------------------
    function approveAndCall(address spender, uint256 tokens, bytes calldata data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

// ------------------------------------------------------------------------
// Owner can transfer out any accidentally BEP20 tokens sent to contract
// ------------------------------------------------------------------------
    function transferAnyBEP20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return BEP20Interface(tokenAddress).transfer(owner, tokens);
    }
}