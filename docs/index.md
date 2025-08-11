# Solidity API

## Core__AdminManagement

Core contract that manages platform admins and merchants, combining ownership, admin, and merchant management.
@dev
- Inherits ownership authorization, platform event logging, admin management, and merchant management.
- Upon deployment, assigns the deployer as the contract owner, master admin, and master merchant.
- Provides functions to update and query the liquidity core contract address, contract name, owner, and health check.

### constructor

```solidity
constructor() public
```

Contract constructor that initializes the owner, master admin, and master merchant.
@dev
- Sets the deployer as the immutable contract owner.
- Grants deployer admin and merchant roles.
- Calls internal functions to register deployer as master admin and merchant.
- Emits a `Logs` event signaling successful deployment.

### updateLiquidityCoreContractAddress

```solidity
function updateLiquidityCoreContractAddress(address _contractAddress) public
```

Updates the address of the `Core__Liquidity` contract used for liquidity management.
@dev
- Can only be called by an admin (`adminOnly` modifier).
- Updates internal reference used by merchant management for balance updates and related logic.
- Emits `ExternalContractAddressUpdated` event documenting the address change.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _contractAddress | address | The new deployed address of the `Core__Liquidity` contract. |

### getLiquidityCoreContractAddress

```solidity
function getLiquidityCoreContractAddress() public view returns (address)
```

Retrieves the current address of the `Core__Liquidity` contract.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The address currently set for liquidity core contract interaction. |

### getContractName

```solidity
function getContractName() public pure returns (string)
```

Returns the name identifier of this contract.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | The constant string "Core__AdminManagement". |

### getContractOwner

```solidity
function getContractOwner() public view returns (address)
```

Returns the owner address of the contract.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The address that deployed the contract and holds ownership rights. |

### ping

```solidity
function ping() external view returns (string, address, uint256)
```

Provides a simple ping endpoint to verify contract availability and basic info.
@dev
- Callable externally to confirm the contract is deployed and responsive.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | contractName The name of the contract. |
| [1] | address | contractAddress The current contract address. |
| [2] | uint256 | currentTimestamp The current blockchain timestamp. |

## Core__Liquidity

### constructor

```solidity
constructor() public
```

### getContractName

```solidity
function getContractName() public view returns (string)
```

### getContractOwner

```solidity
function getContractOwner() public view returns (address)
```

### ping

```solidity
function ping() external view returns (string, address, uint256)
```

## AdminManagement

Manages platform administrators by enabling addition, removal, and retrieval of admin profiles and registrations.
        Enforces that only existing admins can add or remove admins via the inherited `adminOnly` modifier.

_- Inherits from `AdminAuth` to manage admin access control state.
- Inherits from `PlatformEvents` to emit standardized platform events on admin-related actions._

### Admin

