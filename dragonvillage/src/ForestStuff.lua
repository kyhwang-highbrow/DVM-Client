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
    self.m_tStuffInfo = t_stuff

    self.m_hasReward = false
    self.m_isLock = true
    self.m_rewardTime = (t_stuff['reward_at'] or 0)/1000

    if (t_stuff['stuff_lv']) then
        self.m_isLock = false
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function ForestStuff:initUI()
    self.m_ui = ForestStuffUI(self.m_tStuffInfo)
    self.m_rootNode:addChild(self.m_ui.root, 2)
end

-------------------------------------
-- function initAnimator
-------------------------------------
function ForestStuff:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    local res = self.m_tStuffInfo['res']
    self.m_animator = MakeAnimator(res)
    if (self.m_animator) then
        self.m_rootNode:addChild(self.m_animator.m_node)

        -- 위치 지정
        self:setPosition(self.m_tStuffInfo['x'], self.m_tStuffInfo['y'])
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
    local remain_time = (self.m_rewardTime - Timer:getServerTime())
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
    if (self.m_isLock) then
        ccdisplay('lock')
        return
    end

    -- 재화 수령 가능한 상태
    if (self.m_hasReward) then
        local stuff_type = self.m_tStuffInfo['stuff_type']
        local function finish_cb(t_stuff)
            -- 상품 수령 팝업
            UI_ToastPopup()
            
            -- 보상 수령 상태 갱신
            self.m_tStuffInfo['reward_at'] = t_stuff['reward_at']
            self.m_rewardTime = t_stuff['reward_at']/1000
            self.m_hasReward = false
            self.m_ui.vars['notiSprite']:setVisible(false)
        end
        ServerData_Forest:getInstance():request_stuffReward(stuff_type, finish_cb)
        return
    end

    -- 레벨업 UI 오픈
    UI_Forest_StuffLevelupPopup(self)
end