// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SeasonalNaiveAlgorithm {
    
    // Struct to store historical data
    struct HistoricalData {
        uint256 season;
        uint256 value;
    }
    
    // Array to store historical data
    HistoricalData[] private historicalData;
    
    // Function to add historical data
    function addToHistoricalData(uint256 _season, uint256 _value) external {
        // Create a new HistoricalData object with the given season and value
        HistoricalData memory newData = HistoricalData(_season, _value);
        // Add the new data to the historical data array
        historicalData.push(newData);
    }
    
    // Function to get the seasonal forecast for a given season
    function getSeasonalForecast(uint256 _season) public view returns (uint256) {
        // Variables to keep track of the sum of values and count of data points for the given season
        uint256 sumOfValues = 0;
        uint256 dataPointCount = 0;
        
        // Iterate through all historical data points
        for (uint256 i = 0; i < historicalData.length; i++) {
            // Check if the season of the current data point matches the given season
            if (historicalData[i].season == _season) {
                // Add the value of the current data point to the sum
                sumOfValues += historicalData[i].value;
                // Increment the count of data points
                dataPointCount++;
            }
        }
        
        // Calculate the average value for the given season
        uint256 averageValue = sumOfValues / dataPointCount;
        
        // Return the average value as the seasonal forecast
        return averageValue;
    }
}
