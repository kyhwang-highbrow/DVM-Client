local PARENT = UI

-------------------------------------
-- class UI_SkillDetailPopupListItem
-------------------------------------
UI_SkillDetailPopupListItem = class(PARENT, {
        m_dragonData = '',
        m_skillMgr = '',
        m_skillIdx = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopupListItem:init(t_dragon_data, skill_mgr, skill_idx)
    self.m_dragonData = t_dragon_data
    self.m_skillMgr = skill_mgr
    self.m_skillIdx = skill_idx

    local vars = self:load('skill_detail_popup_item.ui')
  
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SkillDetailPopupListItem:initUI()
    local vars = self.vars
    local skill_indivisual_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(self.m_skillIdx)

    ccdump(skill_indivisual_info)

    do -- 스킬 타입
        local skill_idx = self.m_skillIdx
        local str = ''
        if (skill_idx == 0) then
            str = Str('일반 스킬')
        elseif (skill_idx == 1) or (skill_idx == 2) then
            str = Str('패시브 스킬')
        elseif (skill_idx == 3) then
            str = Str('액티브 스킬')
        else
            error('skill_idx : ' .. skill_idx)
        end
        vars['skillTypeLabel']:setString(str)
    end

    do -- 스킬 아이콘
        local skill_id = skill_indivisual_info:getSkillID()
        local icon = IconHelper:getSkillIcon('dragon', skill_id)
        vars['skillNode']:addChild(icon)
    end

    do -- 스킬 이름
        local name = skill_indivisual_info:getSkillName()
        vars['skillNameLabel']:setString(name)
    end
    
    do -- 스킬 설명
        local desc = skill_indivisual_info:getSkillDesc()
        vars['skillDscLabel']:setString(desc)
    end

    do
        local skill_level = skill_indivisual_info:getSkillLevel()
        if (skill_level <= 0) then
            vars['skillOpenSprite']:setVisible(true)
            local skill_idx = self.m_skillIdx
            if (skill_idx == 2) then
                vars['skillOpenLabel']:setString(Str('해츨링 스킬'))
            elseif (skill_idx == 3) then
                vars['skillOpenLabel']:setString(Str('성룡 스킬'))
            else
                error('skill_idx : ' .. skill_idx)
            end
        else
            vars['skillOpenSprite']:setVisible(false)
            vars['enhanceBtn']:setVisible(false)
        end

        if (skill_level <= 0) then
            vars['enhanceBtn']:setVisible(false)
        else
            vars['enhanceBtn']:setVisible(true)
        end
    end

    do -- 레벨 표시
        local skill_level = skill_indivisual_info:getSkillLevel()
        local skill_max_level = self:getSkillMaxLevel()
        vars['skillEnhanceLabel']:setString(Str('Lv.{1}/{2}', skill_level, skill_max_level))
    end


--    priceLabel
end

-------------------------------------
-- function getSkillMaxLevel
-------------------------------------
function UI_SkillDetailPopupListItem:getSkillMaxLevel()
    local eclv = self.m_dragonData['eclv']
    local skill_idx = self.m_skillIdx

    if (skill_idx == 3) then
        return 1
    else
        return 10 + (eclv * 10)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SkillDetailPopupListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SkillDetailPopupListItem:refresh()
end