Represents an admin's profile and metadata about their registration.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct Admin {
  address adminAddress;
  address addedBy;
  uint256 addedAt;
}
```

### AdminManagement__AlreadyAddedAsAdmin

```solidity
error AdminManagement__AlreadyAddedAsAdmin(struct AdminManagement.Admin admin)
```

Error thrown when attempting to add an address that is already an admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| admin | struct AdminManagement.Admin | The existing admin profile for the address. |

### AdminManagement__AddressIsNotAnAdmin

```solidity
error AdminManagement__AddressIsNotAnAdmin()
```

Error thrown when an address is expected to be an admin but is not.

### s_platformAdmins

```solidity
struct AdminManagement.Admin[] s_platformAdmins
```

Array holding all admins currently registered on the platform.

### s_adminAddressToAdditions_admin

```solidity
mapping(address => struct AdminManagement.Admin[]) s_adminAddressToAdditions_admin
```

Maps an admin address to a list of `Admin` structs representing the admins they have added.

### s_adminAddressToAdminProfile

```solidity
mapping(address => struct AdminManagement.Admin) s_adminAddressToAdminProfile
```

Maps an admin address to their `Admin` profile information.

### addAdmin

```solidity
function addAdmin(address _address) public
```

Adds a new admin to the platform.

_- Can only be called by an existing admin (`adminOnly` modifier).
- Reverts with `AdminManagement__AlreadyAddedAsAdmin` if the address is already an admin.
- Updates internal storage and emits `AddedNewAdmin` event upon success._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _address | address | The address to be granted admin privileges. |

### removeAdmin

```solidity
function removeAdmin(address _address) public
```

Removes an existing admin from the platform.

_- Can only be called by an existing admin (`adminOnly` modifier).
- Reverts with `AdminManagement__AddressIsNotAnAdmin` if the address is not an admin.
- Removes admin from all internal lists and mappings.
- Emits a `RemovedAdmin` event upon success._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _address | address | The admin address to be removed. |

### getPlatformAdmins

```solidity
function getPlatformAdmins() public view returns (struct AdminManagement.Admin[])
```

Returns the list of all registered platform admins.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct AdminManagement.Admin[] | An array of `Admin` structs representing all platform admins. |

### getAdminAdminRegistrations

```solidity
function getAdminAdminRegistrations(address _adminAddress) public view returns (struct AdminManagement.Admin[])
```

Retrieves the list of admins added by a specific admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _adminAddress | address | The admin whose additions are requested. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct AdminManagement.Admin[] | An array of `Admin` structs representing the admins added by `_adminAddress`. |

### checkIsAdmin

```solidity
function checkIsAdmin(address _adminAddress) public view returns (bool)
```

Checks whether a given address currently holds admin status.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _adminAddress | address | The address to check. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if the address is an admin, false otherwise. |

### getAdminProfile

```solidity
function getAdminProfile(address _adminAddress) public view returns (struct AdminManagement.Admin)
```

Retrieves the admin profile information for a given address.

_Reverts if the address is not an admin._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _adminAddress | address | The admin address to query. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct AdminManagement.Admin | The `Admin` struct containing profile and registration metadata. |

## MerchantManagement

Manages merchants on the platform, including adding, removing, updating balances, and retrieving merchant profiles.
        Enforces access controls: only admins can add or remove merchants, and only admins or the Core__Liquidity contract
        can update merchant balances.
@dev
- Inherits from AdminAuth and MerchantAuth for role verification.
- Emits platform events to track merchant lifecycle and balance updates.

### Merchant

Struct representing a merchant and metadata about their registration.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct Merchant {
  address merchantId;
  address addedBy;
  uint256 addedAt;
  uint256 balance;
}
```

### MerchantManagement__AlreadyAddedAsMerchant

```solidity
error MerchantManagement__AlreadyAddedAsMerchant(struct MerchantManagement.Merchant merchant)
```

Error thrown when attempting to add an address that is already a merchant.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| merchant | struct MerchantManagement.Merchant | The existing merchant profile for the address. |

### MerchantManagement__AddressIsNotMerchant

```solidity
error MerchantManagement__AddressIsNotMerchant()
```

Error thrown when an address is expected to be a merchant but is not.

### MerchantManagement__ApprovedOperatorsOnly

```solidity
error MerchantManagement__ApprovedOperatorsOnly()
```

Error thrown when an unauthorized operator attempts to update a merchant balance.

### s_platformMerchants

```solidity
struct MerchantManagement.Merchant[] s_platformMerchants
```

List of all merchants currently registered on the platform.

### s_adminAddressToAdditions_merchants

```solidity
mapping(address => struct MerchantManagement.Merchant[]) s_adminAddressToAdditions_merchants
```

Maps an admin address to a list of merchants they have added.

### s_merchantAddressToMerchantProfile

```solidity
mapping(address => struct MerchantManagement.Merchant) s_merchantAddressToMerchantProfile
```

Maps a merchant address to their merchant profile.

### s_liquidityCoreContractAddress

```solidity
address s_liquidityCoreContractAddress
```

Address of the external Core__Liquidity contract authorized to update merchant balances.

_Can only be set or updated by an admin (setter function not shown in this snippet)._

### addMerchant

