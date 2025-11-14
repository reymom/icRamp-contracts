# icRamp Contracts

This repository contains escrow management contracts for an onramping protocol integrated with the Internet Computer (ICP). The contracts manage deposits and withdrawals of ERC20 tokens and native currency, allowing different offrampers to commit and release funds in a decentralized and privacy-preserving manner. The protocol ensures flexibility in handling various tokens and transactions between offrampers and onrampers.

## Deployments

| Network                | Contract Name | Address                                    |
| ---------------------- | ------------- | ------------------------------------------ |
| Sepolia                | Ic2P2Ramp     | 0x4Dfe1aAf305Bfc857529d26053a9E18f87Bfc7d6 |
| Base Sepolia           | Ic2P2Ramp     | 0x43550deEd0bC15a1e7918862558d8E46477536bA |
| Optimism Sepolia       | Ic2P2Ramp     | 0x602475c17c020fe3af7294ec4acf68f93198332c |
| Mantle Sepolia Testnet | Ic2P2Ramp     | 0x43550deEd0bC15a1e7918862558d8E46477536bA |

| Network                | Contract Name | Address                                    |
| ---------------------- | ------------- | ------------------------------------------ |
| Sepolia                | IcRamp        | 0x5fbF6e9290043a20DfbB796ABf25a5806297DeE1 |
| Base Sepolia           | IcRamp        | 0x8D890F0020199653b1B8379377F307c172B2C4Ca |
| Optimism Sepolia       | IcRamp        | 0x3Fe6AD20885ef84Da31B8b857ECA55976BE95CA0 |
| Mantle Sepolia Testnet | IcRamp        | 0xfb19542b43832cfc9e906af846f05a157bc4e4c3 |
| Arbitrum Sepolia       | IcRamp        | 0xc94C04b5d20ea7cC45690809F211c17596C56625 |

| Network  | Contract Name | Address                                    |
| -------- | ------------- | ------------------------------------------ |
| Mainnet  | IcRamp        | 0x4332684406903DAF097f8E0bf0E8E830Fe24C001 |
| Base     | IcRamp        | 0x1A7817Dabf851a05da8cE0cd2D8D1EA0c8140783 |
| Optimism | IcRamp        | 0x1A7817Dabf851a05da8cE0cd2D8D1EA0c8140783 |
| Arbitrum | IcRamp        | 0x6CCa814490d7d835E4349C875eE23467a0684e81 |

| Network | Contract Name              | Address                                    |
| ------- | -------------------------- | ------------------------------------------ |
| Sepolia | IcRamp (no-commit version) | 0xE1De1dd26B1CF389fD108C208268Fb0154A5EB32 |

## Contract Details

### icRamp Contract

The `icRamp` contract is responsible for managing deposits, withdrawals, and the escrow process for ERC20 tokens and native currency. It ensures the secure transfer of funds between offrampers (who deposit funds) and onrampers (who receive those funds after completing the process). Onrampers can commit deposits, through a controller entity such as the ICP EVM canister that can also release the funds to onrampers.

> Note: icRamp is a key piece in the ecosystem of the whole icRamp protocol, which is controlled by ICP canisters in a decentralized fashion. The smart contracts are decentralized to de degree of their controller canisters.

#### Functions

- `deposit(address _token, uint256 _amount)`: Allows an offramper to deposit a specific amount of an ERC20 token.
- `depositBaseCurrency()`: Allows an offramper to deposit native currency (e.g., ETH) into the contract.
- `withdrawToken(address _offramper, address _token, uint256 _amount, uint256 _fees)`: Withdraws a specified amount of an ERC20 token for an offramper, with fees applied.
- `withdrawBaseCurrency(address _offramper, uint256 _amount, uint256 _fees)`: Withdraws native currency for an offramper, with fees applied.
- `commitDeposit(address _offramper, address _token, uint256 _amount)`: Commits a deposit from an offramper, ensuring it can be released later.
- `uncommitDeposit(address _offramper, address _token, uint256 _amount)`: Reverts a previously committed deposit, allowing the offramper to withdraw funds.
- `releaseToken(address _offramper, address _onramper, address _token, uint256 _amount, uint256 _fees)`: Releases committed ERC20 tokens from an offramper to an onramper, applying any necessary fees.
- `releaseBaseCurrency(address _offramper, address _onramper, uint256 _amount, uint256 _fees)`: Releases native currency from an offramper to an onramper, with fees deducted.
- `addValidTokens(address[] memory _tokens)`: Adds a list of tokens to the whitelist of accepted tokens.
- `removeValidTokens(address[] memory _tokens)`: Removes a list of tokens from the whitelist of accepted tokens.
- `setIcpEvmCanister(address _icpEvmCanister)`: Sets the address of the ICP EVM canister responsible for controlling the contract actions.

