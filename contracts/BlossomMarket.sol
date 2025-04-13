// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Interface for interacting with BlossomNFT contracts
interface IBlossomNFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract BlossomMarket {
    // Struct to store NFT listing details
    struct Listing {
        address seller;
        address tokenAddress;
        uint256 tokenId;
        uint256 price;
        bool sold;
    }

    // Array to store all listings
    Listing[] public listings;

    // Events for frontends or off-chain apps to track listing and purchase actions
    event Listed(uint indexed listingId, address seller, uint256 tokenId, uint256 price);
    event Bought(uint indexed listingId, address buyer, uint256 tokenId, uint256 price);

    // Allows NFT owners to list their NFT for sale
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

    // Allows users to buy a listed NFT by sending enough ETH
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

        // Transfer funds to seller
        payable(listing.seller).transfer(listing.price);

        emit Bought(listingId, msg.sender, listing.tokenId, listing.price);
    }

    // Returns all listings, including sold onesgit
    function getAllListings() public view returns (Listing[] memory) {
        return listings;
    }
}

