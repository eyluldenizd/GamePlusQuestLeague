using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GamePlusAPI.Models;

// ── Users ──────────────────────────────────────────────────
[Table("Users")]
public class User
{
    [Key, Column("user_id")] public string UserId { get; set; } = "";
    [Column("name")] public string Name { get; set; } = "";
    [Column("city")] public string? City { get; set; }
    [Column("segment")] public string? Segment { get; set; }
    [Column("created_at")] public DateTime CreatedAt { get; set; }
}

// ── Games ──────────────────────────────────────────────────
[Table("Games")]
public class Game
{
    [Key, Column("game_id")] public string GameId { get; set; } = "";
    [Column("game_name")] public string GameName { get; set; } = "";
    [Column("genre")] public string? Genre { get; set; }
}

// ── ActivityEvents ─────────────────────────────────────────
[Table("ActivityEvents")]
public class ActivityEvent
{
    [Key, Column("event_id")] public string EventId { get; set; } = "";
    [Column("user_id")] public string UserId { get; set; } = "";
    [Column("date")] public DateOnly Date { get; set; }
    [Column("game_id")] public string GameId { get; set; } = "";
    [Column("login_count")] public int LoginCount { get; set; }
    [Column("play_minutes")] public int PlayMinutes { get; set; }
    [Column("pvp_wins")] public int PvpWins { get; set; }
    [Column("coop_minutes")] public int CoopMinutes { get; set; }
    [Column("topup_try")] public int TopupTry { get; set; }
}

// ── Quests ─────────────────────────────────────────────────
[Table("Quests")]
public class Quest
{
    [Key, Column("quest_id")] public string QuestId { get; set; } = "";
    [Column("quest_name")] public string QuestName { get; set; } = "";
    [Column("quest_type")] public string QuestType { get; set; } = "";
    [Column("condition")] public string Condition { get; set; } = "";
    [Column("reward_points")] public int RewardPoints { get; set; }
    [Column("priority")] public int Priority { get; set; }
    [Column("is_active")] public bool IsActive { get; set; }
}

// ── Badges ─────────────────────────────────────────────────
[Table("Badges")]
public class Badge
{
    [Key, Column("badge_id")] public string BadgeId { get; set; } = "";
    [Column("badge_name")] public string BadgeName { get; set; } = "";
    [Column("condition")] public string Condition { get; set; } = "";
    [Column("min_points")] public int MinPoints { get; set; }
    [Column("level")] public int Level { get; set; }
}

// ── BadgeAwards ────────────────────────────────────────────
[Table("BadgeAwards")]
public class BadgeAward
{
    [Key, Column("badge_award_id")] public string BadgeAwardId { get; set; } = "";
    [Column("user_id")] public string UserId { get; set; } = "";
    [Column("badge_id")] public string BadgeId { get; set; } = "";
    [Column("awarded_at")] public DateTime AwardedAt { get; set; }

    public Badge? Badge { get; set; }
}

// ── QuestAwards ────────────────────────────────────────────
[Table("QuestAwards")]
public class QuestAward
{
    [Key, Column("award_id")] public string AwardId { get; set; } = "";
    [Column("user_id")] public string UserId { get; set; } = "";
    [Column("as_of_date")] public DateOnly AsOfDate { get; set; }
    [Column("triggered_quests")] public string TriggeredQuests { get; set; } = "";
    [Column("selected_quest")] public string SelectedQuest { get; set; } = "";
    [Column("reward_points")] public int RewardPoints { get; set; }
    [Column("suppressed_quests")] public string? SuppressedQuests { get; set; }
    [Column("timestamp")] public DateTime Timestamp { get; set; }
}

// ── PointsLedger ───────────────────────────────────────────
[Table("PointsLedger")]
public class PointsLedger
{
    [Key, Column("ledger_id")] public string LedgerId { get; set; } = "";
    [Column("user_id")] public string UserId { get; set; } = "";
    [Column("points_delta")] public int PointsDelta { get; set; }
    [Column("source")] public string Source { get; set; } = "";
    [Column("source_ref")] public string SourceRef { get; set; } = "";
    [Column("created_at")] public DateTime CreatedAt { get; set; }
}

// ── QuestDecisions (audit log) ─────────────────────────────
[Table("QuestDecisions")]
public class QuestDecision
{
    [Key, Column("decision_id")] public string DecisionId { get; set; } = "";
    [Column("user_id")] public string UserId { get; set; } = "";
    [Column("as_of_date")] public DateOnly AsOfDate { get; set; }
    [Column("selected_reward_points")] public int SelectedRewardPoints { get; set; }
    [Column("reason")] public string? Reason { get; set; }
    [Column("timestamp")] public DateTime Timestamp { get; set; }
}

// ── Notifications ──────────────────────────────────────────
[Table("Notifications")]
public class Notification
{
    [Key, Column("notification_id")] public string NotificationId { get; set; } = "";
    [Column("user_id")] public string UserId { get; set; } = "";
    [Column("channel")] public string Channel { get; set; } = "";
    [Column("message")] public string Message { get; set; } = "";
    [Column("sent_at")] public DateTime SentAt { get; set; }
}

// ── View: vw_UserState ─────────────────────────────────────
public class UserState
{
    [Column("user_id")] public string UserId { get; set; } = "";
    [Column("name")] public string Name { get; set; } = "";
    [Column("city")] public string? City { get; set; }
    [Column("segment")] public string? Segment { get; set; }
    [Column("as_of_date")] public DateOnly? AsOfDate { get; set; }
    [Column("login_count_today")] public int LoginCountToday { get; set; }
    [Column("play_minutes_today")] public int PlayMinutesToday { get; set; }
    [Column("pvp_wins_today")] public int PvpWinsToday { get; set; }
    [Column("coop_minutes_today")] public int CoopMinutesToday { get; set; }
    [Column("topup_try_today")] public int TopupTryToday { get; set; }
    [Column("play_minutes_7d")] public int PlayMinutes7d { get; set; }
    [Column("topup_try_7d")] public int TopupTry7d { get; set; }
    [Column("logins_7d")] public int Logins7d { get; set; }
    [Column("login_streak_days")] public int LoginStreakDays { get; set; }
    [Column("total_points")] public int TotalPoints { get; set; }
}

// ── View: vw_Leaderboard ───────────────────────────────────
public class LeaderboardEntry
{
    [Column("rank")] public int Rank { get; set; }
    [Column("user_id")] public string UserId { get; set; } = "";
    [Column("name")] public string Name { get; set; } = "";
    [Column("total_points")] public int TotalPoints { get; set; }
}