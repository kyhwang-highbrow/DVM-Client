local PARENT = UI

local ORI_POS_X = 0
local NEXT_POS_X = -800
local PRE_POS_X = 800

-------------------------------------
-- class UI_MasterRoadRewardPopup
-------------------------------------
UI_MasterRoadRewardPopup = class(PARENT, {
		m_showCb = 'function',

        m_masterRoadUI = 'UI',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MasterRoadRewardPopup:init(stage_id, show_cb)
	local vars = self:load('master_road_popup_simple.ui')
	self.m_showCb = show_cb
	UIManager:open(self, UIManager.POPUP)
	
	-- UI 클래스명 지정
    self.m_uiName = 'UI_MasterRoadRewardPopup'

    -- @jhakim 190701 강제 튜토리얼 진행중에 나중에 가기 버튼이 (눌리지 않아야하는데)눌리면 오류남 
    -- '나중에 가기' 버튼이 action 끝나기 전에 눌리는 것을 방지
    -- vars['nextBtn']:setEnabled(false)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_MasterRoadRewardPopup')


	self:initUI()
	self:initButton()

    -- @UI_ACTION
	self:doActionReset()
	self:doAction(function()
		if (stage_id) then
			local clear_cnt = g_adventureData:getStageClearCnt(stage_id)

			-- @ TUTORIAL : 1-1 end start
			if (stage_id == 1110101) and (clear_cnt == 1) then
				local tutorial_key = TUTORIAL.FIRST_END
				TutorialManager.getInstance():startTutorial(tutorial_key, self)
	    
			-- @ TUTORIAL : 1-2 end start
			elseif (stage_id == 1110102) and (clear_cnt == 1) then
				local tutorial_key = TUTORIAL.ADV_01_02_END
				local step = nil
				local is_force = true
				TutorialManager.getInstance():startTutorial(tutorial_key, self, step, is_force)

			end
		end
        -- vars['nextBtn']:setEnabled(true)

        if (TutorialManager.getInstance():isDoing() == false) then
            -- @ TUTORIAL : 1-1 end, 101
            local tutorial_key = TUTORIAL.FIRST_END
            local check_step = 101
            TutorialManager.getInstance():continueTutorial(tutorial_key, check_step, self)

            -- @ TUTORIAL : 1-1 end, 103
            tutorial_key = TUTORIAL.FIRST_END
            check_step = 103
            TutorialManager.getInstance():continueTutorial(tutorial_key, check_step, self)
        end

        if (self.m_masterRoadUI) then self.m_masterRoadUI.m_bInit = true end

    end, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_MasterRoadRewardPopup:initUI()
    self:makeMasterRoadContent(false) -- is_start_with_move
    self:setOpacityChildren(true) -- 보상 아이콘도 투명도가 적용되기 위한 코드
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MasterRoadRewardPopup:refresh(b_force)
	local vars = self.vars

    local t_road = g_masterRoadData:getFocusMasterRoadInfo()

    -- 스페셜 목표 선택할 경우 프레임 이펙트
    vars['specialSprite']:setVisible(t_road['special'] == 1)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MasterRoadRewardPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function makeMasterRoadContent
-------------------------------------
function UI_MasterRoadRewardPopup:makeMasterRoadContent(is_start_with_move)
    local cur_master_data = g_masterRoadData:getFocusMasterRoadInfo()

    if (not cur_master_data) then
		return
	end

    local cb_close = function()
        self:close()
    end

    local reward_cb = function()
        self:refresh()
        self:showNext()
    end

    -- 내용물 UI 생성
    local master_content_ui = UI_MasterRoadRewardPopupItem(close_cb, reward_cb)
    master_content_ui:setOpacityChildren(true) -- 보상 아이콘도 투명도가 적용되기 위한 코드
    self.m_masterRoadUI = master_content_ui

	-- 기존 UI에 튜토리얼에 필요한 요소 붙임
	self.vars['rewardBtn'] = master_content_ui.vars['rewardBtn']
	self.vars['rewardBtn']:setEnabled(false)

    self.vars['questLinkBtn'] = master_content_ui.vars['questLinkBtn']
	self.vars['questLinkBtn']:setEnabled(false)

	master_content_ui:refresh(cur_master_data)
	
    --클리핑 노드에 붙임
    self.vars['itemNode']:addChild(master_content_ui.root)

	local finish_cb = function()
		-- 튜토리얼에서 다음 페이지 진행시킴
		if (TutorialManager.getInstance():isDoing()) then
			TutorialManager.getInstance():nextIfPlayerWaiting()
		end
		self.vars['rewardBtn']:setEnabled(true)
		self.vars['questLinkBtn']:setEnabled(true)
		
		if (self.m_showCb) then
			self.m_showCb()
		end

        if (self.m_masterRoadUI) then self.m_masterRoadUI.m_bInit = true end
    end

    -- 등장 시 액션
    if (is_start_with_move) then
        master_content_ui.root:setPositionX(900)
		local move_action = cc.EaseInOut:create(cc.MoveTo:create(0.5, cc.p(0, 0)), 2)
		local finish_action = cc.CallFunc:create(finish_cb)
        master_content_ui.root:runAction(cc.Sequence:create(move_action, finish_action))
    else
		finish_cb()
	end

    return master_content_ui
end

-------------------------------------
-- function showNext
-------------------------------------
function UI_MasterRoadRewardPopup:showNext()
    self:makeMasterRoadContent(true) -- is_start_with_move
end




--@CHECK
UI:checkCompileError(UI_MasterRoadRewardPopup)




local PARENT = UI

-------------------------------------
-- class UI_MasterRoadRewardPopupItem
-------------------------------------
UI_MasterRoadRewardPopupItem = class(PARENT, {
        m_ownerCloseCb  = 'function',
        m_ownerRewardCb = 'function',

        m_bInit = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MasterRoadRewardPopupItem:init(close_cb, reward_cb)
	local vars = self:load('master_road_popup_simple_item.ui', nil, true) -- param : url, is_permanent, keep_z_order, use_sprite_frames
    self.m_bInit = false
    self.m_ownerCloseCb = close_cb
    self.m_ownerRewardCb = reward_cb

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MasterRoadRewardPopupItem:initButton()
    local vars = self.vars

    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['questLinkBtn']:registerScriptTapHandler(function() self:click_questLinkBtn() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_MasterRoadRewardPopupItem:initUI()
    local vars = self.vars

    local t_data = g_masterRoadData:getFocusMasterRoadInfo()

    -- npc 대화
	local npc_speech = Str(t_data['t_speech'])
	vars['npcSpeechLabel']:setString(npc_speech)

	-- 목표
	local desc = TableMasterRoad:getDescStr(t_data)
	vars['descLabel']:setString(desc)

	-- 보상 아이콘
	vars['rewardNode']:removeAllChildren(true)
	UI_MasterRoadPopup.makeRewardCard(vars['rewardNode'], t_data['t_reward'], false, 'center')

    -- 보상 아이콘도 투명도가 적용되기 위한 코드
    doAllChildren(vars['rewardNode'], function(node) node:setCascadeOpacityEnabled(true) end)

    -- 보상 상태에 따른 버튼 처리
    local reward_state = g_masterRoadData:getRewardState(t_data['rid'])
    vars['rewardBtn']:setVisible(reward_state == 'has_reward')
    vars['questLinkBtn']:setVisible((reward_state == 'not_yet') and (t_data['rid'] == g_masterRoadData:getFocusRoad()))

    -- 넘버링
    local road_idx = g_masterRoadData:getRoadIdx(t_data['rid'])
    
    -- 보상 상태에 따른 타이틀 처리
    if (reward_state == 'has_reward') then
        vars['titleNumLabel']:setString(Str('{1}번째 임무를 완료하였습니다.', road_idx))
    else
        local num_str = Str('{1}번째 임무입니다.', road_idx)
        vars['titleNumLabel']:setString(num_str)
    end
end

-------------------------------------
-- function click_rewardBtn
-- @brief 보상 받기
-------------------------------------
function UI_MasterRoadRewardPopupItem:click_rewardBtn()
    if (self.m_bInit == false) then return end

    local vars = self.vars
    local focus_rid = g_masterRoadData.m_focusRoad


    local ok_cb = function()
        -- 보상 수령 후 다음 마스터의 길을 불러옴(마지막 마스터의 길의 경우에는 하지 않음) 
        if (focus_rid ~= TableMasterRoad:getLastRoad()) then
            local move_action = cc.EaseIn:create(cc.MoveTo:create(0.2, cc.p(-900, 0)), 1)
            local remove_action = cc.RemoveSelf:create() -- cc.CallFunc:create(function() self.root end)
            local sequence_action = cc.Sequence:create(move_action, remove_action)
            self.root:runAction(sequence_action)
        
            -- ownerUI의 보상 수령 콜백함수 호출(다음 마스터 로드 생성)
            if (self.m_ownerRewardCb) then
                self.m_ownerRewardCb(true) -- is_start_with_move
            end
         end
    end

    local function cb_func(ret)
        -- 보상 획득 표시
        vars['rewardBtn']:setEnabled(false)
        vars['rewardLabel']:setString(Str('수령 완료'))

        -- 보상 수령 후에는 전역 항목에 대해 다시 검사한다. 이것들은 클리어 타이밍이 애매하기 때문
        local function re_cb_func()
            -- 보상 획득
            ItemObtainResult_hasCloseCb(ret, nil, ok_cb)
        end
        g_masterRoadData:updateMasterRoadAfterReward(re_cb_func)
    end
    g_masterRoadData:request_roadReward(focus_rid, cb_func)
end


-------------------------------------
-- function click_questLinkBtn
-------------------------------------
function UI_MasterRoadRewardPopupItem:click_questLinkBtn()
    if (self.m_bInit == false) then return end

    local t_road = g_masterRoadData:getFocusMasterRoadInfo()
    
    local clear_type = t_road['clear_type']
    local clear_cond = t_road['clear_value']

    if (clear_type == 'clr_stg') and (clear_cond == 1110102) then
        clear_type = 'stg_ready'
    end
    
    QuickLinkHelper.quickLink(clear_type, clear_cond)

    -- "바로 가기"버튼을 클릭했을 때 팝업이 자동으로 닫힐지 여부
    if (self.m_ownerCloseCb) then
        self.m_ownerCloseCb()
    end
end
