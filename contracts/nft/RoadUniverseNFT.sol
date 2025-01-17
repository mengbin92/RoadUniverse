// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/chiru-labs/ERC721A-Upgradeable/contracts/ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// @title RoadUniverseNFT - An upgradable ERC721A contract with ownable functionalities.
contract RoadUniverseNFT is ERC721AUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    /**
     * @dev Events for batch operations.
     */
    event BatchTransfer(
        address indexed operator,
        address[] recipients,
        uint256[] tokenIds
    );
    
    using Strings for uint256;

    // The base URI for token metadata.
    string private _uri;

    /**
     * @dev Initializes the contract with a name and symbol.
     * @param name The name of the token collection.
     * @param symbol The symbol of the token collection.
     */
    function initialize(string memory name, string memory symbol) initializerERC721A initializer public {
        __ERC721A_init(name, symbol);
        __Ownable_init(msg.sender);  // Initializes Ownable (sets the owner to msg.sender)
        __UUPSUpgradeable_init(); // Initializes UUPS upgradeability
    }

     /**
     * @dev Mints a specified quantity of tokens to the contract owner.
     * @param quantity The number of tokens to mint.
     */
    function mint(uint256 quantity) external onlyOwner {
        require(quantity > 0, "Mint quantity must be greater than zero.");
        _mint(msg.sender, quantity); // Mints the tokens to the owner's address.
    }

    /**
     * @dev Authorizes contract upgrades. Only callable by the owner.
     * @param newImplementation The address of the new contract implementation.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}


    /**
     * @dev Sets the base URI for token metadata.
     * @param uri The base URI string.
     */
    function setURI(string memory uri) public onlyOwner {
        require(bytes(uri).length > 0, "URI cannot be empty.");
        _uri = uri;
    }

    /**
     * @dev Returns the URI for a specific token ID.
     * @param tokenId The token ID for which to retrieve the URI.
     * @return The token URI string.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // Ensure the token exists before returning its URI.
        require(_exists(tokenId), "Token does not exist.");
        return string(abi.encodePacked(_uri, tokenId.toString()));
    }
    /**
     * @dev Allows the owner to batch transfer nft to multiple recipients.
     * @param recipients The array of recipient addresses.
     */
    function batchTransfer(
        address[] calldata recipients,
        uint256[] calldata tokenIds
    ) external onlyOwner {
        require(recipients.length > 0, "No recipients provided");
        require(
            recipients.length == tokenIds.length,
            "Recipients and tokenIds length mismatch"
        );

        uint256 senderBalance = balanceOf(msg.sender);
        require(
            senderBalance >= recipients.length,
            "Insufficient balance to transfer"
        );
        // Loop through all the recipients and transfer the corresponding token to each
        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 tokenId = tokenIds[i];
            // Ensure the recipient address is valid (non-zero address)
            require(recipient != address(0), "Invalid recipient address");
            // Ensure the tokenId exists and is owned by the sender
            require(
                ownerOf(tokenId) == msg.sender,
                "Sender does not own the token"
            );
            // Transfer the token to the recipient
            safeTransferFrom(msg.sender, recipient, tokenId);
        }
        // Emit a BatchTransfer event after completing the transfers
        emit BatchTransfer(msg.sender, recipients, tokenIds);
    }

    /**
     * @dev Retrieves all tokenIds owned by the specified address.
     * @return tokenIds An array of tokenIds owned by the specified address.
     *
     * @notice This function allows you to query the tokenIds of all NFTs owned by a specified address.
     * It works with ERC721AUpgradeable contract, which uses an optimized token storage.
     * @dev This function iterates over the minted tokens from `startTokenId()` to `currentIndex` and checks
     * if each token is owned by the specified address.
     */
    function getTokensByOwner() external view returns (uint256[] memory) {
        uint256 balance = balanceOf(msg.sender); // Get the number of NFTs owned by the address)
        if (balance == 0) {
            return new uint256[](0); // If the address has no NFTs, return an empty array
        }
        uint256[] memory tokenIds = new uint256[](balance); // Create an array to store the tokenIds
        uint256 index = 0;
        uint256 currentTokenId = _startTokenId(); // The first token ID, typically 0 or 1 depending on implementation
        uint256 maxTokenId = _totalMinted(); // The total amount of tokens minted in the contract

        // Iterate over the range of minted tokens and check ownership
        for (
            uint256 tokenId = currentTokenId;
            tokenId < maxTokenId;
            tokenId++
        ) {
            if (ownerOf(tokenId) == msg.sender) {
                tokenIds[index] = tokenId; // If the address owns this tokenId, add it to the list
                index++;
                if (index == balance) break; // If we've already added all owned tokenIds, break early
            }
        }
        return tokenIds; // Return the array of tokenIds owned by the address
    }
}
