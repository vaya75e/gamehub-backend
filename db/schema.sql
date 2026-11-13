
BEGIN;

-- =====================================
-- 1. ตารางประเภทเกม
-- =====================================
CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- =====================================
-- 2. ตารางรูปแบบการเล่น
-- =====================================
CREATE TABLE player_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- =====================================
-- 3. ตารางเกม
-- =====================================
CREATE TABLE games (
    id BIGINT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    cover_url VARCHAR(1000),
    description TEXT,
    players VARCHAR(50),

    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_new BOOLEAN NOT NULL DEFAULT FALSE,
    is_popular BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_games_title_lower
ON games (lower(title));

CREATE INDEX idx_games_featured
ON games (is_featured);

CREATE INDEX idx_games_new
ON games (is_new);

CREATE INDEX idx_games_popular
ON games (is_popular);

-- =====================================
-- 4. ตารางรูปภาพเพิ่มเติม
-- =====================================
CREATE TABLE game_images (
    id BIGSERIAL PRIMARY KEY,
    game_id BIGINT NOT NULL
        REFERENCES games(id) ON DELETE CASCADE,

    image_url VARCHAR(1000) NOT NULL,
    position SMALLINT NOT NULL,

    UNIQUE (game_id, position)
);

CREATE INDEX idx_game_images_game
ON game_images (game_id);

-- =====================================
-- 5. ตารางช่องทางซื้อเกม
-- =====================================
CREATE TABLE game_download_links (
    id BIGSERIAL PRIMARY KEY,
    game_id BIGINT NOT NULL
        REFERENCES games(id) ON DELETE CASCADE,

    platform VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL DEFAULT 0
        CHECK (price >= 0),

    url VARCHAR(1000) NOT NULL
);

CREATE INDEX idx_game_download_links_game
ON game_download_links (game_id);

CREATE INDEX idx_game_download_links_price
ON game_download_links (price);

-- =====================================
-- 6. ตารางความสัมพันธ์เกมกับแนวเกม
-- =====================================
CREATE TABLE game_genres (
    game_id BIGINT NOT NULL
        REFERENCES games(id) ON DELETE CASCADE,

    genre_id INTEGER NOT NULL
        REFERENCES genres(id),

    position SMALLINT NOT NULL,

    PRIMARY KEY (game_id, genre_id),
    UNIQUE (game_id, position)
);

CREATE INDEX idx_game_genres_genre
ON game_genres (genre_id);

-- =====================================
-- 7. ตารางความสัมพันธ์เกมกับรูปแบบการเล่น
-- =====================================
CREATE TABLE game_player_types (
    game_id BIGINT NOT NULL
        REFERENCES games(id) ON DELETE CASCADE,

    player_type_id INTEGER NOT NULL
        REFERENCES player_types(id),

    position SMALLINT NOT NULL,

    PRIMARY KEY (game_id, player_type_id),
    UNIQUE (game_id, position)
);

-- =====================================
-- 8. ตารางสมาชิก
-- =====================================
CREATE TABLE members (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,

    display_name VARCHAR(50) NOT NULL
        CHECK (char_length(btrim(display_name)) >= 1),

    avatar_url VARCHAR(500),

    role VARCHAR(10) NOT NULL DEFAULT 'member'
        CHECK (role IN ('member', 'admin')),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX uq_members_email
ON members (lower(email));

-- =====================================
-- 9. ตารางรีวิว
-- =====================================
CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,

    member_id BIGINT NOT NULL
        REFERENCES members(id) ON DELETE CASCADE,

    game_id BIGINT NOT NULL
        REFERENCES games(id) ON DELETE CASCADE,

    text TEXT NOT NULL
        CHECK (char_length(btrim(text)) >= 10),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (member_id, game_id)
);

CREATE INDEX idx_reviews_game_created
ON reviews (game_id, created_at DESC);

-- =====================================
-- 10. ตารางคะแนนเกม
-- =====================================
CREATE TABLE votes (
    member_id BIGINT NOT NULL
        REFERENCES members(id) ON DELETE CASCADE,

    game_id BIGINT NOT NULL
        REFERENCES games(id) ON DELETE CASCADE,

    score SMALLINT NOT NULL
        CHECK (score BETWEEN 1 AND 10),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (member_id, game_id)
);

CREATE INDEX idx_votes_game
ON votes (game_id);

-- =====================================
-- 11. View คะแนนเฉลี่ย
-- =====================================
CREATE VIEW game_vote_stats AS
SELECT
    game_id,
    COUNT(*) AS vote_count,
    ROUND(AVG(score), 1) AS vote_average
FROM votes
GROUP BY game_id;

-- =====================================
-- 12. ตารางรายการโปรด
-- =====================================
CREATE TABLE wishlist_items (
    member_id BIGINT NOT NULL
        REFERENCES members(id) ON DELETE CASCADE,

    game_id BIGINT NOT NULL
        REFERENCES games(id) ON DELETE CASCADE,

    note VARCHAR(200),
    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (member_id, game_id)
);

CREATE INDEX idx_wishlist_member_added
ON wishlist_items (member_id, added_at DESC);

-- =====================================
-- 13. ข้อมูลแนวเกม
-- =====================================
INSERT INTO genres (name) VALUES
    ('เอาชีวิตรอด'),
    ('แอ็คชั่น'),
    ('แอ็กชัน'),
    ('ผจญภัย'),
    ('จำลองสถานการณ์'),
    ('สยองขวัญ'),
    ('เกมการ์ด'),
    ('เกมอินดี้'),
    ('เกมปาร์ตี้'),
    ('ทำฟาร์ม'),
    ('ปาร์ตี้'),
    ('ซ่อนหา'),
    ('สวมบทบาท'),
    ('แฟนตาซี'),
    ('โลกเปิด'),
    ('ยิงปืน'),
    ('กีฬา');

-- =====================================
-- 14. ข้อมูลรูปแบบการเล่น
-- =====================================
INSERT INTO player_types (name) VALUES
    ('ผู้เล่นคนเดียว'),
    ('ผู้เล่นหลายคน'),
    ('Co-op'),
    ('PvP');

COMMIT;
