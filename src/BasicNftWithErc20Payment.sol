//Build a classic NFT that can only be minted by paying with a particular ERC20 token.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BasicNft is ERC721, Ownable {
    uint256 private s_tokenCounter;
    mapping(uint256 => string) private s_tokenIdToUri;

    IERC20 public immutable paymentToken;
    uint256 public mintPrice; // USDC smallest units (6 decimals)

    error PaymentFailed();
    error WithdrawFailed();
    error NoFunds();

    constructor(
        address _paymentToken,
        uint256 _mintPrice
    ) ERC721("dogie", "DOG") Ownable(msg.sender) {
        paymentToken = IERC20(_paymentToken);
        mintPrice = _mintPrice;
    }

    function setMintPrice(uint256 _newPrice) external onlyOwner {
        mintPrice = _newPrice;
    }

    function mintNft(string calldata tokenUri) external {
        // Pull payment first
        if (!paymentToken.transferFrom(msg.sender, address(this), mintPrice)) {
            revert PaymentFailed();
        }

        // Mint NFT
        uint256 tokenId = s_tokenCounter;
        s_tokenIdToUri[tokenId] = tokenUri;
        _safeMint(msg.sender, tokenId);

        // Increment supply
        s_tokenCounter++;
    }

    function withdrawPayments(address to) external onlyOwner {
        uint256 balance = paymentToken.balanceOf(address(this));
        if (balance == 0) revert NoFunds();

        if (!paymentToken.transfer(to, balance)) {
            revert WithdrawFailed();
        }
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return s_tokenIdToUri[tokenId];
    }
}
