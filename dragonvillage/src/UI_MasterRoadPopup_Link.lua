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
function UI_MasterRoadPopup_Link:init()
	local vars = self:load('master_road_popup_link.ui')
	UIManager:open(self, UIManager.POPUP)

        -- UI 클래스명 지정
    self.m_uiName = 'UI_MasterRoadPopup_Link'
	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_MasterRoadPopup_Link')

	-- @UI_ACTION
	self:doActionReset()
	self:doAction(function()
        -- @ TUTORIAL
        TutorialManager.getInstance():startTutorial(TUTORIAL.FIRST_END, self)
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
            local scene = SceneCommon(UI_MasterRoadPopup, close_cb)
            scene:runScene()
        end
    end)
    self:click_exitBtn()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_MasterRoadPopup_Link:click_exitBtn()
    self:closeWithAction()
end

--@CHECK
UI:checkCompileError(UI_MasterRoadPopup_Link)