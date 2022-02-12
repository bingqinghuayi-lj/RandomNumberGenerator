随机数生成器
有一些时候我们希望可以获得可信任的随机事件，通过区块链可以轻松做到这一点

使用环境:
    Linux-Ubuntu20.04
    Starcoin-barnard
    Starcoin-move
    
设计思路：
    由于链上的数据不能用函数产生随机数，但是可以用未来的区块作为随机数的标准，根据Starcoin区块的产生速度
    可以判定，20秒以后应该至少有4区块产生。
    所以仅需有一个NFT来作为注册标记，然后在20秒过后读取对应区块的hash值即可获得比较满足要求的随机数
    

