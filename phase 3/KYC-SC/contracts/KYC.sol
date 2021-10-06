 pragma solidity ^0.5.9;

contract KYC{


    //customer struct
    struct Customer {
        string userName;
        string data;
        address bank;
        bool kycStatus;
        uint downVotes;
        uint upVotes;
    }

    //bank struct
    struct Bank {
        string name;
        address ethAddress;
        string regNumber;
        uint complaintsReported;
        uint KYC_count;
        bool isAllowedToVote;
    }

    //kyc struct
    struct kycRequest{

        string userName;
        address bankAddress;
        string customerData;
    }

    //variable to hold the total count of banks
    uint public  bankCount;

    //variable to hold the address of admin account
    address public admin;

    //request list mapping of customer name with it's kycRequest details in kycRequest struct
    //kyc request list
    mapping (string=>kycRequest) public request;

    //customer list mapping of customer name with its details in customer struct
    //customer list
    mapping(string => Customer)public  customers;

    //bank list mapping of bank address with its details in bank struct
    //bank list
    mapping(address => Bank) public  banks;

    constructor()public{

        admin=msg.sender;
        bankCount=0;
    }


    //this function will add a customer to the customer list
    function AddCustomer(string memory _userName, string memory _customerData) public {

        //the bank should be present in bank list in order to add a customer in customer list
        require(banks[msg.sender].ethAddress!=address(0),"Bank is not present in the database");

        /*if customer is not present in the customer list , add the customer (if bank address of customer is blank
        it means customer is not in the list) */
        require(customers[_userName].bank == address(0), "Customer is already present, please call modifyCustomer to edit the customer data");


        customers[_userName].userName = _userName;
        customers[_userName].data = _customerData;
        customers[_userName].bank = msg.sender;
        customers[_userName].upVotes=0;
        customers[_userName].downVotes=0;
    }

    //this function allows a bank to view the details of a customer
    function ViewCustomer(string memory _userName) public view returns (string memory, string memory, address) {

        //the bank should be present in bank list in order to view a customer in customer list
        require(banks[msg.sender].ethAddress!=address(0),"Bank is not present in the database");

        /*if customer is present in the customer list , view the customer details
       (if bank address of customer is not  blank it means customer is in the list) */
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        return (customers[_userName].userName, customers[_userName].data, customers[_userName].bank);
    }

    /* this function allows a bank to modify a customer's data . This will remove the customer from the kyc request list and
    set the number of upvotes and downvotes to zero*/

    function ModifyCustomer(string memory _userName, string memory _newcustomerData) public {

        //the bank should be present in bank list in order to modify a customer in customer list
        require(banks[msg.sender].ethAddress!=address(0),"Bank is not present in the database");

        /*if customer is present in the customer list , modify the customer details in the customer list
      (if bank address of customer is not  blank it means customer is in the list) */

        require(customers[_userName].bank != address(0), "Customer is not present in the database");

        customers[_userName].data = _newcustomerData;
        customers[_userName].upVotes=0;
        customers[_userName].downVotes=0;
        delete request[_userName];
    }

    //this function is used to add the KYC request to the requests list
    function AddRequest(string memory _userName,string memory _customerData) public{

        //the bank should be present in bank list in order to add a kyc request for the  _newcustomerData
        require(banks[msg.sender].ethAddress!=address(0),"Bank is not present in the database");

        /*if customer is present in the customer list , add the customer request to request list
        (if bank address of customer is not  blank it means customer is in the list) */

        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        request[_userName].userName=_userName;
        request[_userName].customerData=_customerData;
        request[_userName].bankAddress=msg.sender;
    }

    //this function will remove the request from the request list
    function RemoveRequest(string memory _userName) public{

        //the bank should be present in bank list in order to remove a kyc request of customer in kyc request list
        require(banks[msg.sender].ethAddress!=address(0),"Bank is not present in the database");

        /*if customer is present in the customer list , remove the customer request from  request list
      (if bank address of customer is not  blank it means customer is  in the list)   */

        require(customers[_userName].bank != address(0), "Customer is not present in the database");

        delete request[_userName];

    }
    /*this function allows a bank to cast an upvote for a customer . This vote from a bank means it accepts the customer details
    as well as acknowledge the KYC process done by some bank for the customer*/

    function UpvoteCustomer(string memory _userName)public{

        //the bank should be present in bank list in order to upvote a customer in customer list
        require(banks[msg.sender].ethAddress!=address(0),"Bank is not present in the database");

        //only valid banks should be allowed to upvote a customer
        require(banks[msg.sender].isAllowedToVote==true,"This bank is banned from upvoting/downvoting");

        /*if customer is present in the customer list , upvote the customer
      (if bank address of customer is not  blank it means customer is  in the list)  */

        require(customers[_userName].bank!=address(0),"Customer is not present in the database");

        customers[_userName].upVotes+=1;

        uint threshold=bankCount/3;

        //if number of upvotes is greater than downVotes , set kycStatus of customer as true for customer
        if(customers[_userName].upVotes>customers[_userName].downVotes && customers[_userName].downVotes<threshold){

            customers[_userName].kycStatus=true;

        }
        /* else if the number of downvotes is greater than or equal to threshold, set kycStatus as false for customer
        and the "isAllowedToVote" property of bank who is upvoting to false */

        else  if(customers[_userName].downVotes>=threshold){

            customers[_userName].kycStatus=false;
            banks[msg.sender].isAllowedToVote=false;
        }

    }

    /*this function allows a bank to cast a downvote for the customer . This vote from a bank means that it does not accept the
    customer details*/

    function DownVoteCustomer(string memory _userName)public{

        //the bank should be present in bank list in order to downvote a customer in customer list
        require(banks[msg.sender].ethAddress!=address(0),"Bank is not present in the database");

        //only valid banks should be allowed to downVote a customer
        require(banks[msg.sender].isAllowedToVote==true,"bank is banned from upvoting/downvoting");

        /*if customer is present in the customer list , downvote the customer
      (if bank address of customer is not  blank it means customer is  in the list) */

        require(customers[_userName].bank!=address(0),"Customer is not present in the database");

        customers[_userName].downVotes+=1;

        uint threshold=bankCount/3;

        //if number of upvotes is greater than downVotes , set kycStatus of customer as true for customer
        if(customers[_userName].upVotes>customers[_userName].downVotes && customers[_userName].downVotes<threshold){

            customers[_userName].kycStatus=true;

        }
        //else if the number of downvotes is greater than or equal to threshold, set kycStatus as false for customer
        else  if(customers[_userName].downVotes>=threshold){

            customers[_userName].kycStatus=false;
        }

    }

    //this function is used to fetch bank complaints from the smart contract
    function GetBankComplaints(address bankAddress) view public returns(uint){

        //the bank should be present in bank list in order to fetch compains of a bank
        require(banks[msg.sender].ethAddress!=address(0),"Bank is not present in the database");

        /* if the bank is present in the bank list , fetch the complaints reported for bank
        (if the ethAddress of bank is not blank , bank is present in the bank list) */

        require(banks[bankAddress].ethAddress!=address(0),"Bank should be present in the bank list");

        return banks[bankAddress].complaintsReported;
    }

    //this function is used to fetch bank details
    function ViewBankDetails(address bankAddress) view public returns(string memory,address,string memory,uint,uint,bool){

        //the bank should be present in bank list in order to view details of a bank
        require(banks[msg.sender].ethAddress!=address(0),"Bank is not present in the database");

        /* if the bank is present in the bank list , view bank details
       (if the ethAddress of bank is not blank , bank is present in the bank list) */

        require(banks[bankAddress].ethAddress!=address(0),"Bank should be present in the bank list");

        return (banks[bankAddress].name,banks[bankAddress].ethAddress,banks[bankAddress].regNumber,banks[bankAddress].complaintsReported,banks[bankAddress].KYC_count,banks[bankAddress].isAllowedToVote);
    }

    /*This function is used to report a complaint against any bank in the network. It will also modify the "isAllowedToVote"
    status of the bank according to the conditions mentioned in the problem statement*/

    function ReportBank(address bankAddress)public{

        //the bank should be present in bank list in order to report complain  of a bank
        require(banks[msg.sender].ethAddress!=address(0),"Bank is not present in the database");

        /* if the bank is present in the bank list , report a complain against the bank and set isAllowedToVote variable
        based on condition  (if the ethAddress of bank is not blank , bank is present in the bank list) */

        require(banks[bankAddress].ethAddress!=address(0),"Bank should be present in the bank list");

        banks[bankAddress].complaintsReported+=1;

        uint threshold=bankCount/3;

        /* if more than 1/3 of total number of banks have reported complain against this bank , set "isAllowedToVote" status as
        false */

        if(banks[bankAddress].complaintsReported>=threshold){

            banks[bankAddress].isAllowedToVote=false;
        }


    }

    //modifier to check if the function is called by admin only
    modifier checkAdmin(){

        require(msg.sender==admin,"method invoked by non-admin");
        _;
    }

    /* this function is used by the admin to add a bank to the KYC contract , you need to verify whether the user trying to
    call this function is an admin or not*/
    function AddBank(string memory bankName,address bankAddress,string memory registrationNumber)public checkAdmin{


        /* if the bank is not present in the bank list , add the bank to the bank list
      (if the ethAddress of bank is not blank , bank is present in the bank list) */

        require(banks[bankAddress].ethAddress==address(0),"Bank already present in the banks list");



        banks[bankAddress].name=bankName;
        banks[bankAddress].ethAddress=bankAddress;
        banks[bankAddress].regNumber=registrationNumber;
        banks[bankAddress].complaintsReported=0;
        banks[bankAddress].isAllowedToVote=true;
        banks[bankAddress].KYC_count=0;
        bankCount+=1;
    }

    /* this function can only be used by the admin to change the status of "isAllowedToVote" of any of the banks at any point
    of time */

    function ModifyIsAllowedToVote(address bankAddress, bool status)public checkAdmin{



        /* if the bank is  present in the bank list , change the status of "isAllowedToVote"
    (if the ethAddress of bank is not blank , bank is present in the bank list) */

        require(banks[bankAddress].ethAddress!=address(0),"Bank not present in the banks list");

        banks[bankAddress].isAllowedToVote=status;
    }

    /* this function is used by the admin to remove a bank from KYC contract . you need to verify whether the user trying to
    call this function is the admin or not */

    function RemoveBank(address bankAddress)public checkAdmin{


        /* if the bank is  present in the bank list , remove the bank from banks list
    (if the ethAddress of bank is not blank , bank is present in the bank list) */

        require(banks[bankAddress].ethAddress!=address(0),"Bank not present in the banks list");


        delete banks[bankAddress];

        bankCount-=1;
    }

}


