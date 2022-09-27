pragma solidity ^0.8.17;


contract kapura_coin {

    uint256 private currentCoins; //current coins in peoples address  
    uint256 private spentCoins; //total coins spent by staff
    uint32 public venueCount;
    uint32 public staffCount;
    address private superAdmin;
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
    function setSpentCoins(uint newCoins) public {
        currentCoins = spentCoins - newCoins;
        spentCoins = spentCoins + newCoins;
    }

    constructor() public
    {
        name = "kapuraCoin";
        symbol = "kpc";
        currentCoins = 0;
        spentCoins = 0;
        venueCount = 0;
        staffCount = 0;
        superAdmin = msg.sender;
    } 


    ////Venues////
    // Venues can only be created by superAdmin (contract creator) 
    // Staff can only be added by Venues
    struct Venues
    {
        address venueAddress;
        string venueName;
        uint32 venueID;
    }
    mapping (uint => Venues) public _venues;

    //Adding new Venues to the contract. 
    function addVenue(address _venueAddress, string memory _venueName) public 
    {
        if(msg.sender == superAdmin)
        {
            _venues[venueCount] = Venues(_venueAddress, _venueName, venueCount);
            venueCount++;
        }
    }

    //Venue can pay the staff their reward 
    //Checks to see if the current address belongs to a valid venue ID 
    function payStaff(address _venueAddress, uint32 _venueID, uint32 _staffID, uint32 pay) public 
    {
        address owner = msg.sender;
        if (_venues[_venueID].venueAddress == owner)
        { 
            _staff[_staffID].kapuraCoins = _staff[_staffID].kapuraCoins + pay;
            setCurrentCoins(pay);
        }
    }

    ////Staff////
    struct Staff
    {
        address staffAddress;
        string firstName;
        string lastName;
        uint32 kapuraCoins;
        uint32 staffID;
    }
    mapping (uint => Staff) public _staff;

    //Adding new staff to the contract
    function addStaff(address _staffAddress, uint _venueID, string memory _firstName, string memory _lastName) public
    {
        address owner = msg.sender;
        if (_venues[_venueID].venueAddress == owner)
        {
            _staff[staffCount] = Staff(_staffAddress, _firstName, _lastName, 0, staffCount);
            staffCount++;
        }
    }

    //Function to check that checks if the account logged in is requesting their own data.
    //If true returns account info. Else Check if a venue is trying to pull the staff data
    //If the address is from a venue it returns staff Data
    function getStaffData(uint32 _staffID) public view returns (Staff memory)
    {
        address owner = msg.sender;
        if (_staff[_staffID].staffAddress == owner)
        {
            return _staff[_staffID];
        } else {
            for (uint i = 0; i < venueCount; i++ )
            {
                if (_venues[i].venueAddress == owner)
                {
                    i = venueCount;
                    return _staff[_staffID]; 
                }
            }
        }
    }







}

