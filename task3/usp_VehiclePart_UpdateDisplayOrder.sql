-- Test Case 1: Valid update
DECLARE @Result INT;
DECLARE @JsonData NVARCHAR(MAX) = N'[
    {"VehiclePartID": 1, "DisplayOrder": 2},
    {"VehiclePartID": 2, "DisplayOrder": 1}
]';

EXEC @Result = UpdateVehiclePartDisplayOrder @JsonData;
SELECT 
    CASE @Result
        WHEN 0 THEN 'Success'
        WHEN 1 THEN 'Invalid JSON format'
        WHEN 2 THEN 'No data to process'
        WHEN 3 THEN 'Invalid VehiclePartID found'
        WHEN 4 THEN 'Duplicate DisplayOrder values for same VehicleID'
        WHEN 5 THEN 'Other error'
    END AS Result;

-- Test Case 2: Attempt to create duplicate DisplayOrder for same VehicleID
DECLARE @Result INT;
DECLARE @JsonData NVARCHAR(MAX) = N'[
    {"VehiclePartID": 1, "DisplayOrder": 2},
    {"VehiclePartID": 3, "DisplayOrder": 2}
]';

EXEC @Result = UpdateVehiclePartDisplayOrder @JsonData;
SELECT 
    CASE @Result
        WHEN 0 THEN 'Success'
        WHEN 1 THEN 'Invalid JSON format'
        WHEN 2 THEN 'No data to process'
        WHEN 3 THEN 'Invalid VehiclePartID found'
        WHEN 4 THEN 'Duplicate DisplayOrder values for same VehicleID'
        WHEN 5 THEN 'Other error'
    END AS Result;

-- Test Case 3: Invalid VehiclePartID
DECLARE @Result INT;
DECLARE @JsonData NVARCHAR(MAX) = N'[
    {"VehiclePartID": 999, "DisplayOrder": 1}
]';

EXEC @Result = UpdateVehiclePartDisplayOrder @JsonData;
SELECT 
    CASE @Result
        WHEN 0 THEN 'Success'
        WHEN 1 THEN 'Invalid JSON format'
        WHEN 2 THEN 'No data to process'
        WHEN 3 THEN 'Invalid VehiclePartID found'
        WHEN 4 THEN 'Duplicate DisplayOrder values for same VehicleID'
        WHEN 5 THEN 'Other error'
    END AS Result;

-- Query to verify results
SELECT 
    v.VehicleID,
    v.VehicleName,
    vp.VehiclePartID,
    vp.VehiclePartName,
    vp.DisplayOrder
FROM Vehicle v
JOIN VehiclePart vp ON v.VehicleID = vp.VehicleID
ORDER BY v.VehicleID, vp.DisplayOrder;
