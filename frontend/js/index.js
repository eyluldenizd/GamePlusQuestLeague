async function loadLeaderboard() {
    try {
        const res = await fetch(`${BASE_URL}/api/leaderboard`);
        const data = await res.json();

        const tbody = document.getElementById("leaderboard-body");
        tbody.innerHTML = "";

        // API'den gelen JSON camelCase: rank, userId, name, totalPoints
        data.slice(0, 10).forEach(row => {
            tbody.innerHTML += `
                <tr>
                    <td>${row.rank}</td>
                    <td>${row.userId}</td>
                    <td>${row.name ?? "-"}</td>
                    <td>${row.totalPoints}</td>
                </tr>`;
        });
    } catch (err) {
        console.error("Leaderboard yüklenemedi:", err);
    }
}

async function loadUsers() {
    try {
        const res = await fetch(`${BASE_URL}/api/users`);
        const data = await res.json();

        const tbody = document.getElementById("users-body");
        tbody.innerHTML = "";

        // API'den gelen JSON camelCase: userId, name, totalPoints, loginStreakDays
        data.forEach(user => {
            tbody.innerHTML += `
                <tr onclick="window.location.href='user.html?user_id=${user.userId}'" style="cursor:pointer">
                    <td>${user.userId}</td>
                    <td>${user.name ?? "-"}</td>
                    <td>${user.totalPoints ?? 0}</td>
                    <td>🔥 ${user.loginStreakDays ?? 0}</td>
                </tr>`;
        });
    } catch (err) {
        console.error("Kullanıcılar yüklenemedi:", err);
    }
}

document.addEventListener("DOMContentLoaded", () => {
    loadLeaderboard();
    loadUsers();
});