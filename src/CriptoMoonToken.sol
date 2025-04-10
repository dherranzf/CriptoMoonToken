// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// CriptoMoonToken: An ERC20 token with minting, burning, fees, airdrop, pause, and role-based access control.
contract CriptoMoonToken is ERC20, AccessControl, Pausable, ReentrancyGuard {
    // Roles for permission control in the contract.
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");

    // Maximum token supply.
    uint256 public constant maxSupply = 1000000 * 1e18;

    // Treasury wallet address where the transfer fee will be sent.
    address public treasuryWallet;

    // Fixed transfer fee percentage for the treasury (1%).
    uint256 public constant treasuryFeePercentage = 1;

    // Fixed transfer fee percentage for burning (1%).
    uint256 public constant burnFeePercentage = 1;

    // Event emitted when new tokens are minted.
    event Mint(address indexed to, uint256 amount);

    // Event emitted when tokens are burned.
    event Burn(address indexed from, uint256 amount);

    // Event emitted when the treasury wallet is updated.
    event TreasuryWalletUpdated(address newTreasuryWallet);

    // Event emitted when a role is assigned to an account.
    event RoleAssigned(bytes32 indexed role, address indexed account);

    // Event emitted when a role is removed from an account.
    event RoleRemoved(bytes32 indexed role, address indexed account);

    // Event emitted when an airdrop is performed.
    event AirdropPerformed(address indexed recipient, uint256 amount);

    // Event emitted when ERC20 tokens are recovered.
    event ERC20Recovered(address indexed tokenAddress, uint256 amount, address indexed to);

    // Event emitted when tokens of this contract are recovered.
    event OwnTokensRecovered(uint256 amount, address indexed to);

    // Event emitted when ETH is recovered.
    event ETHRecovered(uint256 amount, address indexed to);

    // Constructor: Initializes the token with name, symbol, initial supply, and treasury wallet.
    constructor(
        string memory name_,
        string memory symbol_,
        address treasuryWallet_
    ) ERC20(name_, symbol_) {
        require(
            treasuryWallet_ != address(0),
            "CriptoMoonToken: treasury wallet cannot be zero address"
        );

        // Assign initial roles to the contract creator.
        _grantRole(ADMIN_ROLE, msg.sender); // ADMIN_ROLE for administrative operations.
        _grantRole(DEV_ROLE, msg.sender); // DEV_ROLE for developers.

        // ADMIN_ROLE also has permissions to manage roles.
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(DEV_ROLE, ADMIN_ROLE);

        // Initialize the treasury wallet.
        treasuryWallet = treasuryWallet_; // Assign the treasury wallet to the provided parameter.
    }

    // Function to pause the contract. Only accessible by accounts with the ADMIN_ROLE.
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    // Function to unpause the contract. Only accessible by accounts with the ADMIN_ROLE.
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    // Function to mint new tokens. Only accessible by accounts with the ADMIN_ROLE.
    function mint(address to, uint256 amount) external onlyRole(ADMIN_ROLE) whenNotPaused {
        // Ensure the total supply after minting does not exceed the maximum supply.
        require(
            totalSupply() + amount <= maxSupply,
            "CriptoMoonToken: max supply exceeded"
        );
        _mint(to, amount);
        emit Mint(to, amount); // Emit event to log the operation.
    }

    // Function to burn tokens. Any user can burn their own tokens.
    function burn(uint256 amount) external whenNotPaused {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount); // Emit event to log the operation.
    }

    // Function to assign a role to an account. Only accessible by accounts with the ADMIN_ROLE.
    function assignRole(
        bytes32 role,
        address account
    ) external onlyRole(ADMIN_ROLE) {
        grantRole(role, account);
        emit RoleAssigned(role, account); // Emit event to log the role assignment.
    }

    // Function to revoke a role from an account. Only accessible by accounts with the ADMIN_ROLE.
    function removeRole(
        bytes32 role,
        address account
    ) external onlyRole(ADMIN_ROLE) {
        revokeRole(role, account);
        emit RoleRemoved(role, account); // Emit event to log the role removal.
    }

    // Function to perform an airdrop. Only accessible by accounts with the ADMIN_ROLE.
    function airdrop(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external onlyRole(ADMIN_ROLE) whenNotPaused {
        require(
            recipients.length == amounts.length,
            "CriptoMoonToken: recipients and amounts length mismatch"
        );

        for (uint256 i = 0; i < recipients.length; i++) {
            // Ensure the total supply does not exceed the maximum after each transfer.
            require(
                totalSupply() + amounts[i] <= maxSupply,
                "CriptoMoonToken: max supply exceeded"
            );
            _mint(recipients[i], amounts[i]);
            emit Mint(recipients[i], amounts[i]); // Emit event to log the minting.
            emit AirdropPerformed(recipients[i], amounts[i]); // Emit event to log the airdrop.
        }
    }

    // Function to recover ERC20 tokens accidentally sent to the contract (other tokens, not the native token).
    // Only accessible by accounts with the ADMIN_ROLE.
    function recoverERC20(
        address tokenAddress,
        uint256 amount,
        address to
    ) external nonReentrant onlyRole(ADMIN_ROLE) {
        require(
            tokenAddress != address(this),
            "CriptoMoonToken: use recoverOwnToken for native token"
        );
        IERC20(tokenAddress).transfer(to, amount); // Use transfer for ERC20 tokens.
        emit ERC20Recovered(tokenAddress, amount, to); // Emit event to log the recovery.
    }

    // Function to recover tokens of this contract sent to itself by mistake.
    // Only accessible by accounts with the ADMIN_ROLE.
    function recoverOwnToken(
        uint256 amount,
        address to
    ) external nonReentrant onlyRole(ADMIN_ROLE) {
        require(
            amount <= balanceOf(address(this)),
            "CriptoMoonToken: insufficient contract balance"
        );
        _transfer(address(this), to, amount); // Use _transfer for native tokens of this contract.
        emit OwnTokensRecovered(amount, to);
    }

    // Function to recover ETH sent to the contract by mistake.
    // Only accessible by accounts with the ADMIN_ROLE.
    function recoverETH(
        uint256 amount,
        address payable to
    ) external nonReentrant onlyRole(ADMIN_ROLE) {
        require(
            address(this).balance >= amount,
            "CriptoMoonToken: insufficient ETH balance"
        );

        (bool success, ) = to.call{value: amount}("");
        require(success, "CriptoMoonToken: ETH transfer failed");

        emit ETHRecovered(amount, to); // Emit event to log the recovery.
    }

    // Allow the contract to receive ETH.
    receive() external payable {}

    // Function to recover native tokens sent to the contract by mistake.
    // Only accessible by accounts with the ADMIN_ROLE.
    function recoverNativeTokens(
        uint256 amount,
        address to
    ) external nonReentrant onlyRole(ADMIN_ROLE) {
        uint256 contractBalance = balanceOf(address(this));
        require(
            amount <= contractBalance,
            "CriptoMoonToken: insufficient contract balance"
        );
        _transfer(address(this), to, amount);
        emit NativeTokensRecovered(amount, to); // Emit event to log the recovery.
    }

    // Function to update the treasury wallet. Only accessible by accounts with the ADMIN_ROLE.
    function updateTreasuryWallet(
        address newTreasuryWallet
    ) external onlyRole(ADMIN_ROLE) {
        require(
            newTreasuryWallet != address(0),
            "CriptoMoonToken: treasury wallet cannot be zero address"
        );
        treasuryWallet = newTreasuryWallet;
        emit TreasuryWalletUpdated(newTreasuryWallet);
    }

    // Override the transfer function to include fees and ensure it cannot be executed while paused.
    function transfer(address to, uint256 amount)
        public
        override
        whenNotPaused
        returns (bool)
    {
        _transferWithFees(_msgSender(), to, amount);
        return true;
    }

    // Override the transferFrom function to include fees and ensure it cannot be executed while paused.
    function transferFrom(address from, address to, uint256 amount)
        public
        override
        whenNotPaused
        returns (bool)
    {
        uint256 currentAllowance = allowance(from, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(from, _msgSender(), currentAllowance - amount);

        _transferWithFees(from, to, amount);
        return true;
    }

    // Internal function to handle transfers with fees for treasury and burning.
    function _transferWithFees(address from, address to, uint256 amount)
        internal
    {
        // Exclude the treasury wallet from fees.
        if (from == treasuryWallet || to == treasuryWallet) {
            super._transfer(from, to, amount);
            return;
        }

        uint256 treasuryAmount = (amount * treasuryFeePercentage) / 100;
        uint256 burnAmount = (amount * burnFeePercentage) / 100;
        uint256 amountAfterFee = amount - burnAmount - treasuryAmount;

        // Transfer the fee portion to the treasury wallet.
        if (treasuryAmount > 0) {
            super._transfer(from, treasuryWallet, treasuryAmount);
        }

        // Burn the corresponding portion.
        if (burnAmount > 0) {
            _burn(from, burnAmount);
        }

        // Transfer the remaining amount to the recipient.
        super._transfer(from, to, amountAfterFee);
    }

    // Override the approve function to protect it with whenNotPaused, preventing approvals during a pause.
    function approve(address spender, uint256 amount)
        public
        override
        whenNotPaused
        returns (bool)
    {
        return super.approve(spender, amount);
    }

}
