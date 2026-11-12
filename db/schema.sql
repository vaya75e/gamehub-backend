BEGIN;

CREATE TABLE genres (
    id       SERIAL       PRIMARY KEY,
    name_en  VARCHAR(50)  NOT NULL,
    name_th  VARCHAR(50)
);

CREATE TABLE games (
    id            BIGSERIAL     PRIMARY KEY,
    title         VARCHAR(255)  NOT NULL,
    image_url     VARCHAR(500),
    price         NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (price >= 0),
    description   TEXT,
    players       VARCHAR(50),
    download_url  VARCHAR(500),
    platform      VARCHAR(50),
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX idx_games_title_lower ON games (lower(title));
CREATE INDEX idx_games_price       ON games (price);

CREATE TABLE game_genres (
    game_id   BIGINT    NOT NULL REFERENCES games (id) ON DELETE CASCADE,
    genre_id  INTEGER   NOT NULL REFERENCES genres (id),
    position  SMALLINT  NOT NULL,
    PRIMARY KEY (game_id, genre_id),
    UNIQUE (game_id, position)
);
CREATE INDEX idx_game_genres_genre ON game_genres (genre_id);

CREATE TABLE members (
    id             BIGSERIAL     PRIMARY KEY,
    email          VARCHAR(255)  NOT NULL,
    password_hash  VARCHAR(255)  NOT NULL,
    display_name   VARCHAR(50)   NOT NULL CHECK (char_length(btrim(display_name)) >= 1),
    avatar_url     VARCHAR(500),
    role           VARCHAR(10)   NOT NULL DEFAULT 'member' CHECK (role IN ('member', 'admin')),
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX uq_members_email ON members (lower(email));

CREATE TABLE reviews (
    id          BIGSERIAL    PRIMARY KEY,
    member_id   BIGINT       NOT NULL REFERENCES members (id) ON DELETE CASCADE,
    game_id     BIGINT       NOT NULL REFERENCES games (id) ON DELETE CASCADE,
    text        TEXT         NOT NULL CHECK (char_length(btrim(text)) >= 10),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    UNIQUE (member_id, game_id)
);
CREATE INDEX idx_reviews_game_created ON reviews (game_id, created_at DESC);

CREATE TABLE votes (
    member_id   BIGINT       NOT NULL REFERENCES members (id) ON DELETE CASCADE,
    game_id     BIGINT       NOT NULL REFERENCES games (id) ON DELETE CASCADE,
    score       SMALLINT     NOT NULL CHECK (score BETWEEN 1 AND 10),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    PRIMARY KEY (member_id, game_id)
);
CREATE INDEX idx_votes_game ON votes (game_id);

CREATE VIEW game_vote_stats AS
SELECT game_id,
       count(*)             AS vote_count,
       round(avg(score), 1) AS vote_average
FROM votes
GROUP BY game_id;

CREATE TABLE wishlist_items (
    member_id   BIGINT        NOT NULL REFERENCES members (id) ON DELETE CASCADE,
    game_id     BIGINT        NOT NULL REFERENCES games (id) ON DELETE CASCADE,
    note        VARCHAR(200),
    added_at    TIMESTAMPTZ   NOT NULL DEFAULT now(),
    PRIMARY KEY (member_id, game_id)
);
CREATE INDEX idx_wishlist_member_added ON wishlist_items (member_id, added_at DESC);

INSERT INTO genres (name_en, name_th) VALUES
    ('Action',     'แอ็กชัน'),
    ('Adventure',  'ผจญภัย'),
    ('RPG',        'สวมบทบาท'),
    ('Strategy',   'วางแผน'),
    ('Simulation', 'จำลอง'),
    ('Sports',     'กีฬา'),
    ('Racing',     'แข่งรถ'),
    ('Horror',     'สยองขวัญ'),
    ('Puzzle',     'ไขปริศนา'),
    ('Shooter',    'ยิง');

COMMIT;

