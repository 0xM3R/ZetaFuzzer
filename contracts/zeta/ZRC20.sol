// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./interfaces/ISystem.sol";
import "./interfaces/IZRC20.sol";

contract ZRC20 is IZRC20Metadata, ZRC20Events {
    address public constant FUNGIBLE_MODULE_ADDRESS = 0x735b14BB79463307AAcBED86DAf3322B1e6226aB;
    uint256 public CHAIN_ID; // Regular uint256 instead of immutable
    CoinType public COIN_TYPE; // Correct declaration of CoinType as immutable
    
    address public SYSTEM_CONTRACT_ADDRESS;
    uint256 public GAS_LIMIT;
    uint256 public PROTOCOL_FLAT_FEE;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address public gatewayAddress;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 chainId_,
        CoinType coinType_, // Make sure this is passed to the constructor
        address systemContract_,
        uint256 gasLimit_,
        uint256 protocolFlatFee_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        CHAIN_ID = chainId_; // Regular uint256 instead of immutable
        COIN_TYPE = coinType_; // Initialize immutable COIN_TYPE in the constructor
        SYSTEM_CONTRACT_ADDRESS = systemContract_;
        GAS_LIMIT = gasLimit_;
        PROTOCOL_FLAT_FEE = protocolFlatFee_;
    }


    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function setName(string memory newName) external override {
        _name = newName;
    }

    function setSymbol(string memory newSymbol) external override {
        _symbol = newSymbol;
    }

    function deposit(address to, uint256 amount) external override returns (bool) {
        _mint(to, amount);
        emit Deposit("", to, amount);
        return true;
    }

    function burn(uint256 amount) external override returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

    function withdraw(bytes memory to, uint256 amount) external override returns (bool) {
        (address gasZRC20, uint256 gasFee) = withdrawGasFee();
        require(IZRC20(gasZRC20).transferFrom(msg.sender, FUNGIBLE_MODULE_ADDRESS, gasFee), "Gas fee transfer failed");
        _burn(msg.sender, amount);
        emit Withdrawal(msg.sender, to, amount, gasFee, PROTOCOL_FLAT_FEE);
        return true;
    }

    function updateSystemContractAddress(address addr) external onlyFungible {
        require(addr != address(0), "Zero address not allowed");
        SYSTEM_CONTRACT_ADDRESS = addr;
        emit UpdatedSystemContract(addr);
    }

    function updateGatewayAddress(address addr) external onlyFungible {
        require(addr != address(0), "Zero address not allowed");
        gatewayAddress = addr;
        emit UpdatedGateway(addr);
    }

    function updateGasLimit(uint256 gasLimit_) external onlyFungible {
        GAS_LIMIT = gasLimit_;
        emit UpdatedGasLimit(GAS_LIMIT);
    }

    function updateProtocolFlatFee(uint256 protocolFlatFee_) external onlyFungible {
        PROTOCOL_FLAT_FEE = protocolFlatFee_;
        emit UpdatedProtocolFlatFee(PROTOCOL_FLAT_FEE);
    }

    function withdrawGasFee() public view override returns (address, uint256) {
        return (address(this), 0); // Example placeholder
    }

    function withdrawGasFeeWithGasLimit(uint256 /* gasLimit */) public view override returns (address, uint256) {
        return (address(this), 0); // Example placeholder
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ZRC20: transfer from the zero address");
        require(recipient != address(0), "ZRC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ZRC20: transfer amount exceeds balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ZRC20: approve from the zero address");
        require(spender != address(0), "ZRC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ZRC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ZRC20: burn from the zero address");

        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    modifier onlyFungible() {
        require(msg.sender == FUNGIBLE_MODULE_ADDRESS, "Caller is not fungible module");
        _;
    }
}

