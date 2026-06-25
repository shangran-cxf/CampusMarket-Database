-- ============================================
-- 校园集市 - 存储过程
-- ============================================

-- 1. 获取热门帖子（按hot_score排序）
DELIMITER //
CREATE OR REPLACE PROCEDURE sp_hot_posts(IN top_n INT)
BEGIN
    SELECT p.post_id, p.title, s.name AS section_name,
           p.view_count, p.like_count, p.comment_count, p.hot_score
    FROM posts p
    JOIN sections s ON p.sec_id = s.sec_id
    WHERE p.status = '正常'
    ORDER BY p.hot_score DESC
    LIMIT top_n;
END //

-- 2. 板块统计（每个板块的帖子数、浏览量、点赞数）
CREATE OR REPLACE PROCEDURE sp_section_stats()
BEGIN
    SELECT s.name AS 板块,
           COUNT(p.post_id) AS 帖子数,
           IFNULL(SUM(p.view_count), 0) AS 总浏览量,
           IFNULL(SUM(p.like_count), 0) AS 总点赞数
    FROM sections s
    LEFT JOIN posts p ON s.sec_id = p.sec_id
    GROUP BY s.sec_id, s.name
    ORDER BY 帖子数 DESC;
END //

-- 3. 用户活跃度统计
CREATE OR REPLACE PROCEDURE sp_user_activity(IN uid VARCHAR(20))
BEGIN
    SELECT '发帖' AS 行为, COUNT(*) AS 次数 FROM posts WHERE user_id = uid
    UNION ALL
    SELECT '评论', COUNT(*) FROM comments WHERE user_id = uid
    UNION ALL
    SELECT '点赞', COUNT(*) FROM likes WHERE user_id = uid;
END //

-- 4. 根据关键词搜索帖子
CREATE OR REPLACE PROCEDURE sp_search_posts(IN keyword VARCHAR(100))
BEGIN
    SELECT p.post_id, p.title, s.name AS section_name,
           p.content, p.view_count, p.pub_time
    FROM posts p
    JOIN sections s ON p.sec_id = s.sec_id
    WHERE p.title LIKE CONCAT('%', keyword, '%')
       OR p.content LIKE CONCAT('%', keyword, '%')
    ORDER BY p.pub_time DESC;
END //

-- 5. 更新帖子热度分（view*0.3 + like*0.5 + comment*0.2）
CREATE OR REPLACE PROCEDURE sp_refresh_hot_score(IN pid INT)
BEGIN
    UPDATE posts
    SET hot_score = view_count * 0.3 + like_count * 0.5 + comment_count * 0.2
    WHERE post_id = pid;
END //

DELIMITER ;
