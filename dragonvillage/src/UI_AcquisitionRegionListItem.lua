local PARENT = class(UI, ITableViewCell:getCloneTable())


-------------------------------------
-- class UI_AcquisitionRegionListItem
-------------------------------------
UI_AcquisitionRegionListItem = class(PARENT, {
        m_region = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AcquisitionRegionListItem:init(region)
    self.m_region = region

    local vars = self:load('location_popup_list.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AcquisitionRegionListItem:initUI()
    local vars = self.vars
    
    local table_drop = TableDrop()
    local stage_id = tonumber(self.m_region)
     
    do -- 스테이지 카테고리
        local category = g_stageData:getStageCategoryStr(stage_id)
        vars['locationLabel1']:setString(category)
    end

    do -- 스테이지 이름
        local name = g_stageData:getStageName(stage_id)
        vars['locationLabel2']:setString(name)
    end

    do -- 보스 썸네일 표시
        local table_stage_desc = TableStageDesc()
        local icon = table_stage_desc:getLastMonsterIcon(stage_id)
        vars['iconNode']:addChild(icon.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AcquisitionRegionListItem:initButton(t_user_info)
    local vars = self.vars
    --vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_AcquisitionRegionListItem:refresh(t_user_info)
    local vars = self.vars
end