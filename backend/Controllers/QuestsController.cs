using GamePlusAPI.Data;
using GamePlusAPI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;

namespace GamePlusAPI.Controllers;

[ApiController]
[Route("api/quests")]
public class QuestsController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly QuestEngineService _questEngine;
    private readonly BadgeService _badgeService;

    public QuestsController(AppDbContext db, QuestEngineService questEngine, BadgeService badgeService)
    {
        _db = db;
        _questEngine = questEngine;
        _badgeService = badgeService;
    }

    // GET /api/quests
    // Tüm aktif görevleri listeler
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var quests = await _db.Quests
            .Where(q => q.IsActive)
            .OrderBy(q => q.Priority)
            .ToListAsync();

        return Ok(quests);
    }

    // POST /api/quests/run?date=2026-03-12
    // Görev motorunu çalıştırır (ödül, ledger, bildirim, rozet)
    [HttpPost("run")]
    public async Task<IActionResult> Run([FromQuery] string? date)
    {
        var asOfDate = date != null
            ? DateOnly.Parse(date)
            : DateOnly.FromDateTime(DateTime.UtcNow);

        await _questEngine.RunAsync(asOfDate);
        await _badgeService.AssignBadgesAsync();

        return Ok(new { message = $"{asOfDate} için görev motoru çalıştırıldı." });
    }
}