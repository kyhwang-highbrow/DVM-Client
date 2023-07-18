local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), UI_FevertimeUIHelper:getCloneTable())

local L_STAGE_ID = {1700011, 1700012, 1700013, 1700014, 1700015, 1700016}

-------------------------------------
-- class UI_RuneGuardianDungeonScene
-------------------------------------
UI_RuneGuardianDungeonScene = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneGuardianDungeonScene:init()
    local vars = self:load('rune_guardian_dungeon_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_RuneGuardianDungeonScene')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_RuneGuardianDungeonScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RuneGuardianDungeonScene'
    self.m_titleStr = Str('룬 수호자 던전')
    self.m_uiBgm = 'bgm_lobby'
    self.m_subCurrency = 'subjugation_ticket'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneGuardianDungeonScene:initUI()
    local vars = self.vars
    for i, stage_id in ipairs(L_STAGE_ID) do
        if (vars['stageNode'..i]) then
            local ui_item = UI_RuneGuardianDungeonListItem(stage_id)
            vars['stageNode'..i]:addChild(ui_item.root)
        end
    end

    if (not g_settingData:getIsShowedRunGuardianDungeonInfoPopup()) then
        vars['infoMenu']:setVisible(true)
    else
        vars['infoMenu']:setVisible(false)
    end

end

