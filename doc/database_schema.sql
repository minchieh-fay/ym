-- 线下组局平台数据库建表脚本
-- 数据库: PostgreSQL 15+
-- 字符集: UTF-8
-- 时区: Asia/Shanghai

-- 创建数据库
CREATE DATABASE group_activity_platform 
WITH ENCODING 'UTF8' 
LC_COLLATE 'zh_CN.UTF-8' 
LC_CTYPE 'zh_CN.UTF-8' 
TEMPLATE template0;

-- 使用数据库
\c group_activity_platform;

-- 创建扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 1. 用户相关表

-- 1.1 用户表
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    avatar_url VARCHAR(500),
    gender TINYINT DEFAULT 0, -- 0-未知, 1-男, 2-女
    birthday DATE,
    city VARCHAR(50),
    status TINYINT DEFAULT 1, -- 0-禁用, 1-正常, 2-封禁
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- 用户表索引
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_city ON users(city);
CREATE INDEX idx_users_created_at ON users(created_at);

-- 1.2 用户兴趣标签表
CREATE TABLE user_interests (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    interest_tag VARCHAR(20) NOT NULL, -- 美食, 桌游, 户外, 运动, 咖啡等
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_interests_user_id ON user_interests(user_id);
CREATE INDEX idx_user_interests_tag ON user_interests(interest_tag);

-- 1.3 用户会员信息表
CREATE TABLE user_memberships (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    membership_type TINYINT NOT NULL, -- 1-月度, 2-季度, 3-年度, 4-单次体验
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    status TINYINT DEFAULT 1, -- 0-过期, 1-有效
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_memberships_user_id ON user_memberships(user_id);
CREATE INDEX idx_user_memberships_status ON user_memberships(status);
CREATE INDEX idx_user_memberships_dates ON user_memberships(start_date, end_date);

-- 2. 活动相关表

-- 2.1 活动类型表
CREATE TABLE activity_types (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL, -- 晚餐, 剧本杀, 狼人杀, 下午茶, 徒步等
    icon_url VARCHAR(500),
    sort_order INT DEFAULT 0,
    status TINYINT DEFAULT 1, -- 0-禁用, 1-启用
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入默认活动类型
INSERT INTO activity_types (name, sort_order) VALUES 
('晚餐', 1), 
('剧本杀', 2), 
('狼人杀', 3), 
('下午茶', 4), 
('徒步', 5),
('户外', 6),
('运动', 7),
('咖啡', 8);

-- 2.2 活动表
CREATE TABLE activities (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    cover_url VARCHAR(500),
    activity_type_id BIGINT NOT NULL REFERENCES activity_types(id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    location VARCHAR(200) NOT NULL,
    address VARCHAR(500),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    max_participants INT NOT NULL DEFAULT 4,
    current_participants INT DEFAULT 0,
    fee_type TINYINT DEFAULT 1, -- 1-AA制, 2-免费, 3-固定费用
    fee_amount DECIMAL(10, 2) DEFAULT 0,
    fee_description VARCHAR(200),
    status TINYINT DEFAULT 1, -- 0-草稿, 1-招募中, 2-已满员, 3-已结束, 4-已取消
    is_member_only BOOLEAN DEFAULT FALSE,
    created_by BIGINT NOT NULL, -- 创建者ID(运营人员)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- 活动表索引
CREATE INDEX idx_activities_type ON activities(activity_type_id);
CREATE INDEX idx_activities_start_time ON activities(start_time);
CREATE INDEX idx_activities_status ON activities(status);
CREATE INDEX idx_activities_location ON activities(latitude, longitude);
CREATE INDEX idx_activities_member_only ON activities(is_member_only);
CREATE INDEX idx_activities_created_at ON activities(created_at);
CREATE INDEX idx_activities_query ON activities(activity_type_id, status, start_time, is_member_only);

-- 2.3 活动报名表
CREATE TABLE activity_registrations (
    id BIGSERIAL PRIMARY KEY,
    activity_id BIGINT NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status TINYINT DEFAULT 1, -- 0-已取消, 1-待审核, 2-已通过, 3-已拒绝
    registration_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by BIGINT,
    rejection_reason VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(activity_id, user_id)
);

CREATE INDEX idx_activity_registrations_activity ON activity_registrations(activity_id);
CREATE INDEX idx_activity_registrations_user ON activity_registrations(user_id);
CREATE INDEX idx_activity_registrations_status ON activity_registrations(status);
CREATE INDEX idx_activity_registrations_user_activity ON activity_registrations(user_id, activity_id, status);

-- 3. 聊天相关表

-- 3.1 聊天室表
CREATE TABLE chat_rooms (
    id BIGSERIAL PRIMARY KEY,
    activity_id BIGINT NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(200),
    status TINYINT DEFAULT 1, -- 0-已关闭, 1-正常
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_rooms_activity ON chat_rooms(activity_id);

-- 3.2 聊天室成员表
CREATE TABLE chat_room_members (
    id BIGSERIAL PRIMARY KEY,
    chat_room_id BIGINT NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_read_at TIMESTAMP,
    UNIQUE(chat_room_id, user_id)
);

CREATE INDEX idx_chat_room_members_room ON chat_room_members(chat_room_id);
CREATE INDEX idx_chat_room_members_user ON chat_room_members(user_id);

-- 3.3 聊天消息表
CREATE TABLE chat_messages (
    id BIGSERIAL PRIMARY KEY,
    chat_room_id BIGINT NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message_type TINYINT DEFAULT 1, -- 1-文本, 2-图片, 3-表情
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    status TINYINT DEFAULT 1, -- 0-已删除, 1-正常
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_messages_room ON chat_messages(chat_room_id);
CREATE INDEX idx_chat_messages_sender ON chat_messages(sender_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);
CREATE INDEX idx_messages_room_time ON chat_messages(chat_room_id, created_at DESC);

-- 3.4 好友关系表
CREATE TABLE user_friends (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    friend_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status TINYINT DEFAULT 1, -- 0-已删除, 1-正常
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, friend_id),
    CHECK(user_id != friend_id)
);

CREATE INDEX idx_user_friends_user ON user_friends(user_id);
CREATE INDEX idx_user_friends_friend ON user_friends(friend_id);

-- 4. 支付相关表

-- 4.1 订单表
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_no VARCHAR(32) UNIQUE NOT NULL,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_type TINYINT NOT NULL, -- 1-活动报名, 2-会员购买
    activity_id BIGINT REFERENCES activities(id) ON DELETE SET NULL,
    membership_type TINYINT, -- 会员类型(当order_type=2时)
    amount DECIMAL(10, 2) NOT NULL,
    status TINYINT DEFAULT 1, -- 0-已取消, 1-待支付, 2-已支付, 3-已退款
    payment_method TINYINT, -- 1-微信支付, 2-支付宝
    payment_time TIMESTAMP,
    refund_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_no ON orders(order_no);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_type ON orders(order_type);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- 4.2 支付记录表
CREATE TABLE payment_records (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    payment_no VARCHAR(64) UNIQUE NOT NULL,
    third_party_no VARCHAR(64),
    amount DECIMAL(10, 2) NOT NULL,
    status TINYINT DEFAULT 1, -- 0-失败, 1-成功, 2-处理中
    payment_method TINYINT NOT NULL,
    callback_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payment_records_order ON payment_records(order_id);
CREATE INDEX idx_payment_records_payment_no ON payment_records(payment_no);
CREATE INDEX idx_payment_records_third_party ON payment_records(third_party_no);

-- 5. 管理相关表

-- 5.1 举报记录表
CREATE TABLE reports (
    id BIGSERIAL PRIMARY KEY,
    reporter_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reported_user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    reported_message_id BIGINT REFERENCES chat_messages(id) ON DELETE CASCADE,
    report_type TINYINT NOT NULL, -- 1-用户, 2-消息
    reason TINYINT NOT NULL, -- 1-骚扰, 2-不当言论, 3-虚假信息, 4-其他
    description TEXT,
    status TINYINT DEFAULT 1, -- 0-已处理, 1-待处理, 2-已忽略
    handled_by BIGINT,
    handled_at TIMESTAMP,
    handle_result VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reports_reporter ON reports(reporter_id);
CREATE INDEX idx_reports_reported_user ON reports(reported_user_id);
CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_created_at ON reports(created_at);

-- 5.2 系统配置表
CREATE TABLE system_configs (
    id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(50) UNIQUE NOT NULL,
    config_value TEXT NOT NULL,
    description VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入默认配置
INSERT INTO system_configs (config_key, config_value, description) VALUES 
('max_activity_participants', '8', '活动最大参与人数'),
('min_activity_participants', '2', '活动最小参与人数'),
('activity_advance_hours', '24', '活动提前报名小时数'),
('member_monthly_price', '12800', '月度会员价格(分)'),
('member_quarterly_price', '28800', '季度会员价格(分)'),
('member_yearly_price', '69800', '年度会员价格(分)'),
('member_single_price', '9800', '单次体验价格(分)'),
('platform_commission_rate', '0.05', '平台佣金比例'),
('chat_message_retention_days', '30', '聊天消息保留天数');

-- 6. 数据约束

-- 6.1 活动参与人数约束
ALTER TABLE activities ADD CONSTRAINT chk_participants 
CHECK (current_participants <= max_participants);

-- 6.2 订单金额约束
ALTER TABLE orders ADD CONSTRAINT chk_amount_positive 
CHECK (amount > 0);

-- 6.3 会员时间约束
ALTER TABLE user_memberships ADD CONSTRAINT chk_membership_dates 
CHECK (end_date > start_date);

-- 6.4 活动时间约束
ALTER TABLE activities ADD CONSTRAINT chk_activity_time 
CHECK (end_time IS NULL OR end_time > start_time);

-- 7. 触发器

-- 7.1 更新活动参与人数触发器
CREATE OR REPLACE FUNCTION update_activity_participants()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.status = 2 THEN
        UPDATE activities 
        SET current_participants = current_participants + 1 
        WHERE id = NEW.activity_id;
    ELSIF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        IF NEW.status = 2 AND OLD.status != 2 THEN
            UPDATE activities 
            SET current_participants = current_participants + 1 
            WHERE id = NEW.activity_id;
        ELSIF OLD.status = 2 AND NEW.status != 2 THEN
            UPDATE activities 
            SET current_participants = current_participants - 1 
            WHERE id = NEW.activity_id;
        END IF;
    ELSIF TG_OP = 'DELETE' AND OLD.status = 2 THEN
        UPDATE activities 
        SET current_participants = current_participants - 1 
        WHERE id = OLD.activity_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_activity_participants
    AFTER INSERT OR UPDATE OR DELETE ON activity_registrations
    FOR EACH ROW EXECUTE FUNCTION update_activity_participants();

-- 7.2 自动创建聊天室触发器
CREATE OR REPLACE FUNCTION create_chat_room_when_activity_full()
RETURNS TRIGGER AS $$
BEGIN
    -- 当活动满员时自动创建聊天室
    IF NEW.status = 2 AND OLD.status != 2 THEN
        -- 检查是否已经满员
        IF (SELECT current_participants FROM activities WHERE id = NEW.activity_id) 
           >= (SELECT max_participants FROM activities WHERE id = NEW.activity_id) THEN
            -- 创建聊天室
            INSERT INTO chat_rooms (activity_id, name, description)
            SELECT 
                NEW.activity_id,
                a.title || ' 聊天室',
                '活动成局后的交流群'
            FROM activities a 
            WHERE a.id = NEW.activity_id;
            
            -- 添加所有已通过审核的参与者到聊天室
            INSERT INTO chat_room_members (chat_room_id, user_id)
            SELECT 
                cr.id,
                ar.user_id
            FROM chat_rooms cr
            JOIN activity_registrations ar ON ar.activity_id = cr.activity_id
            WHERE cr.activity_id = NEW.activity_id 
            AND ar.status = 2;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_chat_room
    AFTER UPDATE ON activity_registrations
    FOR EACH ROW EXECUTE FUNCTION create_chat_room_when_activity_full();

-- 8. 视图

-- 8.1 用户活动统计视图
CREATE VIEW user_activity_stats AS
SELECT 
    u.id as user_id,
    u.nickname,
    COUNT(DISTINCT ar.activity_id) as total_activities,
    COUNT(DISTINCT CASE WHEN ar.status = 2 THEN ar.activity_id END) as successful_activities,
    COUNT(DISTINCT uf.friend_id) as friend_count
FROM users u
LEFT JOIN activity_registrations ar ON u.id = ar.user_id
LEFT JOIN user_friends uf ON u.id = uf.user_id AND uf.status = 1
GROUP BY u.id, u.nickname;

-- 8.2 活动统计视图
CREATE VIEW activity_stats AS
SELECT 
    a.id as activity_id,
    a.title,
    a.activity_type_id,
    at.name as activity_type_name,
    a.start_time,
    a.current_participants,
    a.max_participants,
    a.status,
    COUNT(ar.id) as total_registrations,
    COUNT(CASE WHEN ar.status = 2 THEN 1 END) as approved_registrations
FROM activities a
LEFT JOIN activity_types at ON a.activity_type_id = at.id
LEFT JOIN activity_registrations ar ON a.id = ar.activity_id
GROUP BY a.id, a.title, a.activity_type_id, at.name, a.start_time, 
         a.current_participants, a.max_participants, a.status;

-- 9. 存储过程

-- 9.1 用户注册存储过程
CREATE OR REPLACE FUNCTION register_user(
    p_phone VARCHAR(20),
    p_nickname VARCHAR(50),
    p_interests TEXT[]
)
RETURNS BIGINT AS $$
DECLARE
    v_user_id BIGINT;
    v_interest VARCHAR(20);
BEGIN
    -- 插入用户
    INSERT INTO users (phone, nickname) 
    VALUES (p_phone, p_nickname) 
    RETURNING id INTO v_user_id;
    
    -- 插入兴趣标签
    FOREACH v_interest IN ARRAY p_interests
    LOOP
        INSERT INTO user_interests (user_id, interest_tag) 
        VALUES (v_user_id, v_interest);
    END LOOP;
    
    RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

-- 9.2 活动报名存储过程
CREATE OR REPLACE FUNCTION register_activity(
    p_user_id BIGINT,
    p_activity_id BIGINT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_count INT;
    v_max_count INT;
    v_existing_count INT;
BEGIN
    -- 检查活动是否存在且可报名
    SELECT current_participants, max_participants 
    INTO v_current_count, v_max_count
    FROM activities 
    WHERE id = p_activity_id AND status = 1;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- 检查是否已满员
    IF v_current_count >= v_max_count THEN
        RETURN FALSE;
    END IF;
    
    -- 检查用户是否已报名
    SELECT COUNT(*) INTO v_existing_count
    FROM activity_registrations 
    WHERE user_id = p_user_id AND activity_id = p_activity_id;
    
    IF v_existing_count > 0 THEN
        RETURN FALSE;
    END IF;
    
    -- 插入报名记录
    INSERT INTO activity_registrations (user_id, activity_id, status) 
    VALUES (p_user_id, p_activity_id, 1);
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- 10. 权限设置

-- 创建应用用户
CREATE USER app_user WITH PASSWORD 'your_secure_password';
GRANT CONNECT ON DATABASE group_activity_platform TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- 创建只读用户(用于报表)
CREATE USER readonly_user WITH PASSWORD 'readonly_password';
GRANT CONNECT ON DATABASE group_activity_platform TO readonly_user;
GRANT USAGE ON SCHEMA public TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;

-- 完成建表
COMMENT ON DATABASE group_activity_platform IS '线下组局平台数据库';
