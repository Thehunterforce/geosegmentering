-- ============================================================
-- NearbyShopsDemo - SQLite Schema
-- ============================================================

CREATE TABLE IF NOT EXISTS Customer (
    CustomerId  INTEGER PRIMARY KEY,
    Name        TEXT NOT NULL,
    Email       TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS CustomerLocation (
    CustomerId  INTEGER PRIMARY KEY REFERENCES Customer(CustomerId),
    HomeLat     REAL NOT NULL,
    HomeLong    REAL NOT NULL,
    IsProcessed INTEGER DEFAULT 0   -- 0 = new, 1 = matched against all shops
);

CREATE TABLE IF NOT EXISTS Shop (
    ShopId      INTEGER PRIMARY KEY,
    Name        TEXT NOT NULL,
    ShopLat     REAL NOT NULL,
    ShopLong    REAL NOT NULL,
    IsProcessed INTEGER DEFAULT 0   -- 0 = new, 1 = matched against all customers
);

CREATE TABLE IF NOT EXISTS CustomerNearbyShop (
    Id          INTEGER PRIMARY KEY AUTOINCREMENT,
    CustomerId  INTEGER REFERENCES Customer(CustomerId),
    ShopId      INTEGER REFERENCES Shop(ShopId),
    DistanceKm  REAL NOT NULL,
    CreatedAt   TEXT DEFAULT (datetime('now')),
    UNIQUE(CustomerId, ShopId)      -- avoid duplicates on re-runs
);
