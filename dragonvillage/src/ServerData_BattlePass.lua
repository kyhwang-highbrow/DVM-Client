-------------------------------------
-- class ServerData_BattlePass
-- @brief 
-------------------------------------
--[[
    --Server 
    {
        ['121701']={
                    ['normal']={ ['0']=1;};
                    ['premium']={ };
                    ['cur_level']=0;
                    ['end_date']=1618758000001;
                    ['is_premium']=0;
                    ['start_date']=1614930387833;
                    ['cur_exp']=0;
        };
    }

    --Table
    { 
        ['level']=0;
        ['id']=121701100;
        ['type']='normal';
        ['item']='700002;100000';
        ['exp']=0;
        ['pid']=121701;
    };
]]

ServerData_BattlePass = class({
        m_serverData = 'ServerData',

        m_battlePassTable = 'TableBattlePass',
        -- StructBattlePassInfo Map
        -- keyword : product id
        m_passInfoData = 'map',
        m_normalKey = '',
        m_premiumKey = '',
    })

REWARD_STATUS = {
    NOT_AVAILABLE = 0,  -- 0 -- 진행 중
    POSSIBLE = 1,       -- 1 -- 보상 수령 가능 상태
    RECEIVED = 2,       -- 2 -- 보상 수령 완료
}    
    
-------------------------------------
-- function init
-------------------------------------
function ServerData_BattlePass:init(server_data)
    self.m_serverData = server_data
    self.m_battlePassTable = TableBattlePass()
    self.m_passInfoData = {}
    self.m_normalKey = 'normal'
    self.m_premiumKey = 'premium'
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Server
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

-------------------------------------
-- function isPurchased
-- 결제 여부
-------------------------------------
function ServerData_BattlePass:isPurchased(pass_id)
    local t_data = self.m_passInfoData[tostring(pass_id)]
    if(not t_data) then return false end
    if(not t_data['is_premium']) then return false end
    if(t_data['is_premium'] ~= 1) then return false end

    -- 1:결제O or 0:결제X
    return true
end

-------------------------------------
-- function isPurchased
-- 결제 여부
-------------------------------------
function ServerData_BattlePass:isProduct(product_id)
    local t_data = self.m_passInfoData[tostring(product_id)]
    
    if(not t_data) then return false end

    return true
end

-------------------------------------
-- function getUserExp
-- 현재 유저 경험치
-------------------------------------
function ServerData_BattlePass:getUserExp(pass_id)
    local key = tostring(pass_id)
    return self.m_passInfoData[key]['cur_exp']
end

-------------------------------------
-- function getUserLevel
-- 현재 유저 레벨
-------------------------------------
function ServerData_BattlePass:getUserLevel(pass_id)
    local key = tostring(pass_id)

    return self.m_passInfoData[key]['cur_level']
end

function ServerData_BattlePass:GetRewardStatus(pass_id, type_key, index)
    
    local key = tostring(pass_id)
    local rewardsStatus = self.m_passInfoData[key][type_key]
    local level = tostring(self:getLevelFromIndex(pass_id, index))

    return rewardsStatus[level]
end

-------------------------------------
-- function isExistAvailableReward
-- 
-------------------------------------
function ServerData_BattlePass:isExistAvailableReward(pass_id, type_key)

    if(type_key == self.m_premiumKey) and (not self:isPurchased(pass_id)) then
        return false
    end

    local key = tostring(pass_id)

    for k, v in pairs(self.m_passInfoData[key][type_key]) do
        if(v == 1) then return true end
    end

    return false
end

--functino ServerData_BattlePass:isExistAvailableReward
function ServerData_BattlePass:isVisible_battlePassNoti()

    for key, table in pairs(self.m_passInfoData) do
        if self:isExistAvailableReward(key, self.m_normalKey) or self:isExistAvailableReward(key, self.m_premiumKey) then
            return true
        end
    end

    return false
end



--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Table
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
function ServerData_BattlePass:getItemInfo(pass_id, index)

end

-------------------------------------
-- function getNormalList
-- 일반보상 리스트
-------------------------------------
function ServerData_BattlePass:getNormalList(pass_id)
    return self.m_battlePassTable:getNormalRewardList(pass_id)
end

-------------------------------------
-- function getPremiumList
-- 패스보상 리스트
-------------------------------------
function ServerData_BattlePass:getPremiumList(pass_id)
    return self.m_battlePassTable:getPremiumRewardList(pass_id)
end



-------------------------------------
-- function getMaxExp
-- 패스 맥스 경험치
-------------------------------------
function ServerData_BattlePass:getMaxExp(pass_id)
    return self.m_battlePassTable:getMaxExp(pass_id)
end

-------------------------------------
-- function getMaxLevel
-- 달성할 수 있는 맥스 레벨
-------------------------------------
function ServerData_BattlePass:getMaxLevel(pass_id)
    return self.m_battlePassTable:getMaxLevel(pass_id)
end

-------------------------------------
-- function getLevelNum
-- CellUI 생성을 위한 레벨 갯수
-- 레벨이 0부터 시작시 + 1 을 리턴
-------------------------------------
function ServerData_BattlePass:getLevelNum(pass_id)
    if(self.m_battlePassTable:getMinLevel(pass_id) == 0) then
        return self.m_battlePassTable:getMaxLevel(pass_id) + 1
    else
        return self.m_battlePassTable:getMaxLevel(pass_id)
    end
end

