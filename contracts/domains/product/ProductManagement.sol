// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../../lib/PlatformEvents.sol";
import "../auth/OnlyOwnerAuth.sol";
import "../auth/ProductManagementAuth.sol";

/**
 * @title ProductManagement
 * @notice Manages products on the platform, including adding, updating, deleting, and retrieving products.
 * @dev Inherits from:
 *      - `ProductManagementAuth`: Provides role-based access control for verified product managers.
 *      - `PlatformEvents`: Enables product-related event emission using standardized enums.
 * 
 *      Key Functionalities:
 *      - Add new products linked to merchants.
 *      - Update product metadata and images.
 *      - Delete products from platform and all associated lists.
 *      - Retrieve product details by ID, by admin, or by merchant.
 *      - Maintain synchronized state across multiple mappings and arrays.
 * 
 *      Security Considerations:
 *      - Product management actions require verification through `onlyVerifiedProductManager`.
 *      - Merchant validity is checked via the external `Core__AdminManagement` contract.
 *      - All product IDs are unique; duplicates are prevented by `s_productIdToBoolean`.
 */
contract ProductManagement is ProductManagementAuth, PlatformEvents {

    /**
     * @notice Represents a product's core information.
     * @dev Includes metadata, ownership, timestamps, and merchant association.
     */
    struct Product {
        string id;                    ///< Unique product identifier.
        address addedBy;               ///< Address of the admin or merchant who added the product.
        uint256 addedAt;               ///< Timestamp when the product was first added.
        string productImageCID;        ///< IPFS CID for the product's image.
        string productMetadataCID;     ///< IPFS CID for additional metadata (JSON, etc.).
        uint256 updatedAt;             ///< Timestamp when the product was last updated.
        address merchantId;            ///< Merchant address associated with the product.
    }

    /**
     * @notice Error thrown when trying to add a product with an already existing ID.
     * @param product The existing product that has the duplicate ID.
     */
    error ProductManagement__ProductWithProvidedIdAlreadyExists(Product product);

    /**
     * @notice Error thrown when attempting to fetch, update, or delete a product that does not exist.
     */
    error ProductManagement__ProductWithProvidedIdDoesNotExist();

    /**
     * @notice Error thrown when a provided address is not recognized as an admin.
     */
    error ProductManagement__AddressIsNotAnAdmin();

    /**
     * @notice Error thrown when a provided merchant address does not exist in the admin management core.
     */
    error ProductManagement__MerchantDoesNotExist();

    /**
     * @dev Stores all products on the platform.
     */
    Product[] private s_platformProducts;

    /**
     * @dev Maps admin addresses to the products they have added.
     */
    mapping(address => Product[]) private s_adminAddressToProductsAdded;

    /**
     * @dev Maps a product ID to its corresponding product details.
     */
    mapping(string => Product) private s_productIdToProduct;

    /**
     * @dev Tracks whether a product ID exists in the system.
     */
    mapping(string => bool) private s_productIdToBoolean;

    /**
     * @dev Maps merchant addresses to their associated products.
     */
    mapping(address => Product[]) private s_merchantToProducts;

    /**
     * @notice Constant string holding the current contract name.
     * @dev Used in event emissions to ensure consistent naming.
     */
    string private constant CURRENT_CONTRACT_NAME = "ProductManagement"; // keep name in one variable to avoid mispelling it at any point

    /**
     * @notice Adds a new product to the platform.
     * @dev Ensures:
     *      - Product ID is unique.
     *      - Merchant exists in `Core__AdminManagement`.
     *      - Caller is a verified product manager.
     * 
     *      Updates:
     *      - Platform-wide products list.
     *      - Admin-specific products list.
     *      - Merchant-specific products list.
     *      - ID-to-product mapping and existence tracker.
     * 
     *      Emits:
     *      - `ProductChore` event with `ProductChoreActivityType.AddedNewProduct`.
     * 
     * @param _productId Unique ID for the product.
     * @param _productImageCID IPFS CID for the product image.
     * @param _productMetadataCID IPFS CID for the product metadata.
     * @param _merchantId Address of the merchant associated with this product.
     */
    function addProduct(
        string memory _productId,
        string memory _productImageCID,
        string memory _productMetadataCID,
        address _merchantId
    )
        public
        onlyVerifiedProductManager(msg.sender)
    {
        if(s_productIdToBoolean[_productId]) {
            Product memory existingProduct = s_productIdToProduct[_productId];
            revert ProductManagement__ProductWithProvidedIdAlreadyExists(existingProduct);
        }

        // Core__AdminManagement(interface) - from the externally deployed 'Core__AdminManagement' contract
        if(!Core__AdminManagement(s_adminManagementCoreContractAddress).checkIsMerchant(_merchantId)) {
            revert ProductManagement__MerchantDoesNotExist();
        }

        Product memory newProduct = Product(
            {
                id: _productId,
                addedBy: msg.sender,
                addedAt: block.timestamp,
                productImageCID: _productImageCID,
                productMetadataCID: _productMetadataCID,
                updatedAt: block.timestamp,
                merchantId: _merchantId
            }
        );

        s_platformProducts.push(newProduct);

        Product[] storage productsAddedByAdmin = s_adminAddressToProductsAdded[msg.sender];
        productsAddedByAdmin.push(newProduct);
        s_adminAddressToProductsAdded[msg.sender] = productsAddedByAdmin;

        s_productIdToProduct[_productId] = newProduct;
        s_productIdToBoolean[_productId] = true;

        Product[] storage merchantProducts = s_merchantToProducts[_merchantId];
        merchantProducts.push(newProduct);
        s_merchantToProducts[_merchantId] = merchantProducts;

        // ProductChoreActivityType(enum) - from PlatformEvents.sol
        emit ProductChore(
            "new product added successfully",
            block.timestamp,
            ProductChoreActivityType.AddedNewProduct,
            CURRENT_CONTRACT_NAME,
            _productId,
            msg.sender
        );
    }

    /**
     * @notice Deletes an existing product from the platform.
     * @dev Ensures:
     *      - Product ID exists.
     *      - Caller is a verified product manager.
     * 
     *      Removes the product from:
     *      - Platform-wide list.
     *      - Admin-specific list.
     *      - Merchant-specific list.
     *      - Mappings.
     * 
     *      Emits:
     *      - `ProductChore` event with `ProductChoreActivityType.DeletedProduct`.
     * 
     * @param _productId Unique ID of the product to delete.
     */
    function deleteProduct(string memory _productId) public onlyVerifiedProductManager(msg.sender) {
        if(!s_productIdToBoolean[_productId]) {
            revert ProductManagement__ProductWithProvidedIdDoesNotExist();
        }

        // remove from platform products
        for(uint256 i=0; i < s_platformProducts.length; i++) {
            if (keccak256(bytes(s_platformProducts[i].id)) == keccak256(bytes(_productId))) {
                s_platformProducts[i] = s_platformProducts[s_platformProducts.length - 1];
                s_platformProducts.pop();
                break;
            }
        }

        Product memory productToDelete = s_productIdToProduct[_productId];

        // remove from list of products added by the admin
        for(uint256 i=0; i < s_adminAddressToProductsAdded[productToDelete.addedBy].length; i++) {
            if (keccak256(bytes(s_adminAddressToProductsAdded[productToDelete.addedBy][i].id)) == keccak256(bytes(_productId))) {
                s_adminAddressToProductsAdded[productToDelete.addedBy][i] = s_adminAddressToProductsAdded[productToDelete.addedBy][s_adminAddressToProductsAdded[productToDelete.addedBy].length - 1];
                s_adminAddressToProductsAdded[productToDelete.addedBy].pop();
                break;
            }
        }

         // remove from list of products for merchant
        for(uint256 i=0; i < s_merchantToProducts[productToDelete.merchantId].length; i++) {
            if (keccak256(bytes(s_merchantToProducts[productToDelete.merchantId][i].id)) == keccak256(bytes(_productId))) {
                s_merchantToProducts[productToDelete.merchantId][i] = s_merchantToProducts[productToDelete.merchantId][s_merchantToProducts[productToDelete.merchantId].length - 1];
                s_merchantToProducts[productToDelete.merchantId].pop();
                break;
            }
        }

        // resets all the values of that product in the mapping to their empty defaults;
        delete s_productIdToProduct[_productId];
        s_productIdToBoolean[_productId] = false;

        // ProductChoreActivitType(enum) - from PlatformEvents.sol
        emit ProductChore(
            "product removed successfully",
            block.timestamp,
            ProductChoreActivityType.DeletedProduct,
            CURRENT_CONTRACT_NAME,
            _productId,
            msg.sender
        );
    }

    /**
     * @notice Updates product metadata and image.
     * @dev Ensures:
     *      - Product exists.
     *      - Caller is a verified product manager.
     * 
     *      Updates:
     *      - Platform-wide list.
     *      - Admin-specific list.
     *      - Merchant-specific list.
     *      - ID-to-product mapping.
     * 
     *      Emits:
     *      - `ProductChore` event with `ProductChoreActivityType.UpdatedProduct`.
     * 
     * @param _productId Unique ID of the product to update.
     * @param _productImageCID New IPFS CID for the product image.
     * @param _productMetadataCID New IPFS CID for the product metadata.
     */
    function updateProduct(
        string memory _productId,
        string memory _productImageCID,
        string memory _productMetadataCID
    )
        public
        onlyVerifiedProductManager(msg.sender)
    {
        if(!s_productIdToBoolean[_productId]) {
            revert ProductManagement__ProductWithProvidedIdDoesNotExist();
        }

        Product storage productToUpdate = s_productIdToProduct[_productId];

        Product memory updatedProduct = Product(
            {
                id: _productId,
                addedBy: productToUpdate.addedBy,
                addedAt: productToUpdate.addedAt,
                productImageCID: _productImageCID,
                productMetadataCID: _productMetadataCID,
                updatedAt: block.timestamp,
                merchantId:  productToUpdate.merchantId
            }
        );

        // update in platform products
        for(uint256 i=0; i < s_platformProducts.length; i++) {
            if (keccak256(bytes(s_platformProducts[i].id)) == keccak256(bytes(_productId))) {
                s_platformProducts[i] = updatedProduct;
                break;
            }
        }

        // update in list of products added by an admin
        for(uint256 i=0; i < s_adminAddressToProductsAdded[msg.sender].length; i++) {
            if (keccak256(bytes(s_adminAddressToProductsAdded[msg.sender][i].id)) == keccak256(bytes(_productId))) {
                s_adminAddressToProductsAdded[msg.sender][i] = updatedProduct;
                break;
            }
        }

        // update in list of products added by a merchant
        for(uint256 i=0; i < s_merchantToProducts[productToUpdate.merchantId].length; i++) {
            if (keccak256(bytes(s_merchantToProducts[productToUpdate.merchantId][i].id)) == keccak256(bytes(_productId))) {
                s_merchantToProducts[productToUpdate.merchantId][i] = updatedProduct;
                break;
            }
        }

        s_productIdToProduct[_productId] = updatedProduct;
        s_productIdToBoolean[_productId] = true; // seems unnecessary - leave though

        // ProductChoreActivitType(enum) - from PlatformEvents.sol
        emit ProductChore(
            "product updated successfully",
            block.timestamp,
            ProductChoreActivityType.UpdatedProduct,
            CURRENT_CONTRACT_NAME,
            _productId,
            msg.sender
        );
    }

    /**
     * @notice Retrieves a single product by ID.
     * @dev Reverts if the product does not exist.
     * @param _productId Unique ID of the product to retrieve.
     * @return Product struct containing all product details.
     */
    function getProduct(string memory _productId) public view returns (Product memory) {
        if(!s_productIdToBoolean[_productId]) {
            revert ProductManagement__ProductWithProvidedIdDoesNotExist();
        }
        return s_productIdToProduct[_productId];
    }

    /**
     * @notice Retrieves all products added by a specific admin.
     * @dev Reverts if the provided address is not an admin in `Core__AdminManagement`.
     * @param _adminAddress Address of the admin whose products are being fetched.
     * @return Array of Product structs.
     */
    function getProductsAddedByAdmin(address _adminAddress) public view returns(Product[] memory) {
        // Core__AdminManagement(interface) - from ProductManagementAuth.sol
        if(!Core__AdminManagement(s_adminManagementCoreContractAddress).checkIsAdmin(_adminAddress)) {
            revert ProductManagement__AddressIsNotAnAdmin();
        }
        return s_adminAddressToProductsAdded[_adminAddress];
    } 

    /**
     * @notice Retrieves all products associated with a specific merchant.
     * @param _merchantId Address of the merchant.
     * @return Array of Product structs belonging to the merchant.
     */
    function getMerchantProducts(address _merchantId) public view returns(Product[] memory){
        return s_merchantToProducts[_merchantId];
    }

    /**
     * @notice Retrieves all products on the platform.
     * @return Array of Product structs representing all platform products.
     */
    function getPlatformProducts() public view returns(Product[] memory) {
        return s_platformProducts;
    }
}
