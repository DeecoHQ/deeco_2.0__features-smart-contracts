// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../../lib/PlatformEvents.sol";
import "../auth/OnlyOwnerAuth.sol";
import "../auth/ProductManagementAuth.sol";
import "../../interfaces/IAdminManagement__Base.sol";

contract ProductManagement is ProductManagementAuth, PlatformEvents {

    struct Product {
        string id;                    ///< Unique product identifier.
        address addedBy;               ///< Address of the admin or merchant who added the product.
        uint256 addedAt;               ///< Timestamp when the product was first added.
        string productImageCID;        ///< IPFS CID for the product's image.
        string productMetadataCID;     ///< IPFS CID for additional metadata (JSON, etc.).
        uint256 updatedAt;             ///< Timestamp when the product was last updated.
        address merchantId;            ///< Merchant address associated with the product.
    }

    error ProductManagement__ProductWithProvidedIdAlreadyExists(Product product);

    error ProductManagement__ProductWithProvidedIdDoesNotExist();

    error ProductManagement__AddressIsNotAnAdmin();

    error ProductManagement__MerchantDoesNotExist();

    Product[] private s_platformProducts;

    mapping(address => Product[]) private s_adminAddressToProductsAdded;

    mapping(string => Product) private s_productIdToProduct;

    mapping(string => bool) private s_productIdToBoolean;

    mapping(address => Product[]) private s_merchantToProducts;

    string private constant CURRENT_CONTRACT_NAME = "ProductManagement"; // keep name in one variable to avoid mispelling it at any point

    uint256 s_ledgerIdTracker = 0;

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
        if(!s_merchantManagementContract__Base.checkIsMerchant(_merchantId)) {
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

    function getProduct(string memory _productId) public view returns (Product memory) {
        if(!s_productIdToBoolean[_productId]) {
            revert ProductManagement__ProductWithProvidedIdDoesNotExist();
        }
        return s_productIdToProduct[_productId];
    }

    function getProductsAddedByAdmin(address _adminAddress) public view returns(Product[] memory) {
        // Core__AdminManagement(interface) - from ProductManagementAuth.sol
        if(!s_adminManagementContract__Base.checkIsAdmin(_adminAddress)) {
            revert ProductManagement__AddressIsNotAnAdmin();
        }
        return s_adminAddressToProductsAdded[_adminAddress];
    } 

    function getMerchantProducts(address _merchantId) public view returns(Product[] memory){
        return s_merchantToProducts[_merchantId];
    }

    function getPlatformProducts() public view returns(Product[] memory) {
        return s_platformProducts;
    }
}
