pragma solidity ^0.8.17;

//First Smart Contract written by myself for uni assignment. 
//This is a smart contract that rewards internal points for a hospitality 
//chain. It's design is meant to encourage staff within the chain to 
//help other venues within the same company by getting rewarded per hour 
//in this internal point system. The points can then be implemented within the 
//Venues and used as an internal currency to buy food/drink 
//As it is not an issued tradeable token, their should be no tax obligation

//Version 0.1 // Barebones implementation

contract kapura_coin {

    address private superAdmin;
    uint256 private currentCoins; //current coins in peoples address  
    uint256 private spentCoins; //total coins spent by staff
    uint32 public venueCount;
    uint32 public staffCount;
    uint32 public conversion;
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
    constructor(string memory _name, string memory _symbol, uint32 _conversion) public
    {
        name = _name;
        symbol = _symbol;
        currentCoins = 0;
        spentCoins = 0;
        venueCount = 0;
        staffCount = 0;
        superAdmin = msg.sender;
        conversion = _conversion; //How many coins = $1 local currecny 
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
    mapping (uint => Venues) public _venues;

    //Adding new Venues to the contract. 
    function addVenue(address _venueAddress, string memory _venueName) public 
    {
        require(msg.sender == superAdmin);
        _venues[venueCount] = Venues(_venueAddress, _venueName, venueCount);
        venueCount++;
    }

    //Venue can pay the staff their reward 
    //Checks to see if the current address belongs to a valid venue ID 
    function payStaff(address _venueAddress, uint32 _venueID, uint32 _staffID, uint32 pay) public 
    {
        address owner = msg.sender;
        require(_venues[_venueID].venueAddress == owner);
        _staff[_staffID].kapuraCoins = _staff[_staffID].kapuraCoins + pay;
        setCurrentCoins(pay);
    }

    //Take Payment
    function takePayment(address _venueAddress, uint32 _venueID, address _staffAddress, uint32 _staffID, uint32 payed) public returns (string memory)
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
                }
                else 
                    return "Not enought Balance";
            }
            else
                return "Incorrect Address";
        } 
        else
            return "Wrong Venue Address";
        //subtract from the staff coins
        //add to spent coins
        //subtract from circulating coins
    }


    ////////////////////////////////////////////////////////////////////////
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

    //Adding new staff to the contract // possible to add staff with current ID? 
    function addStaff(address _staffAddress, uint _venueID, string memory _firstName, string memory _lastName) public
    {
        address owner = msg.sender;
        require(_venues[_venueID].venueAddress == owner);
            _staff[staffCount] = Staff(_staffAddress, _firstName, _lastName, 0, staffCount);
            staffCount++;
    }

    //Function to check that checks if the account logged in is requesting their own data.
    //If true returns account info. Else Check if a venue is trying to pull the staff data
    //If the address is from a venue it returns staff Data
    function getStaffData(uint32 _staffID) public view returns (Staff memory)
    {
        address owner = msg.sender;
        if (_staff[_staffID].staffAddress == owner)
            return _staff[_staffID];
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
    }









}

