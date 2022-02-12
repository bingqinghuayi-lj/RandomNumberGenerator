address 0x08192CFd78098f8F5e17b8824a389424 {
    module RandomNumberGenerator{

        use 0x1::Signer;
        use 0x1::NFT;
        use 0x1::Vector;
        use 0x1::Timestamp;
        use 0x1::Block;
        struct Shared_Cap has key,store{
            Mint_cap :      NFT::MintCapability<Meta>,
            Burn_cap :      NFT::BurnCapability<Meta>,
        }
        struct Meta has key,drop,store,copy{
             Time :      u64,
        }
        struct Body has key,drop,store,copy{

        }
        struct NFT_list has key,store{
            Nft : vector<NFT::NFT<Meta, Body>>,
            Random:u64
        }
        public fun  AdminAddress():address{
            return @0x08192CFd78098f8F5e17b8824a389424
        }      

        public fun init(account:&signer) {
            let addr = Signer::address_of(account);
            assert( addr == AdminAddress() , 21000);
            assert( exists<Shared_Cap> ( AdminAddress() ) , 22000 );
            NFT::register_v2<Meta>(account,NFT::new_meta(b"RandomNumberGeneratorFlag",b"Random numbers can be obtained by burning this NFT after a specified time"));
            let nft_mint_cap    = NFT::remove_mint_capability<Meta>(account);
            let nft_burn_cap    = NFT::remove_burn_capability<Meta>(account);
            move_to(account, Shared_Cap { Mint_cap:nft_mint_cap ,Burn_cap:nft_burn_cap} );
            
        }
        public fun getRandomNumber (account:&signer) acquires Shared_Cap ,NFT_list{
            let addr = Signer::address_of(account);
            if(exists<NFT_list>(addr))
            {
                let cap = borrow_global_mut<Shared_Cap>(AdminAddress());
                let list = borrow_global_mut<NFT_list>(addr);
                let nft_v = &mut list.Nft;
                
                if(Vector::is_empty<NFT::NFT<Meta, Body>>(nft_v)){
                    
                    let nft = NFT::mint_with_cap_v2<Meta,Body>(addr,&mut cap.Mint_cap,NFT::new_meta(b"RandomNumberGeneratorFlag",b"Random numbers can be obtained by burning this NFT after a specified time"),Meta{Time:Timestamp::now_seconds() + 10 * 2},Body{});
                    Vector::push_back<NFT::NFT<Meta, Body>>( nft_v ,nft);
                }else{
                    let nft = Vector::remove<NFT::NFT<Meta, Body>>(nft_v,0);
                    let meta = NFT::get_type_meta<Meta,Body>(&nft);
                    if(meta.Time <= Timestamp::now_seconds()){
                        NFT::burn_with_cap(&mut cap.Burn_cap,nft);
                        let parent_hash = Block::get_parent_hash();
                        let i = 0;
                        let j:u64 = 0;
                        while(i < 8){
                            let n = (* Vector::borrow<u8>(&parent_hash,(i as u64)) as u64);
                            j = j + ( n << i ) ;
                            i = i + 1;
                        };
                        let random = &mut list.Random;
                        *random = j;
                    }else{
                        Vector::push_back<NFT::NFT<Meta, Body>>( nft_v ,nft);
                    };
                };

            }else{
                let list = NFT_list{Nft:Vector::empty<NFT::NFT<Meta, Body>>(),Random:0};
                
                let cap = borrow_global_mut<Shared_Cap>(AdminAddress());
                let nft = NFT::mint_with_cap_v2<Meta,Body>(addr,&mut cap.Mint_cap,NFT::new_meta(b"RandomNumberGeneratorFlag",b"Random numbers can be obtained by burning this NFT after a specified time"),Meta{Time:Timestamp::now_seconds() + 10 * 1},Body{});
                let nft_v = &mut list.Nft;
                Vector::push_back<NFT::NFT<Meta, Body>>( nft_v ,nft);
                move_to(account,list);
            };
           
            
        }
    }

    module RandomNumberGenerator_Script{
        use 0x08192CFd78098f8F5e17b8824a389424::RandomNumberGenerator;
        public (script) fun getRandomNumber(account:signer){
            RandomNumberGenerator::getRandomNumber(&account);
        }
        public (script) fun init(account:signer){
            RandomNumberGenerator::init(&account);
        }
    }

}