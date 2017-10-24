-- 관련 테이블
-- table_package_levelup
-- table_shop_lsit
-- table_shop_basic

-------------------------------------
-- class ServerData_LevelUpPackage
-- @breif 레벨업 패키지 관리
-------------------------------------
ServerData_LevelUpPackage = class({
        m_serverData = 'ServerData',
        m_bDirty = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_LevelUpPackage:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function ckechDirty
-------------------------------------
function ServerData_LevelUpPackage:ckechDirty()
    if self.m_bDirty then
        return
    end

    -- 만료 시간 체크 할 것!
    --self.m_expirationData
    self:setDirty()
end

-------------------------------------
-- function setDirty
-------------------------------------
function ServerData_LevelUpPackage:setDirty()
    self.m_bDirty = true
end

-------------------------------------
-- function isDirty
-------------------------------------
function ServerData_LevelUpPackage:isDirty()
    return self.m_bDirty
end