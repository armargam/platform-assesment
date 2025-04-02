# Stored Procedure Optimization: usp_VehiclePart_ReadSearch

## Original Procedure
```sql
CREATE PROCEDURE usp_VehiclePart_ReadSearch
    @vehicleName nvarchar(20),
    @vehiclePartName nvarchar(20) = NULL,
    @sku nvarchar(10) = NULL,
    @isStockItem bit = NULL
AS
    SELECT 
        v.VehicleName,
        vp.VehiclePartName,
        vp.Sku, 
        vp.IsStockItem
    FROM Vehicle v 
    JOIN VehiclePart vp ON v.VehicleID = vp.VehicleID
    WHERE 
    v.VehicleName = @vehicleName AND
    (vp.VehiclePartName LIKE '%' + @vehiclePartName + '%' OR @vehiclePartName IS NULL) AND
    (vp.Sku = @sku OR @sku IS NULL) AND
    (vp.IsStockItem = @isStockItem OR @isStockItem IS NULL)
```

# Optimized Version 

1. Strategic Indexes

```
-- Index for Vehicle name lookups
CREATE NONCLUSTERED INDEX IX_Vehicle_Name 
ON Vehicle(VehicleName)
INCLUDE (VehicleID);

-- Covering index for VehiclePart searches
CREATE NONCLUSTERED INDEX IX_VehiclePart_Search
ON VehiclePart(VehicleID, IsStockItem)
INCLUDE (VehiclePartName, Sku);

```

2. Optimized Stored Procedure

```
CREATE OR ALTER PROCEDURE usp_VehiclePart_ReadSearch
    @vehicleName NVARCHAR(20),
    @vehiclePartName NVARCHAR(20) = NULL,
    @sku NVARCHAR(10) = NULL,
    @isStockItem BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Parameter validation and cleanup
    IF @vehicleName IS NULL
        RETURN -1;

    SET @vehicleName = LTRIM(RTRIM(@vehicleName));
    SET @vehiclePartName = NULLIF(LTRIM(RTRIM(@vehiclePartName)), '');
    SET @sku = NULLIF(LTRIM(RTRIM(@sku)), '');

    -- Prepare search pattern once
    DECLARE @searchPattern NVARCHAR(22);
    IF @vehiclePartName IS NOT NULL
        SET @searchPattern = N'%' + @vehiclePartName + N'%';

    -- Main query with optimizations
    SELECT 
        v.VehicleName,
        vp.VehiclePartName,
        vp.Sku,
        vp.IsStockItem
    FROM Vehicle v WITH (FORCESEEK)
    INNER JOIN VehiclePart vp WITH (INDEX(IX_VehiclePart_Search))
        ON v.VehicleID = vp.VehicleID
    WHERE v.VehicleName = @vehicleName
        AND (@vehiclePartName IS NULL OR vp.VehiclePartName LIKE @searchPattern)
        AND (@sku IS NULL OR vp.Sku = @sku)
        AND (@isStockItem IS NULL OR vp.IsStockItem = @isStockItem)
    OPTION (RECOMPILE, OPTIMIZE FOR UNKNOWN);

    RETURN 0;
END;

```

# Key Improvements MAde

Key Optimizations
1. Index Improvements
Added covering indexes for common search patterns

Optimized for frequent query patterns

Included columns to reduce lookups

2. Parameter Handling
Added NULL validation for required parameters

Proper string trimming

NULLIF for optional parameters

Pre-computed search pattern

3. Query Optimizations
Added SET NOCOUNT ON

Used WITH (FORCESEEK) for index usage

Specified index hints

Added OPTION (RECOMPILE) for optimal plans

OPTIMIZE FOR UNKNOWN to handle parameter sniffing

Improved NULL handling logic

4. Performance Enhancements
Reduced string concatenations

Better NULL handling

Improved index usage

Optimized join operations

