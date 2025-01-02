// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import 'https://github.com/chiru-labs/ERC721A-Upgradeable/contracts/ERC721AUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

contract RoadUniverseNFT is ERC721AUpgradeable, OwnableUpgradeable,UUPSUpgradeable {
    // Take note of the initializer modifiers.
    // - initializerERC721A for ERC721AUpgradeable.
    // - initializer for OpenZeppelin's OwnableUpgradeable.
    function initialize(string memory name, string memory symbol) initializerERC721A initializer public {
        __ERC721A_init(name, symbol);
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    function mint(uint256 quantity) external onlyOwner {
        // _mint's second argument now takes in a quantity, not a tokenId.
        _mint(msg.sender, quantity);
    }

    // _authorizeUpgrade: required
    function _authorizeUpgrade(address) internal override onlyOwner {}

    function tokenURI(uint256 tokenId) public pure override returns (string memory) {
        return string(abi.encodePacked("https://api.example.com/metadata/erc721/", uint2str(tokenId)));
    }

    // uint 转 string 的辅助函数
    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}