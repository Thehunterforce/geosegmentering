-- ============================================================
-- 05_formula_comparison.sql
-- Sammenligner Haversine vs Sfærisk Lov til Cosinus
-- ============================================================

SELECT
    c.Name                          AS Customer,
    s.Name                          AS Shop,

    -- Haversine
    ROUND(6371 * 2 * ASIN(SQRT(
        POWER(SIN(RADIANS((s.ShopLat - cl.HomeLat) / 2)), 2) +
        COS(RADIANS(cl.HomeLat)) * COS(RADIANS(s.ShopLat)) *
        POWER(SIN(RADIANS((s.ShopLong - cl.HomeLong) / 2)), 2)
    )), 4)                          AS Haversine_km,

    -- Sfærisk Lov til Cosinus
    ROUND(6371 * ACOS(
        COS(RADIANS(cl.HomeLat)) * COS(RADIANS(s.ShopLat))
        * COS(RADIANS(s.ShopLong) - RADIANS(cl.HomeLong))
        + SIN(RADIANS(cl.HomeLat)) * SIN(RADIANS(s.ShopLat))
    ), 4)                           AS Cosine_km,

    -- Absolut forskel i meter
    ROUND(ABS(
        6371 * 2 * ASIN(SQRT(
            POWER(SIN(RADIANS((s.ShopLat - cl.HomeLat) / 2)), 2) +
            COS(RADIANS(cl.HomeLat)) * COS(RADIANS(s.ShopLat)) *
            POWER(SIN(RADIANS((s.ShopLong - cl.HomeLong) / 2)), 2)
        ))
        -
        6371 * ACOS(
            COS(RADIANS(cl.HomeLat)) * COS(RADIANS(s.ShopLat))
            * COS(RADIANS(s.ShopLong) - RADIANS(cl.HomeLong))
            + SIN(RADIANS(cl.HomeLat)) * SIN(RADIANS(s.ShopLat))
        )
    ) * 1000, 2)                    AS Difference_meters,

    -- Relativ forskel i procent
    ROUND(ABS(
        6371 * 2 * ASIN(SQRT(
            POWER(SIN(RADIANS((s.ShopLat - cl.HomeLat) / 2)), 2) +
            COS(RADIANS(cl.HomeLat)) * COS(RADIANS(s.ShopLat)) *
            POWER(SIN(RADIANS((s.ShopLong - cl.HomeLong) / 2)), 2)
        ))
        -
        6371 * ACOS(
            COS(RADIANS(cl.HomeLat)) * COS(RADIANS(s.ShopLat))
            * COS(RADIANS(s.ShopLong) - RADIANS(cl.HomeLong))
            + SIN(RADIANS(cl.HomeLat)) * SIN(RADIANS(s.ShopLat))
        )
    )
    /
    NULLIF(6371 * 2 * ASIN(SQRT(
        POWER(SIN(RADIANS((s.ShopLat - cl.HomeLat) / 2)), 2) +
        COS(RADIANS(cl.HomeLat)) * COS(RADIANS(s.ShopLat)) *
        POWER(SIN(RADIANS((s.ShopLong - cl.HomeLong) / 2)), 2)
    )), 0) * 100, 6)                AS Difference_pct

FROM CustomerLocation cl
CROSS JOIN Shop s
JOIN Customer c ON c.CustomerId = cl.CustomerId
ORDER BY Difference_meters DESC;
