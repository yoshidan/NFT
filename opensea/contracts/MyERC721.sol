//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy ) public proxies;
}

contract MyERC721 is ERC721PresetMinterPauserAutoId {

    address proxyRegistryAddress;

    uint256 _currentTokenId;

    event OnMint(uint256 tokenId);
    event OnBurn(uint256 tokenId);

    event Notify(address signer, string message);

    // baseTokenURI/をつけないとmetadata解析に失敗する
    // mint時にmetadataは確定するようで修正は不可
    constructor(address _proxyRegistryAddress, string memory baseTokenURI) ERC721PresetMinterPauserAutoId("MyERC721", "MYNFT", baseTokenURI)
    {
        //このログはブロックチェーンのノード側で出力される
        console.log("Deploying contract name MyERC721");
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    //OpenSeaを使う場合 許可されたユーザはgas-lessになるようだ。
    function isApprovedForAll(address _owner, address _operator) public view virtual override returns (bool) {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == _operator) {
            return true;
        }
        return super.isApprovedForAll(_owner, _operator);
   }

    // NFTを発行する。トークンIDは0からの連番
    function mint(address to) public virtual override {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");
        _mint(to, _currentTokenId);
        emit OnMint(_currentTokenId);
        _currentTokenId += 1;
    }

    // 現在発行済みの最大トークンID
    // metadataは先にアップロードしておかないとダメっぽいので、maxTokenIdで発行済みのトークンIDを確認してからmetadataをアップしておく
    // 運営のみが発行するNFTならそれでよいが、複数人がmintしまくるケースだと、最大トークンIDは随時変わるので、別でトークンIDとアイテムを紐づけてカスタムトークンIDを設定する仕組みが必要。
    function maxTokenId() public view returns (uint256) {
        console.log(_currentTokenId);
        return _currentTokenId;
    }

    //発行済みの削除
    function burn(uint256 tokenId) public virtual override {
        super.burn(tokenId) ;
        emit OnBurn(tokenId);
    }

    //event emitterを使ってスマコンからsubscriberになんでもメッセージ送信出来そう
    function notify(string memory message) public virtual {
        emit Notify(_msgSender(), message);
    }
}
