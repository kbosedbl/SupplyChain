pragma solidity >=0.8.1 < 0.9.0;

contract SupplyChainDataManagement {
    
    // Struct to store historical data
    struct User {
        string userID;
        string aadharID;
        string name;
        string stakeholderType;
    }

    struct Time {
        uint day;
        int month;
        uint year;
    }

    struct Medicine {
        string batchCode;
        string medicineName;
        string idOfUser;
        uint quantitySoldInNumbers;
        Time timeOfSelling;
        string addedByStakeHolderType;
        Time mfdDate;
        Time expDate;    
        //string medicineType;    
    }

    struct UnitMedicineMonth{
        uint units;
        int256 month;
        uint year;
    }

    struct MonthAndYear{
        uint month;
        uint year;
    }
    
    // Array to store historical data
    User[] private users;
    Medicine[] public  medicines;
    uint i = 0;

    event log(uint256 A , uint256 B , uint256 C ,uint256 D ,uint256 E);

    string public letters = "abcdefghijklmnopqrstuvwxyz";
    // I needed to add this to the random function to generate a different random number
    uint counter =1;

    
    function compareStrings(string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }


    // Function to add historical data
    function registerUser(string calldata _aadharID, string calldata _name, string calldata _stakeholderType) public returns (string memory) {
        // Create a new HistoricalData object with the given season and value
        string memory _userID = randomString();
        User memory user = User(_userID, _aadharID, _name , _stakeholderType);
        // Add the new data to the historical data array
        for(i = 0 ; i < users.length ; i++) {
            if(compareStrings(users[i].aadharID , _aadharID )) {
                return "Already Exists";
            }
        }
        users.push(user);
        return _userID;
    }    



    // ID parameter
    function addMedicine(string memory _batchCode, string calldata _medicineName, uint256 _medicineQuantity, string calldata _userID ,
    Time calldata _timeOfSell,Time calldata _mfdDate , Time calldata _expDate) public returns (int256) {
        string memory _typeOfStakeHolder = findStakeHolderByUserID(_userID);
        Medicine memory medicine = Medicine(_batchCode, 
        _medicineName , _userID, _medicineQuantity, _timeOfSell , _typeOfStakeHolder , _mfdDate , _expDate);
        // Add the new data to the historical data array
        for(uint i = 0 ; i < medicines.length ; i++) {
            if(compareStrings(medicines[i].batchCode , _batchCode)) {
                return -1;
            }
        }
        medicines.push(medicine);
        return 1;//_medicineID;
    }

    function findStakeHolderByUserID(string memory _userID) public view returns(string memory){
        for(uint i = 0 ; i < users.length ; i++) {
            if(compareStrings(_userID, users[i].userID)) {
                return users[i].stakeholderType;
            }
        }
        return "Retailer";
    }
    
    // Function to get the seasonal forecast for a given season
    function getSeasonalForecast(int startMonth , int endMonth , string memory medicineName , string memory level) external returns (uint256[] memory) {
        // Variables to keep track of the sum of values and count of data points for the given season
        uint256[] memory quantity = new uint256[]((uint)(endMonth - startMonth + 1));
        // Iterate through all historical data points
        for(int256 month = startMonth ; month <= endMonth ; month++){
            uint256 sumOfValues = 0;
            uint256 dataPointCount = 0;        
            for (uint256 i = 0; i < medicines.length; i++) {
                // Check if the season of the current data point matches the given season
                if (medicines[i].timeOfSelling.month == month && compareStrings(medicineName, medicines[i].medicineName) && 
                compareStrings(level, medicines[i].addedByStakeHolderType)) {
                    // Add the value of the current data point to the sum
                    sumOfValues += medicines[i].quantitySoldInNumbers;
                    // Increment the count of data points
                    dataPointCount++;
                }
            }
            uint256 averageValue = sumOfValues / dataPointCount;
            quantity[(uint256)(month - startMonth)] = averageValue;
        }
        
        // Calculate the average value for the given season
        return quantity;
    }

    function getMovingAvgForecast(int k, int startMonth, int endMonth, string memory medicineName , string memory level) external returns (int256[] memory) {
        // Variables to keep track of the sum of values and count of data points for the given season
        // Iterate through all historical data points
        int256[] memory quantity = new int256[]((uint)(endMonth - startMonth + 1));
        if(k >= 12) {
            return quantity;
        }
        // Iterate through all historical data points
        for(int month = startMonth ; month <= endMonth ; month++){
            int256 sumOfValues = 0;
            int256 dataPointCount = 0;        
            for (uint256 i = 0; i < medicines.length; i++) {
                // Check if the season of the current data point matches the given season
                int diff = ABS(medicines[i].timeOfSelling.month - month);
                if (true &&
                 compareStrings(medicines[i].medicineName, medicineName) && compareStrings(level, medicines[i].addedByStakeHolderType)
                  && diff <= k) {
                    // Add the value of the current data point to the sum


                            sumOfValues = sumOfValues + (int256)(medicines[i].quantitySoldInNumbers);
                            dataPointCount++;
                        
                    
                }
            }
            int256 averageValue = sumOfValues / dataPointCount;
            quantity[(uint)(month - startMonth)] = (averageValue);
        }
        
        // Calculate the average value for the given season
        return quantity;
    } 

    function test() public view returns (Medicine[] memory) {
        return medicines;
    }

    function deleteMedicine(string memory _batchcode) external returns (bool){
        for(uint i = 0 ; i < medicines.length ; i++) {
            if(compareStrings(medicines[i].batchCode , _batchcode)) {
                delete (medicines[i]);
                return true;
            }
        }    
        return false;
    }

    function ABS(int256 a) public view returns (int256){
        if(a < 0) {
            return (a * -1);
        }
        return a;
    }

    function weightedMovingAverageMethod(int k, int startMonth, int endMonth, string memory medicineName , string memory level) external returns (int256[] memory){
        int256[] memory quantity = new int256[]((uint)(endMonth - startMonth + 1));
        // Iterate through all historical data points        
        int256[] memory weights = new int256[](11);       
        if(k >= 12) {
            return quantity;
        }
        else {
            for(int i = 0 ; i < 11 ; i++) {
                weights[(uint)(i)] = (i + 1) * (i + 1);
            }            
        }
        for(int month = startMonth ; month <= endMonth ; month++){
            int256 sumOfValues = 0;
            int256 dataPointCount = 0;        
            for (uint256 i = 0; i < medicines.length; i++) {
                int diff = ABS(medicines[i].timeOfSelling.month - month);                            
                // Check if the season of the current data point matches the given season
                if (diff <= k && true &&
                 compareStrings(medicines[i].medicineName, medicineName) && compareStrings(level, medicines[i].addedByStakeHolderType)) {
                    // Add the value of the current data point to the sum
                    
                    
                            sumOfValues += (weights[(uint)(10 - diff)] * (int256)(medicines[i].quantitySoldInNumbers));
                            dataPointCount += (weights[(uint)(10 - diff)]);
                    
                    
                }
            }
            int256 averageValue = sumOfValues / dataPointCount;
            quantity[(uint)(month - startMonth)] = (averageValue);
        }
        
        // Calculate the average value for the given season
        return quantity;
    }

    function random() public view returns (uint) {
        uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty))) % 100;
        return random;
    }
        
    function randomString() public  payable returns(string memory){
        uint size = 10;
        bytes memory randomWord=new bytes(size);
        // since we have 26 letters
        bytes memory chars = new bytes(35);
        chars="abcdefghijklmnopqrstuvwxyz123456789";
        for (uint i=0;i<size;i++){
            uint randomNumber = random2(35);
            // Index access for string is not possible
            randomWord[i]=chars[randomNumber];
        }
        return string(randomWord);
    }

    function random2(uint number) public payable returns(uint){
        counter++;
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender,counter))) % number;
    }

    

}