```solidity
function addMerchant(address _merchantId) public
```

Adds a new merchant to the platform.

_Only callable by an admin (`adminOnly` modifier).
     Reverts with `MerchantManagement__AlreadyAddedAsMerchant` if the merchant already exists._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merchantId | address | The address of the merchant to add. |

### removeMerchant

```solidity
function removeMerchant(address _merchantId) public
```

Removes an existing merchant from the platform.

_Only callable by an admin (`adminOnly` modifier).
     Reverts with `MerchantManagement__AddressIsNotMerchant` if merchant does not exist.
     Removes merchant from storage mappings and arrays._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merchantId | address | The address of the merchant to remove. |

### getMerchantBalance

```solidity
function getMerchantBalance(address _merchantId) public view returns (uint256)
```

Returns the current balance of a merchant.

_Reverts if the address is not registered as a merchant._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merchantId | address | The merchant address to query. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The current balance of the merchant. |

### updateMerchantBalance

```solidity
function updateMerchantBalance(address _merchantId, uint256 _newBalance) public
```

Updates the balance for a merchant.

_Only callable by an admin or the Core__Liquidity contract.
     Reverts with `MerchantManagement__ApprovedOperatorsOnly` if caller is unauthorized.
     Emits an `UpdatedMerchantBalance` event upon success._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merchantId | address | The merchant address whose balance will be updated. |
| _newBalance | uint256 | The new balance value to set. |

### getPlatformMerchants

```solidity
function getPlatformMerchants() public view returns (struct MerchantManagement.Merchant[])
```

Returns all merchants registered on the platform.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct MerchantManagement.Merchant[] | An array of `Merchant` structs representing all merchants. |

### getAdminMerchantRegistrations

```solidity
function getAdminMerchantRegistrations(address _adminAddress) public view returns (struct MerchantManagement.Merchant[])
```

Returns the list of merchants added by a specific admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _adminAddress | address | The admin address whose merchant additions are requested. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct MerchantManagement.Merchant[] | An array of `Merchant` structs representing merchants added by the admin. |

### checkIsMerchant

```solidity
function checkIsMerchant(address _merchantId) public view returns (bool)
```

Checks if an address is a registered merchant.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merchantId | address | The address to check. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if the address is a merchant, false otherwise. |

### getMerchantProfile

```solidity
function getMerchantProfile(address _merchantId) public view returns (struct MerchantManagement.Merchant)
```

Retrieves the merchant profile for a given address.

_Reverts if the address is not a merchant._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merchantId | address | The merchant address to query. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct MerchantManagement.Merchant | The `Merchant` struct containing profile and registration metadata. |

## AdminAuth

Provides an access control mechanism restricting certain functions to addresses designated as administrators.

_This contract implements a simple admin-only modifier that checks whether the caller's address
     is marked as an admin in the `s_isAdmin` mapping. The mapping is `internal`, meaning it is accessible
     within this contract and any contracts that inherit from it.

     Usage:
     - Functions decorated with the `adminOnly` modifier can only be called by addresses that have `true` in `s_isAdmin`.
     - Non-admin callers attempting to execute such functions will trigger a revert using a custom error, which is
       more gas-efficient than revert strings.

     Example:
     ```
     contract MyContract is AdminAuth {
         function restrictedFunction() external adminOnly {
             // Function logic accessible only by admins
         }
     }
     ```

     Security Considerations:
     - Proper initialization of `s_isAdmin` is crucial to avoid lockout or unauthorized access.
     - Access modification functions (e.g., adding/removing admins) should themselves be protected with `adminOnly`._

### AdminAuth__AccessDenied_AdminOnly

```solidity
error AdminAuth__AccessDenied_AdminOnly()
```

Error indicating that the caller does not have administrator privileges.

_Thrown when the `adminOnly` modifier is applied and `msg.sender` is not marked as an admin in `s_isAdmin`._

### s_isAdmin

```solidity
mapping(address => bool) s_isAdmin
```

Tracks whether a given address has administrator privileges.

