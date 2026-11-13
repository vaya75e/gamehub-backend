BEGIN;

-- แนวเพิ่ม (ข้ามตัวที่มีแล้ว)
INSERT INTO genres (name_en, name_th)
SELECT v.n, v.t FROM (VALUES
  ('Open World','โอเพนเวิลด์'), ('Survival','เอาตัวรอด'), ('Indie','อินดี้'),
  ('Fighting','ต่อสู้'), ('Platformer','แพลตฟอร์ม'), ('Sandbox','แซนด์บ็อกซ์'),
  ('Roguelike','โรกไลก์'), ('Card','การ์ด'), ('Rhythm','จังหวะ'),
  ('Stealth','แอบแฝง'), ('Battle Royale','แบทเทิลรอยัล'), ('MMORPG','เอ็มเอ็มโออาร์พีจี'),
  ('Sci-Fi','ไซไฟ'), ('Fantasy','แฟนตาซี'), ('Casual','คลายเครียด'),
  ('Visual Novel','วิชวลโนเวล'), ('Tower Defense','ป้องกันฐาน')
) AS v(n,t)
WHERE NOT EXISTS (SELECT 1 FROM genres g WHERE lower(g.name_en) = lower(v.n));

-- โหมดผู้เล่น (เลือกได้หลายอัน)
CREATE TABLE IF NOT EXISTS player_modes (
    id       SERIAL PRIMARY KEY,
    name_en  VARCHAR(50) NOT NULL UNIQUE,
    name_th  VARCHAR(50) NOT NULL
);
INSERT INTO player_modes (name_en, name_th) VALUES
  ('Single Player', 'ผู้เล่นคนเดียว'),
  ('Multiplayer',   'ผู้เล่นหลายคน'),
  ('Online',        'ออนไลน์'),
  ('Offline',       'ออฟไลน์')
ON CONFLICT (name_en) DO NOTHING;

CREATE TABLE IF NOT EXISTS game_player_modes (
    game_id  BIGINT  NOT NULL REFERENCES games (id) ON DELETE CASCADE,
    mode_id  INTEGER NOT NULL REFERENCES player_modes (id),
    PRIMARY KEY (game_id, mode_id)
);

-- ย้ายค่า players เดิมคร่าว ๆ
INSERT INTO game_player_modes (game_id, mode_id)
SELECT g.id, pm.id FROM games g, player_modes pm
WHERE pm.name_en = 'Single Player' AND g.players ~ '(^|[^0-9])1([^0-9]|$)'
ON CONFLICT DO NOTHING;
INSERT INTO game_player_modes (game_id, mode_id)
SELECT g.id, pm.id FROM games g, player_modes pm
WHERE pm.name_en = 'Multiplayer' AND g.players ~ '[2-9]'
ON CONFLICT DO NOTHING;
INSERT INTO game_player_modes (game_id, mode_id)
SELECT g.id, pm.id FROM games g, player_modes pm
WHERE pm.name_en = 'Online' AND g.players ILIKE '%online%'
ON CONFLICT DO NOTHING;

-- รูปเพิ่มเติม (แกลเลอรี)
CREATE TABLE IF NOT EXISTS game_images (
    id        BIGSERIAL PRIMARY KEY,
    game_id   BIGINT       NOT NULL REFERENCES games (id) ON DELETE CASCADE,
    url       VARCHAR(500) NOT NULL,
    position  SMALLINT     NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_game_images_game ON game_images (game_id, position);

-- ราคาและส่วนลดแยกตามแพลตฟอร์ม
CREATE TABLE IF NOT EXISTS game_platforms (
    game_id           BIGINT        NOT NULL REFERENCES games (id) ON DELETE CASCADE,
    platform          VARCHAR(50)   NOT NULL,
    price             NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (price >= 0),
    discount_percent  SMALLINT      NOT NULL DEFAULT 0 CHECK (discount_percent BETWEEN 0 AND 100),
    download_url      VARCHAR(500),
    PRIMARY KEY (game_id, platform)
);
INSERT INTO game_platforms (game_id, platform, price, download_url)
SELECT id, coalesce(nullif(btrim(platform), ''), 'Other'), price, download_url
FROM games g
WHERE NOT EXISTS (SELECT 1 FROM game_platforms p WHERE p.game_id = g.id);

COMMIT;