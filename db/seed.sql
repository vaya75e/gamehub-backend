BEGIN;

INSERT INTO games (title, image_url, price, description, players, download_url, platform) VALUES
 ('Space Raiders', 'https://placehold.co/400x560?text=Space+Raiders', 0,
  'เกมยิงยานอวกาศสุดมันส์ ฟรีทั้งเกม', '1-4', 'https://store.steampowered.com/', 'Steam'),
 ('Dungeon Quest', 'https://placehold.co/400x560?text=Dungeon+Quest', 299,
  'RPG ลงดันเจี้ยน สะสมอาวุธและอัปเลเวล', '1', 'https://store.epicgames.com/', 'Epic'),
 ('Turbo Drift', 'https://placehold.co/400x560?text=Turbo+Drift', 159,
  'เกมแข่งรถดริฟต์ เล่นออนไลน์ได้', 'Online 2-8', 'https://store.steampowered.com/', 'Steam'),
 ('Farm Friends', 'https://placehold.co/400x560?text=Farm+Friends', 89,
  'เกมจำลองฟาร์มสบาย ๆ เล่นกับเพื่อนได้', '1-4', 'https://play.google.com/', 'Mobile');

INSERT INTO game_genres (game_id, genre_id, position) VALUES
 (1, 10, 0), (1, 1, 1),
 (2, 3, 0),  (2, 2, 1),
 (3, 7, 0),
 (4, 5, 0);

COMMIT;


