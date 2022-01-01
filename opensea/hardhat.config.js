require("@nomiclabs/hardhat-waffle");

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const networks = {
  rinkeby: {
    //rinkebyに参加するためのノードのURL（Alchemyとうで取得すると楽）
    url: process.env.RINKEBY_URL,
    accounts: [
      // MetaMaskウォレットの秘密鍵
      process.env.RINKEBY_ACCOUNT
    ]
  },
  local: {
    url: "http://127.0.0.1:8545",
        accounts: [
      // npx hardhat node時に生成されたアカウントのどれかのPrivate Keyを指定する（どれでもいい)
      "92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e"
    ]
  }
};

console.log(networks.rinkeby)

module.exports = {
  networks,
  solidity: "0.8.4",
};
