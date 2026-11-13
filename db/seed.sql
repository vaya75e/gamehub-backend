BEGIN;

CREATE TEMP TABLE seed_games (
    id BIGINT,
    title TEXT,
    cover_url TEXT,
    description TEXT,
    players TEXT,
    is_featured BOOLEAN,
    is_new BOOLEAN,
    is_popular BOOLEAN,
    gallery JSONB,
    download_links JSONB,
    genres JSONB,
    player_types JSONB
) ON COMMIT DROP;

INSERT INTO seed_games
SELECT *
FROM jsonb_to_recordset($games$
[
  {
    "id":1,
    "title":"Sons of the Forest",
    "cover_url":"https://bit.ly/3Uv44xL",
    "description":"ผู้เล่นต้องออกสำรวจเกาะลึกลับเพื่อตามหามหาเศรษฐีที่หายตัวไป แต่กลับพบกับเกาะที่เต็มไปด้วยมนุษย์กินคนและสิ่งมีชีวิตกลายพันธุ์ ผู้เล่นต้องรวบรวมทรัพยากร สร้างที่พัก คราฟต์อาวุธ และเอาชีวิตรอดจากอันตราย สามารถเล่นคนเดียวหรือร่วมมือกับเพื่อนได้",
    "players":"1-8","is_featured":true,"is_new":false,"is_popular":true,
    "gallery":["https://bit.ly/4iG1Y5S","https://bit.ly/4zcGAvn","https://bit.ly/48luLIn","https://bit.ly/4ewg8p4"],
    "download_links":[{"platform":"Steam","price":590,"url":"https://store.steampowered.com/app/1326470/Sons_Of_The_Forest/"}],
    "genres":["เอาชีวิตรอด","แอ็คชั่น","ผจญภัย","จำลองสถานการณ์","สยองขวัญ"],
    "player_types":["ผู้เล่นคนเดียว","Co-op"]
  },
  {
    "id":2,
    "title":"Slap 'em UP!",
    "cover_url":"https://bit.ly/48M6yLs",
    "description":"เกมการ์ดแนวปาร์ตี้ (Casual Party Card Game) ฝีมือคนไทย พัฒนาโดย Urnique Studio ซึ่งหยิบยกกติกาเกมไพ่สลาฟที่ทุกคนคุ้นเคยมาทำใหม่ให้มีความสนุกสนานและกวนโอ๊ยยิ่งขึ้น",
    "players":"1-4","is_featured":true,"is_new":false,"is_popular":true,
    "gallery":["https://bit.ly/4iQ2uhQ","https://bit.ly/4iOs9r4","https://bit.ly/4jeO3nZ","https://bit.ly/4kiztOp"],
    "download_links":[{"platform":"Steam","price":0,"url":"https://store.steampowered.com/app/3703520/Slap_em_UP/"}],
    "genres":["เกมการ์ด","เกมอินดี้","เกมปาร์ตี้"],
    "player_types":["ผู้เล่นหลายคน","PvP"]
  },
  {
    "id":3,
    "title":"Stardew Valley",
    "cover_url":"https://bit.ly/4AuiSMd",
    "description":"เกมแนวจำลองชีวิตและทำฟาร์มผสมผสาน RPG ที่ให้ผู้เล่นเริ่มต้นชีวิตใหม่ในเมืองชนบท โดยได้รับมรดกเป็นฟาร์มเก่าจากคุณปู่ ผู้เล่นจะต้องฟื้นฟูพื้นที่รกร้างให้กลายเป็นฟาร์มที่อุดมสมบูรณ์ สามารถปลูกพืช เลี้ยงสัตว์ ตกปลา ขุดเหมือง และสร้างสิ่งของต่าง ๆ นอกจากนี้ยังสามารถพบปะพูดคุย สร้างมิตรภาพ และพัฒนาความสัมพันธ์กับชาวเมือง รวมถึงสำรวจเรื่องราวและความลับที่ซ่อนอยู่ในหุบเขาได้อย่างอิสระ",
    "players":"1-8","is_featured":true,"is_new":true,"is_popular":true,
    "gallery":["https://bit.ly/4etUlyn","https://bit.ly/3WGaLh1","https://bit.ly/4jeO3nZ","https://bit.ly/4tg66id"],
    "download_links":[{"platform":"Steam","price":315,"url":"https://store.steampowered.com/app/413150/Stardew_Valley/"}],
    "genres":["จำลองสถานการณ์","ทำฟาร์ม","ผจญภัย"],
    "player_types":["ผู้เล่นคนเดียว","Co-op"]
  },
  {
    "id":4,
    "title":"MECCHA CHAMELEON",
    "cover_url":"https://bit.ly/4sVEHBV",
    "description":"เกมปาร์ตี้แนวซ่อนหาที่ผู้เล่นต้องระบายสีตัวละครให้กลมกลืนกับฉาก เพื่อหลบซ่อนจากฝ่ายค้นหา โดยต้องใช้ไหวพริบและการสังเกตเพื่อเอาชนะคู่แข่ง สามารถเล่นสนุกกับเพื่อนผ่านระบบออนไลน์ได้",
    "players":"2-10","is_featured":true,"is_new":true,"is_popular":true,
    "gallery":["https://bit.ly/4iBr6w1","https://bit.ly/4iUMriR","https://bit.ly/4k8SGBW","https://bit.ly/4zeMYlG"],
    "download_links":[{"platform":"Steam","price":125,"url":"https://store.steampowered.com/app/4704690/MECCHA_CHAMELEON/"}],
    "genres":["ปาร์ตี้","ซ่อนหา"],
    "player_types":["ผู้เล่นหลายคน","Co-op","PvP"]
  },
  {
    "id":5,
    "title":"PEAK",
    "cover_url":"https://l1nq.com/udmdmir",
    "description":"PEAK เป็นเกมผจญภัยปีนเขาแบบร่วมมือกัน ผู้เล่นจะรับบทเป็นลูกเสือที่ติดอยู่บนเกาะลึกลับ และต้องช่วยกันปีนขึ้นไปยังยอดเขาเพื่อเอาชีวิตรอด ระหว่างทางต้องระวังอุปสรรค จัดการพลังงานและอาการบาดเจ็บ พร้อมใช้อุปกรณ์ช่วยปีนเขา สามารถเล่นคนเดียวหรือร่วมมือกับเพื่อนได้",
    "players":"1-4","is_featured":true,"is_new":true,"is_popular":true,
    "gallery":["https://sl1nk.com/q6y7oq8","https://sl1nk.com/48glaiq","https://sl1nk.com/zzyk78f","https://sl1nk.com/rcxdid8"],
    "download_links":[{"platform":"Steam","price":159,"url":"https://store.steampowered.com/app/3527290/PEAK/"}],
    "genres":["แอ็คชั่น","ผจญภัย","เอาชีวิตรอด"],
    "player_types":["ผู้เล่นคนเดียว","Co-op"]
  },
  {
    "id":6,
    "title":"RV There Yet?",
    "cover_url":"https://sl1nk.com/brx8f3f",
    "description":"เกมขับรถบ้านผจญภัยที่ผู้เล่นต้องเดินทางกลับบ้านผ่านเส้นทางอันตราย ต้องช่วยกันขับรถ แก้ไขอุปสรรค ใช้อุปกรณ์ลากจูง และเอาชีวิตรอดระหว่างการเดินทาง",
    "players":"1-4","is_featured":true,"is_new":true,"is_popular":true,
    "gallery":["https://l1nq.com/qbcan77","https://l1nq.com/zr7qix0","https://sl1nk.com/kb5un3b","https://l1nq.com/nq4i6hd"],
    "download_links":[{"platform":"Steam","price":179,"url":"https://store.steampowered.com/app/3949040/RV_There_Yet/"}],
    "genres":["แอ็คชั่น","ผจญภัย","จำลองสถานการณ์"],
    "player_types":["ผู้เล่นคนเดียว","Co-op"]
  },
  {
    "id":7,
    "title":"Green Hell",
    "cover_url":"https://sl1nk.com/pd88ype",
    "description":"เกมเอาชีวิตรอดในป่าฝนอเมซอน ผู้เล่นต้องหาอาหาร ล่าสัตว์ สร้างที่พัก ประดิษฐ์อุปกรณ์ และดูแลสุขภาพร่างกายและจิตใจเพื่อเอาชีวิตรอดจากป่าที่เต็มไปด้วยอันตราย",
    "players":"1-4","is_featured":true,"is_new":false,"is_popular":true,
    "gallery":["https://l1nq.com/n5h1pnf","https://sl1nk.com/b17wgxp","https://sl1nk.com/kgkkte0","https://l1nq.com/1ut3urr"],
    "download_links":[{"platform":"Steam","price":319,"url":"https://store.steampowered.com/app/815370/Green_Hell/"}],
    "genres":["เอาชีวิตรอด","แอ็คชั่น","ผจญภัย","จำลองสถานการณ์"],
    "player_types":["ผู้เล่นคนเดียว","Co-op"]
  },
  {
    "id":8,
    "title":"Genshin Impact",
    "cover_url":"https://l1nq.com/oegy9xe",
    "description":"เกมผจญภัยสวมบทบาทในโลกแฟนตาซีแบบเปิด ผู้เล่นออกสำรวจดินแดน Teyvat ต่อสู้ด้วยพลังธาตุ รวบรวมตัวละคร และค้นพบเรื่องราวของโลก",
    "players":"1-4","is_featured":true,"is_new":false,"is_popular":true,
    "gallery":["https://l1nq.com/fznkeri","https://l1nq.com/hqne50a","https://sl1nk.com/1cpb2sg","https://sl1nk.com/zf6q9he"],
    "download_links":[{"platform":"เว็บไซต์ทางการ","price":0,"url":"https://genshin.hoyoverse.com/en/home"}],
    "genres":["แอ็คชั่น","ผจญภัย","สวมบทบาท","แฟนตาซี","โลกเปิด"],
    "player_types":["ผู้เล่นคนเดียว","ผู้เล่นหลายคน","Co-op"]
  },
  {
    "id":9,
    "title":"The Sims 3",
    "cover_url":"https://sl1nk.com/q9qcjyw",
    "description":"เกมจำลองชีวิตที่ให้ผู้เล่นสร้างตัวละคร กำหนดบุคลิก ออกแบบบ้าน สร้างครอบครัว ทำงาน และใช้ชีวิตในโลกเปิดที่มีอิสระในการเล่น",
    "players":"1","is_featured":false,"is_new":false,"is_popular":false,
    "gallery":["https://sl1nk.com/9tv2v6q","https://l1nq.com/prj6856","https://l1nq.com/15eh348","https://l1nq.com/jjk6y63"],
    "download_links":[
      {"platform":"Steam","price":539,"url":"https://store.steampowered.com/app/47890/The_Sims_3/"},
      {"platform":"EA","price":840,"url":"https://www.ea.com/games/the-sims/the-sims-3?utm_source=chatgpt.com"}
    ],
    "genres":["จำลองสถานการณ์","สวมบทบาท"],
    "player_types":["ผู้เล่นคนเดียว"]
  },
  {
    "id":10,
    "title":"The Sims 4",
    "cover_url":"https://sl1nk.com/zjt5y8l",
    "description":"เกมจำลองชีวิตที่ให้ผู้เล่นสร้างตัวละคร ออกแบบบ้าน ทำกิจกรรมในชีวิตประจำวัน สร้างความสัมพันธ์ ทำงาน และกำหนดเรื่องราวชีวิตของตัวละครได้ตามต้องการ",
    "players":"1","is_featured":false,"is_new":false,"is_popular":true,
    "gallery":["https://l1nq.com/apl9kzz","https://sl1nk.com/fvogsi2","https://l1nq.com/1fk9wk4","https://sl1nk.com/spfdl27"],
    "download_links":[
      {"platform":"Steam","price":0,"url":"https://store.steampowered.com/app/1222670/The_Sims_4/#app_reviews_hash"},
      {"platform":"EA","price":0,"url":"https://www.ea.com/games/the-sims/the-sims-4?utm_source=chatgpt.com"},
      {"platform":"Epic Games Store","price":0,"url":"https://store.epicgames.com/p/the-sims-4?utm_source=chatgpt.com"}
    ],
    "genres":["จำลองสถานการณ์","สวมบทบาท"],
    "player_types":["ผู้เล่นคนเดียว"]
  },
  {
    "id":11,
    "title":"3on3 FreeStyle: Rebound",
    "cover_url":"https://sl1nk.com/d4adee9",
    "description":"เกมบาสเกตบอลแนวสตรีทที่ผู้เล่นเลือกตัวละครและร่วมแข่งขันบาสเกตบอลแบบ 3 ต่อ 3 พร้อมใช้ทักษะเฉพาะตัวในการทำคะแนนและเอาชนะทีมคู่แข่ง",
    "players":"1-6","is_featured":true,"is_new":false,"is_popular":false,
    "gallery":["https://sl1nk.com/e7gxbdx","https://l1nq.com/rp4c05k","https://l1nq.com/z585d80","https://l1nq.com/ub4q52j"],
    "download_links":[{"platform":"Steam","price":0,"url":"https://store.steampowered.com/app/1292630/3on3_FreeStyle_Rebound/"}],
    "genres":["กีฬา","แอ็คชั่น"],
    "player_types":["ผู้เล่นคนเดียว","ผู้เล่นหลายคน","Co-op","PvP"]
  },
  {
    "id":12,
    "title":"PratFall",
    "cover_url":"https://l1nq.com/t37j0ee",
    "description":"เกมผจญภัยแนวร่วมมือกัน ผู้เล่นต้องเดินทางลงไปในถ้ำอันตรายเพื่อช่วยเหลือสุนัขที่หายไป ระหว่างทางต้องขุดดิน หลบกับดัก ระเบิดสิ่งกีดขวาง และช่วยเหลือเพื่อนร่วมทีม",
    "players":"1 คนขึ้นไป","is_featured":false,"is_new":true,"is_popular":false,
    "gallery":["https://sl1nk.com/17bxfzn","https://sl1nk.com/8wgxtyj","https://sl1nk.com/lq9s5du","https://sl1nk.com/m6fxbyd"],
    "download_links":[{"platform":"Steam","price":159,"url":"https://store.steampowered.com/app/4244510/Pratfall/"}],
    "genres":["แอ็คชั่น","ผจญภัย","เอาชีวิตรอด"],
    "player_types":["ผู้เล่นคนเดียว","ผู้เล่นหลายคน","Co-op"]
  },
  {
    "id":13,
    "title":"Apex Legends",
    "cover_url":"https://sl1nk.com/i7s8ji4",
    "description":"เกมยิงแนว Battle Royale ที่ผู้เล่นเลือกตัวละครที่มีความสามารถแตกต่างกัน แล้วร่วมทีมต่อสู้กับทีมอื่นเพื่อเป็นผู้รอดชีวิตคนสุดท้าย",
    "players":"1-3","is_featured":false,"is_new":false,"is_popular":true,
    "gallery":["https://sl1nk.com/5w788kt","https://l1nq.com/w313cvt","https://sl1nk.com/ltj0rn1","https://sl1nk.com/ngsl3w1"],
    "download_links":[
      {"platform":"Steam","price":0,"url":"https://store.steampowered.com/app/1172470/Apex_Legends/"},
      {"platform":"EA","price":0,"url":"https://www.ea.com/games/apex-legends/apex-legends?utm_source=chatgpt.com"}
    ],
    "genres":["เอาชีวิตรอด","แอ็คชั่น","ยิงปืน"],
    "player_types":["ผู้เล่นหลายคน","Co-op","PvP"]
  },
  {
    "id":14,
    "title":"PUBG: BATTLEGROUNDS",
    "cover_url":"https://l1nq.com/c9beq0n",
    "description":"เกมยิงแนว Battle Royale ที่ผู้เล่นกระโดดร่มลงสู่สนามรบ ค้นหาอาวุธและอุปกรณ์ ต่อสู้กับผู้เล่นคนอื่น และเอาชีวิตรอดจนเป็นคนหรือทีมสุดท้าย",
    "players":"1-4","is_featured":false,"is_new":false,"is_popular":true,
    "gallery":["https://sl1nk.com/61oh1ma","https://sl1nk.com/axupm6i","https://sl1nk.com/r833263","https://sl1nk.com/fn9yn06"],
    "download_links":[
      {"platform":"Steam","price":0,"url":"https://store.steampowered.com/app/578080/PUBG_BATTLEGROUNDS/"},
      {"platform":"Epic Games Store","price":0,"url":"https://store.epicgames.com/p/pubg-59c1d9"}
    ],
    "genres":["เอาชีวิตรอด","แอ็คชั่น","ยิงปืน"],
    "player_types":["ผู้เล่นคนเดียว","ผู้เล่นหลายคน","Co-op","PvP"]
  },
  {
    "id":15,
    "title":"VALORANT",
    "cover_url":"https://l1nq.com/w7lqhin",
    "description":"เกมยิงมุมมองบุคคลที่หนึ่งแบบทีม 5 ต่อ 5 ผู้เล่นเลือกเอเจนต์ที่มีความสามารถเฉพาะตัว วางแผนโจมตีและป้องกันเพื่อทำภารกิจให้สำเร็จ",
    "players":"1-10","is_featured":true,"is_new":false,"is_popular":true,
    "gallery":["https://sl1nk.com/me8lgd3","https://l1nq.com/9co6iaa","https://sl1nk.com/5zbvbcp","https://l1nq.com/sztgesw"],
    "download_links":[
      {"platform":"Epic Games Store","price":0,"url":"https://store.epicgames.com/p/valorant"},
      {"platform":"เว็บไซต์ทางการ","price":0,"url":"https://playvalorant.com/th-th/?utm_source=chatgpt.com"}
    ],
    "genres":["แอ็คชั่น","ยิงปืน"],
    "player_types":["ผู้เล่นหลายคน","PvP"]
  },
  {
    "id":16,
    "title":"Super Battle Golf",
    "cover_url":"https://l1nq.com/cg9pgy6",
    "description":"เกมกอล์ฟออนไลน์แนวปาร์ตี้ที่ผู้เล่นแข่งขันกันตีลูกกอล์ฟไปยังหลุมพร้อมกัน สามารถใช้ไอเทมก่อกวนและขัดขวางคู่แข่งระหว่างการแข่งขันได้",
    "players":"1-8","is_featured":true,"is_new":true,"is_popular":false,
    "gallery":["https://l1nq.com/x4oirpw","https://l1nq.com/jllikyd","https://l1nq.com/3p687b1","https://sl1nk.com/gkb9mvk"],
    "download_links":[{"platform":"Steam","price":259,"url":"https://store.steampowered.com/app/4069520/Super_Battle_Golf/"}],
    "genres":["กีฬา","เกมปาร์ตี้"],
    "player_types":["ผู้เล่นคนเดียว","ผู้เล่นหลายคน","Co-op","PvP"]
  },
  {
    "id":17,
    "title":"Minecraft",
    "cover_url":"https://sl1nk.com/mg5lnip",
    "description":"เกมแซนด์บ็อกซ์ที่ให้ผู้เล่นสำรวจโลกแบบบล็อก เก็บทรัพยากร สร้างสิ่งก่อสร้าง ประดิษฐ์อุปกรณ์ และเอาชีวิตรอดจากสัตว์ประหลาด",
    "players":"1 คนขึ้นไป","is_featured":false,"is_new":false,"is_popular":true,
    "gallery":["https://sl1nk.com/gu6jp7y","https://l1nq.com/nxglej4","https://sl1nk.com/57alf9i","https://sl1nk.com/cunqta0"],
    "download_links":[{"platform":"เว็บไซต์ทางการ","price":1059,"url":"https://www.minecraft.net/en-us/about-minecraft"}],
    "genres":["ผจญภัย","เอาชีวิตรอด","จำลองสถานการณ์"],
    "player_types":["ผู้เล่นคนเดียว","ผู้เล่นหลายคน","Co-op"]
  },
  {
    "id":18,
    "title":"Aniimo",
    "cover_url":"https://sl1nk.com/vi16ixa",
    "description":"เกมผจญภัยสวมบทบาทโลกเปิดที่ให้ผู้เล่นออกสำรวจโลก Idyll จับและสะสมสิ่งมีชีวิตมหัศจรรย์ที่เรียกว่า Aniimo พร้อมพัฒนาความสามารถและค้นพบความลับของโลก",
    "players":"1","is_featured":false,"is_new":true,"is_popular":true,
    "gallery":["https://l1nq.com/2lbf6je","https://l1nq.com/gu3rovh","https://l1nq.com/0g075eq","https://l1nq.com/w5ygwkk"],
    "download_links":[
      {"platform":"Epic Games Store","price":0,"url":"https://store.epicgames.com/p/aniimo-759396"},
      {"platform":"Steam","price":0,"url":"https://store.steampowered.com/app/4126040/Aniimo/"},
      {"platform":"เว็บไซต์ทางการ","price":0,"url":"https://aniimo.com/"}
    ],
    "genres":["ผจญภัย","สวมบทบาท","โลกเปิด","แฟนตาซี"],
    "player_types":["ผู้เล่นคนเดียว","ผู้เล่นหลายคน"]
  },
  {
    "id":19,
    "title":"Planet Zoo 2",
    "cover_url":"https://l1nq.com/bkiflzy",
    "description":"เกมจำลองการสร้างและบริหารสวนสัตว์ ผู้เล่นออกแบบพื้นที่อยู่อาศัยของสัตว์ ดูแลสัตว์ จัดการพนักงาน และพัฒนาสวนสัตว์ให้เติบโต โดยมีสัตว์น้ำและสัตว์บินได้เพิ่มเติม",
    "players":"1","is_featured":false,"is_new":false,"is_popular":false,
    "gallery":["https://l1nq.com/97mhtt6","https://sl1nk.com/ibc3c8z","https://l1nq.com/bnbvbxn","https://l1nq.com/ph73xud"],
    "download_links":[
      {"platform":"Steam","price":1079,"url":"https://store.steampowered.com/app/3219030/Planet_Zoo_2/"},
      {"platform":"Epic Games Store","price":1079,"url":"https://store.epicgames.com/p/planet-zoo-2-cbdaa7"}
    ],
    "genres":["จำลองสถานการณ์"],
    "player_types":["ผู้เล่นคนเดียว"]
  },
  {
    "id":20,
    "title":"Castlevania: Belmont's Curse",
    "cover_url":"https://sl1nk.com/2s9rtk2",
    "description":"เกมแอ็คชั่นผจญภัยแบบ 2 มิติ ผู้เล่นรับบทเป็น Rose Belmont ออกต่อสู้กับเหล่าปีศาจ สำรวจเมืองปารีสและปราสาทของ Dracula โดยใช้อาวุธและแส้ศักดิ์สิทธิ์",
    "players":"1","is_featured":true,"is_new":true,"is_popular":true,
    "gallery":["https://sl1nk.com/1nxum23","https://sl1nk.com/ztnxlkq","https://sl1nk.com/zpc7c0i","https://sl1nk.com/e01pzsr"],
    "download_links":[{"platform":"Steam","price":845,"url":"https://store.steampowered.com/app/4231820/Castlevania_Belmonts_Curse/"}],
    "genres":["แอ็คชั่น","ผจญภัย","แฟนตาซี","สยองขวัญ"],
    "player_types":["ผู้เล่นคนเดียว"]
  }
]
$games$::jsonb)
AS x(
    id BIGINT,
    title TEXT,
    cover_url TEXT,
    description TEXT,
    players TEXT,
    is_featured BOOLEAN,
    is_new BOOLEAN,
    is_popular BOOLEAN,
    gallery JSONB,
    download_links JSONB,
    genres JSONB,
    player_types JSONB
);

