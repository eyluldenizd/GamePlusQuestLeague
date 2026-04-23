async function loadLeaderboard() {
    try {
        const res = await fetch(`${BASE_URL}/api/leaderboard`);
        const data = await res.json();

        const tbody = document.getElementById("leaderboard-body");
        tbody.innerHTML = "";

        data.slice(0, 10).forEach(row => {
            tbody.innerHTML += `
                <tr>
                    <td>${row.rank}</td>
                    <td>${row.user_id}</td>
                    <td>${row.name ?? "-"}</td>
                    <td>${row.total_points}</td>
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

        data.forEach(user => {
            tbody.innerHTML += `
                <tr onclick="window.location.href='user.html?user_id=${user.user_id}'" style="cursor:pointer">
                    <td>${user.user_id}</td>
                    <td>${user.name ?? "-"}</td>
                    <td>${user.total_points ?? 0}</td>
                    <td>🔥 ${user.login_streak_days ?? 0}</td>
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