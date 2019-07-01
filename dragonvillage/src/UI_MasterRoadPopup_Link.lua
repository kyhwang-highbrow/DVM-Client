local PARENT = UI

-------------------------------------
-- class UI_MasterRoadPopup_Link
-------------------------------------
UI_MasterRoadPopup_Link = class(PARENT, {
        m_tableView = '',
		m_currRid = 'number',
		m_selectedSprite = 'cc.Sprite',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MasterRoadPopup_Link:init(stage_id)
	local vars = self:load('master_road_popup_link.ui')
	UIManager:open(self, UIManager.POPUP)

     -- UI 클래스명 지정
    self.m_uiName = 'UI_MasterRoadPopup_Link'

	-- backkey 지정
	-- 나중에 고민하고 살릴 예정
	-- g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_MasterRoadPopup_Link')


    -- @jhakim 190701 강제 튜토리얼 진행중에 나중에 가기 버튼이 (눌리지 않아야하는데)눌리면 오류남 
    -- '나중에 가기' 버튼이 action 끝나기 전에 눌리는 것을 방지
    vars['nextBtn']:setEnabled(false)

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
        vars['nextBtn']:setEnabled(true)

    end, false)

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_MasterRoadPopup_Link:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MasterRoadPopup_Link:initButton()
    local vars = self.vars
    vars['nextBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['linkBtn']:registerScriptTapHandler(function() self:click_questLinkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MasterRoadPopup_Link:refresh()
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
-- function click_questLinkBtn
-------------------------------------
function UI_MasterRoadPopup_Link:click_questLinkBtn()
    self:setCloseCB(function()
        local function close_cb()
            SceneLobby():runScene()
        end
        if (TutorialManager.getInstance():isDoing()) then
            local ui = UI_MasterRoadPopup()
            ui:setCloseCB(close_cb)
        else
            local auto_close = false
            local scene = SceneCommon(UI_MasterRoadPopup, close_cb, auto_close)
            scene:runScene()
        end
    end)
    self:click_exitBtn()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_MasterRoadPopup_Link:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_MasterRoadPopup_Link)