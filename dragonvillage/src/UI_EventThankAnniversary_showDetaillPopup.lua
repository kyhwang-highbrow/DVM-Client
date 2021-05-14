local PARENT = UI

-------------------------------------
-- class UI_EventThankAnniversary_showDetaillPopup
-------------------------------------
UI_EventThankAnniversary_showDetaillPopup = class(PARENT, {
	m_reward_num = 'number',

	m_rewardCb = 'function',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:init(reward_num, reward_cb)
    local vars = self:load('event_thanks_anniversary_popup_01.ui')
	UIManager:open(self, UIManager.POPUP)	
	self.m_rewardCb = reward_cb

    self.m_uiName = 'UI_EventThankAnniversary_showDetaillPopup'

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventThankAnniversary_showDetaillPopup')	

	self.m_reward_num = reward_num

    self:initUI()
    self:initButton()
    self:refresh()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:initUI()
    local vars = self.vars

    local reward_label
    local item_card_1
    local item_card_2
    local item_label_1
    local item_label_2
    local l_item_str
    local dsc_label 
    
    -- 신규 유저용 선물
    if (self.m_reward_num == 1) then
        reward_label = '신규 유저 추천!'
        item_card_1 = UI_ItemCard(700001, 5000)
        item_card_2 = UI_ItemCard(700612)
        item_label_1 = Str('다이아 5,000개')
        item_label_2 = '전설 추천\n드래곤 선택권'
        dsc_label = '해당 드래곤 중 한 마리를 선택하여 소환할 수 있습니다.'
                
        local item_list_str = TablePickDragon:getCustomList(700612)-- 드래곤 내용물
        l_item_str = pl.stringx.split(item_list_str, ',')
		
		vars['dragonInfoBtn']:setVisible(true)
    -- 기존 유저용 선물
    else
        reward_label = '베테랑 유저 추천!'
        item_card_1 = UI_ItemCard(700001, 5000)
        item_card_2 = UI_ItemCard(700701)   -- 성장재료 선택권
        item_label_1 = Str('다이아 5,000개')
        item_label_2 = '성장 재료\n선택권'
        dsc_label = '위 아이템 중 하나를 선택해 받을 수 있습니다.'

        local table_pick_item = TABLE:get('table_pick_item')
		local t_pick_item = table_pick_item[700701]
		local item_str = t_pick_item['item_id']
        l_item_str = pl.stringx.split(item_str, ',')
    end

    -- 제목
    vars['rewardLabel']:setString(Str(reward_label))

    -- 보상 카드 1
    if (item_card_1) then
        vars['itemNode1']:addChild(item_card_1.root)
    end

    -- 보상 카드 2
    if (item_card_2) then
        vars['itemNode2']:addChild(item_card_2.root)
    end

    -- 보상 이름 1,2
    vars['itemLabel1']:setString(Str(item_label_1))
    vars['itemLabel2']:setString(Str(item_label_2))
    
    -- 보상 설명
    vars['dscLabel']:setString(Str(dsc_label))

    -- 보상 카드 아이템
    local l_pos = getPosXForCenterSortting(500, -200, #l_item_str, 82) -- background_width, start_pos, count, list_item_width
    for i, content_str in ipairs(l_item_str) do
        local l_content = plSplit(content_str, ';')
        local list_item_ui
        
        local item_id = tonumber(l_content[1])
        local cnt = tonumber(l_content[2]) or 0
        if (self.m_reward_num == 1) then
            list_item_ui = MakeSimpleDragonCard(item_id) -- 드래곤 카드
        else
            list_item_ui = UI_ItemCard(item_id, cnt or 0) -- 아이템 카드
        end
        if (list_item_ui) then
            list_item_ui.root:setScale(0.55)
            list_item_ui.root:setPosition(l_pos[i], 0)
            vars['itemNode']:addChild(list_item_ui.root)       
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
	vars['dragonInfoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:refresh()

end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:click_okBtn()
	local finish_cb = function()
		UI_EventThankAnniversary_rewardPopup(self.m_reward_num)
		self:close()
		if (self.m_rewardCb) then
			self.m_rewardCb()
		end
	end
	self:request_evnetThankReward(finish_cb)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:click_infoBtn()
	UI_PickDragon.makePickDragon(nil, 700612, nil, true) -- mid, item_id, , is_info
end
-------------------------------------
-- function request_evnetThankReward
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:request_evnetThankReward(finish_cb, _reward_num)
    local reward_num = _reward_num or self.m_reward_num
  
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if (ret['comeback_reward']) then
            g_eventData:setEventUserReward(ret['comeback_reward'])    
        end

        if (finish_cb) then
            finish_cb()
        end
    end

    -- 콜백 함수
    local function fail_cb(ret)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get_comeback_reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('choice', reward_num) -- 1: 신규 2 : 복귀
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end