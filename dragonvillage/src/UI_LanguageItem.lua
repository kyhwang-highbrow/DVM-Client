-- @inherit UI
-- @inherit ITableViewCell
local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
---@class UI_LanguageItem : UI, UIC_TableViewCell
-------------------------------------
UI_LanguageItem = class(PARENT, {
    m_structLang = 'Language',
})

-------------------------------------
---@function init
-------------------------------------
function UI_LanguageItem:init(struct_language)
    self.m_structLang = struct_language

    self:load('setting_language_cell.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
---@function initUI
-------------------------------------
function UI_LanguageItem:initUI()
    local vars = self.vars
    local struct_language = self.m_structLang

    do -- 언어 이름 (해당 언어로 표기, SystemFont)
        local display_name = struct_language:getLanguageSimpleDisplayName()
        vars['onLabel1']:setString(display_name)
        vars['offLabel1']:setString(display_name)
    end

    do -- 언어 이름 (영어로 표기, TTF)
        local en_name = struct_language:getLanguageEnglishDisplayName()
        local lang_code = struct_language:getLanguageCode()

        if IS_TEST_MODE() == true  then
            en_name = string.format('%s (%s)', en_name, lang_code)            
        end
        
        vars['onLabel2']:setString(en_name)
        vars['offLabel2']:setString(en_name)
    end
end

-------------------------------------
---@function initButton
-------------------------------------
function UI_LanguageItem:initButton()
    local vars = self.vars
end

-------------------------------------
---@function refresh
-------------------------------------
function UI_LanguageItem:refresh()
    local vars = self.vars
end
