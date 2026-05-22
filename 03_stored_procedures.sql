-- ============================================================
-- 03_stored_procedures.sql  –  Haversine matching procedures
-- ============================================================

-- ── Full load: unprocessed shops × unprocessed customers ────
GO
CREATE PROCEDURE dbo.usp_NearbyShops_FullLoad
    @MaxDistanceKm FLOAT = 50.0
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Shop WHERE IsProcessed = 0)
       AND NOT EXISTS (SELECT 1 FROM CustomerLocation WHERE IsProcessed = 0)
    BEGIN
        PRINT 'Nothing to process.';
        RETURN;
    END

    INSERT INTO CustomerNearbyShop (CustomerId, ShopId, DistanceKm)
    SELECT cl.CustomerId, dist.ShopId, CAST(ROUND(dist.DistanceKm, 0) AS INT)
    FROM CustomerLocation cl
    OUTER APPLY (
        SELECT
            s.ShopId,
            6371 * ACOS(
                COS(RADIANS(cl.HomeLat)) * COS(RADIANS(s.ShopLat))
                * COS(RADIANS(s.ShopLong) - RADIANS(cl.HomeLong))
                + SIN(RADIANS(cl.HomeLat)) * SIN(RADIANS(s.ShopLat))
            ) AS DistanceKm
        FROM Shop s
        WHERE s.IsProcessed = 0          -- only NEW shops
    ) dist
    WHERE cl.IsProcessed = 0             -- only NEW customers
      AND dist.DistanceKm < @MaxDistanceKm;

    DECLARE @inserted INT = @@ROWCOUNT;

    UPDATE Shop             SET IsProcessed = 1 WHERE IsProcessed = 0;
    UPDATE CustomerLocation SET IsProcessed = 1 WHERE IsProcessed = 0;

    PRINT CONCAT('Full load complete. Records inserted: ', @inserted);
END;
GO

-- ── Incremental: new shops × all customers
--                new customers × all shops  ──────────────────
CREATE PROCEDURE dbo.usp_NearbyShops_Incremental
    @MaxDistanceKm FLOAT = 50.0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @newShops     INT = (SELECT COUNT(*) FROM Shop             WHERE IsProcessed = 0);
    DECLARE @newCustomers INT = (SELECT COUNT(*) FROM CustomerLocation WHERE IsProcessed = 0);

    IF @newShops = 0 AND @newCustomers = 0
    BEGIN
        PRINT 'Nothing new to process.';
        RETURN;
    END

    -- New shops × ALL customers
    IF @newShops > 0
    BEGIN
        INSERT INTO CustomerNearbyShop (CustomerId, ShopId, DistanceKm)
        SELECT cl.CustomerId, dist.ShopId, CAST(ROUND(dist.DistanceKm, 0) AS INT)
        FROM CustomerLocation cl
        OUTER APPLY (
            SELECT
                s.ShopId,
                6371 * ACOS(
                    COS(RADIANS(cl.HomeLat)) * COS(RADIANS(s.ShopLat))
                    * COS(RADIANS(s.ShopLong) - RADIANS(cl.HomeLong))
                    + SIN(RADIANS(cl.HomeLat)) * SIN(RADIANS(s.ShopLat))
                ) AS DistanceKm
            FROM Shop s
            WHERE s.IsProcessed = 0      -- only NEW shops
        ) dist
        WHERE dist.DistanceKm < @MaxDistanceKm
          AND NOT EXISTS (
              SELECT 1 FROM CustomerNearbyShop x
              WHERE x.CustomerId = cl.CustomerId AND x.ShopId = dist.ShopId
          );

        PRINT CONCAT('New shops processed: ', @newShops,
                     '  →  matches inserted: ', @@ROWCOUNT);

        UPDATE Shop SET IsProcessed = 1 WHERE IsProcessed = 0;
    END

    -- New customers × ALL shops
    IF @newCustomers > 0
    BEGIN
        INSERT INTO CustomerNearbyShop (CustomerId, ShopId, DistanceKm)
        SELECT cl.CustomerId, dist.ShopId, CAST(ROUND(dist.DistanceKm, 0) AS INT)
        FROM CustomerLocation cl
        OUTER APPLY (
            SELECT
                s.ShopId,
                6371 * ACOS(
                    COS(RADIANS(cl.HomeLat)) * COS(RADIANS(s.ShopLat))
                    * COS(RADIANS(s.ShopLong) - RADIANS(cl.HomeLong))
                    + SIN(RADIANS(cl.HomeLat)) * SIN(RADIANS(s.ShopLat))
                ) AS DistanceKm
            FROM Shop s              -- ALL shops
        ) dist
        WHERE cl.IsProcessed = 0     -- only NEW customers
          AND dist.DistanceKm < @MaxDistanceKm
          AND NOT EXISTS (
              SELECT 1 FROM CustomerNearbyShop x
              WHERE x.CustomerId = cl.CustomerId AND x.ShopId = dist.ShopId
          );

        PRINT CONCAT('New customers processed: ', @newCustomers,
                     '  →  matches inserted: ', @@ROWCOUNT);

        UPDATE CustomerLocation SET IsProcessed = 1 WHERE IsProcessed = 0;
    END
END;
GO
