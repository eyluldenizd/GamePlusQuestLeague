using GamePlusAPI.Data;
using GamePlusAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace GamePlusAPI.Services;

public class BadgeService
{
    private readonly AppDbContext _db;

    public BadgeService(AppDbContext db)
    {
        _db = db;
    }

    // Tüm kullanıcılara hak ettikleri rozetleri atar
    public async Task AssignBadgesAsync()
    {
        var badges = await _db.Badges.OrderBy(b => b.MinPoints).ToListAsync();
        var userPoints = await _db.UserStates.ToListAsync();

        foreach (var user in userPoints)
        {
            foreach (var badge in badges.Where(b => user.TotalPoints >= b.MinPoints))
            {
                bool alreadyHas = await _db.BadgeAwards
                    .AnyAsync(ba => ba.UserId == user.UserId && ba.BadgeId == badge.BadgeId);

                if (!alreadyHas)
                {
                    _db.BadgeAwards.Add(new BadgeAward
                    {
                        BadgeAwardId = $"BA-{user.UserId}-{badge.BadgeId}",
                        UserId = user.UserId,
                        BadgeId = badge.BadgeId,
                        AwardedAt = DateTime.UtcNow
                    });
                }
            }
        }

        await _db.SaveChangesAsync();
    }
}