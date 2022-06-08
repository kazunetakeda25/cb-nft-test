// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CBNFT1 is ERC721, ERC721Enumerable, ERC721Holder, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;
    mapping(address => bool) private _claimed;
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private constant _CLAIM_PRICE = 10_000_000_000_000_000; // 0.01 ETH

    string public baseURI;

    event BaseURIChanged(string baseURI_);
    event Claimed(address indexed to_, uint256 tokenId_);

    modifier nonReentrant() {
        require(_status != _ENTERED, "CBNFT1: Reentrant Call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor(string memory baseURI_) ERC721("CBNFT1", "CB1") {
        baseURI = baseURI_;
        _tokenIdCounter.increment(); // starts from 1
    }

    receive() external payable {}

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }

    function setBaseURI(string calldata baseURI_) external onlyOwner {
        baseURI = baseURI_;
        emit BaseURIChanged(baseURI_);
    }

    function claim() external payable nonReentrant {
        require(!_claimed[msg.sender], "CBNFT1: Already claimed");
        require(_CLAIM_PRICE >= msg.value, "CBNFT1: Invalid payment amount");
        require(msg.sender == tx.origin, "CBNFT1: No smart contract call");
        _safeMint(msg.sender, _tokenIdCounter.current());
        _claimed[msg.sender] = true;
        _tokenIdCounter.increment();
        emit Claimed(msg.sender, _tokenIdCounter.current());
    }

    function withdrawETH(address payable to_) external onlyOwner nonReentrant {
        require(to_ != address(0), "CBNFT1: Zero address");
        uint256 amount = address(this).balance;
        to_.transfer(amount);
    }

    function tokenURI(uint256 tokenId_)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId_),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, tokenId_.toString(), ".json")
                )
                : "";
    }

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId_);
    }
}
