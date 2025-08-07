# Solidity API

## Core

This contract serves as the main entry point of the platform, inheriting admin and access control features

_Inherits from `Restricted`, `EventsEmitter`, and `AdminManagement`. Initializes the master admin on deployment._

### constructor

```solidity
constructor(string _contractName) public
```

Initializes the Core contract, setting the deployer as the master admin

_Sets up initial admin and emits deployment log. The `i_masterAdmin` is set in the constructor body._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _contractName | string | A descriptive name for the contract instance, stored privately |

## AdminManagement

Enables addition and removal of platform admins with event logging

_Inherits access control from `Restricted` (via `Auth`) and event emitters from `EventsEmitter`_

### AdminManagement__alreadyAddedAsAdmin

```solidity
error AdminManagement__alreadyAddedAsAdmin()
```

Error thrown when attempting to add an already existing admin

### AdminManagement__userIsNotAnAdmin

```solidity
error AdminManagement__userIsNotAnAdmin()
```

Error thrown when attempting to remove a non-admin address

### Admin

Represents an admin record with address, who added them, and when

```solidity
struct Admin {
  address newAdminAddress;
  address addedBy;
  uint256 addedAt;
}
```

### s_platformAdmins

```solidity
struct AdminManagement.Admin[] s_platformAdmins
```

_Stores all platform admins added so far_

### addAdmin

```solidity
function addAdmin(address _address) public
```

Adds a new admin to the platform

_Only callable by existing admins (enforced via `adminOnly` modifier)
Emits an `AddedNewAdmin` event on success_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _address | address | The address of the new admin to add |

### removeAdmin

```solidity
function removeAdmin(address _address) public
```

Removes an existing admin from the platform

_Only callable by existing admins
Cleans up both global and sender-specific admin lists
Emits a `RemovedAdmin` event on success_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _address | address | The admin address to be removed |

### getPlatformAdmins

```solidity
function getPlatformAdmins() public view returns (struct AdminManagement.Admin[])
```

Returns the list of all platform admins

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct AdminManagement.Admin[] | An array of `Admin` structs representing all added admins |

### getAdminRegistrations

```solidity
function getAdminRegistrations(address _adminAddress) public view returns (struct AdminManagement.Admin[])
```

Retrieves a list of admins added by a specific admin

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _adminAddress | address | The address of the admin whose additions you want to query |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct AdminManagement.Admin[] | An array of `Admin` structs added by the given address |

### checkIsAdmin

```solidity
function checkIsAdmin(address _adminAddress) public view returns (bool)
```

Checks whether an address is currently marked as an admin

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _adminAddress | address | The address to check |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if the address is an admin, false otherwise |

## Restricted__accessDenied_AdminOnly

```solidity
error Restricted__accessDenied_AdminOnly()
```

Error thrown when a non-admin attempts to access a restricted function.

## Restricted

### i_masterAdmin

```solidity
address i_masterAdmin
```

The address of the master admin, set at deployment and immutable.

### s_isAdmin

```solidity
mapping(address => bool) s_isAdmin
```

A mapping of addresses that are granted admin rights.

### adminOnly

```solidity
modifier adminOnly()
```

Modifier that restricts function access to the master admin or approved admins.

_Reverts with `Restricted__accessDenied_AdminOnly` if the caller is not authorized._

## EventsEmitter

This contract defines all the events for the project.

_Events can be inherited and emitted by other contracts for standardized logging._

### Logs

```solidity
event Logs(string message, uint256 timestamp, string contractName)
```

Emitted for general logging purposes.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | A custom message describing the log. |
| timestamp | uint256 | The timestamp when the log was emitted. |
| contractName | string | The name of the contract emitting the log. |

### RemovedAdmin

```solidity
event RemovedAdmin(string message, uint256 timestamp, string contractName, address removedAdminAddress)
```

Emitted when an admin is removed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | A description of the removal action. |
| timestamp | uint256 | The time the removal occurred. |
| contractName | string | The name of the contract emitting the event. |
| removedAdminAddress | address | The address of the admin that was removed. |

### AddedNewAdmin

```solidity
event AddedNewAdmin(string message, uint256 timestamp, string contractName, address addedAdminAddress)
```

Emitted when a new admin is added.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | A description of the addition action. |
| timestamp | uint256 | The time the new admin was added. |
| contractName | string | The name of the contract emitting the event. |
| addedAdminAddress | address | The address of the new admin that was added. |

## AggregatorV3Interface

### decimals

```solidity
function decimals() external view returns (uint8)
```

### description

```solidity
function description() external view returns (string)
```

### version

```solidity
function version() external view returns (uint256)
```

### getRoundData

```solidity
function getRoundData(uint80 _roundId) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
```

### latestRoundData

```solidity
function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
```

## EthUsdConverter

Provides utility functions to fetch ETH price and convert between ETH and USD

_Uses Chainlink's AggregatorV3Interface for fetching live ETH/USD price data_

### getEthPrice

```solidity
function getEthPrice() public view returns (uint256)
```

Retrieves the current ETH price in USD from the Chainlink price feed

_Returns price scaled to 18 decimal places (from Chainlink's 8 decimals)_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The latest ETH price in USD with 18 decimals |

### usdToEth

```solidity
function usdToEth(uint256 _usdAmount) public view returns (uint256, uint256)
```

Converts a USD amount (18 decimal format) to the equivalent ETH amount

_Input USD amount must be in 18 decimal format (e.g. 3466.67 = 3466670000000000000000)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _usdAmount | uint256 | The USD amount to convert, in 18 decimal standard format |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | standardUnitAmount The equivalent ETH value in 18 decimal format |
| [1] | uint256 | readAbleAmount The equivalent ETH value as a whole number (no decimals) |

### ethToUSD

```solidity
function ethToUSD(uint256 _ethAmount) public view returns (uint256, uint256)
```

Converts an ETH amount (18 decimal format) to the equivalent USD amount

_Input ETH amount must be in 18 decimal format (e.g. 2.5 ETH = 2500000000000000000)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _ethAmount | uint256 | The ETH amount to convert, in 18 decimal standard format |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | standardUnitPrice The equivalent USD value in 18 decimal format |
| [1] | uint256 | readablePrice The equivalent USD value as a whole number (no decimals) |

