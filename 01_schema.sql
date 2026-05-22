-- ============================================================
-- 01_schema.sql  –  Create all tables
-- ============================================================

CREATE TABLE Customer (
    CustomerId  INT           PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    Email       NVARCHAR(100) NOT NULL
);

CREATE TABLE CustomerLocation (
    CustomerId  INT   PRIMARY KEY REFERENCES Customer(CustomerId),
    HomeLat     FLOAT NOT NULL,
    HomeLong    FLOAT NOT NULL,
    IsProcessed BIT   NOT NULL DEFAULT 0   -- 0 = new, 1 = matched against all shops
);

CREATE TABLE Shop (
    ShopId      INT           PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    ShopLat     FLOAT         NOT NULL,
    ShopLong    FLOAT         NOT NULL,
    IsProcessed BIT           NOT NULL DEFAULT 0   -- 0 = new, 1 = matched against all customers
);

CREATE TABLE CustomerNearbyShop (
    Id          INT           PRIMARY KEY IDENTITY,
    CustomerId  INT           NOT NULL REFERENCES Customer(CustomerId),
    ShopId      INT           NOT NULL REFERENCES Shop(ShopId),
    DistanceKm  INT           NOT NULL,
    CreatedAt   DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_CustomerShop UNIQUE (CustomerId, ShopId)   -- no duplicate pairs
);
