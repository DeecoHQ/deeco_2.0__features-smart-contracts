// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title AdminAuth
 * @notice Provides an access control mechanism restricting certain functions to addresses designated as administrators.
 * @dev This contract implements a simple admin-only modifier that checks whether the caller's address
 *      is marked as an admin in the `s_isAdmin` mapping. The mapping is `internal`, meaning it is accessible
 *      within this contract and any contracts that inherit from it.
 * 
 *      Usage:
 *      - Functions decorated with the `adminOnly` modifier can only be called by addresses that have `true` in `s_isAdmin`.
 *      - Non-admin callers attempting to execute such functions will trigger a revert using a custom error, which is
 *        more gas-efficient than revert strings.
 * 
 *      Example:
 *      ```
 *      contract MyContract is AdminAuth {
 *          function restrictedFunction() external adminOnly {
 *              // Function logic accessible only by admins
 *          }
 *      }
 *      ```
 * 
 *      Security Considerations:
 *      - Proper initialization of `s_isAdmin` is crucial to avoid lockout or unauthorized access.
 *      - Access modification functions (e.g., adding/removing admins) should themselves be protected with `adminOnly`.
 */
contract AdminAuth {

    /**
     * @notice Error indicating that the caller does not have administrator privileges.
     * @dev Thrown when the `adminOnly` modifier is applied and `msg.sender` is not marked as an admin in `s_isAdmin`.
     */
    error AdminAuth__AccessDenied_AdminOnly();

    /**
     * @notice Tracks whether a given address has administrator privileges.
     * @dev Mapping from an Ethereum address to a boolean value:
     *      - `true`: The address is an administrator.
     *      - `false`: The address is not an administrator.
     * 
     *      Marked as `internal`, so it is accessible to this contract and any derived contracts.
     */
    mapping(address => bool) internal s_isAdmin;

    /**
     * @notice Restricts function execution to admin addresses only.
     * @dev Checks if `msg.sender` is marked as an admin in the `s_isAdmin` mapping.
     *      If the caller is not an admin, the function reverts with `AdminAuth__AccessDenied_AdminOnly`.
     * 
     *      Functions using this modifier will execute `_` (the function body) only if the caller passes the admin check.
     * 
     * @custom:example
     * function restrictedAction() external adminOnly {
     *     // logic that only an admin can perform
     * }
     */
    modifier adminOnly() {
        if (!s_isAdmin[msg.sender]) {
            revert AdminAuth__AccessDenied_AdminOnly();
        }

        _;
    }
}
