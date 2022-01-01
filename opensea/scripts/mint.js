async function main() {
    //deploy.js実行後に取得できるコントラクトアドレスを指定すること
    const contractAddress = process.env.CONTRACT_ADDRESS;

    //mintの対象とするcontractを取得する
    const MyERC721 = await ethers.getContractFactory("MyERC721");
    console.log("Contract Address:", contractAddress);
    const token = await MyERC721.attach(contractAddress);

    //hardhat.config.jsに定義したアカウントが取得できる
    const [deployer] = await ethers.getSigners();

    //そのアカウントでmintする
    //トークンIDは1から順に採番号されていく。https://storage.googleaps.com/bucketName/1 などにjson
    const miteResult = await token.mint(deployer.address)
    const maxTokenId = await token.maxTokenId()
    console.log("Minted :", miteResult)
    console.log("TokenId :", maxTokenId);
}

main().catch(console.error)