-- เพิ่มประเภทเกม
INSERT INTO genres (name)
SELECT DISTINCT value
FROM seed_games, LATERAL jsonb_array_elements_text(genres)
ON CONFLICT (name) DO NOTHING;

-- เพิ่มประเภทผู้เล่น
INSERT INTO player_types (name)
SELECT DISTINCT value
FROM seed_games, LATERAL jsonb_array_elements_text(player_types)
ON CONFLICT (name) DO NOTHING;

-- เพิ่มข้อมูลเกม
INSERT INTO games (
    id, title, cover_url, description, players,
    is_featured, is_new, is_popular
)
SELECT
    id, title, cover_url, description, players,
    is_featured, is_new, is_popular
FROM seed_games
ON CONFLICT (id) DO NOTHING;

-- เพิ่มรูปภาพแกลเลอรี
INSERT INTO game_images (game_id, image_url, position)
SELECT
    s.id,
    img.value,
    (img.ordinality - 1)::INTEGER
FROM seed_games s,
LATERAL jsonb_array_elements_text(s.gallery)
WITH ORDINALITY AS img(value, ordinality)
ON CONFLICT (game_id, position)
DO UPDATE SET image_url = EXCLUDED.image_url;

-- เพิ่มลิงก์ดาวน์โหลดและราคา
INSERT INTO game_download_links (game_id, platform, price, url)
SELECT
    s.id,
    link->>'platform',
    (link->>'price')::NUMERIC(10,2),
    link->>'url'
