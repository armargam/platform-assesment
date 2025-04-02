[
    {
        "VehiclePartID": 1,
        "DisplayOrder": 2
    },
    {
        "VehiclePartID": 2,
        "DisplayOrder": 1
    }
]
# Vehicle Part Display Order Update Procedure

## Overview
This T-SQL stored procedure manages the display order of vehicle parts in a database. It accepts JSON input to update the DisplayOrder column while maintaining uniqueness constraints and handling various error conditions.

## Schema
```sql
CREATE TABLE Vehicle (
    VehicleID int IDENTITY (1,1), 
    VehicleName nvarchar(20)
);

CREATE TABLE VehiclePart (
    VehiclePartID int IDENTITY (1,1), 
    VehicleID int, 
    VehiclePartName nvarchar(20),
    Sku nvarchar(10),
    IsStockItem bit DEFAULT 1, 
    DisplayOrder int NOT NULL, 
    UNIQUE (VehicleID, DisplayOrder)
);
```

# Stored Procedure Details
## Parameters
```
[
    {
        "VehiclePartID": 1,
        "DisplayOrder": 2
    },
    {
        "VehiclePartID": 2,
        "DisplayOrder": 1
    }
]
```

# Return Codes


Code	Description
0	Success
1	Invalid JSON format
2	No data to process
3	Invalid VehiclePartID found
4	Duplicate DisplayOrder values for same VehicleID
5	Other error