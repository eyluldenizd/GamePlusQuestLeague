function getUserIdFromUrl() {
    return new URLSearchParams(window.location.search).get("user_id");
}

function metricCard(label, value) {
    return `
        <div class="card">
            <span class="card-label">${label}</span>
            <span class="card-value">${value}</span>
        </div>`;
}

async function loadUserDetail() {
    const userId = getUserIdFromUrl();
    if (!userId) {
        document.getElementById("username").innerText = "Kullanıcı bulunamadı";
        return;
    }

    try {
        // --- 1. User State (metrikler + streak + puan) ---
        const stateRes = await fetch(`${BASE_URL}/api/users/${userId}/state`);
        const state = await stateRes.json();

        document.getElementById("username").innerText = `${state.name} (${state.user_id})`;
        document.getElementById("user-meta").innerText = `${state.city ?? ""} · ${state.segment ?? ""}`;

        document.getElementById("today").innerHTML =
            metricCard("Login", state.login_count_today) +
            metricCard("Oynama (dk)", state.play_minutes_today) +
            metricCard("PvP Kazanma", state.pvp_wins_today) +
            metricCard("Coop (dk)", state.coop_minutes_today) +
            metricCard("Topup", state.topup_try_today);

        document.getElementById("last7").innerHTML =
            metricCard("Oynama 7g (dk)", state.play_minutes_7d) +
            metricCard("Topup 7g", state.topup_try_7d) +
            metricCard("Login 7g", state.logins_7d);

        document.getElementById("streak").innerHTML = `
            <div class="streak-box">
                🔥 <strong>${state.login_streak_days}</strong> gün kesintisiz giriş
            </div>`;

        // --- 2. Quest Awards ---
        const questRes = await fetch(`${BASE_URL}/api/users/${userId}/quests`);
        const quests = await questRes.json();

        if (quests.length === 0) {
            document.getElementById("quests").innerHTML = "<p>Henüz görev kazanımı yok.</p>";
        } else {
            document.getElementById("quests").innerHTML = quests.map(q => `
                <div class="quest-card">
                    <div>📅 ${q.as_of_date}</div>
                    <div>✅ Seçilen: <strong>${q.selected_quest}</strong> (+${q.reward_points} puan)</div>
                    <div>🎯 Tetiklenen: ${q.triggered_quests}</div>
                    <div>🚫 Baskılanan: ${q.suppressed_quests || "—"}</div>
                </div>`).join("");
        }

        // --- 3. Points Ledger ---
        const ledgerRes = await fetch(`${BASE_URL}/api/users/${userId}/ledger`);
        const ledger = await ledgerRes.json();

        document.getElementById("ledger").innerHTML = ledger.length === 0
            ? `<tr><td colspan="4">Kayıt yok</td></tr>`
            : ledger.map(l => `
                <tr>
                    <td>${l.created_at?.substring(0, 10)}</td>
                    <td>+${l.points_delta}</td>
                    <td>${l.source}</td>
                    <td>${l.source_ref}</td>
                </tr>`).join("");

        // --- 4. Badges ---
        const badgeRes = await fetch(`${BASE_URL}/api/users/${userId}/badges`);
        const badges = await badgeRes.json();

        document.getElementById("badges").innerHTML = badges.length === 0
            ? "<p>Henüz rozet kazanılmadı.</p>"
            : badges.map(b => `<span class="badge">${b.badge_name}</span>`).join("");

        // --- 5. Notifications ---
        const notifRes = await fetch(`${BASE_URL}/api/users/${userId}/notifications`);
        const notifs = await notifRes.json();

        document.getElementById("notifications").innerHTML = notifs.length === 0
            ? `<tr><td colspan="3">Bildirim yok</td></tr>`
            : notifs.map(n => `
                <tr>
                    <td>${n.sent_at?.substring(0, 10)}</td>
                    <td>${n.channel}</td>
                    <td>${n.message}</td>
                </tr>`).join("");

    } catch (err) {
        console.error("Kullanıcı detayı yüklenemedi:", err);
        document.getElementById("username").innerText = "Hata oluştu";
    }
}

document.addEventListener("DOMContentLoaded", loadUserDetail);