# 🪙 CriptoMoonToken - SmartContract ERC20 Token with Advanced Features

A Solidity-based ERC20 token contract with advanced features such as minting, burning, transfer fees, airdrops, pausing, and role-based access control. This project leverages **OpenZeppelin** libraries for security and modularity.

## 📑 Table of Contents
- [🧑‍💻 Features](#-features)
- [🎨 Technology Stack](#-technology-stack)
- [🗂️ Project Structure](#-project-structure)
- [📖 How to Use This Repo](#-how-to-use-this-repo)
- [🔮 Future Improvements](#-future-improvements)
- [📜 License](#-license)

## 🧑‍💻 Features
- **Minting**: Admins can mint new tokens up to a maximum supply.
- **Burning**: Any user can burn their own tokens.
- **Transfer Fees**: Automatically deducts fees for treasury and burning on transfers.
- **Airdrops**: Admins can distribute tokens to multiple recipients in a single transaction.
- **Pausing**: Admins can pause all token transfers and operations.
- **Role-Based Access Control**: Uses `ADMIN_ROLE` and `DEV_ROLE` for secure and flexible permission management.
- **Token Recovery**: Admins can recover accidentally sent ERC20 or native tokens.

### 📜 Available Functions

| Function Name             | Description                                                                                     | Access Control       |
|---------------------------|-------------------------------------------------------------------------------------------------|----------------------|
| `constructor(string, string, address)` | Initializes the token with name, symbol, and treasury wallet.                        | Public               |
| `pause()`                 | Pauses all token transfers and operations.                                                     | `ADMIN_ROLE`         |
| `unpause()`               | Resumes all token transfers and operations.                                                    | `ADMIN_ROLE`         |
| `mint(address, uint256)`  | Mints new tokens to a specified address, ensuring the max supply is not exceeded.               | `ADMIN_ROLE`         |
| `burn(uint256)`           | Burns tokens from the caller's balance.                                                        | Public               |
| `assignRole(bytes32, address)` | Assigns a specific role to an account.                                                     | `ADMIN_ROLE`         |
| `removeRole(bytes32, address)` | Revokes a specific role from an account.                                                   | `ADMIN_ROLE`         |
| `airdrop(address[], uint256[])` | Distributes tokens to multiple recipients in a single transaction.                        | `ADMIN_ROLE`         |
| `recoverERC20(address, uint256, address)` | Recovers ERC20 tokens accidentally sent to the contract.                        | `ADMIN_ROLE`         |
| `recoverNativeTokens(uint256, address)` | Recovers native tokens accidentally sent to the contract.                         | `ADMIN_ROLE`         |
| `updateTreasuryWallet(address)` | Updates the treasury wallet address.                                                      | `ADMIN_ROLE`         |
| `transfer(address, uint256)` | Transfers tokens to another address, applying fees unless exempt.                            | Public               |
| `transferFrom(address, address, uint256)` | Transfers tokens on behalf of another address, applying fees unless exempt.       | Public               |
| `approve(address, uint256)` | Approves a spender to transfer tokens on behalf of the caller.                                | Public               |

### 🔒 Security Considerations
1. `ADMIN_ROLE` is the most powerful role. Accounts with this role can grant or revoke any other role.
2. `ADMIN_ROLE` has administrative permissions for minting, airdrops, and role management.
3. `DEV_ROLE` can be used for specific development functionalities.
4. It is recommended to transfer `ADMIN_ROLE` to a multisig contract or decentralized system to avoid centralization risks.
5. Ensure accounts with `ADMIN_ROLE` are trustworthy, as they have direct control over token supply and role management.

## 🎨 Technology Stack

### Key Technologies
| Technology       | Purpose & Advantages                                                                                     |
|------------------|----------------------------------------------------------------------------------------------------------|
| **Solidity**     | A secure and efficient programming language for writing Ethereum-based smart contracts.                  |
| **OpenZeppelin** | Provides reusable and secure smart contract libraries for ERC20, access control, and security features.  |
| **Remix**        | A powerful web-based IDE for writing, testing, and deploying smart contracts.                            |

### Design Practices
- **Use of Audited Libraries**: Leverages OpenZeppelin's well-audited libraries to ensure security and reliability.
- **Event Logging**: Implements detailed event logging for all critical operations to enhance transparency and traceability.
- **Role-Based Access Control**: Ensures only authorized users can perform specific actions.

## 🗂️ Project Structure

The project is organized as follows:

```
src/
├── CriptoMoonWolfToken.sol  # ERC20 token contract implementation
```

## 📖 How to Use This Repo

Follow these steps to set up and deploy the contract:

### ⚙️ Setup

1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/CriptoMoonWolf-Token.git
   cd CriptoMoonWolf-Token
   ```

### 🚀 Deployment

1. Compile the contract using Remix, Foundry or your preferred deployment tool.
   
2. Deploy the contract using Remix, Foundry or your preferred deployment tool.


### 🧪 Testing

Testing the contract using Remix, Foundry or your preferred deployment tool.

## 🔮 Future Improvements

- **Advanced Airdrop Features**: Add Snapshot and support for conditional airdrops based on user activity or token holdings.
- **Dynamic Fee Mechanism**: Allow the treasury and burn fee percentages to be updated by the admin, with proper safeguards.
- **Gas Optimization**: Further optimize gas usage for frequently used functions like transfers and airdrops.

- **Governance Integration**: Introduce a governance mechanism to decentralize decision-making for critical operations.
- **Staking Rewards**: Implement a staking mechanism to reward token holders for locking their tokens.

- **Upgradeable Contract**: Use a proxy pattern to make the contract upgradeable for future feature additions.
- **Multisignature Wallet Support**: Integrate multisignature wallets for critical administrative actions to enhance security and decentralization.
- **Multi-Treasury Support**: Enable multiple treasury wallets with configurable fee splits.


## 📜 License

This project is licensed under the GPL-3.0 License. See the `LICENSE` file for details.