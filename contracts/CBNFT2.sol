// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CBNFT2 is ERC721, ERC721Enumerable, ERC721Holder, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    string public baseURI;
    address public swappableContract; // ERC721 contract address (CBNFT2)

    event BaseURIChanged(string baseURI_);
    event SwappableContractChanged(address indexed swappableContract_);
    event Claimed(address indexed to_, uint256 tokenId_);

    modifier nonReentrant() {
        require(_status != _ENTERED, "CBNFT2: Reentrant Call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor(string memory baseURI_) ERC721("CBNFT2", "CB2") {
        baseURI = baseURI_;
        _tokenIdCounter.increment(); // starts from 1
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }

    function _isContract(address contractAddress_)
        internal
        view
        returns (bool)
    {
        uint256 size;
        assembly {
            size := extcodesize(contractAddress_)
        }
        return size > 0;
    }

    function setBaseURI(string calldata baseURI_) external onlyOwner {
        baseURI = baseURI_;
        emit BaseURIChanged(baseURI_);
    }

    function setSwappableContract(address swappableContract_)
        external
        onlyOwner
    {
        require(
            _isContract(swappableContract_),
            "CBNFT2: Not a contract address"
        );
        swappableContract = swappableContract_;
        emit SwappableContractChanged(swappableContract_);
    }

    function claim(address fromContract_, uint256 fromTokenId_)
        external
        nonReentrant
    {
        require(
            fromContract_ == swappableContract,
            "CBNFT2: Not a swappable contract"
        );
        require(msg.sender == tx.origin, "CBNFT2: No smart contract call");

        _safeMint(msg.sender, _tokenIdCounter.current());
        _tokenIdCounter.increment();
        IERC721(fromContract_).safeTransferFrom(
            msg.sender,
            address(this),
            fromTokenId_,
            ""
        );
        emit Claimed(msg.sender, _tokenIdCounter.current());
    }

    function swapBack(
        address fromContract_,
        uint256 fromTokenId_,
        uint256 toTokenId_
    ) external nonReentrant {
        require(msg.sender == tx.origin, "CBNFT2: No smart contract call");
        _safeTransfer(msg.sender, address(this), toTokenId_, "");
        IERC721(fromContract_).safeTransferFrom(
            address(this),
            msg.sender,
            fromTokenId_,
            ""
        );
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
