using GamePlusAPI.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;

namespace GamePlusAPI.Controllers;

[ApiController]
[Route("api/users")]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _db;

    public UsersController(AppDbContext db)
    {
        _db = db;
    }

    // GET /api/users
    // Tüm kullanıcıların state bilgisi (liste sayfası için)
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var users = await _db.UserStates.ToListAsync();
        return Ok(users);
    }

    // GET /api/users/{userId}/state
    // Tek kullanıcının tüm metrikleri (detay sayfası için)
    [HttpGet("{userId}/state")]
    public async Task<IActionResult> GetState(string userId)
    {
        var state = await _db.UserStates
            .FirstOrDefaultAsync(u => u.UserId == userId);

        if (state == null) return NotFound(new { message = $"{userId} bulunamadı" });
        return Ok(state);
    }

    // GET /api/users/{userId}/quests
    // Kullanıcının görev kazanımları
    [HttpGet("{userId}/quests")]
    public async Task<IActionResult> GetQuests(string userId)
    {
        var awards = await _db.QuestAwards
            .Where(q => q.UserId == userId)
            .OrderByDescending(q => q.AsOfDate)
            .ToListAsync();

        return Ok(awards);
    }

    // GET /api/users/{userId}/ledger
    // Kullanıcının puan defteri
    [HttpGet("{userId}/ledger")]
    public async Task<IActionResult> GetLedger(string userId)
    {
        var ledger = await _db.PointsLedger
            .Where(l => l.UserId == userId)
            .OrderByDescending(l => l.CreatedAt)
            .ToListAsync();

        return Ok(ledger);
    }

    // GET /api/users/{userId}/badges
    // Kullanıcının rozetleri
    [HttpGet("{userId}/badges")]
    public async Task<IActionResult> GetBadges(string userId)
    {
        var badges = await _db.BadgeAwards
            .Where(b => b.UserId == userId)
            .Include(b => b.Badge)
            .ToListAsync();

        var result = badges.Select(b => new
        {
            b.BadgeId,
            BadgeName = b.Badge!.BadgeName,
            Level = b.Badge.Level,
            b.AwardedAt
        });

        return Ok(result);
    }

    // GET /api/users/{userId}/notifications
    // Kullanıcının bildirimleri
    [HttpGet("{userId}/notifications")]
    public async Task<IActionResult> GetNotifications(string userId)
    {
        var notifs = await _db.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.SentAt)
            .ToListAsync();

        return Ok(notifs);
    }
}