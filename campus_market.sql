-- ================================================================
-- 武汉理工大学 校园集市数据库
-- CampusMarket Database Schema
-- 
-- 适用数据库: MySQL 5.7+ / 8.0+
-- 包含：建表语句、索引、视图、触发器、存储过程、测试数据
-- ================================================================

DROP DATABASE IF EXISTS CampusMarket;
CREATE DATABASE CampusMarket
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE CampusMarket;

-- ================================================================
-- 1. 用户表 (users)
-- ================================================================
CREATE TABLE IF NOT EXISTS users (
    user_id         VARCHAR(20)     PRIMARY KEY COMMENT '学号，主键',
    nickname        VARCHAR(50)     NOT NULL    COMMENT '用户昵称',
    wechat_openid   VARCHAR(100)    UNIQUE      COMMENT '微信OpenID，唯一',
    phone           VARCHAR(20)                 COMMENT '手机号',
    avatar_url      VARCHAR(255)                COMMENT '头像URL',
    reg_time        DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    status          ENUM('正常','禁言') DEFAULT '正常' COMMENT '用户状态',
    role            ENUM('普通','管理员') DEFAULT '普通' COMMENT '用户角色'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ================================================================
-- 2. 板块表 (sections)
-- ================================================================
CREATE TABLE IF NOT EXISTS sections (
    sec_id          INT             PRIMARY KEY AUTO_INCREMENT COMMENT '板块编号，自增主键',
    name            VARCHAR(30)     NOT NULL UNIQUE COMMENT '板块名称',
    description     VARCHAR(200)                COMMENT '板块描述',
    sort_order      INT             DEFAULT 0   COMMENT '排序序号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='板块表';

-- ================================================================
-- 3. 帖子表 (posts)
-- ================================================================
CREATE TABLE IF NOT EXISTS posts (
    post_id         INT             PRIMARY KEY AUTO_INCREMENT COMMENT '帖子编号，自增主键',
    user_id         VARCHAR(20)     NOT NULL    COMMENT '发布者学号',
    sec_id          INT             NOT NULL    COMMENT '所属板块编号',
    title           VARCHAR(200)    NOT NULL    COMMENT '帖子标题',
    content         TEXT                        COMMENT '帖子正文内容',
    contact         VARCHAR(100)                COMMENT '联系方式',
    pub_time        DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    status          ENUM('正常','已结束','已删除') DEFAULT '正常' COMMENT '帖子状态',
    view_count      INT             DEFAULT 0   COMMENT '浏览量',
    like_count      INT             DEFAULT 0   COMMENT '点赞数（冗余字段，用于热度计算）',
    comment_count   INT             DEFAULT 0   COMMENT '评论数（冗余字段，用于热度计算）',
    hot_score       DECIMAL(10,4)   DEFAULT 0   COMMENT '热度值，公式：view_count*0.3 + comment_count*0.5 + like_count*0.2',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (sec_id)  REFERENCES sections(sec_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子表';

-- ================================================================
-- 4. 评论表 (comments)
-- ================================================================
CREATE TABLE IF NOT EXISTS comments (
    cmt_id          INT             PRIMARY KEY AUTO_INCREMENT COMMENT '评论编号，自增主键',
    post_id         INT             NOT NULL    COMMENT '所属帖子编号',
    user_id         VARCHAR(20)     NOT NULL    COMMENT '评论者学号',
    content         TEXT            NOT NULL    COMMENT '评论内容',
    cmt_time        DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- ================================================================
-- 5. 点赞表 (likes)
-- 联合主键: (post_id, user_id)
-- ================================================================
CREATE TABLE IF NOT EXISTS likes (
    post_id         INT             NOT NULL    COMMENT '帖子编号',
    user_id         VARCHAR(20)     NOT NULL    COMMENT '点赞者学号',
    like_time       DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    PRIMARY KEY (post_id, user_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='点赞表';

-- ================================================================
-- 6. 收藏表 (favorites)
-- 联合主键: (post_id, user_id)
-- ================================================================
CREATE TABLE IF NOT EXISTS favorites (
    post_id         INT             NOT NULL    COMMENT '帖子编号',
    user_id         VARCHAR(20)     NOT NULL    COMMENT '收藏者学号',
    fav_time        DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    PRIMARY KEY (post_id, user_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏表';

-- ================================================================
-- 7. 举报表 (reports)
-- ================================================================
CREATE TABLE IF NOT EXISTS reports (
    rp_id           INT             PRIMARY KEY AUTO_INCREMENT COMMENT '举报编号，自增主键',
    post_id         INT             NOT NULL    COMMENT '被举报帖子编号',
    reporter_id     VARCHAR(20)     NOT NULL    COMMENT '举报者学号',
    reason          VARCHAR(200)    NOT NULL    COMMENT '举报原因',
    status          ENUM('待处理','已处理','驳回') DEFAULT '待处理' COMMENT '处理状态',
    report_time     DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '举报时间',
    handle_time     DATETIME                    COMMENT '处理时间',
    handle_note     VARCHAR(200)                COMMENT '处理备注',
    FOREIGN KEY (post_id)     REFERENCES posts(post_id),
    FOREIGN KEY (reporter_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='举报表';


-- ================================================================
-- 8. 索引设计 (Indexes)
-- ================================================================

-- posts 表索引
CREATE INDEX idx_posts_user_id    ON posts(user_id)       COMMENT '按发布者查询';
CREATE INDEX idx_posts_sec_id     ON posts(sec_id)        COMMENT '按板块查询';
CREATE INDEX idx_posts_status     ON posts(status)        COMMENT '按状态筛选';
CREATE INDEX idx_posts_pub_time   ON posts(pub_time)      COMMENT '按发布时间排序';
CREATE INDEX idx_posts_hot_score  ON posts(hot_score DESC) COMMENT '按热度排序（降序）';

-- comments 表索引
CREATE INDEX idx_comments_post_id ON comments(post_id)    COMMENT '按帖子查评论';
CREATE INDEX idx_comments_user_id ON comments(user_id)    COMMENT '按评论者查询';

-- reports 表索引
CREATE INDEX idx_reports_post_id   ON reports(post_id)    COMMENT '按被举报帖子查';
CREATE INDEX idx_reports_status    ON reports(status)     COMMENT '按处理状态查';


-- ================================================================
-- 9. 视图 (Views)
-- ================================================================

-- 9.1 热门帖子视图：按热度降序排列
CREATE OR REPLACE VIEW v_hot_posts AS
SELECT  p.post_id, p.title, u.nickname AS author, s.name AS section,
        p.view_count, p.like_count, p.comment_count, p.hot_score,
        p.pub_time
FROM posts p
JOIN users u ON p.user_id = u.user_id
JOIN sections s ON p.sec_id = s.sec_id
WHERE p.status = '正常'
ORDER BY p.hot_score DESC;

-- 9.2 用户活跃度视图
CREATE OR REPLACE VIEW v_user_activity AS
SELECT  u.user_id, u.nickname,
        COUNT(DISTINCT p.post_id)   AS post_count,
        COUNT(DISTINCT c.cmt_id)    AS comment_count,
        COUNT(DISTINCT l.post_id)   AS like_given_count,
        u.reg_time
FROM users u
LEFT JOIN posts p    ON u.user_id = p.user_id AND p.status != '已删除'
LEFT JOIN comments c ON u.user_id = c.user_id
LEFT JOIN likes l    ON u.user_id = l.user_id
GROUP BY u.user_id;


-- ================================================================
-- 10. 触发器 (Triggers)
-- ================================================================

-- 10.1 新增评论 → 更新 posts.comment_count 和 hot_score
DELIMITER //
CREATE TRIGGER trg_after_insert_comment
AFTER INSERT ON comments
FOR EACH ROW
BEGIN
    UPDATE posts
    SET comment_count = comment_count + 1,
        hot_score = view_count * 0.3 + (comment_count + 1) * 0.5 + like_count * 0.2
    WHERE post_id = NEW.post_id;
END//

-- 10.2 删除评论 → 更新 posts.comment_count 和 hot_score
CREATE TRIGGER trg_after_delete_comment
AFTER DELETE ON comments
FOR EACH ROW
BEGIN
    UPDATE posts
    SET comment_count = comment_count - 1,
        hot_score = view_count * 0.3 + (comment_count - 1) * 0.5 + like_count * 0.2
    WHERE post_id = OLD.post_id;
END//

-- 10.3 新增点赞 → 更新 posts.like_count 和 hot_score
CREATE TRIGGER trg_after_insert_like
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count + 1,
        hot_score = view_count * 0.3 + comment_count * 0.5 + (like_count + 1) * 0.2
    WHERE post_id = NEW.post_id;
END//

-- 10.4 取消点赞 → 更新 posts.like_count 和 hot_score
CREATE TRIGGER trg_after_delete_like
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count - 1,
        hot_score = view_count * 0.3 + comment_count * 0.5 + (like_count - 1) * 0.2
    WHERE post_id = OLD.post_id;
END//
DELIMITER ;


-- ================================================================
-- 11. 存储过程 (Stored Procedures)
-- ================================================================

-- 11.1 批量更新所有帖子热度（可用于定时任务）
DELIMITER //
CREATE PROCEDURE sp_update_all_hot_scores()
BEGIN
    UPDATE posts
    SET hot_score = view_count * 0.3 + comment_count * 0.5 + like_count * 0.2
    WHERE status = '正常';
END//

-- 11.2 按板块查询热门帖子
CREATE PROCEDURE sp_get_hot_posts_by_section(IN p_sec_id INT)
BEGIN
    SELECT  p.post_id, p.title, u.nickname AS author,
            p.view_count, p.like_count, p.comment_count, p.hot_score
    FROM posts p
    JOIN users u ON p.user_id = u.user_id
    WHERE p.sec_id = p_sec_id AND p.status = '正常'
    ORDER BY p.hot_score DESC;
END//
DELIMITER ;


-- ================================================================
-- 12. 测试数据 (Sample Data)
-- ================================================================

-- 12.1 板块数据
INSERT INTO sections (name, description, sort_order) VALUES
('二手交易',   '校园二手物品买卖、闲置转让', 1),
('拼车出行',   '拼车、顺风车信息',           2),
('校园兼职',   '校内兼职、实习信息',         3),
('失物招领',   '丢失物品寻找、拾物归还',     4),
('学习资料',   '教材、笔记、复习资料共享',   5),
('生活服务',   '校园生活相关服务信息',       6);

-- 12.2 用户数据
INSERT INTO users (user_id, nickname, wechat_openid, phone, role) VALUES
('2021001', '张三',   'wx_openid_001', '13800001001', '普通'),
('2021002', '李四',   'wx_openid_002', '13800001002', '普通'),
('2021003', '王五',   'wx_openid_003', '13800001003', '普通'),
('2021004', '赵六',   'wx_openid_004', '13800001004', '普通'),
('2021005', '管理员小陈', 'wx_openid_005', '13800001005', '管理员');

-- 12.3 帖子数据
INSERT INTO posts (user_id, sec_id, title, content, contact, status, view_count) VALUES
('2021001', 1, '出二手高数教材，九成新', '大一下学期的高等数学教材，几乎全新，有笔记，30元出', 'QQ:123456', '正常', 120),
('2021002', 2, '周五拼车去武汉站', '周五下午3点南湖出发去武汉站，还有3个位置，每人15', '微信:lisi2021', '正常', 85),
('2021003', 3, '找周末兼职，校内优先', '大二学生，周六日有时间，希望能找校内兼职，工资面议', '电话:13800001003', '正常', 200),
('2021001', 4, '捡到一张校园卡', '在图书馆三楼捡到校园卡，学号2021008，请失主联系', 'QQ:123456', '正常', 300),
('2021004', 5, '计算机组成原理复习笔记', '自己整理的计组复习笔记，涵盖所有考点，5元一份电子版', '微信:zhaoliu2021', '正常', 150),
('2021002', 1, '出售二手电动车', '骑了一年的电动车，电池还很好，800元出，可看车', '电话:13800001002', '正常', 90),
('2021003', 6, '求推荐校内打印店', '哪家打印店价格实惠？求学长学姐推荐', '直接回复即可', '正常', 45),
('2021004', 1, '出四级真题卷', '2024年四级真题卷，全新未做，20元带走', '微信:zhaoliu2021', '已结束', 60),
('2021005', 4, '【管理员】失物招领规范', '请发布失物招领时注明物品特征、丢失地点和联系方式', '-', '正常', 500);

-- 12.4 评论数据
INSERT INTO comments (post_id, user_id, content) VALUES
(1, '2021004', '教材还在吗？我想买'),
(1, '2021001', '还在的，私聊我'),
(3, '2021001', '我也在找兼职，有合适的可以一起'),
(4, '2021005', '已联系失主，感谢同学！'),
(5, '2021002', '笔记能预览一下吗？'),
(2, '2021003', '还有位置吗？我想拼车');

-- 12.5 点赞数据
INSERT INTO likes (post_id, user_id) VALUES
(1, '2021004'), (1, '2021003'),
(3, '2021001'), (3, '2021004'),
(4, '2021002'), (4, '2021003'), (4, '2021005'),
(5, '2021002'),
(9, '2021001'), (9, '2021002'), (9, '2021003'), (9, '2021004');

-- 12.6 收藏数据
INSERT INTO favorites (post_id, user_id) VALUES
(1, '2021004'),
(5, '2021002'),
(9, '2021001');

-- 12.7 举报数据
INSERT INTO reports (post_id, reporter_id, reason, status) VALUES
(6, '2021001', '价格虚高，与实际不符', '待处理');


-- ================================================================
-- 13. 初始化热度值（基于已有测试数据）
-- ================================================================
UPDATE posts
SET like_count = (SELECT COUNT(*) FROM likes WHERE likes.post_id = posts.post_id),
    comment_count = (SELECT COUNT(*) FROM comments WHERE comments.post_id = posts.post_id);

UPDATE posts
SET hot_score = view_count * 0.3 + comment_count * 0.5 + like_count * 0.2
WHERE status = '正常';
