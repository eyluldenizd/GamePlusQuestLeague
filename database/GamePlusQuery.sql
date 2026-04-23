-- ============================================================
--  GamePlus Quest League – SQL Server Database Script
--  Tüm tablolar, foreign key'ler, index'ler ve seed data
-- ============================================================

-- ============================================================
-- 1. USERS
-- ============================================================
CREATE TABLE Users (
    user_id     NVARCHAR(10)  NOT NULL PRIMARY KEY,
    name        NVARCHAR(100) NOT NULL,
    city        NVARCHAR(100) NULL,
    segment     NVARCHAR(50)  NULL,
    created_at  DATETIME2     NOT NULL DEFAULT GETUTCDATE()
);
GO

INSERT INTO Users (user_id, name, city, segment) VALUES
('U1', N'Ayşe',  N'Istanbul', 'STUDENT'),
('U2', N'Ali',   N'Ankara',   'STUDENT'),
('U3', N'Deniz', N'Izmir',    'STUDENT'),
('U4', N'Mert',  N'Bursa',    'YOUNG_PRO'),
('U5', N'Ece',   N'Antalya',  'YOUNG_PRO');
GO

-- ============================================================
-- 2. GAMES
-- ============================================================
CREATE TABLE Games (
    game_id    NVARCHAR(10)  NOT NULL PRIMARY KEY,
    game_name  NVARCHAR(100) NOT NULL,
    genre      NVARCHAR(50)  NULL
);
GO

INSERT INTO Games (game_id, game_name, genre) VALUES
('G1', 'Arena Rivals',  'PVP'),
('G2', 'Sky Builders',  'CASUAL'),
('G3', 'Shadow Quest',  'RPG'),
('G4', 'Turbo Racers',  'RACING');
GO

-- ============================================================
-- 3. ACTIVITY EVENTS
-- ============================================================
CREATE TABLE ActivityEvents (
    event_id      NVARCHAR(10) NOT NULL PRIMARY KEY,
    user_id       NVARCHAR(10) NOT NULL,
    [date]        DATE         NOT NULL,
    game_id       NVARCHAR(10) NOT NULL,
    login_count   INT          NOT NULL DEFAULT 0,
    play_minutes  INT          NOT NULL DEFAULT 0,
    pvp_wins      INT          NOT NULL DEFAULT 0,
    coop_minutes  INT          NOT NULL DEFAULT 0,
    topup_try     INT          NOT NULL DEFAULT 0,
    CONSTRAINT FK_Events_User FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Events_Game FOREIGN KEY (game_id) REFERENCES Games(game_id)
);
GO

CREATE INDEX IX_ActivityEvents_User_Date ON ActivityEvents (user_id, [date]);
GO

INSERT INTO ActivityEvents (event_id, user_id, [date], game_id, login_count, play_minutes, pvp_wins, coop_minutes, topup_try) VALUES
('E-1',  'U1', '2026-03-08', 'G3', 1, 68,  1, 20,  0),
('E-2',  'U1', '2026-03-09', 'G1', 1, 48,  4,  3,  0),
('E-3',  'U1', '2026-03-10', 'G4', 1, 179, 0, 116, 100),
('E-4',  'U1', '2026-03-11', 'G1', 1, 84,  0,  2,  50),
('E-5',  'U1', '2026-03-12', 'G4', 1, 137, 0, 30,  0),
('E-6',  'U2', '2026-03-08', 'G1', 1, 138, 0, 18,  0),
('E-7',  'U2', '2026-03-09', 'G2', 1, 87,  2, 20,  100),
('E-8',  'U2', '2026-03-10', 'G4', 1, 45,  2, 74,  50),
('E-9',  'U2', '2026-03-11', 'G4', 1, 42,  0,  5,  100),
('E-10', 'U2', '2026-03-12', 'G3', 1, 64,  1, 13,  0),
('E-11', 'U3', '2026-03-08', 'G4', 1, 60,  2, 39,  100),
('E-12', 'U3', '2026-03-09', 'G4', 1, 76,  0, 74,  100),
('E-13', 'U3', '2026-03-10', 'G1', 1, 78,  2,  3,  100),
('E-14', 'U3', '2026-03-11', 'G1', 1, 46,  4,  1,  100),
('E-15', 'U3', '2026-03-12', 'G4', 1, 82,  1, 87,  100),
('E-16', 'U4', '2026-03-08', 'G2', 1, 110, 1, 18,  50),
('E-17', 'U4', '2026-03-09', 'G4', 1, 122, 1, 31,  0),
('E-18', 'U4', '2026-03-10', 'G2', 1, 92,  0, 18,  0),
('E-19', 'U4', '2026-03-11', 'G2', 1, 164, 1, 10,  150),
('E-20', 'U4', '2026-03-12', 'G2', 1, 144, 1, 19,  0),
('E-21', 'U5', '2026-03-08', 'G3', 1, 161, 1,  5,  0),
('E-22', 'U5', '2026-03-09', 'G4', 1, 68,  1, 53,  0),
('E-23', 'U5', '2026-03-10', 'G1', 1, 49,  4, 18,  0),
('E-24', 'U5', '2026-03-11', 'G3', 1, 117, 2, 11,  100),
('E-25', 'U5', '2026-03-12', 'G1', 1, 157, 4, 14,  0);
GO

