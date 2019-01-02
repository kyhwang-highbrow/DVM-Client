local PARENT = UI

-------------------------------------
-- class UI_CapsuleBoxTodayInfoPopup
-------------------------------------
UI_CapsuleBoxTodayInfoPopup = class(PARENT,{
		
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBoxTodayInfoPopup:init()
	local vars = self:load('event_capsule_box_schedule.ui')
	UIManager:open(self, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CapsuleBoxTodayInfoPopup')

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBoxTodayInfoPopup:initUI()
	local vars = self.vars
    local capsulebox_data = g_capsuleBoxData:getCapsuleBoxInfo()
    vars['rotationTitleLabel']:setString(capsulebox_data['first']:getCapsuleTitle())

    -- 전설 캡슐 뽑기 리스트
    local rank = 1
    local l_reward = capsulebox_data['first']:getRankRewardList(rank)
    local first_dragon_attr
    for idx, struct_reward in ipairs(l_reward) do
        -- 드래곤 아이디로 리스트 아이템 생성
        local dragon_id = tonumber(struct_reward['item_id']) - 640000 - (10000)
        local today_dragon_card = UI_CapsuleBoxTodayListItem(dragon_id)
        if (vars['itemNode' .. idx]) then
            vars['itemNode' .. idx]:addChild(today_dragon_card.root)
        end

        --첫 번째 드래곤 속성 저장
        if (idx == 1) then
            first_dragon_attr = TableDragon:getDragonAttr(dragon_id)
        end
        idx = idx + 1
    end

    --첫 번째 드래곤 속성으로 배경 생성
    local animator = ResHelper:getUIDragonBG(first_dragon_attr, 'idle')
    vars['bgNode']:addChild(animator.m_node)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBoxTodayInfoPopup:initButton()
	local vars = self.vars
	
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBoxTodayInfoPopup:refresh()
	local vars = self.vars

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_CapsuleBoxTodayInfoPopup:click_closeBtn()
    self:close()
end


--@CHECK
UI:checkCompileError(UI_CapsuleBoxTodayInfoPopup)
