using GamePlusAPI.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;

namespace GamePlusAPI.Controllers;

[ApiController]
[Route("api/leaderboard")]
public class LeaderboardController : ControllerBase
{
    private readonly AppDbContext _db;

    public LeaderboardController(AppDbContext db)
    {
        _db = db;
    }

    // GET /api/leaderboard
    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var board = await _db.LeaderboardEntries.ToListAsync();
        return Ok(board);
    }
}