-- ============================================================
-- 4. QUESTS
-- ============================================================
CREATE TABLE Quests (
    quest_id    NVARCHAR(10)  NOT NULL PRIMARY KEY,
    quest_name  NVARCHAR(200) NOT NULL,
    quest_type  NVARCHAR(20)  NOT NULL CHECK (quest_type IN ('DAILY','WEEKLY','STREAK','SYSTEM')),
    condition   NVARCHAR(500) NOT NULL,   -- human-readable, evaluated in C# engine
    reward_points INT         NOT NULL DEFAULT 0,
    priority    INT           NOT NULL,   -- küçük = daha yüksek öncelik
    is_active   BIT           NOT NULL DEFAULT 1
);
GO

INSERT INTO Quests (quest_id, quest_name, quest_type, condition, reward_points, priority, is_active) VALUES
('Q-01', N'Günlük Giriş',       'DAILY',   'login_count_today >= 1',      50,  5, 1),
('Q-02', N'Kesintisiz Seri',     'STREAK',  'login_streak_days >= 3',     150,  4, 1),
('Q-03', N'PvP Ustası',          'DAILY',   'pvp_wins_today >= 3',        200,  2, 1),
('Q-04', N'Coop Takım Oyunu',    'DAILY',   'coop_minutes_today >= 60',   180,  3, 1),
('Q-05', N'Haftalık Maraton',    'WEEKLY',  'play_minutes_7d >= 600',     500,  6, 1),
('Q-06', N'Harcamaya Ödül',      'WEEKLY',  'topup_try_7d >= 200',        250,  7, 1);
GO

-- ============================================================
-- 5. BADGES
-- ============================================================
CREATE TABLE Badges (
    badge_id         NVARCHAR(10)  NOT NULL PRIMARY KEY,
    badge_name       NVARCHAR(100) NOT NULL,
    condition        NVARCHAR(200) NOT NULL,
    min_points       INT           NOT NULL,  -- eşik sayısal olarak da saklanır
    level            INT           NOT NULL
);
GO

INSERT INTO Badges (badge_id, badge_name, condition, min_points, level) VALUES
('B-01', N'Bronz Oyuncu', 'total_points >= 300',  300,  1),
('B-02', N'Gümüş Oyuncu', 'total_points >= 800',  800,  2),
('B-03', N'Altın Oyuncu',  'total_points >= 1500', 1500, 3);
GO

-- ============================================================
-- 6. QUEST AWARDS  (çakışma sonrası kazanılan ödüller)
-- ============================================================
CREATE TABLE QuestAwards (
    award_id          NVARCHAR(10)   NOT NULL PRIMARY KEY,
    user_id           NVARCHAR(10)   NOT NULL,
    as_of_date        DATE           NOT NULL,
    triggered_quests  NVARCHAR(500)  NOT NULL,  -- pipe-separated: Q-02|Q-01
    selected_quest    NVARCHAR(10)   NOT NULL,
    reward_points     INT            NOT NULL,
    suppressed_quests NVARCHAR(500)  NULL,
    [timestamp]       DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_QA_User  FOREIGN KEY (user_id)        REFERENCES Users(user_id),
    CONSTRAINT FK_QA_Quest FOREIGN KEY (selected_quest) REFERENCES Quests(quest_id),
    CONSTRAINT UQ_QA_UserDate UNIQUE (user_id, as_of_date)  -- günde 1 ödül kuralı
);
GO

