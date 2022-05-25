local PARENT = ForestObject

-------------------------------------
-- class ForestStuff
-------------------------------------
ForestStuff = class(PARENT, {
        m_tStuffInfo = 'string',
        
        m_ui = 'ForestStuffUI',
        
        m_hasReward = 'bool',
        m_isLock = 'bool',
        m_rewardTime = 'timestamp',
     })

-------------------------------------
-- function init
-------------------------------------
function ForestStuff:init(t_stuff)
    self.m_objectType = 'stuff'
    self:setStuffInfo(t_stuff)
end

-------------------------------------
-- function setStuffInfo
-------------------------------------
function ForestStuff:setStuffInfo(t_stuff)
    self.m_tStuffInfo = t_stuff

    self.m_hasReward = false
    self.m_isLock = true
    self.m_rewardTime = (t_stuff['reward_at'] or 0)/1000

    if (t_stuff['stuff_lv']) then
        self.m_isLock = false
    end

    if self.m_ui then
        self.m_ui.m_tSuffInfo = self.m_tStuffInfo
        self.m_ui:refresh()
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function ForestStuff:initUI()
    self.m_ui = ForestStuffUI(self)
    self.m_rootNode:addChild(self.m_ui.root, 2)
end

-------------------------------------
-- function initAnimator
-------------------------------------
function ForestStuff:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    local res = 'res/bg/dragon_forest/dragon_forest.vrp'
    self.m_animator = MakeAnimator(res)
    if (self.m_animator) then
        local t_stuff_info = self.m_tStuffInfo
        self.m_animator:changeAni(t_stuff_info['stuff_type'] .. '_idle', true)
        self.m_animator:setIgnoreLowEndMode(true)
        self:setPosition(t_stuff_info['x'], t_stuff_info['y'])
        self.m_rootNode:addChild(self.m_animator.m_node)
    end
end

-------------------------------------
-- function update
-------------------------------------
function ForestStuff:update(dt)
    -- 오픈 체크
    if (self.m_isLock) then
        return
    end
 
    -- 보상 있는지 체크
    if (self.m_hasReward) then
        return
    end

    -- 남은시간 출력
    local remain_time = (self.m_rewardTime - ServerTime:getInstance():getCurrentTimestampSeconds())
    if remain_time > 0 then
        self.m_ui:updateTime(remain_time)
    else
        self.m_hasReward = true
        self.m_ui:readyForReward()
    end
end

-------------------------------------
-- function getStuffType
-------------------------------------
function ForestStuff:getStuffType()
    return self.m_tStuffInfo['stuff_type']
end

-------------------------------------
-- function touchStuff
-------------------------------------
function ForestStuff:touchStuff()
	-- 잠금 : 열리지 않음
    if (self.m_isLock) then
        return
    end
    
	local stuff_type = self.m_tStuffInfo['stuff_type']

    -- 재화 수령 가능한 상태
    if (self.m_hasReward) then
        local function finish_cb(t_stuff, t_item_info)
            -- 보상 수령 상태 갱신
            self.m_tStuffInfo['reward_at'] = t_stuff['reward_at']
            self.m_rewardTime = t_stuff['reward_at']/1000
            self.m_hasReward = false
            self.m_ui:resetReward()

            -- 재화 정보 출력
            if (t_item_info) then
                -- 아이콘 표시
                local item_id = t_item_info['item_id']
                local item_cnt = t_item_info['count']

				-- 아이템 획득 토스트 팝
				local t_reward_item = {['item_id'] = item_id, ['count'] = item_cnt}
                local l_reward_item = {}
                table.insert(l_reward_item, t_reward_item)
                local ui_obtain = UI_ObtainToastPopup(l_reward_item)
                ui_obtain.root:setPositionY(100)
                --[[
                
                local parent_node = self.m_ui.root
                local t_param = {
                    ['pos_x'] = self.m_ui.vars['rewardVisual'].m_node:getPositionX(),
                    ['pos_y'] = self.m_ui.vars['rewardVisual'].m_node:getPositionY() + 50,
                    ['scale'] = 0.7
                }
                SensitivityHelper:makeObtainEffect_Big(item_id, item_cnt, parent_node, t_param)
                
                -- 토스트 메세지
                local reward_str = UIHelper:makeItemStr(t_item_info)
                UI_ToastPopup(reward_str)
                --]]
                
            end
        end
        ServerData_Forest:getInstance():request_stuffReward(stuff_type, finish_cb)
        return
    end

    -- 레벨업 UI 오픈
	if (self.m_tStuffInfo['stuff_lv'] < TableForestStuffLevelInfo:getStuffMaxLV(stuff_type)) then
		UI_Forest_StuffLevelupPopup(nil, self)
	end
end

