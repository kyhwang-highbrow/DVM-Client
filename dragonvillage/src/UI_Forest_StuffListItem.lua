local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_Forest_StuffListItem
-------------------------------------
UI_Forest_StuffListItem = class(PARENT,{
        m_forestStuffType = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_StuffListItem:init(t_data)
    local vars = self:load('dragon_forest_popup_item.ui')
    self.m_forestStuffType = t_data['stuff_type']

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest_StuffListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Forest_StuffListItem:initButton()
    local vars = self.vars
    vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest_StuffListItem:refresh()
    local vars = self.vars

    local stuff_type = self.m_forestStuffType
    local t_data = ServerData_Forest:getInstance():getStuffInfo_Indivisual(stuff_type)

    -- 아이콘
    vars['objectVisual']:changeAni(stuff_type .. '_idle', true)

    -- 이름 레벨
    local name = Str(t_data['t_stuff_name'])
    local lv = t_data['stuff_lv'] or 0
    local display_lv = math_max(lv, 1) -- 1레벨의 정보는 보여주도록 하자
    vars['nameLabel']:setString(string.format('%s Lv.%d', name, display_lv))

    -- 설명
    local stuff_type = t_data['stuff_type']
    local desc = TableForestStuffLevelInfo:getStuffOptionDesc(stuff_type, display_lv)
    vars['dscLabel']:setString(desc)

	-- 잠금 여부
    vars['lockSprite']:setVisible(lv == 0)

    -- 레벨업 버튼 활성 여부
    if (lv < TableForestStuffLevelInfo:getStuffMaxLV(stuff_type)) then
        -- 테이머 레벨 제한 확인
		local table_stuff = TableForestStuffLevelInfo:getStuffTable(stuff_type)
		local t_next_level_info = table_stuff[lv + 1]
        local forest_lv = ServerData_Forest:getInstance():getExtensionLV()
        local open_lv = t_next_level_info['extension_lv']
        if (open_lv > forest_lv) then
            vars['lockSprite2']:setVisible(true)
            vars['lockLabel']:setString(Str('숲 Lv.{1}', open_lv))
            vars['levelupBtn']:setVisible(false)
        else
            vars['lockSprite2']:setVisible(false)
            vars['levelupBtn']:setVisible(true)
        end

        vars['maxSprite']:setVisible(false)

    -- 최대 레벨
    else
        vars['lockSprite2']:setVisible(false)
        vars['levelupBtn']:setVisible(false)
        vars['maxSprite']:setVisible(true)
    end
end

-------------------------------------
-- function click_levelupBtn
-------------------------------------
function UI_Forest_StuffListItem:click_levelupBtn()
    local stuff_type = self.m_forestStuffType

    local ui = UI_Forest_StuffLevelupPopup(stuff_type, nil)
    
    local function close_cb()
        self:refresh()
    end

    ui:setCloseCB(close_cb)    
end