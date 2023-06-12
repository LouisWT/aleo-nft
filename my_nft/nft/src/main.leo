// The 'nft' program.
program nft.aleo {
    record nft {
        owner: address,
        gates: u64,
        symbol: u128,
        data1: u128,
        data2: u128,
    }

    struct NftData {
        value1: u128,
        value2: u128,
    }

    mapping nft_totals: field => u8;

    mapping nft_owner_data1: address => u128;

    mapping nft_owner_data2: address => u128;

    transition initialize(public value1: u128, public value2: u128) -> u32 {
        assert_eq(self.caller, aleo1y9mnptjc23wxtnr6gnjac0efu4fq859dsjk8mmryj3rg0feq0qzs8awmhn);
        let nft_data: NftData = NftData {
            value1: value1,
            value2: value2,
        };
        let h: field = BHP256::hash(nft_data);
        return then finalize(h);
    }

    finalize initialize (public hash: field) {
        let current_amount: u8 = Mapping::get_or_init(nft_totals, hash, 0u8);
        Mapping::set(nft_totals, hash, current_amount + 1u8);
    }

    transition mint(public owner: address, public data1: u128, public data2: u128) -> nft {
        let item: nft = nft {
            owner: owner,
            gates: 0u64,
            symbol: 86795840032555669230657698889553936384u128,
            data1: data1,
            data2: data2,
        };
        let d: NftData = NftData {
            value1: data1,
            value2: data2,
        };
        let h: field = BHP256::hash(d);
        return item then finalize(h);
    }

    finalize mint(public hash: field) {
        let current_amount: u8 = Mapping::get_or_init(nft_totals, hash, 0u8);
        Mapping::set(nft_totals, hash, current_amount - 1u8);
    }

    transition transfer_private (public item: nft, private recevier: address) -> nft {
        assert_eq(item.owner, self.caller);
        let new_item: nft = nft {
            owner: recevier,
            gates: item.gates,
            symbol: item.symbol,
            data1: item.data1,
            data2: item.data2,
        };
        return new_item;
    }

    transition convert_private_to_public (public item: nft) {
        assert_eq(item.owner, self.caller);
        return then finalize(item.owner, item.data1, item.data2);
    }

    finalize convert_private_to_public (public owner: address, public data1: u128, public data2: u128) {
        let current_data1: u128 = Mapping::get_or_init(nft_owner_data1, owner, 0u128);
        Mapping::set(nft_owner_data1, owner, current_data1 + data1);
        let current_data2: u128 = Mapping::get_or_init(nft_owner_data2, owner, 0u128);
        Mapping::set(nft_owner_data2, owner, current_data2 + data2);
    }

    transition convert_public_to_private(public data1: u128, public data2: u128) -> nft {
        let item: nft = nft {
            owner: self.caller,
            gates: 0u64,
            symbol: 86795840032555669230657698889553936384u128,
            data1: data1,
            data2: data2,
        };
        return item then finalize(self.caller, data1, data2);
    }

    finalize convert_public_to_private(public owner: address, public data1: u128, public data2: u128) {
        let current_data1: u128 = Mapping::get_or_init(nft_owner_data1, owner, 0u128);
        Mapping::set(nft_owner_data1, owner, current_data1 - data1);
        let current_data2: u128 = Mapping::get_or_init(nft_owner_data2, owner, 0u128);
        Mapping::set(nft_owner_data2, owner, current_data2 - data2);
    }

    transition transfer_public (private receiver: address, private data1: u128, private data2: u128) {
        return then finalize(self.caller, receiver, data1, data2);
    }

    finalize transfer_public (public owner: address, public receiver: address, public data1: u128, data2: u128) {
        let owner_data1: u128 = Mapping::get_or_init(nft_owner_data1, owner, 0u128);
        Mapping::set(nft_owner_data1, owner, owner_data1 - data1);
        let owner_data2: u128 = Mapping::get_or_init(nft_owner_data2, owner, 0u128);
        Mapping::set(nft_owner_data2, owner, owner_data2 - data2);

        let receiver_data1: u128 = Mapping::get_or_init(nft_owner_data1, receiver, 0u128);
        Mapping::set(nft_owner_data1, owner, receiver_data1 + data1);
        let receiver_data2: u128 = Mapping::get_or_init(nft_owner_data2, receiver, 0u128);
        Mapping::set(nft_owner_data2, owner, receiver_data2 + data2);
    }
}
