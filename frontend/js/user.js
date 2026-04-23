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

        // C# → JSON camelCase dönüşümü:
        // UserId → userId, Name → name, City → city, Segment → segment
        // LoginCountToday → loginCountToday, PlayMinutesToday → playMinutesToday vb.

        document.getElementById("username").innerText = `${state.name} (${state.userId})`;
        document.getElementById("user-meta").innerText = `${state.city ?? ""} · ${state.segment ?? ""}`;

        document.getElementById("today").innerHTML =
            metricCard("Login",         state.loginCountToday) +
            metricCard("Oynama (dk)",   state.playMinutesToday) +
            metricCard("PvP Kazanma",   state.pvpWinsToday) +
            metricCard("Coop (dk)",     state.coopMinutesToday) +
            metricCard("Topup",         state.topupTryToday);

        document.getElementById("last7").innerHTML =
            metricCard("Oynama 7g (dk)", state.playMinutes7d) +
            metricCard("Topup 7g",       state.topupTry7d) +
            metricCard("Login 7g",       state.logins7d);

        document.getElementById("streak").innerHTML = `
            <div class="streak-box">
                🔥 <strong>${state.loginStreakDays}</strong> gün kesintisiz giriş
            </div>`;

        // --- 2. Quest Awards ---
        const questRes = await fetch(`${BASE_URL}/api/users/${userId}/quests`);
        const quests = await questRes.json();

        // C# → JSON: AsOfDate → asOfDate, SelectedQuest → selectedQuest,
        //             RewardPoints → rewardPoints, TriggeredQuests → triggeredQuests,
        //             SuppressedQuests → suppressedQuests

        if (quests.length === 0) {
            document.getElementById("quests").innerHTML = "<p>Henüz görev kazanımı yok.</p>";
        } else {
            document.getElementById("quests").innerHTML = quests.map(q => `
                <div class="quest-card">
                    <div>📅 ${q.asOfDate}</div>
                    <div>✅ Seçilen: <strong>${q.selectedQuest}</strong> (+${q.rewardPoints} puan)</div>
                    <div>🎯 Tetiklenen: ${q.triggeredQuests}</div>
                    <div>🚫 Baskılanan: ${q.suppressedQuests || "—"}</div>
                </div>`).join("");
        }

        // --- 3. Points Ledger ---
        const ledgerRes = await fetch(`${BASE_URL}/api/users/${userId}/ledger`);
        const ledger = await ledgerRes.json();

        // C# → JSON: CreatedAt → createdAt, PointsDelta → pointsDelta,
        //             Source → source, SourceRef → sourceRef

        document.getElementById("ledger").innerHTML = ledger.length === 0
            ? `<tr><td colspan="4">Kayıt yok</td></tr>`
            : ledger.map(l => `
                <tr>
                    <td>${l.createdAt?.substring(0, 10)}</td>
                    <td>+${l.pointsDelta}</td>
                    <td>${l.source}</td>
                    <td>${l.sourceRef}</td>
                </tr>`).join("");

        // --- 4. Badges ---
        const badgeRes = await fetch(`${BASE_URL}/api/users/${userId}/badges`);
        const badges = await badgeRes.json();

        // UsersController anonim obje döndürüyor:
        // { badgeId, badgeName, level, awardedAt }

        document.getElementById("badges").innerHTML = badges.length === 0
            ? "<p>Henüz rozet kazanılmadı.</p>"
            : badges.map(b => `<span class="badge">${b.badgeName}</span>`).join("");

        // --- 5. Notifications ---
        const notifRes = await fetch(`${BASE_URL}/api/users/${userId}/notifications`);
        const notifs = await notifRes.json();

        // C# → JSON: SentAt → sentAt, Channel → channel, Message → message

        document.getElementById("notifications").innerHTML = notifs.length === 0
            ? `<tr><td colspan="3">Bildirim yok</td></tr>`
            : notifs.map(n => `
                <tr>
                    <td>${n.sentAt?.substring(0, 10)}</td>
                    <td>${n.channel}</td>
                    <td>${n.message}</td>
                </tr>`).join("");

    } catch (err) {
        console.error("Kullanıcı detayı yüklenemedi:", err);
        document.getElementById("username").innerText = "Hata oluştu";
    }
}

document.addEventListener("DOMContentLoaded", loadUserDetail);