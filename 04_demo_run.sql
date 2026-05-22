-- ============================================================
-- 04_demo_run.sql  –  Full demo walkthrough
-- Run each section separately and inspect results in between
-- ============================================================


-- ── Full load: Frank × all shops ────────────────────────────
EXEC dbo.usp_NearbyShops_FullLoad @MaxDistanceKm = 50.0;
GO

-- Frank's nearby shops with distances
SELECT
    c.Name      AS Customer,
    s.Name      AS Shop,
    ns.DistanceKm
FROM CustomerNearbyShop ns
JOIN Customer c ON c.CustomerId = ns.CustomerId
JOIN Shop     s ON s.ShopId     = ns.ShopId
ORDER BY c.Name, ns.DistanceKm;
GO
