local PARENT = UI

-------------------------------------
-- class UI_MasterRoadRewardPopupNew
-------------------------------------
UI_MasterRoadRewardPopupNew = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MasterRoadRewardPopupNew:init(stage_id)
	local vars = self:load('master_road_popup_simple_new.ui')
	UIManager:open(self, UIManager.POPUP)
	
	-- UI 클래스명 지정
    self.m_uiName = 'UI_MasterRoadRewardPopupNew'

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_rewardBtn() end, 'UI_MasterRoadRewardPopupNew')


	self:initUI()
	self:initButton()
    self:refresh(true) -- b_force

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

    end, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_MasterRoadRewardPopupNew:initUI()
    local vars = self.vars

    -- 테이블 콜백으로 갱신하면 눈에 보이는 텀이 있어 최초에 호출함
    local t_road = TableMasterRoad():get(g_masterRoadData:getDisplayRoad())

    -- npc 일러스트
    local res = t_road['res']
	vars['npcNode']:removeAllChildren(true)
    local animator = MakeAnimator(res)
    animator:changeAni('idle', true)
    vars['npcNode']:addChild(animator.m_node)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MasterRoadRewardPopupNew:refresh(b_force)
	local vars = self.vars


    local t_data = g_masterRoadData:getFocusMasterRoadInfo()

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
    vars['closeBtn']:setVisible(reward_state ~= 'has_reward')
    --vars['questLinkBtn']:setVisible((reward_state == 'not_yet') and (t_data['rid'] == g_masterRoadData:getFocusRoad()))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MasterRoadRewardPopupNew:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function click_rewardBtn
-- @brief 보상 받기
-------------------------------------
function UI_MasterRoadRewardPopupNew:click_rewardBtn()
    local vars = self.vars
    local focus_rid = g_masterRoadData.m_focusRoad

    local ok_cb = function()
        self:closeWithAction() 
    end

    local function cb_func(ret)

        -- 보상 수령 후에는 전역 항목에 대해 다시 검사한다. 이것들은 클리어 타이밍이 애매하기 때문
        local function re_cb_func()
            -- 보상 획득
            ItemObtainResult_hasCloseCb(ret, nil, ok_cb)
        end
        g_masterRoadData:updateMasterRoadAfterReward(re_cb_func)
    end
    g_masterRoadData:request_roadReward(focus_rid, cb_func)
end




--@CHECK
UI:checkCompileError(UI_MasterRoadRewardPopupNew)