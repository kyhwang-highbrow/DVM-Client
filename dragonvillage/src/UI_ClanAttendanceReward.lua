local PARENT = UI

-------------------------------------
-- class UI_ClanAttendanceReward
-------------------------------------
UI_ClanAttendanceReward = class(PARENT, {
        m_tRewardInfo = 'table',
        m_lastAttdCnt = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanAttendanceReward:init(t_reward_info, attd_cnt)
    self.m_tRewardInfo = t_reward_info
    self.m_lastAttdCnt = attd_cnt

    local vars = self:load('clan_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_ClanAttendanceReward'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanAttendanceReward')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- 토스트 메시지 띄우기용
    local t_ret = {['new_mail']=true}
    ItemObtainResult(t_ret)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanAttendanceReward:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanAttendanceReward:initUI()
    local vars = self.vars

    -- 전날 출석 인원수 출력
    local str = Str('{1}명 출석', self.m_lastAttdCnt)
    vars['attendanceLabel']:setString(str)

    -- 보상 받을 아이템 리스트 아이콘 생성
    local icon_list = {}
    for i,v in ipairs(self.m_tRewardInfo or {}) do
        local count = v['count']
        local item_id = v['item_id']
        local item_card = UI_ItemCard(item_id, count)
        table.insert(icon_list, item_card)
    end

    -- 아이템 아이콘 위치 정렬
    local scale = (120 / 150)
    local width = 150 * scale
    local l_pos = getSortPosList(width + 5, table.count(icon_list))
    for i,v in ipairs(icon_list) do
        vars['rewardNode']:addChild(v.root)
        v.root:setScale(scale)
        v.root:setPositionX(l_pos[i])
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanAttendanceReward:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanAttendanceReward:refresh()
    local vars = self.vars
end