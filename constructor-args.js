const { ethers } = require("hardhat");

require("dotenv").config();

const dk = process.env.DEPLOYMENT_KEY;
const minters = [
    '0x0616Ab4786C29d0e33F9cCe808886211F7C80D35', //tdg
    '0x28ba8a72cc5d3eafdbd27929b658e446c697148b', //xrdna
    '0x18872e7ffEf6d3C56B2E7051575bE3a1F0188C18', //powers
];
module.exports = [
    new ethers.Wallet(dk).address,
    minters
]