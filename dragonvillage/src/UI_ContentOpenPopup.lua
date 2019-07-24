local PARENT = UI

-------------------------------------
-- class UI_ContentOpenPopup
-------------------------------------
UI_ContentOpenPopup = class(PARENT,{
        m_content_type = 'string',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ContentOpenPopup:init(content_type)
    self.m_content_type = content_type

    local vars = self:load('popup_contents_open.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ContentOpenPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ContentOpenPopup:initUI()
    local vars = self.vars
    local content_type = self.m_content_type

    if (content_type == 'attr_tower') then
        self.vars['linkBtn']:setVisible(true)
    
    -- 시험의 탑 층 개방용 팝업
    elseif (content_type == 'attr_tower_expend') then
        self.vars['linkBtn']:setVisible(true)
        local expend_floor = g_attrTowerData:getAttrMaxStageId()%1000
        self.vars['descLabel']:setString(Str('전 속성 {1}층 개방', expend_floor))

        -- 나머지는 시험의 탑과 동일하게 사용
        content_type = 'attr_tower'
        self.m_content_type = 'attr_tower'
    end
    
    vars['contentsVisual']:changeAni('open_'..content_type, true)
    vars['contentsLabel']:setString(getContentName(content_type))

    local open_desc = g_contentLockData:getOpenContentDesc(content_type)
    vars['infoLabel']:setString(open_desc)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ContentOpenPopup:initButton()
    local vars = self.vars
    self.vars['okBtn']:registerScriptTapHandler(function() self:close() end)
    self.vars['linkBtn']:registerScriptTapHandler(function() self:click_lickBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ContentOpenPopup:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ContentOpenPopup:click_lickBtn()
    local content_type = self.m_content_type
    -- 시험의 탑 바로가기
    if (content_type == 'attr_tower') then
        UINavigator:goTo('attr_tower')
    -- 거목 던전 바로가기
    elseif (content_type == 'nest_tree') then
        UINavigator:goTo('nest_tree')
    -- 진화 던전 바로가기
    elseif (content_type == 'nest_evo_stone') then
        UINavigator:goTo('nest_evo_stone')
    -- 고대의 탑 바로가기
    elseif (content_type == 'ancient') then
        UINavigator:goTo('ancient')
    -- 콜로세움 바로가기
    elseif (content_type == 'colosseum') then
        UINavigatorDefinition:goTo('colosseum')
    -- 악몽 던전 바로가기
    elseif (content_type == 'nest_nightmare') then
        UINavigator:goTo('nest_nightmare') 
    -- 인연 던전 바로가기
    elseif (content_type == 'secret_relation') then
        UINavigator:goTo('secret_relation')
    -- 클랜 바로가기
    elseif (content_type == 'clan') then
        UINavigatorDefinition:goTo('clan') 
    -- 그림자의 신전 바로가기
    elseif (content_type == 'challenge_mode') then
        UINavigatorDefinition:goTo('challenge_mode')
    -- 그랜드 콜로세움 바로가기
    elseif (content_type == 'grand_arena') then
        UINavigatorDefinition:goTo('grand_arena')
    end
end

--@CHECK
UI:checkCompileError(UI_ContentOpenPopup)
