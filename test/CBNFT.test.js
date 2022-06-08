const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("[Test] Contracts CBNFT1 and CBNFT2", function () {

    let deployer, alice; // deployer: Contract deployer for CBNFT1 and CBNFT2, alice: NFT minter
    let CBNFT1Instance, CBNFT2Instance; // Contract instances

    before("Deploy contracts", async function() {

        [deployer, alice] = await ethers.getSigners();

        const CBNFT1 = await ethers.getContractFactory("CBNFT1");
        CBNFT1Instance = await CBNFT1.deploy("BASEURI:TODO");
        await CBNFT1Instance.deployed();
        console.log(`CBNFT1 contract address: ${CBNFT1Instance.address}`);

        const CBNFT2 = await ethers.getContractFactory("CBNFT2");
        CBNFT2Instance = await CBNFT2.deploy("BASEURI:TODO");
        await CBNFT2Instance.deployed();
        console.log(`CBNFT2 contract address: ${CBNFT2Instance.address}`);

    });

    it("CBNFT1 Pass", async function() {

        // Alice claim 1 NFT from CBNFT1 for 0.01ETH
        await CBNFT1Instance.connect(alice).claim({value: ethers.utils.parseUnits("0.01")});

        // Alice's CBNFT1 balance should be 1
        expect(await CBNFT1Instance.balanceOf(alice.address)).to.eq(1);

        // CBNFT1 #1 owner should be Alice
        expect(await CBNFT1Instance.ownerOf(1)).to.eq(alice.address);

    });

    it("CBNFT2 Pass", async function() {

        // Deployer set swappable NFT contract as CBNFT1
        await CBNFT2Instance.connect(deployer).setSwappableContract(CBNFT1Instance.address);

        // Alice send CBNFT1 #1 to CBNFT2 contract to receive CBNFT2 #1
        await CBNFT1Instance.connect(alice).approve(CBNFT2Instance.address, 1);
        await CBNFT2Instance.connect(alice).claim(CBNFT1Instance.address, 1);

        // Alice's CBNFT1 balance should be 0, CBNFT2 balance should be 1
        expect(await CBNFT1Instance.balanceOf(alice.address)).to.eq(0);
        expect(await CBNFT2Instance.balanceOf(alice.address)).to.eq(1);

        // CBNFT2 #1 owner should be Alice
        expect(await CBNFT2Instance.ownerOf(1)).to.eq(alice.address);

        // Alice swap back CBNFT2 #1 and CBNFT1 #1
        await CBNFT2Instance.connect(alice).swapBack(CBNFT1Instance.address, 1, 1);

        // CBNFT1 #1 owner should be Alice, CBNFT2 #1 owner should be CBNFT2 contract
        expect(await CBNFT1Instance.ownerOf(1)).to.eq(alice.address);
        expect(await CBNFT2Instance.ownerOf(1)).to.eq(CBNFT2Instance.address);

    });

});
