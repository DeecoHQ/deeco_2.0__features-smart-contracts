# Solidity API

## Core

This contract serves as the main entry point of the platform, inheriting admin/access control features, and all of the other smart contracts - serving as a converging point

_Inherits from `Auth`, `PlatformEvents`, and `AdminManagement`. Initializes the master admin on deployment._

### contractName

```solidity
string contractName
```

Stores the name of the contract instance

_Intended to be immutable but can't be due to non-value type restriction_

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

_Inherits access control from `Auth` (via `Auth`) and event emitters from `EventsEmitter`_

### Admin

Represents an admin record with address, who added them, and when

```solidity
struct Admin {
  address newAdminAddress;
  address addedBy;
  uint256 addedAt;
}
```

### AdminManagement__AlreadyAddedAsAdmin

```solidity
error AdminManagement__AlreadyAddedAsAdmin(struct AdminManagement.Admin admin)
```

Error thrown when attempting to add an already existing admin

### AdminManagement__AddressIsNotAnAdmin

```solidity
error AdminManagement__AddressIsNotAnAdmin()
```

Error thrown when a provided user(address) is not an admin

### s_platformAdmins

```solidity
struct AdminManagement.Admin[] s_platformAdmins
```

Stores all platform admins added so far

_This array grows as new admins are added and shrinks as they are removed._

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

### getAdminProfile

```solidity
function getAdminProfile(address _adminAddress) public view returns (struct AdminManagement.Admin)
```

Retrieves the full admin profile for a given address

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _adminAddress | address | The address of the admin whose profile you want |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct AdminManagement.Admin | An `Admin` struct containing the profile details |

## Auth

This contract provides admin-only access control functionality.

_The master admin is set as an immutable address; additional admins can be added to the mapping._

### Auth__AccessDenied_AdminOnly

```solidity
error Auth__AccessDenied_AdminOnly()
```

Error thrown when a non-admin attempts to access a restricted function.

### i_masterAdmin

```solidity
address i_masterAdmin
```

The address of the master admin, set at deployment and immutable.

_This variable is used for strict ownership control and cannot be changed after deployment._

### s_isAdmin

```solidity
mapping(address => bool) s_isAdmin
```

Mapping of admin addresses to their admin status.

_`true` indicates the address has admin privileges; `false` means no admin rights._

### adminOnly

```solidity
modifier adminOnly()
```

Modifier that restricts function access to the master admin or approved admins.

_Reverts with `Auth__AccessDenied_AdminOnly` if the caller is not authorized._

## ProductManagement

Handles adding, updating, deleting, and retrieving product information within the platform.

_Inherits from Auth for admin-only access and PlatformEvents for event emission._

### Product

Structure to store product details.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct Product {
  string id;
  address addedBy;
  uint256 addedAt;
  string productImageCID;
  string productMetadataCID;
  uint256 updatedAt;
}
```

### ProductManagement__ProductAlreadyExistsWithProvidedId

```solidity
error ProductManagement__ProductAlreadyExistsWithProvidedId(struct ProductManagement.Product product)
```

Error indicating that a product with the given ID already exists.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| product | struct ProductManagement.Product | The full existing product data. |

### ProductManagement__ProductWithProvidedIdDoesNotExist

```solidity
error ProductManagement__ProductWithProvidedIdDoesNotExist()
```

Error indicating that no product with the given ID exists.

### ProductManagement__AddressIsNotAnAdmin

```solidity
error ProductManagement__AddressIsNotAnAdmin()
```

Error indicating that the provided address is not an admin.

### addProduct

```solidity
function addProduct(string _productId, string _productImageCID, string _productMetadataCID) public
```

Adds a new product to the platform.

_Only callable by an admin. Emits a ProductChore event on success._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _productId | string | Unique identifier for the new product. |
| _productImageCID | string | CID for the product image on IPFS. |
| _productMetadataCID | string | CID for the product metadata on IPFS. |

### deleteProduct

```solidity
function deleteProduct(string _productId) public
```

Deletes a product from the platform.

_Only callable by an admin. Emits a ProductChore event on success._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _productId | string | Unique identifier of the product to delete. |

### updateProduct

```solidity
function updateProduct(string _productId, string _productImageCID, string _productMetadataCID) public
```

Updates details of an existing product.

_Only callable by an admin. Emits a ProductChore event on success._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _productId | string | Unique identifier of the product to update. |
| _productImageCID | string | New CID for the product image on IPFS. |
| _productMetadataCID | string | New CID for the product metadata on IPFS. |

### getProduct

```solidity
function getProduct(string _productId) public view returns (struct ProductManagement.Product)
```

Retrieves details of a product by its ID.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _productId | string | Unique identifier of the product to retrieve. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ProductManagement.Product | The Product struct containing product details. |

### getProductsAddedByAdmin

```solidity
function getProductsAddedByAdmin(address _adminAddress) public view returns (struct ProductManagement.Product[])
```

Retrieves all products added by a specific admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _adminAddress | address | Address of the admin. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ProductManagement.Product[] | Array of Product structs added by the given admin. |

### getPlatformProducts

```solidity
function getPlatformProducts() public view returns (struct ProductManagement.Product[])
```

Retrieves all products on the platform.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ProductManagement.Product[] | Array of all Product structs in the platform. |

## PlatformEvents

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
event RemovedAdmin(string message, uint256 timestamp, string contractName, address removedAdminAddress, address removedBy)
```

Emitted when an admin is removed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | A description of the removal action. |
| timestamp | uint256 | The time the removal occurred. |
| contractName | string | The name of the contract emitting the event. |
| removedAdminAddress | address | The address of the admin that was removed. |
| removedBy | address | The address of the account that performed the removal. |

### AddedNewAdmin

```solidity
event AddedNewAdmin(string message, uint256 timestamp, string contractName, address addedAdminAddress, address addedBy)
```

Emitted when a new admin is added.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | A description of the addition action. |
| timestamp | uint256 | The time the new admin was added. |
| contractName | string | The name of the contract emitting the event. |
| addedAdminAddress | address | The address of the new admin that was added. |
| addedBy | address | The address of the account that performed the addition. |

### ProductChoreActivityType

Enumeration of product-related activity types.

_Used for categorizing `ProductChore` events._

```solidity
enum ProductChoreActivityType {
  AddedNewProduct,
  UpdatedProduct,
  DeletedProduct
}
```

### ProductChore

```solidity
event ProductChore(string message, uint256 timestamp, enum PlatformEvents.ProductChoreActivityType activity, string contractName, string productId, address addedBy)
```

Emitted when a product-related action occurs.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | A description of the action taken on the product. |
| timestamp | uint256 | The time the action occurred. |
| activity | enum PlatformEvents.ProductChoreActivityType | The type of product activity (add, update, delete). |
| contractName | string | The name of the contract emitting the event. |
| productId | string | The unique product identifier (string to support non-numeric DB IDs like MongoDB). |
| addedBy | address | The address of the account that performed the product action. |

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

