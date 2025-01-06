// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/chiru-labs/ERC721A-Upgradeable/contracts/ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// @title RoadUniverseNFT - An upgradable ERC721A contract with ownable functionalities.
contract RoadUniverseNFT is ERC721AUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
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
}
