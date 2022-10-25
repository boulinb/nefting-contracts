pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract NeftingNft is ERC1155, Pausable, Ownable, ERC2981 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint96 maxRoyalties;

    constructor() public ERC1155("https://api.nefting.com/nft-metadata/ethereum/{id}") {
        // Set maxRoyalties to 50%
        maxRoyalties = 5000;
    }

    function mint(uint256 amount, uint96 feeNumerator) public whenNotPaused {
        require(feeNumerator <= maxRoyalties, "Royalties can't exceed maxRoyalties.");
        _tokenIds.increment();
        uint256 id = _tokenIds.current();

        _mint(msg.sender, id, amount, "");
        _setTokenRoyalty(id, msg.sender, feeNumerator);
    }

    function burn(address from, uint256 id, uint256 amount) public whenNotPaused {
        _burn(from, id, amount);
    }

    function getMaxRoyalties() public view returns (uint96) {
        return maxRoyalties;
    }

    function setMaxRoyalties(uint96 _maxRoyalties) public onlyOwner {
        require(_maxRoyalties <= 10000, "maxRoyalties can't exceed 100%");

        maxRoyalties = _maxRoyalties;
    }

    function setTokenRoyalty(uint256 id, address receiver, uint96 feeNumerator) public whenNotPaused {
        address currentReceiver;

        (currentReceiver,) = royaltyInfo(id, 0);

        require(currentReceiver == msg.sender, "Not tokenId royalties receiver.");
        require(feeNumerator <= maxRoyalties, "Royalties can't exceed maxRoyalties.");

        _setTokenRoyalty(id, receiver, feeNumerator);
    }

    function setUri(string memory newUri) public onlyOwner {
        _setURI(newUri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}