INSERT INTO QuestAwards (award_id, user_id, as_of_date, triggered_quests, selected_quest, reward_points, suppressed_quests, [timestamp]) VALUES
('QA-100', 'U1', '2026-03-12', 'Q-02|Q-01',         'Q-02', 150, 'Q-01',           '2026-03-12T21:00:00Z'),
('QA-101', 'U2', '2026-03-12', 'Q-02|Q-01|Q-06',    'Q-02', 150, 'Q-01|Q-06',      '2026-03-12T20:56:00Z'),
('QA-102', 'U3', '2026-03-12', 'Q-04|Q-02|Q-01|Q-06','Q-04',180, 'Q-02|Q-01|Q-06', '2026-03-12T20:52:00Z'),
('QA-103', 'U4', '2026-03-12', 'Q-02|Q-01|Q-05|Q-06','Q-02',150, 'Q-01|Q-05|Q-06', '2026-03-12T20:48:00Z'),
('QA-104', 'U5', '2026-03-12', 'Q-03|Q-02|Q-01',    'Q-03', 200, 'Q-02|Q-01',      '2026-03-12T20:44:00Z');
GO

-- ============================================================
-- 7. POINTS LEDGER
-- ============================================================
CREATE TABLE PointsLedger (
    ledger_id   NVARCHAR(10)  NOT NULL PRIMARY KEY,
    user_id     NVARCHAR(10)  NOT NULL,
    points_delta INT          NOT NULL,
    source      NVARCHAR(50)  NOT NULL DEFAULT 'QUEST_REWARD',
    source_ref  NVARCHAR(10)  NOT NULL,  -- award_id
    created_at  DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Ledger_User  FOREIGN KEY (user_id)   REFERENCES Users(user_id),
    CONSTRAINT FK_Ledger_Award FOREIGN KEY (source_ref) REFERENCES QuestAwards(award_id)
);
GO

CREATE INDEX IX_PointsLedger_User ON PointsLedger (user_id);
GO

INSERT INTO PointsLedger (ledger_id, user_id, points_delta, source, source_ref, created_at) VALUES
('L-300', 'U1', 150, 'QUEST_REWARD', 'QA-100', '2026-03-12T21:00:00Z'),
('L-301', 'U2', 150, 'QUEST_REWARD', 'QA-101', '2026-03-12T20:56:00Z'),
('L-302', 'U3', 180, 'QUEST_REWARD', 'QA-102', '2026-03-12T20:52:00Z'),
('L-303', 'U4', 150, 'QUEST_REWARD', 'QA-103', '2026-03-12T20:48:00Z'),
('L-304', 'U5', 200, 'QUEST_REWARD', 'QA-104', '2026-03-12T20:44:00Z');
GO

-- ============================================================
-- 8. BADGE AWARDS
-- ============================================================
CREATE TABLE BadgeAwards (
    badge_award_id NVARCHAR(20)  NOT NULL PRIMARY KEY,
    user_id        NVARCHAR(10)  NOT NULL,
    badge_id       NVARCHAR(10)  NOT NULL,
    awarded_at     DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_BA_User  FOREIGN KEY (user_id)  REFERENCES Users(user_id),
    CONSTRAINT FK_BA_Badge FOREIGN KEY (badge_id) REFERENCES Badges(badge_id),
    CONSTRAINT UQ_BA_UserBadge UNIQUE (user_id, badge_id)
);
GO

