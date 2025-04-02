-- Add necessary indexes for performance
CREATE NONCLUSTERED INDEX IX_Vehicle_Name 
ON Vehicle(VehicleName)
INCLUDE (VehicleID);

CREATE NONCLUSTERED INDEX IX_VehiclePart_Search
ON VehiclePart(VehicleID, IsStockItem)
INCLUDE (VehiclePartName, Sku);

GO

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
        RETURN -1; -- Invalid vehicle name

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
GO
