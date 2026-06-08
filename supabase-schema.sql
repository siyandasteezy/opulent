-- ═══════════════════════════════════════════════════════════════════════
-- Opulent Interior D-Zines — Supabase Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query → Run All
-- ═══════════════════════════════════════════════════════════════════════

-- ── 1. TABLES ──────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS products (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  category      TEXT NOT NULL,
  category_label TEXT NOT NULL,
  price         NUMERIC(10,2),
  price_queen   NUMERIC(10,2),
  price_king    NUMERIC(10,2),
  has_sizes     BOOLEAN DEFAULT FALSE,
  dimensions    JSONB,
  image_url     TEXT,
  stock_qty     INTEGER DEFAULT 0,
  visible       BOOLEAN DEFAULT TRUE,
  featured      BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS contact_submissions (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  first_name    TEXT NOT NULL,
  last_name     TEXT NOT NULL,
  email         TEXT NOT NULL,
  phone         TEXT,
  service       TEXT,
  message       TEXT NOT NULL,
  is_read       BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS email_subscribers (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email         TEXT UNIQUE NOT NULL,
  source        TEXT DEFAULT 'coming-soon',
  subscribed_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── 2. AUTO-UPDATE updated_at ──────────────────────────────────────────

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_products_updated_at ON products;
CREATE TRIGGER trg_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── 3. ROW LEVEL SECURITY ──────────────────────────────────────────────

ALTER TABLE products            ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_subscribers   ENABLE ROW LEVEL SECURITY;

-- Products: public can read visible items; authenticated (admin) can do everything
DROP POLICY IF EXISTS "public_read_products"  ON products;
DROP POLICY IF EXISTS "auth_all_products"     ON products;
CREATE POLICY "public_read_products"  ON products FOR SELECT TO anon        USING (visible = true);
CREATE POLICY "auth_all_products"     ON products FOR ALL    TO authenticated USING (true) WITH CHECK (true);

-- Contact: public can insert; admin can read/update
DROP POLICY IF EXISTS "public_insert_contact" ON contact_submissions;
DROP POLICY IF EXISTS "auth_all_contacts"     ON contact_submissions;
CREATE POLICY "public_insert_contact" ON contact_submissions FOR INSERT TO anon        WITH CHECK (true);
CREATE POLICY "auth_all_contacts"     ON contact_submissions FOR ALL    TO authenticated USING (true) WITH CHECK (true);

-- Subscribers: public can insert (unique); admin can read/delete
DROP POLICY IF EXISTS "public_insert_subscriber" ON email_subscribers;
DROP POLICY IF EXISTS "auth_all_subscribers"      ON email_subscribers;
CREATE POLICY "public_insert_subscriber" ON email_subscribers FOR INSERT TO anon        WITH CHECK (true);
CREATE POLICY "auth_all_subscribers"     ON email_subscribers FOR ALL    TO authenticated USING (true) WITH CHECK (true);

-- ── 4. SEED PRODUCTS (all 65 catalogue items) ──────────────────────────

INSERT INTO products
  (id,name,category,category_label,price,price_queen,price_king,has_sizes,dimensions,image_url,stock_qty,visible,featured)
VALUES
  ('TSCH001','Matshaba 3 Seater Couch','couch','3-Seater Couch',19995,NULL,NULL,false,'{"Width": "2200mm", "Depth": "900mm", "Height": "690mm"}','images/furniture/TSCH001.jpg',5,true,false),\n  ('TSCH002','Tumeliso 3 Seater Couch','couch','3-Seater Couch',26795,NULL,NULL,false,'{"Width": "2500mm", "Depth": "900mm", "Height": "710mm"}','images/furniture/TSCH002.jpg',5,true,false),\n  ('TSCH003','Rakoro 3 Seater Couch','couch','3-Seater Couch',14495,NULL,NULL,false,'{"Width": "2100mm", "Depth": "900mm", "Height": "710mm"}','images/furniture/TSCH003.jpg',5,true,false),\n  ('TSCH004','Edward 3 Seater Couch','couch','3-Seater Couch',11995,NULL,NULL,false,'{"Width": "2100mm", "Depth": "900mm", "Height": "780mm"}','images/furniture/TSCH004.jpg',5,true,false),\n  ('TSCH005','Mark 3 Seater Couch','couch','3-Seater Couch',17995,NULL,NULL,false,'{"Width": "2100mm", "Depth": "860mm", "Height": "780mm"}','images/furniture/TSCH005.jpg',5,true,false),\n  ('TSCH006','Israel Leather 3 Seater Couch','couch','3-Seater Couch',16595,NULL,NULL,false,'{"Width": "2100mm", "Depth": "890mm", "Height": "860mm"}','images/furniture/TSCH006.jpg',5,true,false),\n  ('TSCH007','Maili 3 Seater Couch','couch','3-Seater Couch',17895,NULL,NULL,false,'{"Width": "2000mm", "Depth": "890mm", "Height": "820mm"}','images/furniture/TSCH007.jpg',5,true,false),\n  ('TSCH008','Tumi 3 Seater Couch','couch','3-Seater Couch',28495,NULL,NULL,false,'{"Width": "2250mm", "Depth": "860mm", "Height": "730mm"}','images/furniture/TSCH008.jpg',5,true,false),\n  ('TSCH009','Tshegofatso 3 Seater Couch','couch','3-Seater Couch',12995,NULL,NULL,false,'{"Width": "2040mm", "Depth": "1000mm", "Height": "860mm"}','images/furniture/TSCH009.jpg',5,true,false),\n  ('TSCH010','Zoe 3 Seater Couch','couch','3-Seater Couch',15995,NULL,NULL,false,'{"Width": "2100mm", "Depth": "890mm", "Height": "860mm"}','images/furniture/TSCH010.jpg',5,true,false),\n  ('TSCH011','Dimakatso 3 Seater Couch','couch','3-Seater Couch',17295,NULL,NULL,false,'{"Width": "2200mm", "Depth": "890mm", "Height": "680mm"}','images/furniture/TSCH011.jpg',5,true,false),\n  ('TSCH012','Mpho 3 Seater Couch','couch','3-Seater Couch',16695,NULL,NULL,false,'{"Width": "2000mm", "Depth": "860mm", "Height": "710mm"}','images/furniture/TSCH012.jpg',5,true,false),\n  ('CFCH001','Lebo 2 Seater Chesterfield','chesterfield','Chesterfield Couch',14595,NULL,NULL,false,'{"Width": "1900mm", "Depth": "900mm", "Height": "780mm"}','images/furniture/CFCH001.jpg',5,true,false),\n  ('CFCH002','Pam 3 Seater Chesterfield','chesterfield','Chesterfield Couch',21595,NULL,NULL,false,'{"Width": "2250mm", "Depth": "910mm", "Height": "670mm"}','images/furniture/CFCH002.jpg',5,true,false),\n  ('CFCH003','Pamler 3 Seater Chesterfield','chesterfield','Chesterfield Couch',17695,NULL,NULL,false,'{"Width": "2250mm", "Depth": "890mm", "Height": "670mm"}','images/furniture/CFCH003.jpg',5,true,false),\n  ('LSCCH001','Shelton L-Shape Couch','lshape','L-Shape Couch',14195,NULL,NULL,false,'{"Width": "2690mm", "Depth": "1940mm", "Height": "840mm"}','images/furniture/LSCCH001.jpg',5,true,false),\n  ('LSCCH002','Joseph L-Shape Couch','lshape','L-Shape Couch',16895,NULL,NULL,false,'{"Width": "2700mm", "Depth": "1950mm", "Height": "860mm"}','images/furniture/LSCCH002.jpg',5,true,false),\n  ('LSCCH003','Mary L-Shape Couch','lshape','L-Shape Couch',23795,NULL,NULL,false,'{"Width": "4000mm", "Depth": "3000mm", "Height": "850mm"}','images/furniture/LSCCH003.jpg',5,true,false),\n  ('LSCCH004','Martha L-Shape Couch','lshape','L-Shape Couch',22395,NULL,NULL,false,'{"Width": "4200mm", "Depth": "1700mm", "Height": "850mm"}','images/furniture/LSCCH004.jpg',5,true,false),\n  ('USCCH001','Hendrick U-Shape Couch','ushape','U-Shape Couch',25695,NULL,NULL,false,'{"Width": "4350mm", "Depth": "1720mm", "Height": "850mm"}','images/furniture/USCCH001.jpg',5,true,false),\n  ('USCCH002','Khosi U-Shape Couch','ushape','U-Shape Couch',23695,NULL,NULL,false,'{"Width": "3600mm", "Depth": "1625mm", "Height": "890mm"}','images/furniture/USCCH002.jpg',5,true,false),\n  ('OCNCH001','Labane Occasional Chair','occasional','Occasional Chair',8095,NULL,NULL,false,'{"Width": "800mm", "Depth": "650mm", "Height": "750mm"}','images/furniture/OCNCH001.jpg',5,true,false),\n  ('OCNCH002','Lichaba Occasional Chair','occasional','Occasional Chair',7895,NULL,NULL,false,'{"Width": "700mm", "Depth": "600mm", "Height": "840mm"}','images/furniture/OCNCH002.jpg',5,true,false),\n  ('OCNCH003','Lukhanyo Occasional Chair','occasional','Occasional Chair',6695,NULL,NULL,false,'{"Width": "750mm", "Depth": "830mm", "Height": "780mm"}','images/furniture/OCNCH003.jpg',5,true,false),\n  ('OCNCH004','Neo Occasional Chair','occasional','Occasional Chair',7595,NULL,NULL,false,'{"Width": "876mm", "Depth": "700mm", "Height": "720mm"}','images/furniture/OCNCH004.jpg',5,true,false),\n  ('OCNCH005','Motale Occasional Chair','occasional','Occasional Chair',5995,NULL,NULL,false,'{"Width": "700mm", "Depth": "700mm", "Height": "786mm"}','images/furniture/OCNCH005.jpg',5,true,false),\n  ('OCNCH006','Molikeng Occasional Chair','occasional','Occasional Chair',11795,NULL,NULL,false,'{"Width": "800mm", "Depth": "600mm", "Height": "655mm"}','images/furniture/OCNCH006.jpg',5,true,false),\n  ('OCNCH007','Refiloe Occasional Chair','occasional','Occasional Chair',5595,NULL,NULL,false,'{"Width": "650mm", "Depth": "550mm", "Height": "640mm"}','images/furniture/OCNCH007.jpg',5,true,false),\n  ('OCNCH008','Khati Occasional Chair','occasional','Occasional Chair',5895,NULL,NULL,false,'{"Width": "600mm", "Depth": "560mm", "Height": "660mm"}','images/furniture/OCNCH008.jpg',5,true,false),\n  ('OCNCH009','Mpeo Occasional Chair','occasional','Occasional Chair',12495,NULL,NULL,false,'{"Width": "1190mm", "Depth": "1190mm", "Height": "850mm"}','images/furniture/OCNCH009.jpg',5,true,false),\n  ('OCNCH010','Mpeoane Occasional Chair','occasional','Occasional Chair',10795,NULL,NULL,false,'{"Width": "1200mm", "Depth": "1000mm", "Height": "710mm"}','images/furniture/OCNCH010.jpg',5,true,false),\n  ('OCNCH011','Tsilo Occasional Chair','occasional','Occasional Chair',7295,NULL,NULL,false,'{"Width": "876mm", "Depth": "700mm", "Height": "890mm"}','images/furniture/OCNCH011.jpg',5,true,false),\n  ('OCNCH012','Simphiwe Oak Occasional Chair','occasional','Occasional Chair',9295,NULL,NULL,false,'{"Width": "800mm", "Depth": "700mm", "Height": "780mm"}','images/furniture/OCNCH012.jpg',5,true,false),\n  ('DNGCH001','Mangole Dining Chair','dining','Dining Chair',4995,NULL,NULL,false,'{"Width": "650mm", "Depth": "600mm", "Height": "850mm"}','images/furniture/DNGCH001.jpg',5,true,false),\n  ('DNGCH002','Khabele Dining Chair','dining','Dining Chair',4495,NULL,NULL,false,'{"Width": "600mm", "Depth": "650mm", "Height": "830mm"}','images/furniture/DNGCH002.jpg',5,true,false),\n  ('DNGCH003','Mnoto Dining Chair','dining','Dining Chair',3995,NULL,NULL,false,'{"Width": "630mm", "Depth": "550mm", "Height": "890mm"}','images/furniture/DNGCH003.jpg',5,true,false),\n  ('DNGCH004','Khanyiso Dining Chair','dining','Dining Chair',5295,NULL,NULL,false,'{"Width": "650mm", "Depth": "600mm", "Height": "850mm"}','images/furniture/DNGCH004.jpg',5,true,false),\n  ('DBCHS001','Zipho Daybed','daybed','Daybed',12495,NULL,NULL,false,'{"Width": "1600mm", "Depth": "600mm", "Height": "430mm"}','images/furniture/DBCHS001.jpg',5,true,false),\n  ('DBCHS002','Thoriso Daybed','daybed','Daybed',9095,NULL,NULL,false,'{"Width": "1600mm", "Depth": "700mm", "Height": "450mm"}','images/furniture/DBCHS002.jpg',5,true,false),\n  ('DBCHS003','Zezethu Chaise','daybed','Chaise',7795,NULL,NULL,false,'{"Width": "1900mm", "Depth": "850mm", "Height": "650mm"}','images/furniture/DBCHS003.jpg',5,true,false),\n  ('DBCHS004','Sekhantsho Chaise','daybed','Chaise',10395,NULL,NULL,false,'{"Width": "1700mm", "Depth": "1100mm", "Height": "450mm"}','images/furniture/DBCHS004.jpg',5,true,false),\n  ('DBCHS005','Leruo Chaise','daybed','Chaise',9395,NULL,NULL,false,'{"Width": "1700mm", "Depth": "500mm", "Height": "450mm"}','images/furniture/DBCHS005.jpg',5,true,false),\n  ('HBDBS001','Violet Sleigh Bed','bedset','Headboard & Base Set',NULL,13495,14695,true,NULL,'images/furniture/HBDBS001.jpg',5,true,false),\n  ('HBDBS002','Makhabele Headboard & Base Set','bedset','Headboard & Base Set',NULL,11495,12395,true,NULL,'images/furniture/HBDBS002.jpg',5,true,false),\n  ('HBDBS003','Malabane Headboard & Base Set','bedset','Headboard & Base Set',NULL,12295,12795,true,NULL,'images/furniture/HBDBS003.jpg',5,true,false),\n  ('HBDBS004','Lebohang Headboard & Base Set','bedset','Headboard & Base Set',NULL,10095,11495,true,NULL,'images/furniture/HBDBS004.jpg',5,true,false),\n  ('HBDBS004B','Tlalane Headboard & Base Set','bedset','Headboard & Base Set',NULL,14495,15495,true,NULL,'images/furniture/HBDBS004B.jpg',5,true,false),\n  ('HBDBS005','Mamaili Headboard & Base Set','bedset','Headboard & Base Set',NULL,11695,12795,true,NULL,'images/furniture/HBDBS005.jpg',5,true,false),\n  ('HBDBS006','Mamatshaba Headboard & Base Set','bedset','Headboard & Base Set',NULL,13495,14795,true,NULL,'images/furniture/HBDBS006.jpg',5,true,false),\n  ('HBDBS007','Shoani Headboard & Base Set','bedset','Headboard & Base Set',NULL,12495,13695,true,NULL,'images/furniture/HBDBS007.jpg',5,true,false),\n  ('HBDBS008','Tseli Headboard & Base Set','bedset','Headboard & Base Set',NULL,12195,13095,true,NULL,'images/furniture/HBDBS008.jpg',5,true,false),\n  ('HDBRD001','Distinct Deep Button Headboard','headboard','Headboard',NULL,5195,6195,true,NULL,'images/furniture/HDBRD001.jpg',5,true,false),\n  ('HDBRD002','Plain Studded Headboard','headboard','Headboard',NULL,4795,5795,true,NULL,'images/furniture/HDBRD002.jpg',5,true,false),\n  ('HDBRD003','Deep Block Headboard','headboard','Headboard',NULL,4595,5595,true,NULL,'images/furniture/HDBRD003.jpg',5,true,false),\n  ('HDBRD004','Distinct Panel Headboard','headboard','Headboard',NULL,4895,5895,true,NULL,'images/furniture/HDBRD004.jpg',5,true,false),\n  ('HDBRD005','Hexagon Headboard','headboard','Headboard',NULL,7895,8895,true,NULL,'images/furniture/HDBRD005.jpg',5,true,false),\n  ('HDBRD006','Bordered Deep Button Headboard','headboard','Headboard',NULL,6995,7895,true,NULL,'images/furniture/HDBRD006.jpg',5,true,false),\n  ('HDBRD007','Sunrise Headboard','headboard','Headboard',NULL,5795,6995,true,NULL,'images/furniture/HDBRD007.jpg',5,true,false),\n  ('HDBRD008','Pleated Button Headboard','headboard','Headboard',NULL,4995,5995,true,NULL,'images/furniture/HDBRD008.jpg',5,true,false),\n  ('OTTMN001','Deep Button Ottoman','ottoman','Ottoman',4595,NULL,NULL,false,'{"Width": "1300mm", "Depth": "500mm", "Height": "450mm"}','images/furniture/OTTMN001.jpg',5,true,false),\n  ('OTTMN002','Button Genuine Leather Ottoman','ottoman','Ottoman',12295,NULL,NULL,false,'{"Width": "1500mm", "Depth": "550mm", "Height": "380mm"}','images/furniture/OTTMN002.jpg',5,true,false),\n  ('OTTMN003','Coffee Table Ottoman','ottoman','Ottoman',6295,NULL,NULL,false,'{"Width": "1200mm", "Depth": "550mm", "Height": "470mm"}','images/furniture/OTTMN003.jpg',5,true,false),\n  ('OTTMN004','Pleated Leather Ottoman','ottoman','Ottoman',12595,NULL,NULL,false,'{"Width": "1200mm", "Depth": "550mm", "Height": "380mm"}','images/furniture/OTTMN004.jpg',5,true,false),\n  ('OTTMN005','Palesa Ottoman','ottoman','Ottoman',4295,NULL,NULL,false,'{"Diameter": "910mm", "Height": "370mm"}','images/furniture/OTTMN005.jpg',5,true,false),\n  ('OTTMN006','Round Button Ottoman','ottoman','Ottoman',4595,NULL,NULL,false,'{"Diameter": "910mm", "Height": "400mm"}','images/furniture/OTTMN006.jpg',5,true,false)
ON CONFLICT (id) DO NOTHING;

-- ── 5. DONE ────────────────────────────────────────────────────────────
-- Next steps:
-- a) Go to Authentication → Users → Add User  (set your admin email + password)
-- b) Copy your Project URL and anon key from Settings → API
-- c) Paste them into js/supabase-config.js on your site