-------------------------------------
-- function setInfoPopupAction
-------------------------------------
function UI_RuneGuardianDungeonScene:setInfoPopupAction()
	local vars = self.vars

	local scale_action = cc.ScaleTo:create(0, 0)
	vars['colorBlock']:runAction(scale_action)

	-- 특정 사이즈까지 줄어들다가 사라짐
    local move_action = cc.EaseInOut:create(cc.MoveTo:create(0.3, cc.p(target_pos_x, -178)), 2)
    local scale_action = cc.EaseInOut:create(cc.ScaleTo:create(0.3, 0.2, 0.4), 2)
	local action_spawm = cc.Spawn:create(move_action, scale_action)
    local disappear = cc.ScaleTo:create(0, 0)
    local callback = cc.CallFunc:create(function()
		vars['infoMenu']:setVisible(false)
	end)
    local seq_action = cc.Sequence:create(action_spawm, disappear, callback)
	vars['infoMenu']:runAction(seq_action)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneGuardianDungeonScene:initButton() 
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function() self:click_runeInfo() end)
    vars['closeBtn']:registerScriptTapHandler(function() 
       self:setInfoPopupAction()
       vars['npcSprite']:setVisible(false)
       g_settingData:setIsShowedRunGuardianDungeonInfoPopup(true)
    end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneGuardianDungeonScene:refresh()
    local vars = self.vars
    local l_active_hot = {}
    do -- 전설 등급 룬 확률 증가 핫타임
        local type = 'dg_rune_legend_up'
        local name = 'RuneLegend'
        self:initFevertimeUI(vars, type, name, '+', l_active_hot)
    end

    do -- 룬 추가 획득 핫타임
        local type = 'dg_rune_up'
        local name = 'Rune'
        self:initFevertimeUI(vars, type, name, '+', l_active_hot)
    end

    do -- 룬 수호자 던전 날개 할인
        local type = 'dg_rg_st_dc'
        local name = 'DgRgSt'
        self:initFevertimeUI(vars, type, name, '-', l_active_hot)
    end

    self:arrangeItemUI(l_active_hot)
end

-------------------------------------
-- function arrangeItemUI
-- @brief itemUI들을 정렬한다!
-------------------------------------
function UI_RuneGuardianDungeonScene:arrangeItemUI(l_hottime)
    for i, ui_name in pairs(l_hottime) do
        local ui = self.vars[ui_name]
        if (ui ~= nil) then
            ui:setVisible(true)
            local pos_x = (i-1) * 72
            ui:setPositionX(pos_x)
        end
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RuneGuardianDungeonScene:click_exitBtn()
	if (g_currScene.m_sceneName == 'SceneRuneGuardianDungeon') then
		local is_use_loading = false
		local scene = SceneLobby(is_use_loading)
		scene:runScene()
	else
		self:close()
	end
end

-------------------------------------
-- function click_runeInfo
-- @brief 룬 도움말(룬 획득확률 -> 룬 수호자 던전) 팝업 출력
-------------------------------------
function UI_RuneGuardianDungeonScene:click_runeInfo()
    UI_HelpRune('probability', 'runeGuardian')
end

--@CHECK
UI:checkCompileError(UI_RuneGuardianDungeonScene)








local PARENT = UI

-------------------------------------
-- class UI_RuneGuardianDungeonListItem
-------------------------------------
UI_RuneGuardianDungeonListItem = class(PARENT, {
        m_stageId = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneGuardianDungeonListItem:init(stage_id)
    local vars = self:load('rune_guardian_dungeon_scene_item.ui')
    self.m_stageId = stage_id

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneGuardianDungeonListItem:initUI()
    local vars = self.vars
    local stage_id = self.m_stageId
    local direction_number = 1   -- 1은 ui 파일의 왼쪽 모양(메뉴) 사용, 2는 오른쪽
                                 -- 세 번째 던전까지는 왼쪽(디폴트)을 사용
    if (stage_id > 1700013) then
        direction_number = 2
    end

    -- 세팅 전에 모두 비활성화 된 상태로 초기화
    for i = 1, 2 do
        vars['mainMenu' .. i]:setVisible(false)        
    end

    local t_data = TableDrop():get(stage_id)
    vars['mainMenu' .. direction_number]:setVisible(true)

    local reward_item_id = t_data['item_1_id']
    local reward_card = UI_ItemCard(reward_item_id, 0)
    vars['rewardNode' .. direction_number]:addChild(reward_card.root)

    local title = t_data['t_name']
    vars['titleLabel' .. direction_number]:setString(Str(title))

    vars['startBtn' .. direction_number]:registerScriptTapHandler(function() self:click_stageBtn(stage_id) end)

    

    -- 고대 유적 던전 소비 활동력 핫타임 관련
    local type = 'dg_rg_st_dc'
    local active, value = g_fevertimeData:isActiveFevertimeByType(type)
    if active then
        local table_drop = TABLE:get('drop')
        local t_drop = table_drop[stage_id]
        local cost_value = math_floor(t_drop['cost_value'] * (1 - value))
        local str = string.format('-%d%%', value * 100)
        vars['actingPowerLabel']:setString(cost_value)
        vars['actingPowerLabel']:setTextColor(cc.c4b(0, 255, 255, 255))
        vars['hotTimeSprite']:setVisible(true)
        vars['hotTimeStLabel']:setString(str)
        vars['staminaSprite']:setVisible(false)
        vars['actingPowerLabel2']:setString(cost_value)
        vars['actingPowerLabel2']:setTextColor(cc.c4b(0, 255, 255, 255))
        vars['hotTimeSprite2']:setVisible(true)
        vars['hotTimeStLabel2']:setString(str)
        vars['staminaSprite2']:setVisible(false)
    else
        vars['actingPowerLabel']:setTextColor(cc.c4b(240, 215, 159, 255))
        vars['hotTimeSprite']:setVisible(false)
        vars['staminaSprite']:setVisible(true)
        vars['actingPowerLabel2']:setTextColor(cc.c4b(240, 215, 159, 255))
        vars['hotTimeSprite2']:setVisible(false)
        vars['staminaSprite2']:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneGuardianDungeonListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneGuardianDungeonListItem:refresh()

end

-------------------------------------
-- function click_stageBtn
-------------------------------------
function UI_RuneGuardianDungeonListItem:click_stageBtn(stage_id)
    UI_AdventureStageInfo(stage_id)
end