#### Events

- `Deposit(address indexed user, address indexed token, uint256 amount)`: Emitted when a user deposits tokens.
- `Withdraw(address indexed user, address indexed token, uint256 amount)`: Emitted when a user withdraws tokens.
- `DepositCommitted(address indexed user, address indexed token, uint256 amount)`: Emitted when a deposit is committed for an onramp transaction.
- `DepositUncommitted(address indexed user, address indexed token, uint256 amount)`: Emitted when a committed deposit is uncommitted, making it available for withdrawal.
- `FeeTracked(address indexed user, address indexed token, uint256 fees)`: Emitted when fees are tracked and attributed to the ICP EVM canister.

### USDT Contract

The USDT contract is a standard ERC20 token used for testing the `icRamp` contract. It allows minting and transferring tokens, enabling test scenarios where users can interact with the ramping protocol.

## Deployment scripts

A set of scripts is provided to deploy the contracts and perform various management tasks, such as adding valid tokens and transferring funds.

### Deployment Steps

1. **Deploy the contract**:
   Use the deployment scripts like deploy_sepolia.sh to deploy the Ic2P2Ramp contract on different networks.

2. **Add valid tokens**:
   After deployment, use add_valid_tokens.sh or AddValidTokens.s.sol to add valid tokens that can be deposited and used within the protocol.

3. **Set the ICP EVM Canister**:
   Ensure the icpEvmCanister is correctly set using the set_icp_evm_canister.sh script.

4. **Manage funds**:
   Utilize transfer_to_canister.sh and TransferEth.s.sol to manage the movement of funds between the canister and the contract.

### icRamp Contract v2

The current `IcRamp` contract manages deposits, withdrawals, and escrow for ERC20 tokens and native currency, but **does not keep a separate committed balance on-chain anymore**. All “lock / unlock” logic lives in the ICP canisters; EVM only sees:

- raw deposits from offrampers,
- withdrawals (cancel),
- releases (successful fills),
- fee accounting.

The ICP EVM canister is the only address allowed to perform withdrawals and releases.

#### Core Functions

- `depositToken(address _token, uint256 _amount)`
  Offramper deposits `_amount` of an ERC20 token into escrow. EscrowManager updates its internal mapping, then the vault pulls tokens with `safeTransferFrom`.

- `depositBaseCurrency()`
  Offramper deposits native currency (e.g. ETH). `msg.value` is tracked in EscrowManager under `token = address(0)`.

- `withdrawToken(address _offramper, address _token, uint256 _amount, uint256 _fees)`
  Callable only by the ICP EVM canister. Decreases the offramper’s escrow balance by `_amount`.

  - If `_offramper == icpEvmCanister`, sends the full `_amount` (no fee).
  - Otherwise, sends `_amount - _fees` and books `_fees` to `icpEvmCanister` via `trackFees`.

- `withdrawBaseCurrency(address _offramper, uint256 _amount, uint256 _fees)`
  Same as above but for native currency (`address(0)` in EscrowManager).

- `releaseToken(address _offramper, address _onramper, address _token, uint256 _amount, uint256 _fees)`
  Called by the ICP EVM canister when an order fill is finalized.

  - `consumeDeposit` burns `_amount` from the offramper’s escrow balance.
  - Sends `_amount - _fees` of the token to `_onramper`.
  - Credits `_fees` to `icpEvmCanister` via `trackFees`.

- `releaseBaseCurrency(address _offramper, address _onramper, uint256 _amount, uint256 _fees)`
  Same semantics, but for native currency.

- `addValidTokens(address[] memory _tokens)` / `removeValidTokens(address[] memory _tokens)`
  Manage the allowlist of ERC20s this vault will accept.

- `setIcpEvmCanister(address _icpEvmCanister)`
  Updates the controller canister that is allowed to call `withdraw*` and `release*`.

#### EscrowManager Events

Escrow state is factored out into `EscrowManager`, which only trusts its owner (the IcRamp contract):

- `Deposit(address indexed user, address indexed token, uint256 amount)`
- `Withdraw(address indexed user, address indexed token, uint256 amount)`
- `DepositConsumed(address indexed user, address indexed token, uint256 amount)`
- `FeeTracked(address indexed user, address indexed token, uint256 fees)`

The old `DepositCommitted` / `DepositUncommitted` events and `commitDeposit/uncommitDeposit` functions are no longer used in this version; locking is handled off-chain (ICP state) and only final actions hit the EVM vault.
