// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./utils/CitizenNFTTest.sol";
import "../CitizenNFT.sol";

contract NewCityDAOCitizen is CitizenTest {
    /// @notice Mint new Citizen NFTs, verify that owners are correct and balance of smart contract
    /// is equal to the value transfered for the minting.
    function testBuyCitizenNFT() public {
        payable(address(bob)).transfer(1 ether);
        uint256 tokenPrice = 250000000000000000;
        bob.onlineApplicationForCitizenship(tokenPrice, 1);
        bob.onlineApplicationForCitizenship(tokenPrice, 1);
        assertEq(citizenNFT.balanceOf(address(bob), citizenNFTInternalId), 2);
        assertEq(address(citizenNFT).balance, 2 * tokenPrice);
    }

    /// @notice Output the tokenURI in base64 format to be used in a decoder and observe the json metadata
    function testTokenURI() public {
        payable(address(bob)).transfer(1 ether);
        bob.onlineApplicationForCitizenship(250000000000000000, 1);
        string memory meta = citizenNFT.uri(citizenNFTInternalId);
        emit log(meta);
    }
}

contract Legislate is CitizenTest {
    /// @notice Test the change of cost for acquiring a citizen NFT.
    /// The test is fuzzed, meaning that it will test many different values as arguments
    function testOwnerChangeCitizenCost(uint96 _weiAmmount) public {
        _weiAmmount = _weiAmmount % 100000000000000000000;
        odys.legislateCostOfEntry(_weiAmmount);
        payable(address(bob)).transfer(10000 ether);
        bob.onlineApplicationForCitizenship(_weiAmmount * 10, 10);
        assertEq(citizenNFT.balanceOf(address(bob), citizenNFTInternalId), 10);
        assertEq(citizenNFT.inquireCostOfEntry(), _weiAmmount);
    }

    /// @notice Test the change of the maximum number regular Citizen NFTs that can be minted
    /// The test is fuzzed, meaning that it will test many different  values  as arguments
    function testOwnerChangeCitizensNumber(uint96 _housingNumber) public {
        odys.buildHousing(_housingNumber);
        uint256 housingNumbers = citizenNFT.inquireHousingNumbers();
        uint256 mintedNFTs = uint256(_housingNumber) + 10000;
        assertEq(mintedNFTs, housingNumbers);
    }

    /// @notice Test the change of the maximum number of founding Citizen NFTs that can be minted
    function testRewriteHistory(uint96 _numberOfNewFoundingCitizens) public {
        odys.rewriteHistory(_numberOfNewFoundingCitizens);
        assertEq(citizenNFT.inquireAboutHistory(), uint256(_numberOfNewFoundingCitizens) + 50);
    }

    /// @notice If a non-owner tries to affect the cost of regular Citizen NFTs, it should fail
    function testFailnonOwnerChangeCitizenCost(uint96 _weiAmmount) public {
        _weiAmmount = _weiAmmount % 100000000000000000000;
        bob.legislateCostOfEntry(_weiAmmount);
    }

    /// @notice If a non-owner user tries to affect the maximum number of regular Citizen NFTs, it should fail
    function testFailChangeCitizensNumber(uint256 _housingNumber) public {
        bob.buildHousing(_housingNumber);
    }

    /// @notice The owner should be able to withdraw the funds that exist in the smart contract
    function testRaidTheCoffers() public {
        payable(address(bob)).transfer(1 ether);
        uint256 tokenPrice = 250000000000000000;
        bob.onlineApplicationForCitizenship(tokenPrice,2);
        odys.raidTheCoffers();
        assertEq(address(odys).balance, tokenPrice * 2);
    }
}
