// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {USDT} from "../src/USDT.sol";
import {Ic2P2ramp} from "../src/Ic2P2ramp.sol";
import {Errors} from "../src/model/Errors.sol";

contract Ic2P2rampTest is Test {
    Ic2P2ramp ic2P2ramp;
    USDT usdt;

    address deployer = address(0x123);
    address offramper = address(0x456);
    address onramper = address(0x789);
    address icpBackend = address(0xABC);

    function setUp() public {
        vm.startPrank(deployer);

        usdt = new USDT(deployer);
        ic2P2ramp = new Ic2P2ramp(deployer);
        ic2P2ramp.setIcpEvmCanister(icpBackend);

        address[] memory tokens = new address[](1);
        tokens[0] = address(usdt);
        ic2P2ramp.addValidTokens(tokens);

        vm.stopPrank();
    }

    // TOKEN ONRAMP
    function testDepositToken() public {
        vm.startPrank(offramper);
        usdt.mint(offramper, 1e18);
        usdt.approve(address(ic2P2ramp), 1e18);
        ic2P2ramp.depositToken(address(usdt), 1e18);
        assertEq(ic2P2ramp.getDeposit(offramper, address(usdt)), 1e18);
        vm.stopPrank();
    }

    function testWithdrawToken() public {
        vm.startPrank(offramper);
        usdt.mint(offramper, 1e18);
        usdt.approve(address(ic2P2ramp), 1e18);
        ic2P2ramp.depositToken(address(usdt), 1e18);
        ic2P2ramp.withdrawToken(address(usdt), 5e17);
        assertEq(ic2P2ramp.getDeposit(offramper, address(usdt)), 5e17);
        vm.stopPrank();
    }

    function testReleaseFundsToken() public {
        vm.startPrank(offramper);
        usdt.mint(offramper, 1e18);
        usdt.approve(address(ic2P2ramp), 1e18);
        ic2P2ramp.depositToken(address(usdt), 1e18);
        vm.stopPrank();

        vm.startPrank(icpBackend);
        ic2P2ramp.commitDeposit(offramper, address(usdt), 1e18);
        ic2P2ramp.releaseFunds(offramper, onramper, address(usdt), 1e18);
        assertEq(ic2P2ramp.getDeposit(offramper, address(usdt)), 0);
        assertEq(usdt.balanceOf(onramper), 1e18);
        assertEq(usdt.balanceOf(offramper), 0);
        vm.stopPrank();
    }

    function testDepositInsufficientFunds() public {
        vm.startPrank(deployer);
        usdt.mint(deployer, 1e18);
        usdt.approve(address(ic2P2ramp), 1e17); // Set allowance lower than the deposit amount
        vm.expectRevert();
        ic2P2ramp.depositToken(address(usdt), 1e18);
        vm.stopPrank();
    }

    function testWithdrawInsufficientFunds() public {
        vm.startPrank(deployer);
        usdt.mint(deployer, 1e18);
        usdt.approve(address(ic2P2ramp), 1e18);
        ic2P2ramp.depositToken(address(usdt), 1e18);
        vm.expectRevert();
        ic2P2ramp.withdrawToken(address(usdt), 2e18);
        vm.stopPrank();
    }

    function testReleaseFundsZeroAddress() public {
        vm.startPrank(offramper);
        usdt.mint(offramper, 1e18);
        usdt.approve(address(ic2P2ramp), 1e18);
        ic2P2ramp.depositToken(address(usdt), 1e18);
        vm.stopPrank();

        vm.startPrank(icpBackend);
        vm.expectRevert(Errors.ZeroAddress.selector);
        ic2P2ramp.releaseFunds(address(0), onramper, address(usdt), 1e18);
        vm.stopPrank();
    }

    function testDepositZeroAddressToken() public {
        vm.startPrank(deployer);
        vm.expectRevert(Errors.ZeroAddress.selector);
        ic2P2ramp.depositToken(address(0), 1e18);
        vm.stopPrank();
    }

    function testWithdrawZeroAddressToken() public {
        vm.startPrank(deployer);
        vm.expectRevert(Errors.ZeroAddress.selector);
        ic2P2ramp.withdrawToken(address(0), 1e18);
        vm.stopPrank();
    }

    // ----------------------
    // NATIVE CURRENCY ONRAMP
    // ----------------------

    function testDepositBaseCurrency() public {
        vm.deal(offramper, 1e18);
        vm.startPrank(offramper);
        ic2P2ramp.depositBaseCurrency{value: 1e18}();
        assertEq(ic2P2ramp.getDeposit(offramper, address(0)), 1e18);
        vm.stopPrank();
    }

    function testWithdrawBaseCurrency() public {
        vm.deal(offramper, 1e18);
        vm.startPrank(offramper);
        ic2P2ramp.depositBaseCurrency{value: 1e18}();
        ic2P2ramp.withdrawBaseCurrency(5e17);
        assertEq(ic2P2ramp.getDeposit(offramper, address(0)), 5e17);
        vm.stopPrank();
    }

    function testReleaseBaseCurrency() public {
        vm.deal(offramper, 1e18);
        vm.startPrank(offramper);
        ic2P2ramp.depositBaseCurrency{value: 1e18}();
        vm.stopPrank();

        vm.startPrank(icpBackend);
        ic2P2ramp.commitDeposit(offramper, address(0), 1e18);
        ic2P2ramp.releaseBaseCurrency(offramper, onramper, 1e18);
        assertEq(address(onramper).balance, 1e18);
        assertEq(ic2P2ramp.getDeposit(offramper, address(0)), 0);
        assertEq(address(offramper).balance, 0);
        vm.stopPrank();
    }
}