_Mapping from an Ethereum address to a boolean value:
     - `true`: The address is an administrator.
     - `false`: The address is not an administrator.

     Marked as `internal`, so it is accessible to this contract and any derived contracts._

### adminOnly

```solidity
modifier adminOnly()
```

Restricts function execution to admin addresses only.

_Checks if `msg.sender` is marked as an admin in the `s_isAdmin` mapping.
     If the caller is not an admin, the function reverts with `AdminAuth__AccessDenied_AdminOnly`.

     Functions using this modifier will execute `_` (the function body) only if the caller passes the admin check.

@custom:example
function restrictedAction() external adminOnly {
    // logic that only an admin can perform
}_

## MerchantAuth

Provides an access control mechanism that restricts certain functions to addresses designated as merchants.

_Implements a `merchantsOnly` modifier that checks whether the caller is a registered merchant using
     the `s_isMerchant` mapping.

     Usage:
     - Apply the `merchantsOnly` modifier to functions that should be accessible exclusively by merchant addresses.
     - The mapping `s_isMerchant` must be managed (e.g., adding/removing merchant addresses) by an authorized process.

     Example:
     ```
     contract MyStore is MerchantAuth {
         function addProduct(string calldata productId) external merchantsOnly {
             // Only merchants can add products
         }
     }
     ```

     Security Considerations:
     - Initialization of merchant addresses must be controlled to prevent unauthorized access.
     - Functions that change merchant status should themselves be access-restricted.
     - The contract does not implement merchant registration logic; inheriting contracts must handle it._

### MerchantAuth__MerchantsOnly

```solidity
error MerchantAuth__MerchantsOnly()
```

Error indicating that the caller is not a registered merchant.

_Reverts with this error when a function protected by `merchantsOnly` is called by a non-merchant address._

### s_isMerchant

```solidity
mapping(address => bool) s_isMerchant
```

Tracks whether an address is recognized as a merchant.

_Mapping from an Ethereum address to a boolean value:
     - `true`: Address is a merchant.
     - `false`: Address is not a merchant.

     Marked as `internal`, allowing access within this contract and any inheriting contracts._

### merchantsOnly

```solidity
modifier merchantsOnly()
```

Restricts function execution to merchant addresses only.

_Checks if `msg.sender` is marked as a merchant in the `s_isMerchant` mapping.
     If not, the function reverts with `MerchantAuth__MerchantsOnly`.

     Functions using this modifier will execute `_` (the function body) only if the caller passes the merchant check.

@custom:example
function uploadInventory() external merchantsOnly {
    // logic that only merchants can perform
}_

## OnlyOwnerAuth

Provides an ownership-based access control mechanism, restricting certain functions to the contract owner only.

_This contract implements a `onlyOwner` modifier that checks whether the caller is the contract's owner.
     The owner is stored in the immutable variable `i_owner` and is set once at contract deployment.

     Usage:
     - Apply the `onlyOwner` modifier to functions that should be accessible only by the contract's owner.
     - Since `i_owner` is `immutable`, it must be assigned during deployment in the constructor of this contract
       or a contract that inherits from it.

     Example:
     ```
     contract MyContract is OnlyOwnerAuth {
         constructor() {
             i_owner = msg.sender; // sets the deployer as the owner
         }
         
         function withdrawFunds() external onlyOwner {
             // only the owner can withdraw
         }
     }
     ```

     Security Considerations:
     - There is no built-in function to transfer ownership; if such functionality is required,
       it must be implemented in the inheriting contract.
     - Make sure to initialize `i_owner` correctly to prevent accidental lockout._

### OnlyOwner__AccessDenied_OwnerOnly

```solidity
error OnlyOwner__AccessDenied_OwnerOnly()
```

Error indicating that the caller is not the contract owner.

_Thrown when a function protected by `onlyOwner` is called by an address different from `i_owner`._

### i_owner

```solidity
address i_owner
```

The address of the contract owner.

_Marked as `internal` for access within this contract and inheriting contracts.
     Marked as `immutable`, meaning it can only be assigned once at deployment and cannot be changed afterward._