function ServerData_BattlePass:getMinLevel(pass_id)
    return self.m_battlePassTable:getMinLevel(pass_id)
end

-------------------------------------
-- function getExpPerLevel
-- 레벨업에 필요한 경험치
-------------------------------------
function ServerData_BattlePass:getRequiredExpPerLevel(pass_id)
    return self.m_battlePassTable:getExpPerLevel(pass_id)
end

function ServerData_BattlePass:getNormalItemInfo(pass_id, index)
    return self.m_battlePassTable:getNormalItemInfo(pass_id, index)
end
    

function ServerData_BattlePass:getPremiumItemInfo(pass_id, index)
    return self.m_battlePassTable:getPremiumItemInfo(pass_id, index)
end

function ServerData_BattlePass:getLevelFromIndex(pass_id, index)
    return self.m_battlePassTable:getLevelFromIndex(pass_id, index)
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// 
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

-------------------------------------
-- function getExp
-- 현재 유저 경험치
-------------------------------------
-- TODO (YOUNGJIN) : 경험치 관련 해서 이름들이 알아보기 힘듬.
function ServerData_BattlePass:getUserExpPerLevel(pass_id)
    return self:getUserExp(pass_id) % self:getRequiredExpPerLevel(pass_id)
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// 
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////




-- getter, setter


-------------------------------------
-- function getRewardedNormalList
-- 받은 일반보상 리스트
-------------------------------------
function ServerData_BattlePass:getRewardedNormalList(pass_id)
    local key = tostring(pass_id)

    return self.m_passInfoData[key]['normal']
end

-------------------------------------
-- function getRewardedPremiumList
-- 받은 패스보상 리스트
-------------------------------------
function ServerData_BattlePass:getRewardedPremiumList(pass_id)
    local key = tostring(pass_id)

    return self.m_passInfoData[key]['premium']
end



-------------------------------------
-- function getRemainTimeStr
-- 남은 시간
-------------------------------------
function ServerData_BattlePass:getRemainTimeStr(pass_id)
    local key = tostring(pass_id)
    local curr_time = Timer:getServerTime()
    local start_time = self.m_passInfoData[key]['start_date']
    start_time = start_time and (tonumber(start_time) / 1000) or 0

    local end_time = self.m_passInfoData[key]['end_date']
    end_time = end_time and (tonumber(end_time) / 1000) or 0

    local str = ''
    if (start_time <= curr_time) and (curr_time <= end_time) then
        local time = (end_time - curr_time)
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true))

    else
        str = ''
    end

    return str
end




-- server communication
-------------------------------------
-- function request_battlePassInfo
-------------------------------------
function ServerData_BattlePass:request_battlePassInfo(finish_cb, fail_cb)
    -- 테이블 정보 한번 업뎃해주기
    self.m_battlePassTable:updateTableMap()

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:updateBattlePassInfo(ret['battle_pass_info'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/battle_pass/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function updateBattlePassInfo
-- 전체 정보 업데이트
-------------------------------------
function ServerData_BattlePass:updateBattlePassInfo(data)
    self.m_passInfoData = {}

    if (not data) then return self.m_passInfoData end

    for id, tData in pairs(data) do
        if (tData) then
            self.m_passInfoData[tostring(id)] = StructBattlePassInfo(tData)
        end
    end
end


-------------------------------------
-- function request_reward
-------------------------------------
function ServerData_BattlePass:request_reward(pid, type, level, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid') 

    -- 성공 콜백
    local function success_cb(ret)
        self:update_reward(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/battle_pass/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('pid', pid)
    --  normal, premium, all
    ui_network:setParam('type', type)
    ui_network:setParam('level', level)
    
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function update_battlePassReqward
-- 전체 정보 업데이트
-------------------------------------
function ServerData_BattlePass:update_reward(data)
    if(not data) then return self.m_passInfoData end

     local info_table = data['battle_pass_info']
    local pid = tostring(info_table['pid'])

    self.m_passInfoData[pid]['normal']  = info_table['n_level_info']
    self.m_passInfoData[pid]['premium'] = info_table['p_level_info']
    self.m_passInfoData[pid]['end_date'] = info_table['end_date']
    --self.m_passInfoData[pid]['mail_item_info'] = data['mail_item_info']
end

-- 1:2 -- 1단계 보상 수령 완료
-- 2:1 -- 2단계 보상 수령 가능 상태
-- 3:0 -- 3간계 진행 중


-- level:0, type:all 로 요청 시 모든 보상 수령 요청
function ServerData_BattlePass:request_allRewards(pid, type, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid') 

    -- 성공 콜백
    local function success_cb(ret)
        self:update_reward(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/battle_pass/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('pid', pid)
    --  normal, premium, all
    ui_network:setParam('type', type)
    ui_network:setParam('level', -1)

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

function ServerData_BattlePass:openBattlePassPopup(close_cb)
    local function coroutine_function(dt)
        local co = CoroutineHelper()
        --co:setBlockPopup()

        co:work('# 배틀패스 정보 받는중')
        self:request_battlePassInfo(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        co:close()

        local is_opend, idx, ui = UINavigatorDefinition:findOpendUI('UI_BattlePassPopup')

        if (is_opend == true) then
            UINavigatorDefinition:closeUIList(idx)
            return
        end

        local ui = UI_BattlePassPopup()

        if(close_cb) then
            ui:setCloseCB(close_cb)
        end
    end

    Coroutine(coroutine_function, "BattlePass Popup Coroutine")
end