using GamePlusAPI.Data;
using GamePlusAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace GamePlusAPI.Services;

public class QuestEngineService
{
    private readonly AppDbContext _db;

    public QuestEngineService(AppDbContext db)
    {
        _db = db;
    }

    // Verilen as_of_date için tüm kullanıcıların görevlerini değerlendirir
    public async Task RunAsync(DateOnly asOfDate)
    {
        var activeQuests = await _db.Quests
            .Where(q => q.IsActive && q.QuestType != "SYSTEM")
            .OrderBy(q => q.Priority)
            .ToListAsync();

        var userStates = await _db.UserStates.ToListAsync();

        foreach (var state in userStates)
        {
            // Aynı gün zaten ödül verilmişse atla
            bool alreadyAwarded = await _db.QuestAwards
                .AnyAsync(a => a.UserId == state.UserId && a.AsOfDate == asOfDate);
            if (alreadyAwarded) continue;

            // Hangi görevler tetiklendi?
            var triggered = activeQuests
                .Where(q => EvaluateCondition(q.Condition, state))
                .ToList();

            if (!triggered.Any()) continue;

            // En yüksek öncelikli (en küçük priority) görevi seç
            var selected = triggered.OrderBy(q => q.Priority).First();
            var suppressed = triggered.Where(q => q.QuestId != selected.QuestId).ToList();

            // award_id üret
            var awardId = $"QA-{DateTime.UtcNow.Ticks % 100000}";
            var timestamp = DateTime.UtcNow;

            // QuestAward kaydet
            var award = new QuestAward
            {
                AwardId = awardId,
                UserId = state.UserId,
                AsOfDate = asOfDate,
                TriggeredQuests = string.Join("|", triggered.Select(q => q.QuestId)),
                SelectedQuest = selected.QuestId,
                RewardPoints = selected.RewardPoints,
                SuppressedQuests = suppressed.Any() ? string.Join("|", suppressed.Select(q => q.QuestId)) : null,
                Timestamp = timestamp
            };
            _db.QuestAwards.Add(award);

            // PointsLedger kaydet
            var ledgerId = $"L-{DateTime.UtcNow.Ticks % 100000}";
            _db.PointsLedger.Add(new PointsLedger
            {
                LedgerId = ledgerId,
                UserId = state.UserId,
                PointsDelta = selected.RewardPoints,
                Source = "QUEST_REWARD",
                SourceRef = awardId,
                CreatedAt = timestamp
            });

            // QuestDecision kaydet (audit log)
            _db.QuestDecisions.Add(new QuestDecision
            {
                DecisionId = $"DQ-{DateTime.UtcNow.Ticks % 100000}",
                UserId = state.UserId,
                AsOfDate = asOfDate,
                SelectedRewardPoints = selected.RewardPoints,
                Reason = $"selected_quest={selected.QuestId}; priority=min",
                Timestamp = timestamp
            });

            // Notification oluştur
            _db.Notifications.Add(new Notification
            {
                NotificationId = $"N-{DateTime.UtcNow.Ticks % 100000}",
                UserId = state.UserId,
                Channel = "BiP",
                Message = $"Kazanım: {selected.QuestId} görevi tamamlandı. +{selected.RewardPoints} puan.",
                SentAt = timestamp
            });
        }

        await _db.SaveChangesAsync();
    }

    // Görev koşulunu user_state metriklerine göre değerlendirir
    private static bool EvaluateCondition(string condition, UserState s)
    {
        return condition.Trim() switch
        {
            "login_count_today >= 1" => s.LoginCountToday >= 1,
            "login_streak_days >= 3" => s.LoginStreakDays >= 3,
            "pvp_wins_today >= 3" => s.PvpWinsToday >= 3,
            "coop_minutes_today >= 60" => s.CoopMinutesToday >= 60,
            "play_minutes_7d >= 600" => s.PlayMinutes7d >= 600,
            "topup_try_7d >= 200" => s.TopupTry7d >= 200,
            _ => false
        };
    }
}