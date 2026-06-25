"""
校园集市 - Flask Web 应用
"""
import hashlib, os
from functools import wraps
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, session
from werkzeug.utils import secure_filename
from db import query, execute, get_conn

app = Flask(__name__)
app.secret_key = 'campus-market-secret-2024'

UPLOAD_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static', 'uploads')
os.makedirs(UPLOAD_DIR, exist_ok=True)


# ── 认证 ──
def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user_id' not in session:
            flash('请先登录', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated


def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user_id' not in session:
            flash('请先登录', 'warning')
            return redirect(url_for('login'))
        user = get_current_user()
        if user.get('role') != '管理员':
            flash('需要管理员权限', 'error')
            return redirect(url_for('index'))
        return f(*args, **kwargs)
    return decorated

def get_current_user():
    if 'user_id' in session:
        u = query("SELECT * FROM users WHERE user_id=%s", (session['user_id'],))
        return u[0] if u else None
    return None

@app.context_processor
def inject_user():
    return dict(current_user=get_current_user())

def hash_password(pw):
    return hashlib.sha256(pw.encode()).hexdigest()

def get_sections():
    return query("SELECT sec_id, name, description FROM sections ORDER BY sort_order")

def get_users():
    return query("SELECT user_id, nickname, exp, level, school, avatar FROM users")

def section_desc():
    return {
        "集市24小时火文": "系统自动聚合24小时内高热度帖子",
        "红包帖": "带红包奖励的帖子",
        "课程评价": "课程评分与学习心得交流", "跑腿代办": "校园跑腿、代办需求发布",
        "打听求助": "校园生活问题咨询与求助", "恋爱交友": "交友、找搭子、社交活动",
        "校园趣事": "校园趣事分享与热门话题", "兼职招聘": "校园兼职信息与实习机会",
        "二手闲置": "二手书籍、电子产品、生活用品交易",
    }

LEVELS = [("小学生", 0), ("初中生", 200), ("高中生", 400),
          ("大学生", 600), ("研究生", 800), ("博士", 1000)]

def add_exp(uid, amount):
    """增加经验值并自动升级"""
    execute("UPDATE users SET exp = exp + %s WHERE user_id = %s", (amount, uid))
    user = query("SELECT exp FROM users WHERE user_id=%s", (uid,))
    if user:
        exp = user[0]['exp']
        new_level = "小学生"
        for lvl, threshold in LEVELS:
            if exp >= threshold:
                new_level = lvl
        execute("UPDATE users SET level = %s WHERE user_id = %s", (new_level, uid))


# ═══ 登录/注册 ═══
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        user_id = request.form['user_id'].strip()
        password = request.form['password']
        u = query("SELECT * FROM users WHERE user_id=%s AND password_hash=%s",
                  (user_id, hash_password(password)))
        if u:
            session['user_id'] = u[0]['user_id']
            session['nickname'] = u[0]['nickname']
            flash(f'欢迎回来，{u[0]["nickname"]}！', 'success')
            return redirect(url_for('home'))
        flash('学号或密码错误', 'error')
    return render_template('login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        user_id = request.form['user_id'].strip()
        nickname = request.form['nickname'].strip()
        password = request.form['password']
        phone = request.form.get('phone', '').strip()
        if not user_id or not nickname or not password:
            flash('请填写所有必填项', 'warning')
            return render_template('register.html')
        if query("SELECT user_id FROM users WHERE user_id=%s", (user_id,)):
            flash('该学号已被注册', 'warning')
            return render_template('register.html')
        execute("INSERT INTO users (user_id, nickname, password_hash, phone) VALUES (%s,%s,%s,%s)",
                (user_id, nickname, hash_password(password), phone))
        flash('注册成功！请登录', 'success')
        return redirect(url_for('login'))
    return render_template('register.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('已退出登录', 'info')
    return redirect(url_for('login'))


# ═══ 🏠 主页 — 仅平台介绍 ═══
@app.route('/home')
@login_required
def home():
    return render_template('home.html')


# ═══ 📌 最新 ═══
@app.route('/')
@login_required
def index():
    red_posts = query("""
        SELECT p.*, u.nickname, s.name AS section_name
        FROM posts p JOIN users u ON p.user_id = u.user_id
        JOIN sections s ON p.sec_id = s.sec_id
        WHERE p.sec_id = 2 AND p.status = '正常'
          AND p.pub_time > DATE_SUB(NOW(), INTERVAL 24 HOUR)
        ORDER BY p.pub_time DESC
    """)
    normal_posts = query("""
        SELECT p.*, u.nickname, s.name AS section_name
        FROM posts p JOIN users u ON p.user_id = u.user_id
        JOIN sections s ON p.sec_id = s.sec_id
        WHERE p.sec_id != 2 AND p.status != '已删除'
        ORDER BY p.pub_time DESC LIMIT 20
    """)
    return render_template('index.html', red_posts=red_posts, normal_posts=normal_posts)


# ═══ 📂 浏览（含搜索） ═══
@app.route('/browse')
@app.route('/browse/<int:sec_id>')
@login_required
def browse(sec_id=None):
    sections = get_sections()
    if sec_id is None:
        sec_id = sections[0]['sec_id'] if sections else 1
    current_sec = next((s for s in sections if s['sec_id'] == sec_id), sections[0])

    stats = query(f"""
        SELECT COUNT(*) AS total, IFNULL(SUM(view_count),0) AS views,
               IFNULL(SUM(like_count),0) AS likes, IFNULL(SUM(comment_count),0) AS comments
        FROM posts WHERE sec_id={sec_id} AND status!='已删除'
    """)[0]

    # 搜索参数
    search_type = request.args.get('type', '')
    keyword = request.args.get('q', '').strip()
    min_likes = request.args.get('min_likes', '')

    posts = []
    search_active = False
    if search_type == 'keyword' and keyword:
        search_active = True
        posts = query(f"""
            SELECT p.*, u.nickname, s.name AS section_name
            FROM posts p JOIN users u ON p.user_id = u.user_id
            JOIN sections s ON p.sec_id = s.sec_id
            WHERE (p.title LIKE '%{keyword}%' OR p.content LIKE '%{keyword}%')
              AND p.status != '已删除'
            ORDER BY p.pub_time DESC
        """)
    elif search_type == 'likes' and min_likes:
        search_active = True
        posts = query(f"""
            SELECT p.*, u.nickname, s.name AS section_name
            FROM posts p JOIN users u ON p.user_id = u.user_id
            JOIN sections s ON p.sec_id = s.sec_id
            WHERE p.like_count >= {int(min_likes)} AND p.status != '已删除'
            ORDER BY p.like_count DESC
        """)
    else:
        posts = query(f"""
            SELECT p.*, u.nickname
            FROM posts p JOIN users u ON p.user_id = u.user_id
            WHERE p.sec_id = {sec_id} AND p.status != '已删除'
            ORDER BY p.pub_time DESC
        """)

    return render_template('browse.html',
                         sections=sections, current_sec=current_sec,
                         current_sec_id=sec_id, posts=posts, stats=stats,
                         desc_map=section_desc(),
                         search_type=search_type, keyword=keyword, min_likes=min_likes,
                         search_active=search_active)


# ═══ ✏️ 发帖 ═══
@app.route('/create_post', methods=['GET', 'POST'])
@login_required
def create_post():
    sections = get_sections()
    if request.method == 'POST':
        uid = session['user_id']
        sec_id = request.form['sec_id']
        title = request.form['title']
        content = request.form['content']
        contact = request.form.get('contact', '')
        post_type = request.form.get('post_type', 'normal')
        if not title or not content:
            flash('标题和内容不能为空', 'warning')
            return render_template('post_form.html', sections=sections)
        if post_type == 'red':
            sec_id = 2
            red_amount = float(request.form.get('red_amount', 0))
            if red_amount <= 0:
                flash('红包金额必须大于0', 'warning')
                return render_template('post_form.html', sections=sections)
            # 检查余额
            user = get_current_user()
            balance = float(user.get('red_balance') or 0)
            if balance < red_amount:
                flash(f'红包币不足！当前余额 ¥{balance:.0f}，需要 ¥{red_amount:.0f}', 'warning')
                return render_template('post_form.html', sections=sections)
            # 扣款
            execute("UPDATE users SET red_balance=red_balance-%s, red_sent=red_sent+%s WHERE user_id=%s",
                    (red_amount, red_amount, uid))
            content = f"{content}\n\n[红包 {red_amount} 元]"
            execute("INSERT INTO posts (user_id, sec_id, title, content, contact, red_amount, red_remaining) VALUES (%s,%s,%s,%s,%s,%s,%s)",
                    (uid, sec_id, title, content, contact, red_amount, red_amount))
        else:
            execute("INSERT INTO posts (user_id, sec_id, title, content, contact) VALUES (%s,%s,%s,%s,%s)",
                    (uid, sec_id, title, content, contact))
        add_exp(uid, 10)  # 发帖 +10exp
        flash('帖子发布成功！经验+10', 'success')
        return redirect(url_for('index'))
    return render_template('post_form.html', sections=sections)


# ═══ 📄 帖子详情 ═══
@app.route('/post/<int:post_id>')
@login_required
def post_detail(post_id):
    post = query(f"""
        SELECT p.*, u.nickname, u.user_id AS author_id, u.level, u.exp, u.school, u.avatar,
               s.name AS section_name
        FROM posts p JOIN users u ON p.user_id = u.user_id
        JOIN sections s ON p.sec_id = s.sec_id
        WHERE p.post_id = {post_id}
    """)
    if not post:
        flash('帖子不存在', 'warning')
        return redirect(url_for('index'))
    post = post[0]

    # 同一用户对同一帖子只计一次浏览（先更新，后面查到的就是最新值）
    uid = session['user_id']
    if not query("SELECT 1 FROM post_views WHERE post_id=%s AND user_id=%s", (post_id, uid)):
        execute("INSERT INTO post_views (post_id, user_id) VALUES (%s,%s)", (post_id, uid))
        execute("UPDATE posts SET view_count = view_count + 1 WHERE post_id = %s", (post_id,))
        post['view_count'] = (post['view_count'] or 0) + 1

    comments = query(f"""
        SELECT c.*, u.nickname, u.avatar
        FROM comments c JOIN users u ON c.user_id = u.user_id
        WHERE c.post_id = {post_id} ORDER BY c.cmt_time ASC
    """)

    liked = query("SELECT 1 FROM likes WHERE post_id=%s AND user_id=%s", (post_id, uid))
    favorited = query("SELECT 1 FROM favorites WHERE post_id=%s AND user_id=%s", (post_id, uid))

    # 红包分配记录
    distributions = query(f"""
        SELECT d.*, u.nickname FROM red_distribution d
        JOIN users u ON d.to_user_id = u.user_id
        WHERE d.post_id = {post_id} ORDER BY d.dist_time DESC
    """)

    return render_template('post_detail.html', post=post, comments=comments,
                         liked=bool(liked), favorited=bool(favorited),
                         distributions=distributions)

@app.route('/post/<int:post_id>/comment', methods=['POST'])
@login_required
def add_comment(post_id):
    content = request.form.get('content', '').strip()
    if content:
        execute("INSERT INTO comments (post_id, user_id, content) VALUES (%s,%s,%s)",
                (post_id, session['user_id'], content))
        add_exp(session['user_id'], 2)  # 评论者 +2
        post = query("SELECT user_id FROM posts WHERE post_id=%s", (post_id,))
        if post:
            add_exp(post[0]['user_id'], 3)  # 帖主 +3
    return redirect(url_for('post_detail', post_id=post_id))


@app.route('/post/<int:post_id>/distribute', methods=['POST'])
@login_required
def distribute_red(post_id):
    """红包分配：将红包发给指定评论者"""
    post = query("SELECT * FROM posts WHERE post_id=%s", (post_id,))
    if not post or session['user_id'] != post[0]['user_id']:
        flash('无权操作', 'error')
        return redirect(url_for('post_detail', post_id=post_id))
    post = post[0]

    to_user = request.form.get('to_user_id', '').strip()
    amount = float(request.form.get('amount', 0))

    if not to_user or amount <= 0:
        flash('请选择用户并输入金额', 'warning')
        return redirect(url_for('post_detail', post_id=post_id))

    remaining = float(post.get('red_remaining') or 0)
    if amount > remaining:
        flash(f'红包余额不足（剩余 ¥{remaining:.0f}）', 'warning')
        return redirect(url_for('post_detail', post_id=post_id))

    # 扣除帖子红包余额
    new_remaining = remaining - amount
    execute("UPDATE posts SET red_remaining=%s WHERE post_id=%s", (new_remaining, post_id))

    # 记录分配
    execute("INSERT INTO red_distribution (post_id, from_user_id, to_user_id, amount) VALUES (%s,%s,%s,%s)",
            (post_id, session['user_id'], to_user, amount))

    # 增加接收者余额（发帖者已在创建时扣过款，此处不重复扣）
    execute("UPDATE users SET red_balance=red_balance+%s, red_received=red_received+%s WHERE user_id=%s",
            (amount, amount, to_user))

    # 红包发完自动结束
    if new_remaining <= 0:
        execute("UPDATE posts SET status='已结束' WHERE post_id=%s", (post_id,))
        flash(f'已分配 ¥{amount:.0f} 给该用户，红包已发完，帖子自动结束', 'success')
    else:
        flash(f'已分配 ¥{amount:.0f} 给该用户，剩余 ¥{new_remaining:.0f}', 'success')

    return redirect(url_for('post_detail', post_id=post_id))


@app.route('/post/<int:post_id>/end', methods=['POST'])
@login_required
def end_post(post_id):
    """发帖者手动结束帖子"""
    post = query("SELECT * FROM posts WHERE post_id=%s", (post_id,))
    if not post or session['user_id'] != post[0]['user_id']:
        flash('无权操作', 'error')
        return redirect(url_for('post_detail', post_id=post_id))

    execute("UPDATE posts SET status='已结束' WHERE post_id=%s", (post_id,))
    flash('帖子已结束', 'success')
    return redirect(url_for('post_detail', post_id=post_id))


# ═══ 💬 消息 ═══
@app.route('/messages')
@login_required
def messages():
    uid = session['user_id']

    # 回复我的：别人在我帖子下的评论
    replies = query(f"""
        SELECT c.*, u.nickname AS commenter, u.avatar,
               p.title AS post_title, p.post_id
        FROM comments c
        JOIN posts p ON c.post_id = p.post_id
        JOIN users u ON c.user_id = u.user_id
        WHERE p.user_id = '{uid}' AND c.user_id != '{uid}'
        ORDER BY c.cmt_time DESC LIMIT 30
    """)

    # 收到的赞：别人对我帖子的点赞
    received_likes = query(f"""
        SELECT l.*, u.nickname AS liker,
               p.title AS post_title, p.post_id
        FROM likes l
        JOIN posts p ON l.post_id = p.post_id
        JOIN users u ON l.user_id = u.user_id
        WHERE p.user_id = '{uid}' AND l.user_id != '{uid}'
        ORDER BY l.like_time DESC LIMIT 30
    """)

    # 我的点赞（我点过赞的帖子）
    my_likes = query(f"""
        SELECT p.*, s.name AS section_name, u.nickname, l.like_time
        FROM likes l JOIN posts p ON l.post_id = p.post_id
        JOIN sections s ON p.sec_id = s.sec_id
        JOIN users u ON p.user_id = u.user_id
        WHERE l.user_id = '{uid}' ORDER BY l.like_time DESC LIMIT 30
    """)

    # 我的码住
    my_favs = query(f"""
        SELECT p.*, s.name AS section_name, u.nickname, f.fav_time
        FROM favorites f JOIN posts p ON f.post_id = p.post_id
        JOIN sections s ON p.sec_id = s.sec_id
        JOIN users u ON p.user_id = u.user_id
        WHERE f.user_id = '{uid}' ORDER BY f.fav_time DESC
    """)

    report_feedback = query(f"""
        SELECT r.*, p.title AS post_title
        FROM reports r JOIN posts p ON r.post_id = p.post_id
        WHERE r.reporter_id = '{uid}' AND r.status != '待处理'
        ORDER BY r.handle_time DESC LIMIT 20
    """)

    return render_template('messages.html',
                         replies=replies, received_likes=received_likes,
                         my_likes=my_likes, my_favs=my_favs,
                         report_feedback=report_feedback)


# ═══ 👤 我的 ═══
@app.route('/profile')
@login_required
def profile():
    uid = session['user_id']
    user = get_current_user()

    level_order = ["小学生", "初中生", "高中生", "大学生", "研究生", "博士"]
    lvl = user.get('level', '小学生')
    idx = level_order.index(lvl) if lvl in level_order else 0
    next_level = level_order[min(idx + 1, 5)]
    exp = user.get('exp', 0)
    progress = min(exp / ((idx + 1) * 200), 1.0) if idx < 5 else 1.0

    my_posts = query(f"""
        SELECT p.*, s.name AS section_name
        FROM posts p JOIN sections s ON p.sec_id = s.sec_id
        WHERE p.user_id = '{uid}' ORDER BY p.pub_time DESC
    """)

    return render_template('profile.html', user=user, next_level=next_level,
                         progress=progress, my_posts=my_posts)


@app.route('/profile/update', methods=['POST'])
@login_required
def update_profile():
    school = request.form.get('school', '').strip()
    if school:
        execute("UPDATE users SET school=%s WHERE user_id=%s", (school, session['user_id']))
    return redirect(url_for('profile'))


@app.route('/upload/avatar', methods=['POST'])
@login_required
def upload_avatar():
    file = request.files.get('avatar')
    if file and file.filename:
        ext = file.filename.rsplit('.', 1)[-1].lower()
        if ext in ('png', 'jpg', 'jpeg', 'gif', 'webp'):
            filename = f"avatar_{session['user_id']}.{ext}"
            filepath = os.path.join(UPLOAD_DIR, filename)
            file.save(filepath)
            avatar_url = f"/static/uploads/{filename}"
            execute("UPDATE users SET avatar=%s WHERE user_id=%s", (avatar_url, session['user_id']))
            flash('头像上传成功！', 'success')
    return redirect(url_for('profile'))


# ═══ 互动操作 (AJAX) ═══
@app.route('/action/like', methods=['POST'])
@login_required
def action_like():
    pid = request.form['post_id']
    uid = session['user_id']
    exist = query("SELECT 1 FROM likes WHERE post_id=%s AND user_id=%s", (pid, uid))
    if not exist:
        execute("INSERT INTO likes (post_id, user_id) VALUES (%s,%s)", (pid, uid))
        add_exp(uid, 1)  # 点赞者 +1
        post = query("SELECT user_id FROM posts WHERE post_id=%s", (pid,))
        if post:
            add_exp(post[0]['user_id'], 2)  # 帖子作者 +2
        return jsonify({"ok": True, "liked": True, "msg": "点赞成功"})
    return jsonify({"ok": False, "liked": True, "msg": "已经点过赞了"})

@app.route('/action/unlike', methods=['POST'])
@login_required
def action_unlike():
    pid = request.form['post_id']
    uid = session['user_id']
    execute("DELETE FROM likes WHERE post_id=%s AND user_id=%s", (pid, uid))
    return jsonify({"ok": True, "liked": False, "msg": "已取消点赞"})

@app.route('/action/favorite', methods=['POST'])
@login_required
def action_favorite():
    pid = request.form['post_id']
    uid = session['user_id']
    exist = query("SELECT 1 FROM favorites WHERE post_id=%s AND user_id=%s", (pid, uid))
    if not exist:
        execute("INSERT INTO favorites (post_id, user_id) VALUES (%s,%s)", (pid, uid))
        return jsonify({"ok": True, "favorited": True, "msg": "码住成功"})
    return jsonify({"ok": False, "favorited": True, "msg": "已经码住了"})

@app.route('/action/unfavorite', methods=['POST'])
@login_required
def action_unfavorite():
    pid = request.form['post_id']
    uid = session['user_id']
    execute("DELETE FROM favorites WHERE post_id=%s AND user_id=%s", (pid, uid))
    return jsonify({"ok": True, "favorited": False, "msg": "已取消码住"})

@app.route('/action/report', methods=['POST'])
@login_required
def action_report():
    pid = request.form['post_id']
    uid = session['user_id']
    reason = request.form.get('reason', '违规内容')
    execute("INSERT INTO reports (post_id, reporter_id, reason) VALUES (%s,%s,%s)", (pid, uid, reason))
    return jsonify({"ok": True, "msg": "举报已提交"})


if __name__ == '__main__':
    app.run(debug=True, port=8501)

# ═══ 🔧 帖子删除（发帖者或管理员） ═══
@app.route('/post/<int:post_id>/delete', methods=['POST'])
@login_required
def delete_post(post_id):
    post = query("SELECT * FROM posts WHERE post_id=%s", (post_id,))
    if not post:
        flash('帖子不存在', 'error')
        return redirect(url_for('index'))
    post = post[0]
    user = get_current_user()
    if session['user_id'] != post['user_id'] and user.get('role') != '管理员':
        flash('无权删除此帖', 'error')
        return redirect(url_for('post_detail', post_id=post_id))
    execute("DELETE FROM posts WHERE post_id=%s", (post_id,))
    flash('帖子已删除，日志已写入 post_log', 'success')
    return redirect(url_for('index'))


# ═══ 🛡️ 管理员：举报管理 ═══
@app.route('/admin/reports')
@admin_required
def admin_reports():
    pending = query("""
        SELECT r.*, p.title AS post_title, u.nickname AS reporter_name
        FROM reports r
        JOIN posts p ON r.post_id = p.post_id
        JOIN users u ON r.reporter_id = u.user_id
        WHERE r.status = '待处理'
        ORDER BY r.report_time DESC
    """)
    processed = query("""
        SELECT r.*, p.title AS post_title, u.nickname AS reporter_name
        FROM reports r
        JOIN posts p ON r.post_id = p.post_id
        JOIN users u ON r.reporter_id = u.user_id
        WHERE r.status != '待处理'
        ORDER BY r.handle_time DESC LIMIT 20
    """)
    deleted_posts = query("""
        SELECT log.*, u.nickname
        FROM post_log log
        JOIN users u ON log.user_id = u.user_id
        ORDER BY log.deleted_at DESC LIMIT 30
    """)
    return render_template('admin_reports.html',
                         pending=pending, processed=processed, deleted_posts=deleted_posts)


@app.route('/admin/reports/<int:rp_id>/handle', methods=['POST'])
@admin_required
def handle_report(rp_id):
    action = request.form.get('action', '已处理')
    note = request.form.get('note', '').strip()
    post_id = request.form.get('post_id', '')

    execute("UPDATE reports SET status=%s, handle_note=%s, handle_time=NOW() WHERE rp_id=%s",
            (action, note, rp_id))

    # 管理员反馈：在帖下评论，举报者可在"回复我的"看到
    report = query("SELECT * FROM reports WHERE rp_id=%s", (rp_id,))
    if report and post_id:
        r = report[0]
        admin_uid = session['user_id']
        feedback = f"[管理员反馈] 您对帖子的举报已处理。{note}"
        execute("INSERT INTO comments (post_id, user_id, content) VALUES (%s,%s,%s)",
                (post_id, admin_uid, feedback))

    flash(f'举报已处理', 'success')
    return redirect(url_for('admin_reports'))
