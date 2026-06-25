/**
 * 校园集市 — SPA 导航 + 主题切换
 * 使用事件委托，绑定一次，覆盖所有动态内容
 */
(function() {
    'use strict';

    const mainEl = document.getElementById('main-content');

    // ── 主题 ──
    const saved = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', saved);
    window.toggleTheme = function() {
        const next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
        document.documentElement.setAttribute('data-theme', next);
        localStorage.setItem('theme', next);
    };

    // ── 判断是否该拦截 ──
    function shouldIntercept(href) {
        if (!href || href.startsWith('javascript:') || href.startsWith('#') ||
            href.startsWith('http://') || href.startsWith('https://') ||
            href === '/login' || href === '/register' || href === '/logout' ||
            href.includes('/action/') || href.endsWith('/comment')) return false;
        return true;
    }

    // ── SPA 导航核心 ──
    async function navigate(url, push) {
        if (!mainEl) { window.location = url; return; }
        try {
            const r = await fetch(url, { headers: { 'X-SPA': '1' } });
            if (!r.ok) throw new Error('fail');
            const html = await r.text();
            const doc = new DOMParser().parseFromString(html, 'text/html');
            const next = doc.getElementById('main-content');
            if (!next) throw new Error('no main');

            document.title = (doc.querySelector('title') || {}).textContent || document.title;
            mainEl.innerHTML = next.innerHTML;

            // 执行新内容中的 script 标签
            mainEl.querySelectorAll('script').forEach(function(old) {
                var s = document.createElement('script');
                s.textContent = old.textContent;
                old.replaceWith(s);
            });

            if (push !== false) window.history.pushState({ url }, '', url);
            _updateSidebar(url);
            window.scrollTo(0, 0);
        } catch (e) {
            window.location = url;
        }
    }

    function _updateSidebar(url) {
        document.querySelectorAll('.sidebar-nav a').forEach(a => {
            const href = a.getAttribute('href');
            a.classList.toggle('active', href === url || (href !== '/' && url.startsWith(href)));
        });
    }

    // ── 事件委托：整个文档只绑定一次 ──
    document.addEventListener('click', function(e) {
        const target = e.target.closest('a[data-spa]');
        if (target) {
            const href = target.getAttribute('href');
            if (shouldIntercept(href)) {
                e.preventDefault();
                navigate(href);
                return;
            }
        }

        // Post card click → detail page
        const card = e.target.closest('.card[data-post-id]');
        if (card && !e.target.closest('button, form, a, .btn, input, textarea, select')) {
            e.preventDefault();
            navigate('/post/' + card.dataset.postId);
            return;
        }

        // Section tab click
        const tab = e.target.closest('.section-tab[data-sec-id]');
        if (tab) {
            e.preventDefault();
            navigate('/browse/' + tab.dataset.secId);
            return;
        }

        // In-page tab switch (no navigation)
        const inpageTab = e.target.closest('.tab-nav .tab-item[data-tab]');
        if (inpageTab) {
            const name = inpageTab.dataset.tab;
            // 隐藏同一页面范围内的所有 tab-panel
            const mainArea = document.getElementById('main-content');
            const panels = mainArea.querySelectorAll('.tab-panel');
            panels.forEach(function(p) { p.style.display = 'none'; });
            // 显示目标
            const target = document.getElementById(name);
            if (target) target.style.display = 'block';
            // 更新 active 状态
            const group = inpageTab.parentElement;
            group.querySelectorAll('.tab-item').forEach(function(t) { t.classList.remove('active'); });
            inpageTab.classList.add('active');
            return;
        }
    });

    // ── 浏览器前进/后退 ──
    window.addEventListener('popstate', function(e) {
        if (e.state && e.state.url) navigate(e.state.url, false);
    });

    // ── 暴露 navigateTo 给 inline onclick ──
    window.navigateTo = function(url) { navigate(url); };

    // ── 全局 AJAX 交互函数 ──
    window.ajaxPost = async function(url, body) {
        var r = await fetch(url, {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body});
        return await r.json();
    };

    window.toggleLike = async function(pid) {
        var btn = document.getElementById('likeBtn');
        var liked = btn && btn.textContent.includes('已点赞');
        var d = liked ? await window.ajaxPost('/action/unlike', 'post_id='+pid)
                     : await window.ajaxPost('/action/like', 'post_id='+pid);
        if (btn && d.liked !== undefined) {
            btn.textContent = d.liked ? '❤️ 已点赞' : '🤍 点赞';
            btn.className = 'btn btn-sm ' + (d.liked ? 'btn-secondary' : 'btn-primary');
        }
        // 更新赞数
        var countEl = document.getElementById('likeCount');
        if (countEl && d.liked !== undefined) {
            var match = countEl.textContent.match(/\d+/);
            var cur = match ? parseInt(match[0]) : 0;
            countEl.textContent = '👍 ' + (d.liked ? cur + 1 : Math.max(0, cur - 1));
        }
        var msg = document.getElementById('actionMsg');
        if (msg) msg.innerHTML = '<span style="color:var(--green);">'+d.msg+'</span>';
        // 不再整页刷新
    };

    window.toggleFav = async function(pid) {
        var btn = document.getElementById('favBtn');
        var faved = btn && btn.textContent.includes('已码住');
        var d = faved ? await window.ajaxPost('/action/unfavorite', 'post_id='+pid)
                     : await window.ajaxPost('/action/favorite', 'post_id='+pid);
        if (btn && d.favorited !== undefined) {
            btn.textContent = d.favorited ? '⭐ 已码住' : '☆ 码住';
            btn.className = 'btn btn-sm ' + (d.favorited ? 'btn-secondary' : 'btn-primary');
        }
        var msg = document.getElementById('actionMsg');
        if (msg) msg.innerHTML = '<span style="color:var(--green);">'+d.msg+'</span>';
    };

    window.reportPost = async function(pid) {
        var reason = prompt('请输入举报原因：', '违规内容');
        if (!reason) return;
        var d = await window.ajaxPost('/action/report', 'post_id='+pid+'&reason='+encodeURIComponent(reason));
        var msg = document.getElementById('actionMsg');
        if (msg) msg.innerHTML = '<span style="color:var(--green);">'+d.msg+'</span>';
    };

    window.unfavMsg = async function(pid, btn) {
        await window.ajaxPost('/action/unfavorite', 'post_id='+pid);
        btn.textContent = '已取消';
        var card = btn.closest('.card');
        if (card) {
            card.style.opacity = '0';
            card.style.transition = 'opacity 0.3s';
            setTimeout(function() { card.remove(); }, 300);
        }
    };

    // ── 确保所有 sidebar 链接有 data-spa ──
    function ensureSpa() {
        document.querySelectorAll('.sidebar-nav a[href]').forEach(a => {
            if (!a.hasAttribute('data-spa')) a.setAttribute('data-spa', '');
        });
    }
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', ensureSpa);
    } else {
        ensureSpa();
    }
})();
