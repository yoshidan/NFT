# プライベートチェーンを作る

## ノード作成
```
docker-compose up peer1-init
docker-compose up peer2-init
```

## ノード起動
```
docker-compose up peer1
docker-compose up peer2
```

## ノードに接続して操作を開始する
```
docker-compose exec peer1 geth attach data/geth.ipc
docker-compose exec peer2 geth attach data/geth.ipc
```

## お互いのノードを認識させる
* peer1の`admin.nodeInfo.enode`で表示されるenodeをpeer2でaddPeerする pr peer2の`admin.nodeInfo.enode`で表示されるenodeをpeer1でaddPeerする
* どちらかでaddPeerすればよい。
* 注意点としては、enodeのipのところは127.0.0.1になっているので、docker-composeでのservice名であるpeer1、peer2に変更する
  - node1のadmin.nodeInfo.enodeが`enode://xxx@127.0.0.1:30303?discport=0`ならpeer2でadmin.addPeerするときには↓になる
    ```
    admin.addPeer("enode://xxx@peer1:30303?discport=0")
    ```

成功するとadmin.peersが追加されnet.peerCountが1になっている
```
> admin.peers
[{
    caps: ["eth/66", "snap/1"],
    enode: "enode://8c62d82458c561c5462f68343f97e27db62957f5fbfffa0d2be6f2c5757e3d04776efe4481c25886084fc0a59a4f2d80218c39269ee65d4375a3a5f837c867d1@172.27.0.2:45614",
    id: "37a4c55a6c3eb46320fcfe7fdcd34a6f689027e86e9cb2f5f68cd59a7675360c",
    name: "Geth/v1.10.15-unstable-356bbe34/linux-amd64/go1.17.5",
    network: {
      inbound: true,
      localAddress: "172.27.0.3:30303",
      remoteAddress: "172.27.0.2:45614",
      static: false,
      trusted: false
    },
    protocols: {
      eth: {
        difficulty: 4238784,
        head: "0xd84fd797fe6de4a35addacf9ca7fae438935e9437606d4c7a10f598f1f84ef99",
        version: 66
      },
      snap: {
        version: 1
      }
    }
}]
> net.peerCount
1
```

## アカウント作成

personal.newAccountを実行する。

```
> personal.newAccount("password1")
"0x37304aaabc92f8fe80b5f18e12355e59ab7ac678"
> personal.newAccount("password2")
"0x8dddb1fdcfd4c8877ed3a6847827cef25de0fb81"

# 別peerのアカウントは表示されない。自身のノードのアカウントのみ表示
> eth.accounts 
["0x37304aaabc92f8fe80b5f18e12355e59ab7ac678", "0x8dddb1fdcfd4c8877ed3a6847827cef25de0fb81"]
> 
```

## マイニングの報酬受け取り先のアカウント指定

```
> miner.setEtherbase(eth.accounts[0]) 
true
> eth.coinbase
"0x37304aaabc92f8fe80b5f18e12355e59ab7ac678"
```

## 採掘開始〜停止

それぞれのノードでminer.start()からminer.stop()してeth.blockNumberが同じであれば同期されている

```
> miner.start()
null
> eth.mining // 採掘中かどうかを確認
true
> eth.blockNumber // ブロックチェーンのブロック数を確認
166
> miner.stop()
null
> eth.blockNumber
315
```

## 残高確認(単位：ETH)
```
> web3.fromWei(eth.getBalance(eth.accounts[0]),"ether")
1575
> web3.fromWei(eth.getBalance(eth.accounts[1]),"ether")
0
```

## 送金
* miner.start()しておく必要がある。startしてないとコマンドは成功するが受け渡しはminer.start()するまでペンディングになる。
* 別peerに送信した場合送信先で残高確認して増えていることが確認できる。

```
> personal.unlockAccount(eth.accounts[0])
Unlock account 0x37304aaabc92f8fe80b5f18e12355e59ab7ac678
Passphrase: 
true

> to = "0xb2d58ffb51c0ed0b8e46b622dd0130b0cdb664cb" #接続している別peerのアカウントも可能
> eth.sendTransaction({from: eth.accounts[0], to: to, value: web3.toWei(1, "ether")}) 
"0xb29d987b83a9a984eb9c12733afbe3c539be71b5b9ebece7a558e47be38f4fec"

# ガス代など確認できる。gasPriceがガス代、valueが総金額、どちらもethではなくwei単位。
> eth.getTransaction("0xb29d987b83a9a984eb9c12733afbe3c539be71b5b9ebece7a558e47be38f4fec")
{
  blockHash: "0x831719f6c1d8aa14d42cf4dbd03f4a774063ed52ec06bdebbb1fa15505510507",
  blockNumber: 280,
  from: "0x83e8d92c741a943718c3f6f8e0e70895fc4837ec",
  gas: 21000,
  gasPrice: 1000000000,
  hash: "0xb29d987b83a9a984eb9c12733afbe3c539be71b5b9ebece7a558e47be38f4fec",
  input: "0x",
  nonce: 0,
  r: "0xc4ad4d192c73fd00d45dc62ab90b1f225f498e29b8359da5f810812468a2e861",
  s: "0xeca346a9cebb679130adaa00b4310b9523b33200ef38aea60fbd65458d0f1e0",
  to: "0xff604ccdb4a791325e7c03fec711b7bce3ef4641",
  transactionIndex: 0,
  type: "0x0",
  v: "0x7f2",
  value: 5000000000000000000
}

```