### onlyOwner

```solidity
modifier onlyOwner()
```

Restricts function execution to the contract owner only.

_Checks if `msg.sender` is equal to `i_owner`.
     If the caller is not the owner, the function reverts with `OnlyOwner__AccessDenied_OwnerOnly`.

     Functions using this modifier will execute `_` (the function body) only if the caller is the owner.

@custom:example
function updateSettings() external onlyOwner {
    // logic accessible only to the owner
}_

## ProductManagementAuth

Provides access control for product management actions by verifying whether a caller is:
        - The contract owner, or
        - An admin, or
        - A merchant, as determined by an external Core Admin Management contract.

_This contract interacts with an externally deployed `Core__AdminManagement` contract to validate
     administrative and merchant privileges. The check is done through the `onlyVerifiedProductManager` modifier.

     Key Features:
     - Restricts product management actions to verified roles only.
     - Owner address is stored in `i_owner` and is immutable after deployment.
     - Admin and merchant roles are checked dynamically through the external `Core__AdminManagement` contract.

     Usage:
     - Use the `onlyVerifiedProductManager` modifier to protect product-related functions.
     - The `_address` parameter should be explicitly passed in from `msg.sender` to ensure clarity and
       to allow for explicit message sender forwarding if needed.

     Example:
     ```
     contract ProductManager is ProductManagementAuth {
         function addProduct(string calldata productId) external onlyVerifiedProductManager(msg.sender) {
             // product addition logic
         }
     }
     ```

     Security Considerations:
     - Ensure `s_adminManagementCoreContractAddress` is set to a trusted and verified deployment of `Core__AdminManagement`.
     - Changes to `s_adminManagementCoreContractAddress` should themselves be access-controlled.
     - Passing `_address` instead of directly reading `msg.sender` adds explicitness but still requires
       validation of inputs._

### ProductManagementAuth__AccessDenied_VerifiedAdminsOnly

```solidity
error ProductManagementAuth__AccessDenied_VerifiedAdminsOnly()
```

Error indicating that the caller is not a verified product manager.

_This error is triggered when none of the following conditions are met:
     - Caller is the owner (`i_owner`), OR
     - Caller is an admin as verified by the `Core__AdminManagement` contract, OR
     - Caller is a merchant as verified by the `Core__AdminManagement` contract._

### i_owner

```solidity
address i_owner
```

The address of the contract owner.

_Immutable and set once during deployment; cannot be modified afterward.
     The owner is automatically granted full product management privileges._

### s_adminManagementCoreContractAddress

```solidity
address s_adminManagementCoreContractAddress
```

The address of the external `Core__AdminManagement` contract.

_This contract is used to dynamically check admin and merchant status.
     Must be a valid deployment of the `Core__AdminManagement` interface._

### onlyVerifiedProductManager

```solidity
modifier onlyVerifiedProductManager(address _address)
```

Restricts access to verified product managers (owner, admin, or merchant).

