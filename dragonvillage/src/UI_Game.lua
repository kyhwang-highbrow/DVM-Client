-------------------------------------
-- class UI_Game
-------------------------------------
UI_Game = class(UI, {
        m_gameScene = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Game:init(game_scene)
    self.m_gameScene = game_scene

    local vars = self:load('ingame_scene_new.ui')
    UIManager:open(self, UIManager.NORMAL)

    vars['pauseButton']:registerScriptTapHandler(function() self:click_pauseButton() end)    

    local label = cc.Label:createWithBMFont('res/font/hit_font.fnt', tostring(999))
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(1, 0.5))
    --label:setAlignment(cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    vars['hitNode']:addChild(label)
    vars['hitLabel'] = label
    vars['goldLabel']:setString('0')

    do -- 스테이지명 지정
        local difficulty, chapter, stage = parseAdventureID(game_scene.m_stageID)
        local chapter_name = chapterName(chapter)
        vars['stageLabel']:setString(chapter_name .. Str(' {1}-{2}', chapter, stage))
    end

    --self:doActionReset()
    --self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_pauseButton() end, 'UI_Game')
end

-------------------------------------
-- function click_pauseButton
-------------------------------------
function UI_Game:click_pauseButton()
    UI_GamePause(function() self.m_gameScene:gamePause() end, function() self.m_gameScene:gameResume() end)
end

-------------------------------------
-- function init_debugUI
-- @brief 인게임에서 실시간으로 각종 설정을 할 수 있도록 하는 UI생성
--        모든 기능은 UI_GameDebug안에서 구현
-------------------------------------
function UI_Game:init_debugUI()
    local debug_ui = UI_GameDebug()
    self.root:addChild(debug_ui.root)
end

-------------------------------------
-- function setGold
-- @brief 
-------------------------------------
function UI_Game:setGold(gold)    
    self.vars['goldLabel']:setString(comma_value(gold))

    local action_node = self.vars['goldNode']
    local x = -72
    local y = -2

    if self.m_gameScene.m_gameWorld:isOnFight() then
        action_node:stopAllActions()
        local start_action = cc.MoveTo:create(0.05, cc.p(x, y + 10))
        local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(x, y)), 0.2)
        action_node:runAction(cc.Sequence:create(start_action, end_action))
    end
end