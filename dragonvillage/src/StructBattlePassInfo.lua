local PARENT = Structure

-------------------------------------
-- class StructBattlePassInfo
-- @brief 
-------------------------------------
StructBattlePassInfo = class(PARENT, {
        -- 서버에서 받음
        normal = 'table',
        premium = 'table',
        cur_level = 'number',
        end_date = 'TimeStamp',
        cur_exp = 'number',
        start_date = 'TimeStamp',
        is_premium = 'boolean',
    })

local THIS = StructBattlePassInfo

-------------------------------------
-- function getThis
-------------------------------------
function StructBattlePassInfo:getThis()
    return THIS
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructBattlePassInfo:getClassName()
    return 'StructBattlePassInfo'
end
-------------------------------------
-- function init
-------------------------------------
function StructBattlePassInfo:init(data)
end

-------------------------------------
-- function updateInfo
-- 전체 데이터 업뎃
-------------------------------------
function StructBattlePassInfo:updateInfo(data)
end

-------------------------------------
-- function getRewardList
-------------------------------------
function StructBattlePassInfo:getRewardList(product_id)
end

-------------------------------------
-- function getExp
-- curExp, maxExp 한꺼번에 반환해도 됨
-------------------------------------
function StructBattlePassInfo:getExp()
end


local THIS = StructBattlePassInfo