-- ============================================================
-- 9. QUEST DECISIONS  (audit log)
-- ============================================================
CREATE TABLE QuestDecisions (
    decision_id           NVARCHAR(10)  NOT NULL PRIMARY KEY,
    user_id               NVARCHAR(10)  NOT NULL,
    as_of_date            DATE          NOT NULL,
    selected_reward_points INT          NOT NULL,
    reason                NVARCHAR(500) NULL,
    [timestamp]           DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_QD_User FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO

INSERT INTO QuestDecisions (decision_id, user_id, as_of_date, selected_reward_points, reason, [timestamp]) VALUES
('DQ-200', 'U1', '2026-03-12', 150, 'selected_quest=Q-02; priority=min', '2026-03-12T21:00:00Z'),
('DQ-201', 'U2', '2026-03-12', 150, 'selected_quest=Q-02; priority=min', '2026-03-12T20:56:00Z'),
('DQ-202', 'U3', '2026-03-12', 180, 'selected_quest=Q-04; priority=min', '2026-03-12T20:52:00Z'),
('DQ-203', 'U4', '2026-03-12', 150, 'selected_quest=Q-02; priority=min', '2026-03-12T20:48:00Z'),
('DQ-204', 'U5', '2026-03-12', 200, 'selected_quest=Q-03; priority=min', '2026-03-12T20:44:00Z');
GO

-- ============================================================
-- 10. NOTIFICATIONS
-- ============================================================
CREATE TABLE Notifications (
    notification_id NVARCHAR(10)   NOT NULL PRIMARY KEY,
    user_id         NVARCHAR(10)   NOT NULL,
    channel         NVARCHAR(20)   NOT NULL DEFAULT 'BiP',
    message         NVARCHAR(500)  NOT NULL,
    sent_at         DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Notif_User FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO

INSERT INTO Notifications (notification_id, user_id, channel, message, sent_at) VALUES
('N-400', 'U1', 'BiP', N'Kazanım: Q-02 görevi tamamlandı. +150 puan.', '2026-03-12T21:00:00Z'),
('N-401', 'U2', 'BiP', N'Kazanım: Q-02 görevi tamamlandı. +150 puan.', '2026-03-12T20:56:00Z'),
('N-402', 'U3', 'BiP', N'Kazanım: Q-04 görevi tamamlandı. +180 puan.', '2026-03-12T20:52:00Z'),
('N-403', 'U4', 'BiP', N'Kazanım: Q-02 görevi tamamlandı. +150 puan.', '2026-03-12T20:48:00Z'),
('N-404', 'U5', 'BiP', N'Kazanım: Q-03 görevi tamamlandı. +200 puan.', '2026-03-12T20:44:00Z');
GO

-- ============================================================
-- VIEWS  (C# backend bunları kullanabilir)
-- ============================================================

-- Kullanıcı toplam puanı – daima ledger'dan türetilir
CREATE VIEW vw_UserTotalPoints AS
    SELECT user_id, SUM(points_delta) AS total_points
    FROM PointsLedger
    GROUP BY user_id;
GO

-- ============================================================
-- USER STATE VIEW
-- ActivityEvents'ten as_of_date = bugün varsayımıyla hesaplanır.
-- C# backend'den parametre göndermek için SSMS'de direkt sorgu
-- veya sp_UserState stored procedure kullanabilirsin (aşağıda var).
-- ============================================================
CREATE VIEW vw_UserState AS
WITH max_dates AS (
    -- Her kullanıcının en son aktivite tarihi
    SELECT user_id, MAX([date]) AS max_date
    FROM ActivityEvents
    GROUP BY user_id
),
today_events AS (
    SELECT
        ae.user_id,
        md.max_date                                                                AS as_of_date,
        SUM(CASE WHEN ae.[date] = md.max_date                            THEN ae.login_count  ELSE 0 END) AS login_count_today,
        SUM(CASE WHEN ae.[date] = md.max_date                            THEN ae.play_minutes ELSE 0 END) AS play_minutes_today,
        SUM(CASE WHEN ae.[date] = md.max_date                            THEN ae.pvp_wins     ELSE 0 END) AS pvp_wins_today,
        SUM(CASE WHEN ae.[date] = md.max_date                            THEN ae.coop_minutes ELSE 0 END) AS coop_minutes_today,
        SUM(CASE WHEN ae.[date] = md.max_date                            THEN ae.topup_try    ELSE 0 END) AS topup_try_today,
        SUM(CASE WHEN ae.[date] >= DATEADD(DAY, -6, md.max_date)         THEN ae.play_minutes ELSE 0 END) AS play_minutes_7d,
        SUM(CASE WHEN ae.[date] >= DATEADD(DAY, -6, md.max_date)         THEN ae.topup_try    ELSE 0 END) AS topup_try_7d,
        SUM(CASE WHEN ae.[date] >= DATEADD(DAY, -6, md.max_date)         THEN ae.login_count  ELSE 0 END) AS logins_7d
    FROM ActivityEvents ae
    JOIN max_dates md ON ae.user_id = md.user_id
    GROUP BY ae.user_id, md.max_date
),
streak_calc AS (
    -- Her kullanıcı için en son tarihten geriye ardışık login günü sayısı
    SELECT
        ae.user_id,
        ae.[date],
        MAX(ae.[date]) OVER (PARTITION BY ae.user_id) AS max_date,
        DATEDIFF(DAY, ae.[date], MAX(ae.[date]) OVER (PARTITION BY ae.user_id)) AS days_back,
        ROW_NUMBER() OVER (PARTITION BY ae.user_id ORDER BY ae.[date] DESC) AS rn
    FROM ActivityEvents ae
    WHERE ae.login_count >= 1
),
streak_final AS (
    SELECT user_id, COUNT(*) AS login_streak_days
    FROM streak_calc
    WHERE days_back = rn - 1   -- ardışık günler: fark ile sıra numarası eşleşiyor
    GROUP BY user_id
)
SELECT
    u.user_id,
    u.name,
    u.city,
    u.segment,
    t.as_of_date,
    t.login_count_today,
    t.play_minutes_today,
    t.pvp_wins_today,
    t.coop_minutes_today,
    t.topup_try_today,
    t.play_minutes_7d,
    t.topup_try_7d,
    t.logins_7d,
    ISNULL(s.login_streak_days, 0) AS login_streak_days,
    ISNULL(tp.total_points, 0)     AS total_points
FROM Users u
LEFT JOIN today_events      t  ON u.user_id = t.user_id
LEFT JOIN streak_final      s  ON u.user_id = s.user_id
LEFT JOIN vw_UserTotalPoints tp ON u.user_id = tp.user_id;
GO

-- Leaderboard view
CREATE VIEW vw_Leaderboard AS
    SELECT
        RANK() OVER (ORDER BY SUM(pl.points_delta) DESC, u.user_id ASC) AS [rank],
        u.user_id,
        u.name,
        SUM(pl.points_delta) AS total_points
    FROM Users u
    LEFT JOIN PointsLedger pl ON u.user_id = pl.user_id
    GROUP BY u.user_id, u.name;
GO

-- Kullanıcı kazanılan rozetler
CREATE VIEW vw_UserBadges AS
    SELECT ba.user_id, u.name, b.badge_name, b.level, ba.awarded_at
    FROM BadgeAwards ba
    JOIN Users  u ON ba.user_id  = u.user_id
    JOIN Badges b ON ba.badge_id = b.badge_id;
GO

-- ============================================================
-- STORED PROCEDURE: Badge engine – C# yerine SQL'den de çağrılabilir
-- ============================================================
CREATE PROCEDURE sp_AssignBadges
    @as_of_date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @as_of_date IS NULL SET @as_of_date = CAST(GETUTCDATE() AS DATE);

    -- Her kullanıcı için eşiği geçen rozetleri ekle (zaten varsa atla)
    INSERT INTO BadgeAwards (badge_award_id, user_id, badge_id, awarded_at)
    SELECT
        'BA-' + u.user_id + '-' + b.badge_id,
        u.user_id,
        b.badge_id,
        GETUTCDATE()
    FROM Users u
    JOIN vw_UserTotalPoints tp ON u.user_id = tp.user_id
    CROSS JOIN Badges b
    WHERE tp.total_points >= b.min_points
      AND NOT EXISTS (
            SELECT 1 FROM BadgeAwards ba
            WHERE ba.user_id = u.user_id AND ba.badge_id = b.badge_id
      );
END;
GO

-- ============================================================
-- QUICK CHECK
-- ============================================================
SELECT 'Users'          AS [Table], COUNT(*) AS Rows FROM Users          UNION ALL
SELECT 'Games',                     COUNT(*)         FROM Games           UNION ALL
SELECT 'ActivityEvents',            COUNT(*)         FROM ActivityEvents  UNION ALL
SELECT 'Quests',                    COUNT(*)         FROM Quests          UNION ALL
SELECT 'Badges',                    COUNT(*)         FROM Badges          UNION ALL
SELECT 'QuestAwards',               COUNT(*)         FROM QuestAwards     UNION ALL
SELECT 'PointsLedger',              COUNT(*)         FROM PointsLedger    UNION ALL
SELECT 'QuestDecisions',            COUNT(*)         FROM QuestDecisions  UNION ALL
SELECT 'Notifications',             COUNT(*)         FROM Notifications   UNION ALL
SELECT 'BadgeAwards',               COUNT(*)         FROM BadgeAwards;
GO

SELECT * FROM vw_Leaderboard;
GO
-- ============================================================
-- BadgeAwards seed data (orijinal SQL'e eklenecek)
-- Tüm kullanıcılar 150+ puan → B-01 Bronz Oyuncu rozeti kazanır
-- ============================================================

-- Önce mevcut BadgeAwards tablosunu kontrol et, yoksa ekle:
INSERT INTO BadgeAwards (badge_award_id, user_id, badge_id, awarded_at)
SELECT 'BA-' + u.user_id + '-' + b.badge_id, u.user_id, b.badge_id, GETUTCDATE()
FROM Users u
JOIN vw_UserTotalPoints tp ON u.user_id = tp.user_id
CROSS JOIN Badges b
WHERE tp.total_points >= b.min_points
  AND NOT EXISTS (
      SELECT 1 FROM BadgeAwards ba
      WHERE ba.user_id = u.user_id AND ba.badge_id = b.badge_id
  );
GO

-- Sonucu kontrol et:
SELECT ba.badge_award_id, ba.user_id, b.badge_name, b.level, ba.awarded_at
FROM BadgeAwards ba
JOIN Badges b ON ba.badge_id = b.badge_id
ORDER BY ba.user_id, b.level;
GO