local PARENT = UI

-------------------------------------
-- class UI_SecretFindPopup
-------------------------------------
UI_SecretFindPopup = class(PARENT,{
    m_dungeonID = 'string',
})

-------------------------------------
-- function init
-------------------------------------
function UI_SecretFindPopup:init(dungeon_id)
    self.m_dungeonID = dungeon_id

    local vars = self:load('secret_dungeon_find_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SecretFindPopup')

    -- @UI_ACTION
    self:addAction(vars['rootNode'], UI_ACTION_TYPE_OPACITY, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SecretFindPopup:initUI()
    local vars = self.vars

    -- 하위 UI가 모두 opacity값을 적용되도록
    self:setOpacityChildren(true)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SecretFindPopup:initButton()
    self.vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
    self.vars['enterBtn']:registerScriptTapHandler(function()
        UINavigator:goTo('secret_relation', self.m_dungeonID)
    end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SecretFindPopup:refresh()
end


-- TODO: 파라미터 정의 필요
function MakeSimpleSecretFindPopup(secret_dungeon)
    if (not secret_dungeon) then return end

    local dungeon_id = secret_dungeon['id']
    local did = secret_dungeon['dragon']
    local stage_id = secret_dungeon['stage']
    local t_info = g_secretDungeonData:parseSecretDungeonID(stage_id)

    local ui = UI_SecretFindPopup(dungeon_id)

    local dungeon_name = TableDragon:getDragonName(did)
    ui.vars['dungeonLabel']:setString(dungeon_name)

    -- 타이틀 및 보스 썸네일 표시
    do
        local res_name
        local icon

        if (t_info['dungeon_mode'] == SECRET_DUNGEON_GOLD) then
            res_name = 'res/ui/typo/kr/secret_dg_find_gold.png'
            icon = TableStageDesc():getLastMonsterIcon(stage_id)

        elseif (t_info['dungeon_mode'] == SECRET_DUNGEON_RELATION) then
            res_name = 'res/ui/typo/kr/secret_dg_find_relation.png'
            icon = MakeSimpleDragonCard(did)

        end

        if (res_name) then
            res_name = Translate:getTranslatedPath(res_name)
    
            local sprite = cc.Sprite:create(res_name)
            sprite:setAnchorPoint(cc.p(0.5, 0.5))
            sprite:setDockPoint(cc.p(0.5, 0.5))
            ui.vars['dungeonTitleNode']:addChild(sprite)
        end

        if (icon) then
            ui.vars['dragonNode']:addChild(icon.root)
        end
    end

    return ui
end

--@CHECK
UI:checkCompileError(UI_SecretFindPopup)
