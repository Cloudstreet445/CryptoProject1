// SPDX-License-Identifier: Weltec

pragma solidity ^0.8.17;

//First Smart Contract written by myself for uni assignment. 
//This is a smart contract that rewards internal points for a hospitality 
//chain. It's design is meant to encourage staff within the chain to 
//help other venues within the same company by getting rewarded per hour 
//in this internal point system. The points can then be implemented within the 
//Venues and used as an internal currency to buy food/drink 
//As it is not an issued tradeable token, their should be no tax obligation

//Version 0.1.5 // Barebones implementation // Added error handling

contract kapura_coin {

    address private contractOwner; //Genreally the Person withing the company who deploys the contract. 
    uint256 private currentCoins; //current coins in peoples address  
    uint256 private spentCoins; //total coins spent by staff

    
    uint32 private venueCount;
    uint32 private staffCount;
    uint32 private transaction;
    uint32 private accStorage;
    uint32 public conversion; //How many coins your want worth $1 local currecny. e.g 100/1

    string public name;
    string public symbol;

    //These coins are private and for internal use only
    //Their is no cap on the coins. Just tracking of
    //the creation and expenditure of the coins. 
    //Hence, no actual token will be minted, just an 
    //Internal database;
    function getCurrentCoins() public view returns (uint) {
        return currentCoins;
    }
    function setCurrentCoins(uint newCoins) public {
        currentCoins = currentCoins + newCoins;
    }
    function getSpentCoins() public view returns (uint) {
        return spentCoins;
    }
    function setSpentCoins(uint _spentCoins) public {
        currentCoins = currentCoins - _spentCoins;
        spentCoins = spentCoins + _spentCoins;
    }

    //Will need to add a month or weekly tracking of spending coins for stocktake. 
    constructor(string memory _name, string memory _symbol, uint32 _conversion)
    {
        name = _name;
        symbol = _symbol;
        currentCoins = 0;
        spentCoins = 0;
        venueCount = 0;
        staffCount = 0;
        contractOwner = msg.sender;
        conversion = _conversion; //How many coins = $1 local currecny
        //Adding a Nul blank Venue and staff at array[0] 
        //This will be returned if function fails
        addVenue(msg.sender, "Error");  
        addStaff(msg.sender, 0, "Error", " ");
    } 

    ///////////////////////////////////////////////////////////////////////
    ////Venues////
    // Venues can only be created by superAdmin (contract creator) 
    // Staff can only be added by Venues

    struct Venues
    {
        address venueAddress;
        string venueName;
        uint32 venueID;
    }

    struct Staff 
    {
        address staffAddress;
        string firstName;
        string lastName;
        uint32 kapuraCoins;
        uint32 staffID;
    }

    struct Accounting //Possible Accounting method for future concideration
    {
        uint amount;
        uint timeStamp;
        address venue;
        address staff;
    }

    mapping (uint => Venues) public _venues;
    mapping (uint => Staff) public _staff;
    mapping (uint => Accounting) private _accounting;

    //Adding new Venues to the contract. 
    function addVenue(address _venueAddress, string memory _venueName) public 
    {
        require(msg.sender == contractOwner);
        _venues[venueCount].venueAddress = _venueAddress;
        _venues[venueCount].venueName = _venueName;
        _venues[venueCount].venueID = venueCount;
        // _venues[venueCount].venueAccouting.week = 0;
        // _venues[venueCount].venueAccouting.ammount = 0;
         venueCount++;
    }

    //Adding new staff to the contract // possible to add staff with current ID? 
    function addStaff(address _staffAddress, uint _venueID, string memory _firstName, string memory _lastName) public
    {
        address owner = msg.sender;
        require(_venues[_venueID].venueAddress == owner);
        _staff[staffCount] = Staff(_staffAddress, _firstName, _lastName, 0, staffCount);
        staffCount++;
    }

    function accountingTransfer(uint _amount, address _staffAddress) private {
        _accounting[transaction].timeStamp = block.timestamp;
        _accounting[transaction].amount = _amount;
        _accounting[transaction].venue = msg.sender;
        _accounting[transaction].staff = _staffAddress;
        transaction++;
    }

    //Venue can pay the staff their reward 
    //Checks to see if the current address belongs to a valid venue ID 
    function payStaff(uint32 _venueID, uint32 _staffID, uint32 pay) public returns (string memory)
    {
        address owner = msg.sender;
        require(_venues[_venueID].venueAddress == owner);
        _staff[_staffID].kapuraCoins = _staff[_staffID].kapuraCoins + pay;
        setCurrentCoins(pay);
        accountingTransfer(pay, _staff[_staffID].staffAddress);
        return "Success";
    }

    //Take Payment
    function takePayment(uint32 _venueID, address _staffAddress, uint32 _staffID, uint32 payed) public returns (string memory)
    {
        uint32 temp;
        payed = payed*conversion;
        if (_venues[_venueID].venueAddress == msg.sender)
        {
            if (_staff[_staffID].staffAddress == _staffAddress)
            {
                temp = _staff[_staffID].kapuraCoins;
                if (temp > payed)
                {
                    _staff[_staffID].kapuraCoins = _staff[_staffID].kapuraCoins - temp;
                    setSpentCoins(temp);
                    accountingTransfer(payed, _staffAddress);
                    return "Success";
                }
                else 
                    return "Error, Insufficient balance";
            }
            else
                return "Error, You are not the owner of this Account";
        } 
        else
            return "Error, You are not the owner of this Venues";
        //subtract from the staff coins
        //add to spent coins
        //subtract from circulating coins
    }

    //Function to check that checks if the account logged in is requesting their own data.
    //If true returns account info. Else Check if a venue is trying to pull the staff data
    //If the address is from a venue it returns staff Data
    function getStaffData(uint32 _staffID) public view returns(Staff memory)
    {
        address owner = msg.sender;
        if (_staff[_staffID].staffAddress == owner)     //We do not have a require here as it can be 
            return _staff[_staffID];                    //Either staff or venue that looks up information
        else 
        {
            for (uint i = 0; i < venueCount; i++ )
            {
                if (_venues[i].venueAddress == owner)
                {
                    i = venueCount;
                    return _staff[_staffID]; 
                }
            }
        }
        return _staff[0];
    }

    function getAccountingData()public view returns (Accounting[] memory)
    {
        require(msg.sender == contractOwner);
        Accounting[] memory _accounts = new Accounting[](transaction);
        for (uint i = 0; i < transaction; i++) 
        {
            Accounting storage _account = _accounting[i];
            _accounts[i] = _account;
        }
        return _accounts;
    }
}