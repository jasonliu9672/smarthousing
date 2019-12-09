const HouseContract = artifacts.require("HouseContract");

contract("HouseContract", accounts =>{
    let houseContract;
    var mainAccount = accounts[0]
    beforeEach(async () => {
        houseContract = await HouseContract.deployed();
    })
    it('should set account 1 as owner', async ()=>{
        let owner = await houseContract.owner.call({from:mainAccount});
        assert.equal(owner,mainAccount,"owner wasn't properly set");
    });
    it('should get the first added contract info', async () =>{
        let physical_address = "2555 main street apt 30433";
        let city = "Irvine";
        let zip_code = 92614;
        let house_type = "2Bed2Bath";
        let rent = "2500";
        let term = "12";
        let pay_day = "5";
        let contract_id = 0;
        return houseContract.addNewContract(physical_address,city,zip_code,house_type,rent,term,pay_day,{from:mainAccount
        }).then(function(result) {
            return houseContract.getContractHouseInfo(contract_id)
        }).then(function(house_info){
            assert.equal(house_info[0],physical_address, 'not the same address');
            assert.equal(house_info[1],city, 'not the same city');
            assert.equal(house_info[2], 92614, 'not the same zip code');
        })
    })
    it('should start the contract after selecting a new pending request', async () =>{
        const account_three = accounts[2];
        let name = "Jason Liu";
        let email = "jasonliu3838@gmail.com";
        let phone_number = "0926066629";
        let contract_id = 0;
        return houseContract.requestLease(name,email,phone_number,contract_id,{from:account_three
        }).then(function(result){
            return houseContract.selectPendingRequest(contract_id,account_three)
        }).then(function(result){
            return houseContract.getContractStatus.call(contract_id);
        }).then(function(state){
            assert.equal(state,2,'contract is not in the right state');
        })
    })
    // it("add a first leasecontract", async ()=>{
    //     const account_three = accounts[2];
    //     let physical_address = "2555 main street apt 30433";
    //     let city = "Irvine";
    //     let zip_code = 92614;
    //     let house_type = "2Bed2Bath";
    //     let rent = "2500";
    //     let term = "12";
    //     let pay_day = "5";
    //     let tx = await houseContract.addNewContract(physical_address,city,zip_code,house_type,rent,term,pay_day,{from:account_three});
    //     //let house_info = await houseContract.getContractHouseInfo.call(contract_id);
    //     assert.strictEqual(tx.receipt.logs.length, 1, "addNewContract() call did not log 1 event");
    //     // assert.equal(house_info[2], zip_code, 'not the same contract');
    // });
    // it("get a contract info", async ()=>{
    //     let contract_id = 0;
    //     let house_info = await houseContract.getContractHouseInfo(contract_id);
    //     assert.equal(house_info[0],"2555 main street apt 30433", 'not the same address');
    //     assert.equal(house_info[2], 92614, 'not the same zip code');
    // });
    // it("request for lease to the sepecific contract", async ()=>{
    //     const account_one = accounts[0];
    //     let name = "Jason Liu";
    //     let email = "jasonliu3838@gmail.com";
    //     let phone_number = "0439945345"
    //     let contract_id = 0;
    //     await houseContract.requestLease(name,email,phone_number,contract_id,{frome:account_one});

    // })
    // it("add a new tenant to the contract")
})