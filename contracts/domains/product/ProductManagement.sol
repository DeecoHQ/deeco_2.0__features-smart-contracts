// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../auth/Auth.sol";
import "../../lib/PlatformEvents.sol";

/// @title Product Management Contract
/// @notice Handles adding, updating, deleting, and retrieving product information within the platform.
/// @dev Inherits from Auth for admin-only access and PlatformEvents for event emission.
contract ProductManagement is Auth, PlatformEvents {
    /// @notice Structure to store product details.
    /// @param id Unique identifier for the product.
    /// @param addedBy Address of the admin who added the product.
    /// @param addedAt Timestamp when the product was added.
    /// @param productImageCID CID (Content Identifier) for the product image stored on IPFS.
    /// @param productMetadataCID CID for product metadata stored on IPFS.
    /// @param updatedAt Timestamp of the last update to the product.
    struct Product {
        string id;
        address addedBy;
        uint256 addedAt;
        string productImageCID;
        string productMetadataCID;
        uint256 updatedAt;
    }

    /// @notice Error indicating that a product with the given ID already exists.
    /// @param product The full existing product data.
    error ProductManagement__ProductAlreadyExistsWithProvidedId(Product product);

    /// @notice Error indicating that no product with the given ID exists.
    error ProductManagement__ProductWithProvidedIdDoesNotExist();

    /// @notice Error indicating that the provided address is not an admin.
    error ProductManagement__AddressIsNotAnAdmin();

    /// @notice Array of all products available on the platform.
    Product[] private s_platformProducts;

    /// @notice Mapping from admin address to the products they have added.
    mapping(address => Product[]) private s_adminAddressToProductsAdded;

    // will be passing the full currently existing product as error param on error: ProductAlreadyExistsWithProvidedId - see above
    /// @notice Mapping from product ID to product details.
    mapping(string => Product) private s_productIdToProduct;

    /// @notice Mapping from product ID to existence status.
    mapping(string => bool) private s_productIdToBoolean;


    // adminOnly(modifier) - from ./auth/Auth.sol
    /// @notice Adds a new product to the platform.
    /// @dev Only callable by an admin. Emits a ProductChore event on success.
    /// @param _productId Unique identifier for the new product.
    /// @param _productImageCID CID for the product image on IPFS.
    /// @param _productMetadataCID CID for the product metadata on IPFS.
    function addProduct(string memory _productId, string memory _productImageCID, string memory _productMetadataCID) public adminOnly {
        if(s_productIdToBoolean[_productId]) {
            Product memory existingProduct = s_productIdToProduct[_productId];

            revert ProductManagement__ProductAlreadyExistsWithProvidedId(existingProduct);
        }

        Product memory newProduct = Product(
            {
                id: _productId,
                addedBy: msg.sender,
                addedAt: block.timestamp,
                productImageCID: _productImageCID,
                productMetadataCID: _productMetadataCID,
                updatedAt: block.timestamp
            }
        );

        s_platformProducts.push(newProduct);

        Product[] storage productsAddedByAdmin = s_adminAddressToProductsAdded[msg.sender];
        productsAddedByAdmin.push(newProduct);

        s_adminAddressToProductsAdded[msg.sender] = productsAddedByAdmin;

        s_productIdToProduct[_productId] = newProduct;

        s_productIdToBoolean[_productId] = true;

        // ProductChoreActivityType(enum) - from PlatformEvents.sol
        emit ProductChore("new product added successfully", block.timestamp, ProductChoreActivityType.AddedNewProduct, "ProductManagement", _productId, msg.sender);
    }

    // adminOnly(modifier) - from ./auth/Auth.sol
    /// @notice Deletes a product from the platform.
    /// @dev Only callable by an admin. Emits a ProductChore event on success.
    /// @param _productId Unique identifier of the product to delete.
    function deleteProduct(string memory _productId) public adminOnly{
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

        // resets all the values of that product in the mapping to their empty defaults;
        delete s_productIdToProduct[_productId];

        s_productIdToBoolean[_productId] = false;

        // ProductChoreActivitType(enum) - from PlatformEvents.sol
        emit ProductChore("product removed successfully", block.timestamp, ProductChoreActivityType.DeletedProduct, "ProductManagement", _productId, msg.sender);
    }

    // adminOnly(modifier) - from ./auth/Auth.sol
    /// @notice Updates details of an existing product.
    /// @dev Only callable by an admin. Emits a ProductChore event on success.
    /// @param _productId Unique identifier of the product to update.
    /// @param _productImageCID New CID for the product image on IPFS.
    /// @param _productMetadataCID New CID for the product metadata on IPFS.
    function updateProduct(string memory _productId, string memory _productImageCID, string memory _productMetadataCID) public adminOnly{
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
                updatedAt: block.timestamp
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

        s_productIdToProduct[_productId] = updatedProduct;

        s_productIdToBoolean[_productId] = true; // seems unnecessary - leave though

        
        // ProductChoreActivitType(enum) - from PlatformEvents.sol
        emit ProductChore("product updated successfully", block.timestamp, ProductChoreActivityType.UpdatedProduct, "ProductManagement", _productId, msg.sender);
    }

    /// @notice Retrieves details of a product by its ID.
    /// @param _productId Unique identifier of the product to retrieve.
    /// @return The Product struct containing product details.
    function getProduct(string memory _productId) public view returns (Product memory) {
        if(!s_productIdToBoolean[_productId]) {
            revert ProductManagement__ProductWithProvidedIdDoesNotExist();
        }

        Product storage product = s_productIdToProduct[_productId];

        return product;
    }

    /// @notice Retrieves all products added by a specific admin.
    /// @param _adminAddress Address of the admin.
    /// @return Array of Product structs added by the given admin.
    function getProductsAddedByAdmin(address _adminAddress) public view returns(Product[] memory) {
        if(!s_isAdmin[_adminAddress]) {
            revert ProductManagement__AddressIsNotAnAdmin();
        }

        Product[] memory adminProducts = s_adminAddressToProductsAdded[_adminAddress];

        return adminProducts;
    } 

    /// @notice Retrieves all products on the platform.
    /// @return Array of all Product structs in the platform.
    function getPlatformProducts() public view returns(Product[] memory) {
        return s_platformProducts;
    }
}
