-- ============================================
-- 校园集市 - 触发器
-- ============================================

-- 0. 创建删除日志表
CREATE TABLE IF NOT EXISTS post_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    title VARCHAR(200),
    user_id VARCHAR(20),
    action VARCHAR(20) DEFAULT 'DELETE',
    deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 1. 点赞时自动 +1
DELIMITER //
CREATE OR REPLACE TRIGGER trg_like_insert
AFTER INSERT ON likes FOR EACH ROW
BEGIN
    UPDATE posts SET like_count = like_count + 1 WHERE post_id = NEW.post_id;
END //

-- 2. 取消点赞自动 -1
CREATE OR REPLACE TRIGGER trg_like_delete
AFTER DELETE ON likes FOR EACH ROW
BEGIN
    UPDATE posts SET like_count = like_count - 1 WHERE post_id = OLD.post_id;
END //

-- 3. 评论时自动 +1
CREATE OR REPLACE TRIGGER trg_comment_insert
AFTER INSERT ON comments FOR EACH ROW
BEGIN
    UPDATE posts SET comment_count = comment_count + 1 WHERE post_id = NEW.post_id;
END //

-- 4. 删除评论时自动 -1
CREATE OR REPLACE TRIGGER trg_comment_delete
AFTER DELETE ON comments FOR EACH ROW
BEGIN
    UPDATE posts SET comment_count = comment_count - 1 WHERE post_id = OLD.post_id;
END //

-- 5. 删除帖子时记录日志
CREATE OR REPLACE TRIGGER trg_post_delete
BEFORE DELETE ON posts FOR EACH ROW
BEGIN
    INSERT INTO post_log(post_id, title, user_id)
    VALUES (OLD.post_id, OLD.title, OLD.user_id);
END //

DELIMITER ;
