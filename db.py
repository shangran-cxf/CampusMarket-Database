"""数据库连接工具"""
import pymysql

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '040915cxf',
    'database': 'campusmarket',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor,
    'autocommit': True,
}


def get_conn():
    """获取数据库连接"""
    return pymysql.connect(**DB_CONFIG)


def query(sql, params=None):
    """执行查询，返回字典列表"""
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(sql, params)
            return cur.fetchall()
    finally:
        conn.close()


def execute(sql, params=None):
    """执行更新（INSERT/UPDATE/DELETE），返回影响行数"""
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            rows = cur.execute(sql, params)
            conn.commit()
            return rows
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


