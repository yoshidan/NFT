async function main() {
    const baseTokenURL = process.env.ERC721_BASE_TOKEN_URL
    console.log("baseTokenURL = ", baseTokenURL)

    //hardhat.config.jsに定義したアカウントが取得できる
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account ", deployer.address);

    // OpenSeaのproxyRegistry 固定
    const proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";

    // Deploy
    const contractFactory = await ethers.getContractFactory("MyERC721");
    const contract = await contractFactory.deploy(proxyRegistryAddress,baseTokenURL);
    console.log("ERC721 deployed. contract address: ", contract.address);
}

main().catch(console.error)
