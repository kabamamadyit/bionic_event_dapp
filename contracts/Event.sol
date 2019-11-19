pragma solidity ^0.5.0;
import "./ERC721Full.sol";

/**@title Event */

contract Event is ERC721Full {

    string public name;
    uint256 public startDate;
    uint256 private ticketId;
    uint256 public endDate;
    uint256 public available;
    string public location;
    uint8 private MAX_PURCHASE = 5;
    string public  description;
    bool canceled;
    uint public ticketPrice;
    address payable public  owner;

    /**@dev created new instance of Event 
    @param organizer account address of event organizer creating the event 
    @param _name title of the event
    @param _start start date of event given in unix timestamp
    @param _end end date of event provided in unix timestamp
    @param _description extra description of the event
    @param _location event location
    @param supply available tickets for sell to the event
    @param _ticketPrice ticket price in wei
    */
    constructor(address payable _organizer, 
    string memory _name, 
    uint _start, 
    uint _end,
    string memory _description,  
    string memory _location,
    uint supply, 
    uint _ticketPrice
    ) ERC721Full(_name, "TKT") public {

        name = _name;
        startDate = _start;
        endDate = _end;
        ticketPrice = _ticketPrice;
        available = supply;
        description = _description;
        owner = _organizer;
        location = _location;

    }



    /**@title Purchase ticket
    @dev allows user to purchase ticket for the event
    @param quantity total amount of ticket the user wishes to purchase maximum amount is 5
    */
    function purchaseTicket(uint quantity) public payable {
        require(quantity <= MAX_PURCHASE, "can not purchase more than 5 ticket at once");
        require(available  >= quantity, "not enough ticket quantity available!!!");
        require(msg.value >= ticketPrice.mul(quantity), "not enough money sent");
        
        for(uint8 i = 0; i < quantity; i++) {
            ticketId++;
            available--;
            _mint(msg.sender,ticketId);
        }
    }

    /**
    @title Transfer ticket 
    @dev allow ticket holders to transfer ownership of there ticket to other users
    @param to address of the reciever 
    @param tokenId id of the ticket to be transfered
    */

    function transferTicket(address _to, uint _tokenId) public {
    require(address(0) != _to, "invalid address provided");
    transferFrom(msg.sender, _to, _tokenId);
    }


    /**
    @title is ticket valid
    @dev validated if a given ticket id is owned by the given user 
    @param owner address of the owner of ticket to be validated
    @param tokenId id of the ticket to be validated
    @returns x boolean value holding the result 
    */
    function isTicketValid(address _owner, uint _tokenId) onlyOwner public  returns(bool) {
        if(ownerOf(_tokenId) == _owner) {
            _burn(_tokenId);
            return true;
        }  else {
            return false;
        }
    }


    /**
    @title cancel event
    @dev allows event organizers to cancel events they have created 
    */

  function cancelEvent() onlyOwner public {
      require(now > startDate, "can not cancel event after it has started");
      canceled = true;
  }

  /**
  
  @title get owners tickets 
  @dev returns tickets array owned by a given user
  @param _owner address of the required 
  @returns x arrays of ticket id owned by user
  */
    function getOwnersTicket(address _owner) public view returns(uint[] memory) {
        return _tokensOfOwner(_owner);
    }
    
    /**
    @title collect payment
    @dev lets event organizer get ether collected for tickets sold for the event
     */

    function collectPayment() onlyOwner public {
        require(now > endDate && !canceled, "can not collect payment before the event is over");
        owner.transfer(address(this).balance);
    }

    /**
    @title get refund 
    @dev returns ether for each ticket the user has incase the event is canceled
    @param ticket id of the ticket to get refunds for
     */
    function getRefund(uint  ticket) public {
        require(address(0) != msg.sender, "invalid address provided");
        require(canceled, "refund is only available for cacanceled events");
            _burn(ticket);
        msg.sender.transfer(ticketPrice);

    }

    /**
    @title is canceled
    @dev lets users check if the event is canceled or not
    @returns true or false
     */
    
    function isCanceled() public view returns(bool) {
        return canceled;
    }

    /**
    @title only owner 
    @dev modifier that checked if current request is made by the event owner 
     */
      modifier onlyOwner {
        require(msg.sender == owner, "only event owner is allowed to perform this action");
        _;
    }

}
