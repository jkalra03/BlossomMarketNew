// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBlossomNFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract BlossomMarket {
    struct Listing {
        address seller;
        address tokenAddress;
        uint256 tokenId;
        uint256 price;
        bool sold;
    }

    Listing[] public listings;

    event Listed(uint indexed listingId, address seller, uint256 tokenId, uint256 price);
    event Bought(uint indexed listingId, address buyer, uint256 tokenId, uint256 price);

    function listNFT(address tokenAddress, uint256 tokenId, uint256 price) public {
        IBlossomNFT nft = IBlossomNFT(tokenAddress);
        require(nft.ownerOf(tokenId) == msg.sender, "Not NFT owner");

        listings.push(Listing({
            seller: msg.sender,
            tokenAddress: tokenAddress,
            tokenId: tokenId,
            price: price,
            sold: false
        }));

        emit Listed(listings.length - 1, msg.sender, tokenId, price);
    }

    function buyNFT(uint listingId) public payable {
        Listing storage listing = listings[listingId];
        require(!listing.sold, "Already sold");
        require(msg.value >= listing.price, "Not enough ETH");

        listing.sold = true;

        // Transfer NFT to buyer
        IBlossomNFT(listing.tokenAddress).safeTransferFrom(
            listing.seller,
            msg.sender,
            listing.tokenId
        );

        // Transfer funds to seller
        payable(listing.seller).transfer(listing.price);

        emit Bought(listingId, msg.sender, listing.tokenId, listing.price);
    }

    function getAllListings() public view returns (Listing[] memory) {
        return listings;
    }
}

