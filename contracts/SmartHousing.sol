pragma solidity ^0.5.0;
import "../node_modules/@openzeppelin/contracts/access/Roles.sol";
import "../node_modules/@openzeppelin/contracts/ownership/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "./DateTime.sol";
///import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

/**
* @title A house leasing contract
*/

contract SmartHousing is Ownable,DateTime{
    using Roles for Roles.Role;
    //prevent overflow c = a + b becomes c = a.add(b)
    using SafeMath for uint256;
    Roles.Role private tenants;
    address private landlord_address;
    struct Landlord{
        string name;
        string hashed_pid;
        address _address;
    }
    struct Tenant{
        string name;
        string hashed_pid;
        address _address;
    }
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
    // defines contract state
    enum State {Pending, Started, Terminated}
    // main lease contract
    struct LeaseContract{
        uint256 id;
        Landlord landlord;
        Tenant tenant;
        HouseInfo house_info; //basic information about this leasing object

        //Contract Metadata
        uint256 rent; // rent per month
        uint256 utility_bill; ///
        uint8 rent_pay_day; // the day that needs to pay rent, for example 5 means you need to pay rent on 9/5 for September
        uint256 total_term; //total number of term for this contract, unit for term is month
        uint256 deposit; //deposit in unit of month, ex: two months deposit
        State state;
        uint256 start_timestamp; // when the contract actually starts
        uint256 paid_rent_count; //array that records rent payments
        string repair_obligation;///

        //Termination
        Termination termination; //provide terminate time and reason
    }
    //list of all contracts
    LeaseContract[] contracts;
    Landlord landlord;
    // highest valid tokenID or contractID
    uint256 internal maxID;
    // number of contracts
    uint256 private contractNumber;
    //A mapping of terminated contracts, checks if a contract is valid
    mapping(uint256 => bool) internal burned;
    //A mapping of approved address for each contract
    mapping(uint256 => address) internal allowance;

    //Events
    event ContractCreated(string physical_address, string city, uint256 zip_code, string house_type, uint256 id);
    event NewLeaseRequest(string name, string email, uint256 phone_number, uint256 contract_id);
    event ContractStarted(uint256 contract_id, address select_address);
    // constructor() public{
    //     landlord._address = msg.sender;
    // }
    constructor(string memory _landlord_name, string memory _landlord_hashed_pid) public{
        landlord._address = msg.sender;
        landlord.name = _landlord_name;
        landlord.hashed_pid = _landlord_hashed_pid;
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
        return _contractId >= 0 && _contractId <= maxID && !burned[_contractId];
    }
     /**
     * @dev check if this signer is allowed to sign this contract
     */
    function isPermittedSigner(uint256 _contractId, address _signer) internal view returns(bool){
        return contracts[_contractId].tenant._address == _signer;
    }
    /**
     * @dev during the appointment with tenant, landlodrd creates a new contract and wait for tenant to sign
     */
    function addNewContract(address _tenant_address,
                            string memory _physical_address,string memory _city, uint256 _zip_code, string memory _house_type,
                            uint256 _rent, uint256 _utility_bill, uint256 _total_term, uint8 _rent_pay_day, uint256 _deposit,
                            string memory _repair_obligation) public onlyOwner returns(uint256){
        LeaseContract memory newcontract;
        newcontract.landlord = landlord;
        newcontract.house_info = HouseInfo({physical_address:_physical_address, city:_city, zip_code:_zip_code, house_type:_house_type });
        newcontract.id = maxID;
        allowance[newcontract.id] = _tenant_address; //only allow this address to sign the contract
        maxID.add(1);
        newcontract.rent = _rent;
        newcontract.utility_bill = _utility_bill;
        newcontract.total_term = _total_term;
        newcontract.rent_pay_day = _rent_pay_day;
        newcontract.deposit = _deposit;
        newcontract.repair_obligation = _repair_obligation;
        newcontract.state = State.Pending;
        contracts.push(newcontract);
        emit ContractCreated(_physical_address,_city,_zip_code,_house_type,newcontract.id);
        return newcontract.id;
    }
    /**
     * @dev sign the contract and the lease start
     */
    function signContract(string memory _name, string memory _hashed_pid, uint256 _contract_id) public{
        require(isValidContract(_contract_id),'Invalid Contract ID');
        require(isPermittedSigner(_contract_id, msg.sender),'Not Permitted To Sign');
        require(contracts[_contract_id].state == State.Pending,'Not At Pending State');
        Tenant memory new_tenant = Tenant(_name,_hashed_pid,msg.sender);
        tenants.add(msg.sender);
        contracts[_contract_id].tenant = new_tenant;
        contracts[_contract_id].state = State.Started;
    }
     /**
     * @dev remove a tenant and delete his allowance to a contract
     */
     function removeTenant(address _tenant)  public onlyOwner{
         tenants.remove(_tenant);
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
     * @dev obtain list of pending id for a pending contract
     */
     function getContractStatus(uint256 _contract_id) public view returns(State){
         return contracts[_contract_id].state;
     }
      /**
     * @dev obtain the tenant for that contract
     */
     function getContractTenant(uint256 _contract_id) public view returns(string memory, string memory, address){
         return (contracts[_contract_id].tenant.name,contracts[_contract_id].tenant.hashed_pid,contracts[_contract_id].tenant._address);
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
     * @dev terminate contract
     */
     function terminateContract(uint256 _contract_id) internal{
        LeaseContract memory target_contract = contracts[_contract_id];
        target_contract.state = State.Terminated;
        this.removeTenant(target_contract.tenant._address);
        burned[target_contract.id] = true;
     }
     /**
     * @dev check the rent payment status and terminate if neccessary, return unpaid rent count
     */
     function updateContractStatus(uint256 _contract_id) public onlyOwner returns(uint256){
        require(isValidContract(_contract_id),'Invalid Contract ID');
        LeaseContract memory target_contract = contracts[_contract_id];
        uint16 current_term = this.getCurrentTerm(_contract_id);
        //if this tenant owe rent in an amount that exceed his deposit, the contract is terminated
        if(current_term - target_contract.paid_rent_count > target_contract.deposit.add(2)){
            terminateContract(_contract_id);
        }
        //lease end
        else if(current_term > target_contract.total_term){
            terminateContract(_contract_id);
        }
        else{
            return(current_term-target_contract.paid_rent_count);
        }
     }


}