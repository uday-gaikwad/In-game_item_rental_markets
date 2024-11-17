module In_game_item_rental_markets::ItemRental {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing an item rental listing
    struct RentalListing has store, key {
        item_id: u64,        // Unique ID for the item
        owner: address,      // Owner of the item
        rental_price: u64,   // Price per rental period (in tokens)
        is_rented: bool,     // Flag to check if the item is rented
    }

    /// Function to create a rental listing for an item
    public fun create_rental_listing(owner: &signer, item_id: u64, rental_price: u64) {
        let listing = RentalListing {
            item_id,
            owner: signer::address_of(owner),
            rental_price,
            is_rented: false,
        };
        move_to(owner, listing);
    }

    /// Function for users to rent an item from a listing
    public fun rent_item(renter: &signer, item_owner: address, item_id: u64) acquires RentalListing {
        let listing = borrow_global_mut<RentalListing>(item_owner);

        // Ensure the item is available for rent
        assert!(!listing.is_rented, 100, "Item is already rented");

        // Transfer the rental payment from the renter to the item owner
        let payment = coin::withdraw<AptosCoin>(renter, listing.rental_price);
        coin::deposit<AptosCoin>(listing.owner, payment);

        // Mark the item as rented
        listing.is_rented = true;
    }
}
