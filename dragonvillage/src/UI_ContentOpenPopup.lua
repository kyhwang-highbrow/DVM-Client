local PARENT = UI

-------------------------------------
-- class UI_ContentOpenPopup
-------------------------------------
UI_ContentOpenPopup = class(PARENT,{
        m_content_type = 'string',
        m_bIsDoneUIAction = 'bool',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ContentOpenPopup:init(content_type)
    self.m_content_type = content_type
    self.m_bIsDoneUIAction = false

    local vars = self:load('popup_contents_open.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_close() end, 'UI_ContentOpenPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(function() self.m_bIsDoneUIAction = true end, false)

    -- 차원문일 때 로컬에 저장해서
    -- 로비 진입 시 컨텐츠 오픈 여부의 판단을 도와야 한다.
    if (content_type == 'dmgate') then
        -- 차원문은 로비 진입 시 보여줘야 할 수도 있기 때문에 
        local has_dmgate_key = g_settingData:get('lobby_dmgate_open_notice') or false

        if not has_dmgate_key then
            g_settingData:applySettingData(true, 'lobby_dmgate_open_notice')
        end 
    end

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
    self.vars['descLabel']:setString(Str('신규 콘텐츠가 오픈되었습니다'))

    -- 시험의 탑 층 개방용 팝업
    if (content_type == 'attr_tower_expend') then
        self.vars['linkBtn']:setVisible(true)
        local expend_floor = g_attrTowerData:getAttrMaxStageId()%1000
        self.vars['descLabel']:setString(Str('전 속성 {1}층 개방', expend_floor))

        -- 나머지는 시험의 탑과 동일하게 사용
        content_type = 'attr_tower'
        self.m_content_type = 'attr_tower'
    else
        self.vars['linkBtn']:setVisible(true)
    end
    
    self:changeAni(content_type)
    vars['contentsLabel']:setString(getContentName(content_type))


    local table_contents = TABLE:get('table_content_help')
    local t_contents = table_contents[content_type] or {}
    local open_desc = t_contents['open_desc'] or ''
    vars['infoLabel']:setString(Str(open_desc))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ContentOpenPopup:initButton()
    local vars = self.vars
    self.vars['okBtn']:registerScriptTapHandler(function() self:click_close() end)
    self.vars['linkBtn']:registerScriptTapHandler(function() self:click_lickBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ContentOpenPopup:refresh()
end

-------------------------------------
-- function click_close
-------------------------------------
function UI_ContentOpenPopup:click_close()
    if (self.m_bIsDoneUIAction == true) then
        self:close()
    end
end

-------------------------------------
-- function click_lickBtn
-------------------------------------
function UI_ContentOpenPopup:click_lickBtn()
    local content_name = self.m_content_type
	if (content_name == 'daily_shop') then
		--UINavigator:goTo('shop_daily', true) -- content_name, is_popup
        UINavigator:goTo('package_shop_test', 'package_daily')
	else
		-- 바로가기
		UINavigator:goTo(content_name)
	end

    self:close()
end

-------------------------------------
-- function changeAni
-------------------------------------
function UI_ContentOpenPopup:changeAni(content_type)
    local vars = self.vars
    -- content_type과 애니메이션 다를 경우 예외처리
    if (content_type == 'forest') then
        content_type = 'dragon_forest'
    end

    if (content_type == 'exploration') then
        content_type = 'exploation'
    end

    if (content_type == 'challenge_mode') then
        content_type = 'challenge'
    end

    vars['contentsVisual']:changeAni('open_'..content_type, true)
end


-------------------------------------
-- function UI_ContentOpenPopup_AttrTower
-- @brief 시험의 탑 층 개방용 팝업
-------------------------------------
function UI_ContentOpenPopup_AttrTower()
    local ui = UI()
    ui:load('popup_contents_open_tutorial.ui')
    local vars = ui.vars
    UIManager:open(ui, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'UI_ContentOpenPopup_AttrTower')

    vars['linkBtn']:setVisible(true)
    local expend_floor = g_attrTowerData:getAttrMaxStageId()%1000
    vars['descLabel']:setString(Str('전 속성 {1}층 개방', expend_floor))


    vars['contentsVisual']:changeAni('open_attr_tower')
    vars['contentsLabel']:setString(getContentName('attr_tower'))
    vars['infoLabel']:setString('')

    vars['linkBtn']:registerScriptTapHandler(function()
        UINavigator:goTo('attr_tower')
        ui:close()
    end)
end


--@CHECK
UI:checkCompileError(UI_ContentOpenPopup)
