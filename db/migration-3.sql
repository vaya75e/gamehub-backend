-- migration-3: นำข้อมูลเกมจริง 20 เรื่อง (จาก data.js ของเพื่อน) เข้า DB เดิม
-- รันครั้งเดียวใน Supabase SQL Editor  (ลบเกมตัวอย่าง 4 เรื่องเดิมและรีวิว/โหวต/รายการโปรดของมันด้วย)
BEGIN;

ALTER TABLE games ADD COLUMN IF NOT EXISTS is_featured BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE games ADD COLUMN IF NOT EXISTS is_new      BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE games ADD COLUMN IF NOT EXISTS is_popular  BOOLEAN NOT NULL DEFAULT FALSE;

INSERT INTO genres (name_en, name_th)
SELECT v.n, v.t FROM (VALUES
  ('Party','ปาร์ตี้'), ('Farming','ทำฟาร์ม'), ('Hide and Seek','ซ่อนหา')
) AS v(n,t)
WHERE NOT EXISTS (SELECT 1 FROM genres g WHERE lower(g.name_en)=lower(v.n));

INSERT INTO player_modes (name_en, name_th) VALUES
  ('Co-op','ร่วมมือ (Co-op)'), ('PvP','แข่งขัน (PvP)')
ON CONFLICT (name_en) DO NOTHING;

