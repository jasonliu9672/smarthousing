pragma solidity ^0.5.0;
import "../node_modules/@openzeppelin/contracts/access/Roles.sol";
import "../node_modules/@openzeppelin/contracts/ownership/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "./DateTime.sol";
///import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

/**
* @title A house leasing contract
* @author Jason Liu
* @notice 
* @dev 
*/

contract HouseContract is Ownable,DateTime{
    using Roles for Roles.Role;
    //prevent overflow c = a + b becomes c = a.add(b)
    using SafeMath for uint256;
    Roles.Role private tenants;
    address private landlord;

    struct HouseInfo{
        string physical_address;
        string city;
        uint256 zip_code;
        //house_type indicate studio, two bedrooms, etc
        string house_type;
    }
    struct Termination{
        uint256 timestamp;
        string reason;
    }
    struct RequestInfo{
        string name;
        string email;
        uint256 phone_number;
    }
    // defines contract state
    enum State {Created, Pending, Started, Terminated}
    // main lease contract
    struct LeaseContract{
        uint256 id;
        address tenant;
        HouseInfo house_info; //basic information about this leasing object

        //Contract Metadata
        uint256 rent; // rent per month
        uint8 rent_pay_day; // the day that needs to pay rent, for example 5 means you need to pay rent on 9/5 for September
        uint256 total_term; //total number of term for this contract, unit for term is month
        uint256 deposit; //deposit in unit of month, ex: two months deposit
        State state;
        uint256 start_timestamp; // when the contract actually starts
        uint256 paid_rent_count; //array that records rent payments

        //Pending
        address[] pending_list; //list of address for all request accounts
        mapping(address => RequestInfo) pending_list_info; //personal info for each request

        //Termination
        Termination termination; //provide terminate time and reason
    }
    //list of all contracts
    LeaseContract[] contracts;
    // highest valid tokenID or contractID
    uint256 internal maxID;
    // number of contracts
    uint256 private contractNumber;
    //A mapping of terminated contracts, checks if a contract is valid
    mapping(uint256 => bool) internal burned;
    //A mapping of approved address for each contract
    mapping(uint256 => address) internal allowance;

    //A nested mapping for managing "operator"
    mapping(address => mapping(address => bool)) internal authorised;

    //Events
    event ContractCreated(string physical_address, string city, uint256 zip_code, string house_type, uint256 id);
    event NewLeaseRequest(string name, string email, uint256 phone_number, uint256 contract_id);
    event ContractStarted(uint256 contract_id, address select_address);
    constructor() public{
        landlord = msg.sender;
    }
    /**
     * @dev check if one month payment is not less than require rent
     */
    function isValidAmount(uint256 _contractId, uint256 _payment) internal view returns(bool){
        return _payment == contracts[_contractId].rent * 1 ether;
    }
    /**
     * @dev check if a contract, its id should be valid and is not burned
     */
    function isValidContract(uint256 _contractId) internal view returns(bool){
        //return _contractId != 0 && _contractId <= maxID && !burned[_contractId];
        return _contractId >= 0 && _contractId <= maxID;
    }
    /**
     * @dev create a new contract with leasing details for people to view
     */
    function addNewContract(string memory _physical_address, string memory _city, uint256 _zip_code, string memory _house_type,
                            uint256 _rent, uint256 _total_term, uint8 _rent_pay_day) public onlyOwner returns(uint256){
        LeaseContract memory newcontract;
        newcontract.house_info = HouseInfo({physical_address:_physical_address, city:_city, zip_code:_zip_code, house_type:_house_type });
        newcontract.id = maxID;
        maxID.add(1);
        newcontract.rent = _rent;
        newcontract.total_term = _total_term;
        newcontract.rent_pay_day = _rent_pay_day;
        newcontract.state = State.Created;
        contracts.push(newcontract);
        emit ContractCreated(_physical_address,_city,_zip_code,_house_type,newcontract.id);
        return newcontract.id;
    }
    /**
     * @dev return house info, rent, and term for specific contract
     */
    function getContractHouseInfo(uint256 _contract_id) public view returns(string memory, string memory, uint256, string memory
                                                                           ,uint256, uint256){
        require(isValidContract(_contract_id),'Invalid Contract ID');
        HouseInfo memory house_info = contracts[_contract_id].house_info;
        return (house_info.physical_address, house_info.city, house_info.zip_code, house_info.house_type, contracts[_contract_id].rent,
                contracts[_contract_id].total_term);
    }
    /**
     * @dev add a new tenant and map him to a corresponding contract
     */
    function addNewTenant(address _newtenant, uint256 _contract_id) internal onlyOwner{
        require(isValidContract(_contract_id),'Invalid Contract ID');
        require(_newtenant != landlord,'Cannot Add Yourself');
        tenants.add(_newtenant);
        allowance[_contract_id] = _newtenant;
    }
     /**
     * @dev remove a tenant and delete his allowance to a contract
     */
     function removeTenant(address _tenant)  public onlyOwner{
         tenants.remove(_tenant);
     }
    /**
     * @dev request from tenant who wants to rent a house and desire to start the leasing process
     */
    function requestLease(string memory _name, string memory _email, uint256 _phone_number, uint256 _contract_id /**uint256 nonce,
                         bytes memory signature*/) public {
        //amount is in amountGet terms
        //bytes32 hash = keccak256(abi.encodePacked(this, _name, _email, _phone_number, _contract_id, nonce));
        require(isValidContract(_contract_id),'Invalid Contract ID');
        //require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash),v,r,s) == user, 'invalid signature');
        RequestInfo memory new_request = RequestInfo(_name,_email,_phone_number);
        contracts[_contract_id].pending_list.push(msg.sender);
        contracts[_contract_id].pending_list_info[msg.sender] = new_request;
        contracts[_contract_id].state = State.Pending;
        //now wait for the landlord to verify request, contact with tenant and authorize access to the contract
    }
    /**
     * @dev obtain list of pending id for a pending contract
     */
     function getContractStatus(uint256 _contract_id) public view returns(State){
         return contracts[_contract_id].state;
     }
    /**
     * @dev obtain list of pending id for a pending contract
     */
    function getContractPendingList(uint256 _contract_id) public view onlyOwner returns(address[] memory){
        return contracts[_contract_id].pending_list;
    }
     /**
     * @dev select one pending request to start the contract
     */
     function selectPendingRequest(uint256 _contract_id, address _select_address) public onlyOwner{
        require(contracts[_contract_id].state == State.Pending, "Contract Does Not Have Pending Requests");
        contracts[_contract_id].tenant = _select_address;
        contracts[_contract_id].state = State.Started;
        contracts[_contract_id].start_timestamp = now;
        addNewTenant(_select_address,_contract_id);

     }
     /**
     * @dev return current term of the given contract
     */
     function getCurrentTerm(uint256 _contract_id)public view returns(uint16){
        uint8 current_month = getMonth(now);
        uint16 current_year = getYear(now);
        uint8 started_month = getMonth(contracts[_contract_id].start_timestamp);
        uint16 started_year = getYear(contracts[_contract_id].start_timestamp);
        return current_year * 12 + current_month - started_year * 12 + started_month;
     }
     /**
     * @dev pay rent to the contract
     */
     function payRent(uint256 _contract_id) public payable{
        require(tenants.has(msg.sender),"Does Not Have Tenant Role");
        require(isValidContract(_contract_id),'Invalid Contract ID');
        require(isValidAmount(_contract_id,msg.value),'Invalid Payment Amount');
        uint16 current_term = this.getCurrentTerm(_contract_id);
        LeaseContract memory target_contract = contracts[_contract_id];
        if(target_contract.paid_rent_count < current_term){
            target_contract.paid_rent_count.add(1);
        }
        else{
            msg.sender.transfer(address(this).balance);
        }
     }
     /**
     * @dev check the rent payment status and terminate if neccessary
     */
     function checkRentPaymentStatus(uint256 _contract_id) public view onlyOwner returns(uint256){
        require(isValidContract(_contract_id),'Invalid Contract ID');
        LeaseContract memory target_contract = contracts[_contract_id];
        uint16 current_term = this.getCurrentTerm(_contract_id);
        //if this tenant owe rent in an amount that exceed his deposit, the contract is terminated
        if(current_term - target_contract.paid_rent_count > target_contract.deposit.add(2)){
            target_contract.state = State.Terminated;
        }
        else{
            return(current_term-target_contract.paid_rent_count);
        }
     }


}