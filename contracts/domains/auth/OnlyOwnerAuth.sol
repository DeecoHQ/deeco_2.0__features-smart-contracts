// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title OnlyOwnerAuth
 * @notice Provides an ownership-based access control mechanism, restricting certain functions to the contract owner only.
 * @dev This contract implements a `onlyOwner` modifier that checks whether the caller is the contract's owner.
 *      The owner is stored in the immutable variable `i_owner` and is set once at contract deployment.
 * 
 *      Usage:
 *      - Apply the `onlyOwner` modifier to functions that should be accessible only by the contract's owner.
 *      - Since `i_owner` is `immutable`, it must be assigned during deployment in the constructor of this contract
 *        or a contract that inherits from it.
 * 
 *      Example:
 *      ```
 *      contract MyContract is OnlyOwnerAuth {
 *          constructor() {
 *              i_owner = msg.sender; // sets the deployer as the owner
 *          }
 *          
 *          function withdrawFunds() external onlyOwner {
 *              // only the owner can withdraw
 *          }
 *      }
 *      ```
 * 
 *      Security Considerations:
 *      - There is no built-in function to transfer ownership; if such functionality is required,
 *        it must be implemented in the inheriting contract.
 *      - Make sure to initialize `i_owner` correctly to prevent accidental lockout.
 */
contract OnlyOwnerAuth {
    
    /**
     * @notice Error indicating that the caller is not the contract owner.
     * @dev Thrown when a function protected by `onlyOwner` is called by an address different from `i_owner`.
     */
    error OnlyOwner__AccessDenied_OwnerOnly();

    /**
     * @notice The address of the contract owner.
     * @dev Marked as `internal` for access within this contract and inheriting contracts.
     *      Marked as `immutable`, meaning it can only be assigned once at deployment and cannot be changed afterward.
     */
    address internal immutable i_owner;

    /**
     * @notice Restricts function execution to the contract owner only.
     * @dev Checks if `msg.sender` is equal to `i_owner`.
     *      If the caller is not the owner, the function reverts with `OnlyOwner__AccessDenied_OwnerOnly`.
     * 
     *      Functions using this modifier will execute `_` (the function body) only if the caller is the owner.
     * 
     * @custom:example
     * function updateSettings() external onlyOwner {
     *     // logic accessible only to the owner
     * }
     */
    modifier onlyOwner() { 
        if(msg.sender != i_owner) {
            revert OnlyOwner__AccessDenied_OwnerOnly();
        }

        _;
    }
}