DELETE FROM games;   -- ลบเกมตัวอย่างเดิม (ลูกตารางลบตามด้วย CASCADE)

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (1,'Sons of the Forest','https://bit.ly/3Uv44xL','ผู้เล่นต้องออกสำรวจเกาะลึกลับเพื่อตามหามหาเศรษฐีที่หายตัวไป แต่กลับพบกับเกาะที่เต็มไปด้วยมนุษย์กินคนและสิ่งมีชีวิตกลายพันธุ์ ผู้เล่นต้องรวบรวมทรัพยากร สร้างที่พัก คราฟต์อาวุธ และเอาชีวิตรอดจากอันตราย สามารถเล่นคนเดียวหรือร่วมมือกับเพื่อนได้','1-8',true,false,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 1, id, 0 FROM genres WHERE name_en='Survival';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 1, id, 1 FROM genres WHERE name_en='Action';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 1, id, 2 FROM genres WHERE name_en='Adventure';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 1, id, 3 FROM genres WHERE name_en='Simulation';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 1, id, 4 FROM genres WHERE name_en='Horror';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 1, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 1, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_images (game_id,url,position) VALUES (1,'https://bit.ly/4iG1Y5S',0);
INSERT INTO game_images (game_id,url,position) VALUES (1,'https://bit.ly/4zcGAvn',1);
INSERT INTO game_images (game_id,url,position) VALUES (1,'https://bit.ly/48luLIn',2);
INSERT INTO game_images (game_id,url,position) VALUES (1,'https://bit.ly/4ewg8p4',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (1,'Steam',590,0,'https://store.steampowered.com/app/1326470/Sons_Of_The_Forest/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (2,'Slap ''em UP!','https://bit.ly/48M6yLs','เกมการ์ดแนวปาร์ตี้ (Casual Party Card Game) ฝีมือคนไทย พัฒนาโดย Urnique Studio ซึ่งหยิบยกกติกาเกมไพ่สลาฟที่ทุกคนคุ้นเคยมาทำใหม่ให้มีความสนุกสนานและกวนโอ๊ยยิ่งขึ้น','1-4',true,false,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 2, id, 0 FROM genres WHERE name_en='Card';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 2, id, 1 FROM genres WHERE name_en='Indie';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 2, id, 2 FROM genres WHERE name_en='Party';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 2, id FROM player_modes WHERE name_en='Multiplayer';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 2, id FROM player_modes WHERE name_en='PvP';
INSERT INTO game_images (game_id,url,position) VALUES (2,'https://bit.ly/4iQ2uhQ',0);
INSERT INTO game_images (game_id,url,position) VALUES (2,'https://bit.ly/4iOs9r4',1);
INSERT INTO game_images (game_id,url,position) VALUES (2,'https://bit.ly/4jeO3nZ',2);
INSERT INTO game_images (game_id,url,position) VALUES (2,'https://bit.ly/4kiztOp',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (2,'Steam',0,0,'https://store.steampowered.com/app/3703520/Slap_em_UP/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (3,'Stardew Valley','https://bit.ly/4AuiSMd','เกมแนวจำลองชีวิตและทำฟาร์มผสมผสาน RPG ที่ให้ผู้เล่นเริ่มต้นชีวิตใหม่ในเมืองชนบท โดยได้รับมรดกเป็นฟาร์มเก่าจากคุณปู่ ผู้เล่นจะต้องฟื้นฟูพื้นที่รกร้างให้กลายเป็นฟาร์มที่อุดมสมบูรณ์ สามารถปลูกพืช เลี้ยงสัตว์ ตกปลา ขุดเหมือง และสร้างสิ่งของต่าง ๆ นอกจากนี้ยังสามารถพบปะพูดคุย สร้างมิตรภาพ และพัฒนาความสัมพันธ์กับชาวเมือง รวมถึงสำรวจเรื่องราวและความลับที่ซ่อนอยู่ในหุบเขาได้อย่างอิสระ','1-8',true,true,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 3, id, 0 FROM genres WHERE name_en='Simulation';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 3, id, 1 FROM genres WHERE name_en='Farming';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 3, id, 2 FROM genres WHERE name_en='Adventure';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 3, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 3, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_images (game_id,url,position) VALUES (3,'https://bit.ly/4etUlyn',0);
INSERT INTO game_images (game_id,url,position) VALUES (3,'https://bit.ly/3WGaLh1',1);
INSERT INTO game_images (game_id,url,position) VALUES (3,'https://bit.ly/4jeO3nZ',2);
INSERT INTO game_images (game_id,url,position) VALUES (3,'https://bit.ly/4tg66id',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (3,'Steam',315,0,'https://store.steampowered.com/app/413150/Stardew_Valley/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (4,'MECCHA CHAMELEON','https://bit.ly/4sVEHBV','เกมปาร์ตี้แนวซ่อนหาที่ผู้เล่นต้องระบายสีตัวละครให้กลมกลืนกับฉาก เพื่อหลบซ่อนจากฝ่ายค้นหา โดยต้องใช้ไหวพริบและการสังเกตเพื่อเอาชนะคู่แข่ง สามารถเล่นสนุกกับเพื่อนผ่านระบบออนไลน์ได้','2-10',true,true,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 4, id, 0 FROM genres WHERE name_en='Party';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 4, id, 1 FROM genres WHERE name_en='Hide and Seek';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 4, id FROM player_modes WHERE name_en='Multiplayer';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 4, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 4, id FROM player_modes WHERE name_en='PvP';
INSERT INTO game_images (game_id,url,position) VALUES (4,'https://bit.ly/4iBr6w1',0);
INSERT INTO game_images (game_id,url,position) VALUES (4,'https://bit.ly/4iUMriR',1);
INSERT INTO game_images (game_id,url,position) VALUES (4,'https://bit.ly/4k8SGBW',2);
INSERT INTO game_images (game_id,url,position) VALUES (4,'https://bit.ly/4zeMYlG',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (4,'Steam',125,0,'https://store.steampowered.com/app/4704690/MECCHA_CHAMELEON/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (5,'PEAK','https://l1nq.com/udmdmir','PEAK เป็นเกมผจญภัยปีนเขาแบบร่วมมือกัน ผู้เล่นจะรับบทเป็นลูกเสือที่ติดอยู่บนเกาะลึกลับ และต้องช่วยกันปีนขึ้นไปยังยอดเขาเพื่อเอาชีวิตรอด ระหว่างทางต้องระวังอุปสรรค จัดการพลังงานและอาการบาดเจ็บ พร้อมใช้อุปกรณ์ช่วยปีนเขา สามารถเล่นคนเดียวหรือร่วมมือกับเพื่อนได้','1-4',true,true,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 5, id, 0 FROM genres WHERE name_en='Action';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 5, id, 1 FROM genres WHERE name_en='Adventure';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 5, id, 2 FROM genres WHERE name_en='Survival';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 5, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 5, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_images (game_id,url,position) VALUES (5,'https://sl1nk.com/q6y7oq8',0);
INSERT INTO game_images (game_id,url,position) VALUES (5,'https://sl1nk.com/48glaiq',1);
INSERT INTO game_images (game_id,url,position) VALUES (5,'https://sl1nk.com/zzyk78f',2);
INSERT INTO game_images (game_id,url,position) VALUES (5,'https://sl1nk.com/rcxdid8',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (5,'Steam',159,0,'https://store.steampowered.com/app/3527290/PEAK/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (6,'RV There Yet?','https://sl1nk.com/brx8f3f','เกมขับรถบ้านผจญภัยที่ผู้เล่นต้องเดินทางกลับบ้านผ่านเส้นทางอันตราย ต้องช่วยกันขับรถ แก้ไขอุปสรรค ใช้อุปกรณ์ลากจูง และเอาชีวิตรอดระหว่างการเดินทาง','1-4',true,true,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 6, id, 0 FROM genres WHERE name_en='Action';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 6, id, 1 FROM genres WHERE name_en='Adventure';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 6, id, 2 FROM genres WHERE name_en='Simulation';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 6, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 6, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_images (game_id,url,position) VALUES (6,'https://l1nq.com/qbcan77',0);
INSERT INTO game_images (game_id,url,position) VALUES (6,'https://l1nq.com/zr7qix0',1);
INSERT INTO game_images (game_id,url,position) VALUES (6,'https://sl1nk.com/kb5un3b',2);
INSERT INTO game_images (game_id,url,position) VALUES (6,'https://l1nq.com/nq4i6hd',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (6,'Steam',179,0,'https://store.steampowered.com/app/3949040/RV_There_Yet/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (7,'Green Hell','https://sl1nk.com/pd88ype','เกมเอาชีวิตรอดในป่าฝนอเมซอน ผู้เล่นต้องหาอาหาร ล่าสัตว์ สร้างที่พัก ประดิษฐ์อุปกรณ์ และดูแลสุขภาพร่างกายและจิตใจเพื่อเอาชีวิตรอดจากป่าที่เต็มไปด้วยอันตราย','1-4',true,false,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 7, id, 0 FROM genres WHERE name_en='Survival';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 7, id, 1 FROM genres WHERE name_en='Action';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 7, id, 2 FROM genres WHERE name_en='Adventure';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 7, id, 3 FROM genres WHERE name_en='Simulation';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 7, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 7, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_images (game_id,url,position) VALUES (7,'https://l1nq.com/n5h1pnf',0);
INSERT INTO game_images (game_id,url,position) VALUES (7,'https://sl1nk.com/b17wgxp',1);
INSERT INTO game_images (game_id,url,position) VALUES (7,'https://sl1nk.com/kgkkte0',2);
INSERT INTO game_images (game_id,url,position) VALUES (7,'https://l1nq.com/1ut3urr',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (7,'Steam',319,0,'https://store.steampowered.com/app/815370/Green_Hell/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (8,'Genshin Impact','https://l1nq.com/oegy9xe','เกมผจญภัยสวมบทบาทในโลกแฟนตาซีแบบเปิด ผู้เล่นออกสำรวจดินแดน Teyvat ต่อสู้ด้วยพลังธาตุ รวบรวมตัวละคร และค้นพบเรื่องราวของโลก','1-4',true,false,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 8, id, 0 FROM genres WHERE name_en='Action';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 8, id, 1 FROM genres WHERE name_en='Adventure';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 8, id, 2 FROM genres WHERE name_en='RPG';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 8, id, 3 FROM genres WHERE name_en='Fantasy';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 8, id, 4 FROM genres WHERE name_en='Open World';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 8, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 8, id FROM player_modes WHERE name_en='Multiplayer';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 8, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_images (game_id,url,position) VALUES (8,'https://l1nq.com/fznkeri',0);
INSERT INTO game_images (game_id,url,position) VALUES (8,'https://l1nq.com/hqne50a',1);
INSERT INTO game_images (game_id,url,position) VALUES (8,'https://sl1nk.com/1cpb2sg',2);
INSERT INTO game_images (game_id,url,position) VALUES (8,'https://sl1nk.com/zf6q9he',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (8,'เว็บไซต์ทางการ',0,0,'https://genshin.hoyoverse.com/en/home');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (9,'The Sims 3','https://sl1nk.com/q9qcjyw','เกมจำลองชีวิตที่ให้ผู้เล่นสร้างตัวละคร กำหนดบุคลิก ออกแบบบ้าน สร้างครอบครัว ทำงาน และใช้ชีวิตในโลกเปิดที่มีอิสระในการเล่น','1',false,false,false);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 9, id, 0 FROM genres WHERE name_en='Simulation';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 9, id, 1 FROM genres WHERE name_en='RPG';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 9, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_images (game_id,url,position) VALUES (9,'https://sl1nk.com/9tv2v6q',0);
INSERT INTO game_images (game_id,url,position) VALUES (9,'https://l1nq.com/prj6856',1);
INSERT INTO game_images (game_id,url,position) VALUES (9,'https://l1nq.com/15eh348',2);
INSERT INTO game_images (game_id,url,position) VALUES (9,'https://l1nq.com/jjk6y63',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (9,'Steam',539,0,'https://store.steampowered.com/app/47890/The_Sims_3/');
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (9,'EA',840,0,'https://www.ea.com/games/the-sims/the-sims-3');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (10,'The Sims 4','https://sl1nk.com/zjt5y8l','เกมจำลองชีวิตที่ให้ผู้เล่นสร้างตัวละคร ออกแบบบ้าน ทำกิจกรรมในชีวิตประจำวัน สร้างความสัมพันธ์ ทำงาน และกำหนดเรื่องราวชีวิตของตัวละครได้ตามต้องการ','1',false,false,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 10, id, 0 FROM genres WHERE name_en='Simulation';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 10, id, 1 FROM genres WHERE name_en='RPG';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 10, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_images (game_id,url,position) VALUES (10,'https://l1nq.com/apl9kzz',0);
INSERT INTO game_images (game_id,url,position) VALUES (10,'https://sl1nk.com/fvogsi2',1);
INSERT INTO game_images (game_id,url,position) VALUES (10,'https://l1nq.com/1fk9wk4',2);
INSERT INTO game_images (game_id,url,position) VALUES (10,'https://sl1nk.com/spfdl27',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (10,'Steam',0,0,'https://store.steampowered.com/app/1222670/The_Sims_4/');
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (10,'EA',0,0,'https://www.ea.com/games/the-sims/the-sims-4');
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (10,'Epic Games Store',0,0,'https://store.epicgames.com/p/the-sims-4');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (11,'3on3 FreeStyle: Rebound','https://sl1nk.com/d4adee9','เกมบาสเกตบอลแนวสตรีทที่ผู้เล่นเลือกตัวละครและร่วมแข่งขันบาสเกตบอลแบบ 3 ต่อ 3 พร้อมใช้ทักษะเฉพาะตัวในการทำคะแนนและเอาชนะทีมคู่แข่ง','1-6',true,false,false);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 11, id, 0 FROM genres WHERE name_en='Sports';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 11, id, 1 FROM genres WHERE name_en='Action';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 11, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 11, id FROM player_modes WHERE name_en='Multiplayer';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 11, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 11, id FROM player_modes WHERE name_en='PvP';
INSERT INTO game_images (game_id,url,position) VALUES (11,'https://sl1nk.com/e7gxbdx',0);
INSERT INTO game_images (game_id,url,position) VALUES (11,'https://l1nq.com/rp4c05k',1);
INSERT INTO game_images (game_id,url,position) VALUES (11,'https://l1nq.com/z585d80',2);
INSERT INTO game_images (game_id,url,position) VALUES (11,'https://l1nq.com/ub4q52j',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (11,'Steam',0,0,'https://store.steampowered.com/app/1292630/3on3_FreeStyle_Rebound/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (12,'PratFall','https://l1nq.com/t37j0ee','เกมผจญภัยแนวร่วมมือกัน ผู้เล่นต้องเดินทางลงไปในถ้ำอันตรายเพื่อช่วยเหลือสุนัขที่หายไป ระหว่างทางต้องขุดดิน หลบกับดัก ระเบิดสิ่งกีดขวาง และช่วยเหลือเพื่อนร่วมทีม','1 คนขึ้นไป',false,true,false);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 12, id, 0 FROM genres WHERE name_en='Action';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 12, id, 1 FROM genres WHERE name_en='Adventure';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 12, id, 2 FROM genres WHERE name_en='Survival';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 12, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 12, id FROM player_modes WHERE name_en='Multiplayer';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 12, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_images (game_id,url,position) VALUES (12,'https://sl1nk.com/17bxfzn',0);
INSERT INTO game_images (game_id,url,position) VALUES (12,'https://sl1nk.com/8wgxtyj',1);
INSERT INTO game_images (game_id,url,position) VALUES (12,'https://sl1nk.com/lq9s5du',2);
INSERT INTO game_images (game_id,url,position) VALUES (12,'https://sl1nk.com/m6fxbyd',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (12,'Steam',159,0,'https://store.steampowered.com/app/4244510/Pratfall/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (13,'Apex Legends','https://sl1nk.com/i7s8ji4','เกมยิงแนว Battle Royale ที่ผู้เล่นเลือกตัวละครที่มีความสามารถแตกต่างกัน แล้วร่วมทีมต่อสู้กับทีมอื่นเพื่อเป็นผู้รอดชีวิตคนสุดท้าย','1-3',false,false,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 13, id, 0 FROM genres WHERE name_en='Survival';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 13, id, 1 FROM genres WHERE name_en='Action';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 13, id, 2 FROM genres WHERE name_en='Shooter';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 13, id FROM player_modes WHERE name_en='Multiplayer';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 13, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 13, id FROM player_modes WHERE name_en='PvP';
INSERT INTO game_images (game_id,url,position) VALUES (13,'https://sl1nk.com/5w788kt',0);
INSERT INTO game_images (game_id,url,position) VALUES (13,'https://l1nq.com/w313cvt',1);
INSERT INTO game_images (game_id,url,position) VALUES (13,'https://sl1nk.com/ltj0rn1',2);
INSERT INTO game_images (game_id,url,position) VALUES (13,'https://sl1nk.com/ngsl3w1',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (13,'Steam',0,0,'https://store.steampowered.com/app/1172470/Apex_Legends/');
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (13,'EA',0,0,'https://www.ea.com/games/apex-legends/apex-legends');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (14,'PUBG: BATTLEGROUNDS','https://l1nq.com/c9beq0n','เกมยิงแนว Battle Royale ที่ผู้เล่นกระโดดร่มลงสู่สนามรบ ค้นหาอาวุธและอุปกรณ์ ต่อสู้กับผู้เล่นคนอื่น และเอาชีวิตรอดจนเป็นคนหรือทีมสุดท้าย','1-4',false,false,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 14, id, 0 FROM genres WHERE name_en='Survival';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 14, id, 1 FROM genres WHERE name_en='Action';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 14, id, 2 FROM genres WHERE name_en='Shooter';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 14, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 14, id FROM player_modes WHERE name_en='Multiplayer';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 14, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 14, id FROM player_modes WHERE name_en='PvP';
INSERT INTO game_images (game_id,url,position) VALUES (14,'https://sl1nk.com/61oh1ma',0);
INSERT INTO game_images (game_id,url,position) VALUES (14,'https://sl1nk.com/axupm6i',1);
INSERT INTO game_images (game_id,url,position) VALUES (14,'https://sl1nk.com/r833263',2);
INSERT INTO game_images (game_id,url,position) VALUES (14,'https://sl1nk.com/fn9yn06',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (14,'Steam',0,0,'https://store.steampowered.com/app/578080/PUBG_BATTLEGROUNDS/');
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (14,'Epic Games Store',0,0,'https://store.epicgames.com/p/pubg-59c1d9');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (15,'VALORANT','https://l1nq.com/w7lqhin','เกมยิงมุมมองบุคคลที่หนึ่งแบบทีม 5 ต่อ 5 ผู้เล่นเลือกเอเจนต์ที่มีความสามารถเฉพาะตัว วางแผนโจมตีและป้องกันเพื่อทำภารกิจให้สำเร็จ','1-10',true,false,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 15, id, 0 FROM genres WHERE name_en='Action';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 15, id, 1 FROM genres WHERE name_en='Shooter';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 15, id FROM player_modes WHERE name_en='Multiplayer';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 15, id FROM player_modes WHERE name_en='PvP';
INSERT INTO game_images (game_id,url,position) VALUES (15,'https://sl1nk.com/me8lgd3',0);
INSERT INTO game_images (game_id,url,position) VALUES (15,'https://l1nq.com/9co6iaa',1);
INSERT INTO game_images (game_id,url,position) VALUES (15,'https://sl1nk.com/5zbvbcp',2);
INSERT INTO game_images (game_id,url,position) VALUES (15,'https://l1nq.com/sztgesw',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (15,'Epic Games Store',0,0,'https://store.epicgames.com/p/valorant');
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (15,'เว็บไซต์ทางการ',0,0,'https://playvalorant.com/th-th/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (16,'Super Battle Golf','https://l1nq.com/cg9pgy6','เกมกอล์ฟออนไลน์แนวปาร์ตี้ที่ผู้เล่นแข่งขันกันตีลูกกอล์ฟไปยังหลุมพร้อมกัน สามารถใช้ไอเทมก่อกวนและขัดขวางคู่แข่งระหว่างการแข่งขันได้','1-8',true,true,false);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 16, id, 0 FROM genres WHERE name_en='Sports';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 16, id, 1 FROM genres WHERE name_en='Party';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 16, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 16, id FROM player_modes WHERE name_en='Multiplayer';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 16, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 16, id FROM player_modes WHERE name_en='PvP';
INSERT INTO game_images (game_id,url,position) VALUES (16,'https://l1nq.com/x4oirpw',0);
INSERT INTO game_images (game_id,url,position) VALUES (16,'https://l1nq.com/jllikyd',1);
INSERT INTO game_images (game_id,url,position) VALUES (16,'https://l1nq.com/3p687b1',2);
INSERT INTO game_images (game_id,url,position) VALUES (16,'https://sl1nk.com/gkb9mvk',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (16,'Steam',259,0,'https://store.steampowered.com/app/4069520/Super_Battle_Golf/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (17,'Minecraft','https://sl1nk.com/mg5lnip','เกมแซนด์บ็อกซ์ที่ให้ผู้เล่นสำรวจโลกแบบบล็อก เก็บทรัพยากร สร้างสิ่งก่อสร้าง ประดิษฐ์อุปกรณ์ และเอาชีวิตรอดจากสัตว์ประหลาด','1 คนขึ้นไป',false,false,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 17, id, 0 FROM genres WHERE name_en='Adventure';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 17, id, 1 FROM genres WHERE name_en='Survival';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 17, id, 2 FROM genres WHERE name_en='Simulation';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 17, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 17, id FROM player_modes WHERE name_en='Multiplayer';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 17, id FROM player_modes WHERE name_en='Co-op';
INSERT INTO game_images (game_id,url,position) VALUES (17,'https://sl1nk.com/gu6jp7y',0);
INSERT INTO game_images (game_id,url,position) VALUES (17,'https://l1nq.com/nxglej4',1);
INSERT INTO game_images (game_id,url,position) VALUES (17,'https://sl1nk.com/57alf9i',2);
INSERT INTO game_images (game_id,url,position) VALUES (17,'https://sl1nk.com/cunqta0',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (17,'เว็บไซต์ทางการ',1059,0,'https://www.minecraft.net/en-us/about-minecraft');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (18,'Aniimo','https://sl1nk.com/vi16ixa','เกมผจญภัยสวมบทบาทโลกเปิดที่ให้ผู้เล่นออกสำรวจโลก Idyll จับและสะสมสิ่งมีชีวิตมหัศจรรย์ที่เรียกว่า Aniimo พร้อมพัฒนาความสามารถและค้นพบความลับของโลก','1',false,true,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 18, id, 0 FROM genres WHERE name_en='Adventure';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 18, id, 1 FROM genres WHERE name_en='RPG';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 18, id, 2 FROM genres WHERE name_en='Open World';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 18, id, 3 FROM genres WHERE name_en='Fantasy';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 18, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 18, id FROM player_modes WHERE name_en='Multiplayer';
INSERT INTO game_images (game_id,url,position) VALUES (18,'https://l1nq.com/2lbf6je',0);
INSERT INTO game_images (game_id,url,position) VALUES (18,'https://l1nq.com/gu3rovh',1);
INSERT INTO game_images (game_id,url,position) VALUES (18,'https://l1nq.com/0g075eq',2);
INSERT INTO game_images (game_id,url,position) VALUES (18,'https://l1nq.com/w5ygwkk',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (18,'Epic Games Store',0,0,'https://store.epicgames.com/p/aniimo-759396');
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (18,'Steam',0,0,'https://store.steampowered.com/app/4126040/Aniimo/');
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (18,'เว็บไซต์ทางการ',0,0,'https://aniimo.com/');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (19,'Planet Zoo 2','https://l1nq.com/bkiflzy','เกมจำลองการสร้างและบริหารสวนสัตว์ ผู้เล่นออกแบบพื้นที่อยู่อาศัยของสัตว์ ดูแลสัตว์ จัดการพนักงาน และพัฒนาสวนสัตว์ให้เติบโต โดยมีสัตว์น้ำและสัตว์บินได้เพิ่มเติม','1',false,false,false);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 19, id, 0 FROM genres WHERE name_en='Simulation';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 19, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_images (game_id,url,position) VALUES (19,'https://l1nq.com/97mhtt6',0);
INSERT INTO game_images (game_id,url,position) VALUES (19,'https://sl1nk.com/ibc3c8z',1);
INSERT INTO game_images (game_id,url,position) VALUES (19,'https://l1nq.com/bnbvbxn',2);
INSERT INTO game_images (game_id,url,position) VALUES (19,'https://l1nq.com/ph73xud',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (19,'Steam',1079,0,'https://store.steampowered.com/app/3219030/Planet_Zoo_2/');
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (19,'Epic Games Store',1079,0,'https://store.epicgames.com/p/planet-zoo-2-cbdaa7');

INSERT INTO games (id,title,image_url,description,players,is_featured,is_new,is_popular) VALUES (20,'Castlevania: Belmont''s Curse','https://sl1nk.com/2s9rtk2','เกมแอ็คชั่นผจญภัยแบบ 2 มิติ ผู้เล่นรับบทเป็น Rose Belmont ออกต่อสู้กับเหล่าปีศาจ สำรวจเมืองปารีสและปราสาทของ Dracula โดยใช้อาวุธและแส้ศักดิ์สิทธิ์','1',true,true,true);
INSERT INTO game_genres (game_id,genre_id,position) SELECT 20, id, 0 FROM genres WHERE name_en='Action';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 20, id, 1 FROM genres WHERE name_en='Adventure';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 20, id, 2 FROM genres WHERE name_en='Fantasy';
INSERT INTO game_genres (game_id,genre_id,position) SELECT 20, id, 3 FROM genres WHERE name_en='Horror';
INSERT INTO game_player_modes (game_id,mode_id) SELECT 20, id FROM player_modes WHERE name_en='Single Player';
INSERT INTO game_images (game_id,url,position) VALUES (20,'https://sl1nk.com/1nxum23',0);
INSERT INTO game_images (game_id,url,position) VALUES (20,'https://sl1nk.com/ztnxlkq',1);
INSERT INTO game_images (game_id,url,position) VALUES (20,'https://sl1nk.com/zpc7c0i',2);
INSERT INTO game_images (game_id,url,position) VALUES (20,'https://sl1nk.com/e01pzsr',3);
INSERT INTO game_platforms (game_id,platform,price,discount_percent,download_url) VALUES (20,'Steam',845,0,'https://store.steampowered.com/app/4231820/Castlevania_Belmonts_Curse/');

-- สรุปราคาต่ำสุด/ชื่อแพลตฟอร์ม/ลิงก์แรก ลงตาราง games (เหมือนที่โค้ด Go ทำตอนบันทึกจากหน้า Admin)
UPDATE games g SET
  price = coalesce((SELECT min(round(price*(100-discount_percent)/100.0,2)) FROM game_platforms WHERE game_id=g.id),0),
  platform = (SELECT string_agg(platform, ', ' ORDER BY platform) FROM game_platforms WHERE game_id=g.id),
  download_url = (SELECT download_url FROM game_platforms WHERE game_id=g.id ORDER BY price, platform LIMIT 1);

-- ให้เลข id ถัดไปของเกมที่เพิ่มจาก Admin ต่อจาก 20
SELECT setval(pg_get_serial_sequence('games','id'), (SELECT max(id) FROM games));

COMMIT;