_This modifier performs three checks:
     1. Whether `_address` matches the immutable `i_owner`.
     2. Whether `_address` is an admin according to `Core__AdminManagement.checkIsAdmin`.
     3. Whether `_address` is a merchant according to `Core__AdminManagement.checkIsMerchant`.

     The `_address` argument should be passed explicitly as `msg.sender` from the calling function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _address | address | The address being verified for product management privileges (typically `msg.sender`). @custom:example function updateProduct(string calldata productId) external onlyVerifiedProductManager(msg.sender) {     // logic to update product details } |

## ProductManagement

Manages products on the platform, including adding, updating, deleting, and retrieving products.

_Inherits from:
     - `ProductManagementAuth`: Provides role-based access control for verified product managers.
     - `PlatformEvents`: Enables product-related event emission using standardized enums.

     Key Functionalities:
     - Add new products linked to merchants.
     - Update product metadata and images.
     - Delete products from platform and all associated lists.
     - Retrieve product details by ID, by admin, or by merchant.
     - Maintain synchronized state across multiple mappings and arrays.

     Security Considerations:
     - Product management actions require verification through `onlyVerifiedProductManager`.
     - Merchant validity is checked via the external `Core__AdminManagement` contract.
     - All product IDs are unique; duplicates are prevented by `s_productIdToBoolean`._

### Product

Represents a product's core information.

_Includes metadata, ownership, timestamps, and merchant association._

```solidity
struct Product {
  string id;
  address addedBy;
  uint256 addedAt;
  string productImageCID;
  string productMetadataCID;
  uint256 updatedAt;
  address merchantId;
}
```

### ProductManagement__ProductWithProvidedIdAlreadyExists

```solidity
error ProductManagement__ProductWithProvidedIdAlreadyExists(struct ProductManagement.Product product)
```

Error thrown when trying to add a product with an already existing ID.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| product | struct ProductManagement.Product | The existing product that has the duplicate ID. |

### ProductManagement__ProductWithProvidedIdDoesNotExist

```solidity
error ProductManagement__ProductWithProvidedIdDoesNotExist()
```

Error thrown when attempting to fetch, update, or delete a product that does not exist.

### ProductManagement__AddressIsNotAnAdmin

```solidity
error ProductManagement__AddressIsNotAnAdmin()
```

Error thrown when a provided address is not recognized as an admin.

### ProductManagement__MerchantDoesNotExist

```solidity
error ProductManagement__MerchantDoesNotExist()
```

Error thrown when a provided merchant address does not exist in the admin management core.

### addProduct

```solidity
function addProduct(string _productId, string _productImageCID, string _productMetadataCID, address _merchantId) public
```

Adds a new product to the platform.

_Ensures:
     - Product ID is unique.
     - Merchant exists in `Core__AdminManagement`.
     - Caller is a verified product manager.

     Updates:
     - Platform-wide products list.
     - Admin-specific products list.
     - Merchant-specific products list.
     - ID-to-product mapping and existence tracker.

     Emits:
     - `ProductChore` event with `ProductChoreActivityType.AddedNewProduct`._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _productId | string | Unique ID for the product. |
| _productImageCID | string | IPFS CID for the product image. |
| _productMetadataCID | string | IPFS CID for the product metadata. |
| _merchantId | address | Address of the merchant associated with this product. |

### deleteProduct

```solidity
function deleteProduct(string _productId) public
```

Deletes an existing product from the platform.

_Ensures:
     - Product ID exists.
     - Caller is a verified product manager.

     Removes the product from:
     - Platform-wide list.
     - Admin-specific list.
     - Merchant-specific list.
     - Mappings.

     Emits:
     - `ProductChore` event with `ProductChoreActivityType.DeletedProduct`._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _productId | string | Unique ID of the product to delete. |

### updateProduct

```solidity
function updateProduct(string _productId, string _productImageCID, string _productMetadataCID) public
```

Updates product metadata and image.

_Ensures:
     - Product exists.
     - Caller is a verified product manager.

     Updates:
     - Platform-wide list.
     - Admin-specific list.
     - Merchant-specific list.
     - ID-to-product mapping.

     Emits:
     - `ProductChore` event with `ProductChoreActivityType.UpdatedProduct`._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _productId | string | Unique ID of the product to update. |
| _productImageCID | string | New IPFS CID for the product image. |
| _productMetadataCID | string | New IPFS CID for the product metadata. |

### getProduct

```solidity
function getProduct(string _productId) public view returns (struct ProductManagement.Product)
```

Retrieves a single product by ID.

_Reverts if the product does not exist._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _productId | string | Unique ID of the product to retrieve. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ProductManagement.Product | Product struct containing all product details. |

### getProductsAddedByAdmin

```solidity
function getProductsAddedByAdmin(address _adminAddress) public view returns (struct ProductManagement.Product[])
```

Retrieves all products added by a specific admin.

_Reverts if the provided address is not an admin in `Core__AdminManagement`._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _adminAddress | address | Address of the admin whose products are being fetched. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ProductManagement.Product[] | Array of Product structs. |

### getMerchantProducts

```solidity
function getMerchantProducts(address _merchantId) public view returns (struct ProductManagement.Product[])
```

Retrieves all products associated with a specific merchant.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merchantId | address | Address of the merchant. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ProductManagement.Product[] | Array of Product structs belonging to the merchant. |

### getPlatformProducts

```solidity
function getPlatformProducts() public view returns (struct ProductManagement.Product[])
```

Retrieves all products on the platform.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ProductManagement.Product[] | Array of Product structs representing all platform products. |

## PlatformEvents

Defines standardized events and enums used across the platform to emit consistent logs
        for administrative, merchant, product, and external contract update activities.

_This contract acts as a centralized event interface to enable easier tracking and monitoring
     of platform activities by off-chain systems and for auditability._

### Logs

```solidity
event Logs(string message, uint256 timestamp, string contractName)
```

General log event for emitting informational messages with timestamps and contract context.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | Human-readable message describing the log. |
| timestamp | uint256 | Unix timestamp when the event was emitted. |
| contractName | string | The name of the contract emitting the event (indexed for efficient filtering). |

### AddedNewAdmin

```solidity
event AddedNewAdmin(string message, uint256 timestamp, string contractName, address addedAdminAddress, address addedBy)
```

Emitted when a new admin is added to the platform.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | Human-readable message describing the event. |
| timestamp | uint256 | Unix timestamp when the admin was added. |
| contractName | string | The contract name emitting this event (indexed). |
| addedAdminAddress | address | Address of the admin account that was added (indexed). |
| addedBy | address | Address of the account (admin/owner) who performed the addition (indexed). |

### RemovedAdmin

```solidity
event RemovedAdmin(string message, uint256 timestamp, string contractName, address removedAdminAddress, address removedBy)
```

Emitted when an admin is removed from the platform.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | Human-readable message describing the event. |
| timestamp | uint256 | Unix timestamp when the admin was removed. |
| contractName | string | The contract name emitting this event (indexed). |
| removedAdminAddress | address | Address of the admin account that was removed (indexed). |
| removedBy | address | Address of the account (admin/owner) who performed the removal (indexed). |

### AddedNewMerchant

```solidity
event AddedNewMerchant(string message, uint256 timestamp, string contractName, address addedMerchantId, address addedBy)
```

Emitted when a new merchant is added to the platform.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | Human-readable message describing the event. |
| timestamp | uint256 | Unix timestamp when the merchant was added. |
| contractName | string | The contract name emitting this event (indexed). |
| addedMerchantId | address | Address of the merchant that was added (indexed). |
| addedBy | address | Address of the account who performed the addition (indexed). |

### UpdatedMerchantBalance

```solidity
event UpdatedMerchantBalance(string message, uint256 timestamp, string contractName, address updatedBy, address merchantId, uint256 Amount)
```

Emitted when a merchant's balance is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | Human-readable message describing the update. |
| timestamp | uint256 | Unix timestamp when the balance was updated. |
| contractName | string | The contract name emitting this event. |
| updatedBy | address | Address of the account performing the update (indexed). |
| merchantId | address | Address of the merchant whose balance was updated (indexed). |
| Amount | uint256 | The amount by which the balance was updated (indexed). |

### RemovedMerchant

```solidity
event RemovedMerchant(string message, uint256 timestamp, string contractName, address removedMerchantId, address removedBy)
```

Emitted when a merchant is removed from the platform.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | Human-readable message describing the event. |
| timestamp | uint256 | Unix timestamp when the merchant was removed. |
| contractName | string | The contract name emitting this event (indexed). |
| removedMerchantId | address | Address of the merchant account that was removed (indexed). |
| removedBy | address | Address of the account who performed the removal (indexed). |

### ProductChoreActivityType

Enum representing the types of product-related activities that can be emitted in events.

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

Emitted when a product-related action occurs (addition, update, or deletion).

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | Human-readable message describing the product activity. |
| timestamp | uint256 | Unix timestamp when the product activity happened. |
| activity | enum PlatformEvents.ProductChoreActivityType | Enum indicating the type of product activity (indexed for filtering). |
| contractName | string | The contract name emitting this event. |
| productId | string | Unique identifier of the product affected (indexed). |
| addedBy | address | Address of the admin/merchant who performed the action (indexed). |

### ExternalContractAddressUpdated

```solidity
event ExternalContractAddressUpdated(string message, uint256 timestamp, string parentContractName, address parentContractAddress, string addressUpdatedFor_ContractName, address newAddressAdded, address updatedBy)
```

Emitted when an external contract address reference is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| message | string | Human-readable message describing the update. |
| timestamp | uint256 | Unix timestamp when the update occurred. |
| parentContractName | string | The name of the contract updating the address. |
| parentContractAddress | address | The address of the contract updating the reference (indexed). |
| addressUpdatedFor_ContractName | string | The name or label of the contract/address being updated. |
| newAddressAdded | address | The address of the contract/address being updated (indexed). |
| updatedBy | address | The address of the account that triggered the update (indexed). |

## Core__ProductManagement

Core-level product management contract that integrates product logic, admin authentication,
        and platform-wide event emission. Acts as the orchestration layer for product-related operations
        while enforcing access control via `AdminAuth` and `ProductManagementAuth` (inherited indirectly).

_This contract:
     - Inherits from `PlatformEvents` for emitting standardized events.
     - Inherits from `ProductManagement` for product domain logic and `ProductManagementAuth`'s access control storage.
     - Inherits from `AdminAuth` for admin verification.
     - Stores the `i_owner` (immutable owner) and the address of the `Core__AdminManagement` contract._

### constructor

```solidity
constructor(address _adminManagementCoreContractAddress) public
```

Deploys the Core__ProductManagement contract and initializes key state variables.

_- Sets the immutable owner `i_owner` (inherited from ProductManagementAuth) to `msg.sender`.
- Stores the reference to the `Core__AdminManagement` contract for admin/merchant verification.
- Emits a `Logs` event to record successful deployment._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _adminManagementCoreContractAddress | address | The address of the deployed `Core__AdminManagement` contract        used for verifying admins and merchants. |

### updateAdminManagementCoreContractAddress

```solidity
function updateAdminManagementCoreContractAddress(address _contractAddress) public
```

Updates the address of the `Core__AdminManagement` contract.
@dev
- This function can only be called by the contract owner (`i_owner`) or a verified admin
  from the current `Core__AdminManagement` contract.
- The updated address is critical for all future verification of admin and merchant roles,
  ensuring interactions refer to the correct external contract.
- Emits an `ExternalContractAddressUpdated` event recording the update details.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _contractAddress | address | The new address of the deployed `Core__AdminManagement` contract. |

### getAdminManagementCoreContractAddress

```solidity
function getAdminManagementCoreContractAddress() public view returns (address)
```

Retrieves the address of the `Core__AdminManagement` contract in use.

_This address is used for all admin/merchant verification checks._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The address of the `Core__AdminManagement` contract. |

### getContractName

```solidity
function getContractName() public pure returns (string)
```

Returns the human-readable name of this contract instance.

_Useful for external systems to verify which contract they are interacting with._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | The contract name as a string. |

### getContractOwner

```solidity
function getContractOwner() public view returns (address)
```

Retrieves the owner address of this contract.

_Owner is immutable and set at deployment in the constructor._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The address of the contract owner. |

### ping

```solidity
function ping() external view returns (string name, address contractAddress)
```

External verification method to confirm contract identity and address.

_Returns both the contract name and its own deployed address.
     Intended to be called by external contracts before processing further logic._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| name | string | The contract name. |
| contractAddress | address | The deployed address of this contract. |

## Core

This contract serves as the main entry point of the platform, inheriting admin and access control features

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

## Auth__AccessDenied_AdminOnly

```solidity
error Auth__AccessDenied_AdminOnly()
```

Error thrown when a non-admin attempts to access a restricted function.

## Auth

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

