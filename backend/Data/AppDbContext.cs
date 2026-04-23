using GamePlusAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace GamePlusAPI.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    // Tablolar
    public DbSet<User> Users { get; set; }
    public DbSet<Game> Games { get; set; }
    public DbSet<ActivityEvent> ActivityEvents { get; set; }
    public DbSet<Quest> Quests { get; set; }
    public DbSet<Badge> Badges { get; set; }
    public DbSet<BadgeAward> BadgeAwards { get; set; }
    public DbSet<QuestAward> QuestAwards { get; set; }
    public DbSet<PointsLedger> PointsLedger { get; set; }
    public DbSet<QuestDecision> QuestDecisions { get; set; }
    public DbSet<Notification> Notifications { get; set; }

    // View'lar (keyless)
    public DbSet<UserState> UserStates { get; set; }
    public DbSet<LeaderboardEntry> LeaderboardEntries { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserState>()
            .HasNoKey()
            .ToView("vw_UserState");

        modelBuilder.Entity<LeaderboardEntry>()
            .HasNoKey()
            .ToView("vw_Leaderboard");

        modelBuilder.Entity<BadgeAward>()
            .HasOne(b => b.Badge)
            .WithMany()
            .HasForeignKey(b => b.BadgeId);
    }
}