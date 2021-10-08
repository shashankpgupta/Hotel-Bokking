// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.16;
import "contracts/DateTimeLibrary.sol";
import "contracts/convert.sol";
contract hotel_reservation{
    address payable public beneficiary;
    uint public roomcost;
    uint penalty7;
    uint penalty2;
    event registration(address guest, uint8 day, uint8 month, uint16 year);
    event cancellation(address guest, uint8 day, uint8 month, uint16 year);
    
    mapping (uint=>uint) private perday; 
    mapping (address=>uint) private has_cancelled;
    mapping (address=>uint) private balance;
    
    constructor  (
        address payable _beneficiary,
        uint256 _roomcost) public
    {
        roomcost = _roomcost;
        penalty7 = 50;
        penalty2 = 0;
        beneficiary = _beneficiary;
    }
    
    function _getDaysInMonth(uint year, uint month) private pure returns (uint daysInMonth) {
        daysInMonth = DateTimeLibrary._getDaysInMonth(year, month);
        return daysInMonth; 
    }
    
    function numericalform(uint day, uint month, uint year) pure private returns (uint){
           return (year*10000 + month*100 + day);
    }
    
    function vacancy(uint day, uint month, uint year) view public returns (bool){   
        uint _datetobook = numericalform(day,month,year);
        if (perday[_datetobook]< 1)
            return true;
        else
            return false;
    }
    
    function diffDays(uint fromTimestamp, uint toTimestamp) private pure returns (uint _days) {
        _days = DateTimeLibrary.diffDays(fromTimestamp, toTimestamp);
        return _days; 
    }
    function convertYMDtoTimestamp(uint16 year,uint8 month,uint8 day) private pure returns (uint256 _converteddate) { 
        _converteddate = convert.convertYMDtoTimestamp( year, month, day);
        return _converteddate; 
    }
    
    function bookandpay(uint8 day, uint8 month, uint16 year) public payable{   
        require(has_cancelled[msg.sender]==0, "You can only book one room in your name");
        uint _datetobook = numericalform(day,month,year);
        require(vacancy(day,month,year)==true,"There are no vacant rooms");
        require(msg.value==roomcost,"You didnt pay the required amount");
        balance[msg.sender]=roomcost;
        perday[_datetobook]++;
        has_cancelled[msg.sender]=1;
        emit registration(msg.sender,day,month,year);
    }
   
    function cancel(uint8 day, uint8 month, uint16 year  ) public{ 
        require(has_cancelled[msg.sender]==1,"You have already cancelled you registration");
        uint currenttime;
        currenttime = block.timestamp;
        uint timestampdate = convertYMDtoTimestamp(year, month,day);

        uint daysbwt = diffDays(currenttime,timestampdate );
        if(daysbwt>7)
            payable(msg.sender).transfer(balance[msg.sender]);
        else if(daysbwt>2)
            payable(msg.sender).transfer(balance[msg.sender]*penalty7/100);
        else if(daysbwt<=2)
            payable(msg.sender).transfer(balance[msg.sender]*penalty2/100);
        perday[numericalform(day,month,year)]--;
        balance[msg.sender] = 0;
        emit cancellation(msg.sender,day,month,year);
        has_cancelled[msg.sender]=0;
    }
    
    function changeroomcost(uint x) public{ 
        require(msg.sender==beneficiary,"error");
        roomcost = x;
    }
    
    function changepenalty7(uint y) public{ 
        require(msg.sender==beneficiary,"error");
        penalty7 = y;
    }
    
    function changepenalty2(uint z) public{ 
        require(msg.sender==beneficiary,"error");
        penalty2 = z;
    }

}
