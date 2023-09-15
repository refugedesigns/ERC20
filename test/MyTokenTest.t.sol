// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18; 

import { DeployMyToken } from "../script/DeployMyToken.s.sol";
import { MyToken } from "../src/MyToken.sol";
import { Test, console } from "forge-std/Test.sol";

interface MintableToken {
  function mint(address, uint256) external;
}

contract MyTokenTest is Test {
    DeployMyToken deploy;
    MyToken myToken;

    address bob; 
    address alice; 
    address public deployerAddr;

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        bob = makeAddr("bob");
        alice = makeAddr("alice");
        deploy = new DeployMyToken();
        myToken = deploy.run();

        deployerAddr = vm.addr(deploy.deployerKey());
        
        vm.prank(deployerAddr);
        myToken.transfer(bob, STARTING_BALANCE);
    }

    function  testBobBalanceIsEqualToStartingBalance() public {
        assertEq(STARTING_BALANCE, myToken.balanceOf(bob));
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        //Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        myToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);

        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testInitialSupply() public {
    assertEq(myToken.totalSupply(), deploy.INITIAL_SUPPLY());
  }

  function testUsersCantMint() public {
    vm.expectRevert();
    MintableToken(address(myToken)).mint(address(this), 1);
  }
}