FROM seed_games s,
LATERAL jsonb_array_elements(s.download_links) AS link
WHERE NOT EXISTS (
    SELECT 1
    FROM game_download_links old
    WHERE old.game_id = s.id
      AND old.platform = link->>'platform'
      AND old.url = link->>'url'
);

-- เพิ่มความสัมพันธ์ประเภทเกม
INSERT INTO game_genres (game_id, genre_id, position)
SELECT
    s.id,
    g.id,
    (genre.ordinality - 1)::INTEGER
FROM seed_games s,
LATERAL jsonb_array_elements_text(s.genres)
WITH ORDINALITY AS genre(value, ordinality)
JOIN genres g ON g.name = genre.value
ON CONFLICT (game_id, genre_id)
DO UPDATE SET position = EXCLUDED.position;

-- เพิ่มความสัมพันธ์ประเภทผู้เล่น
INSERT INTO game_player_types (game_id, player_type_id, position)
SELECT
    s.id,
    p.id,
    (player_type.ordinality - 1)::INTEGER
FROM seed_games s,
LATERAL jsonb_array_elements_text(s.player_types)
WITH ORDINALITY AS player_type(value, ordinality)
JOIN player_types p ON p.name = player_type.value
ON CONFLICT (game_id, player_type_id)
DO UPDATE SET position = EXCLUDED.position;

COMMIT;