// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract airbnb {

    address public owner;
    uint256 private counter;

    constructor() {
        counter = 0;
        owner = msg.sender;
    }

    struct rentalInfo {
        string name;
        string city;
        uint256 maxGuests;
        uint256 pricePerDay;
        string[] datesBooked;
        uint256 id;
        address renter;
    }
    
    event rentalCreated (
        string name,
        string city,
        uint256 maxGuests,
        uint256 pricePerDay,
        string[] datesBooked,
        uint256 id,
        address renter 
    );

    event newDatesBooked (
        string[] datesBooked,
        uint256 id,
        address booker,
        string city
    );

    mapping(uint256 => rentalInfo) rentals;
    uint256[] public rentalIds;

    function addRentals(
        string memory name,
        string memory city,
        uint256 maxGuests,
        uint256 pricePerDay,
        string[] memory datesBooked
     ) public {
        require(msg.sender == owner, "Only the owner of the smart contract can put up rentals");
        rentalInfo storage newRental = rentals[counter];
        newRental.name = name;
        newRental.city = city;
        newRental.maxGuests = maxGuests;
        newRental.pricePerDay = pricePerDay;
        newRental.datesBooked = datesBooked;
        newRental.id = counter;
        newRental.renter = owner;
        rentalIds.push(counter);

        emit rentalCreated(
            name, city, maxGuests, pricePerDay, datesBooked, counter, owner
        );

        counter++;
    }

    function checkBookings(uint256 id, string[] memory newBookings) private view returns (bool) {

        for (uint i = 0; i < newBookings.length; i++) {
            for (uint j = 0; j < rentals[id].datesBooked.length; j++) {
                if(keccak256(abi.encodePacked(rentals[id].datesBooked[j])) == keccak256(abi.encodePacked(newBookings[i]))){
                    return false;
                }
            }
        }
        return true;
    }
    
    function addDatesBooked(uint256 id, string[] memory newBookings) public payable {

        require(id < counter, "No such Rental");
        require(checkBookings(id, newBookings), "Already booked for requested date");
        require(msg.value == (rentals[id].pricePerDay * 1 ether * newBookings.length) , "Please submit the asking price");

        for (uint i = 0; i < newBookings.length; i++) {
            rentals[id].datesBooked.push(newBookings[i]);
        }

        payable(owner).transfer(msg.value);
        emit newDatesBooked(newBookings, id, msg.sender, rentals[id].city);
    }

    function getRental(uint256 id) public view returns (string memory, uint256, string[] memory){
        require(id < counter, "No such Rental");

        rentalInfo storage s = rentals[id];
        return(s.name, s.pricePerDay, s.datesBooked);
    }
}

