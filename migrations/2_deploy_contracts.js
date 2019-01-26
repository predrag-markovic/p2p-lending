const Base = artifacts.require("./Base.sol");
const LendingBoard = artifacts.require("./LendingBoard.sol");

const minimumQuorum = 1;
const minutesForDebate = 30;
const majorityMargin = 50;

module.exports = async deployer => {
    await deployer.deploy(
        LendingBoard,
        minimumQuorum,
        minutesForDebate,
        majorityMargin
    );
    await deployer.deploy(Base, LendingBoard.address);
};
