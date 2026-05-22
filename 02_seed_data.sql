-- ============================================================
-- 02_seed_data.sql  –  Sample customers and shops (Danish locations)
-- ============================================================

INSERT INTO Customer (CustomerId, Name, Email) VALUES
    (1, 'Alice Hansen',    'alice@example.com'),
    (2, 'Bob Nielsen',     'bob@example.com'),
    (3, 'Clara Andersen',  'clara@example.com'),
    (4, 'David Møller',    'david@example.com'),
    (5, 'Eva Christensen', 'eva@example.com');

INSERT INTO CustomerLocation (CustomerId, HomeLat, HomeLong) VALUES
    (1, 55.6761, 12.5683),   -- Copenhagen
    (2, 56.1629, 10.2039),   -- Aarhus
    (3, 55.4038, 10.4024),   -- Odense
    (4, 57.0488,  9.9217),   -- Aalborg
    (5, 55.7167, 12.3333);   -- Lyngby

-- Frank only
INSERT INTO Customer (CustomerId, Name, Email)
VALUES (6, 'Frank Larsen', 'frank@example.com');

INSERT INTO CustomerLocation (CustomerId, HomeLat, HomeLong)
VALUES (6, 55.83279984755982, 11.95831480760489);   -- Overdråby

INSERT INTO Shop (ShopId, Name, ShopLat, ShopLong) VALUES
    (1,  'Copenhagen Central',  55.6761, 12.5683),   -->  Bør matches
    (2,  'Vesterbro Shop',      55.6632, 12.5437),   -->  Bør matches
    (3,  'Aarhus City Store',   56.1529, 10.2038),   -->  bør ikke matches
    (4,  'Odense Main Street',  55.4038, 10.4024),   -->  bør ikke matches
    (5,  'Aalborg North',       57.0700,  9.9300),   -->  bør ikke matches
    (6,  'Hellerup Boutique',   55.7290, 12.5780),   -->  Bør matches
    (7,  'Roskilde Shop',       55.6415, 12.0803),   -->  Bør matches
    (8,  'Malmö Cross-border',  55.6050, 13.0038),   -->  bør ikke matche
    (9,  'Esbjerg Far Away',    55.4761,  8.4600),   -->  bør ikke matches
    (10, 'Silkeborg Store',     56.1714,  9.5507),   -->  bør ikke matches
    (11, 'Frederikssund Local', 55.8442, 12.0650);   -->  bør matches