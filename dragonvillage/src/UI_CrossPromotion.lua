-- 확률업

local PARENT = UI

-------------------------------------
-- class UI_CrossPromotion
-------------------------------------
UI_CrossPromotion = class(PARENT,{
        m_map_target_dragons = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CrossPromotion:init(event_type)
    local event_list = g_eventData:getEventPopupTabList()
    local event_data = event_list[event_type]
    
    ccdump('event_data')

    -- 확률업에 지정된 드래곤 수에 따라 사용하는 ui와 초기화 함수가 다름
    local ui_name = 'event_cross_promotion_rise.ui'

    if (event_data and event_data.m_eventData and event_data.m_eventData['banner']) then
        ui_name = event_data.m_eventData['banner']
    else
        cclog('## UI_CrossPromotion :: ui데이터가 없으니 테이블깞을 확인하시오')
    end

    self:load(ui_name)

    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @breif 확률업 드래곤이 2개가 적용되었을 경우 UI 초기화
-------------------------------------
function UI_CrossPromotion:initUI()
    local vars = self.vars
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_CrossPromotion:initButton()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_CrossPromotion:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CrossPromotion:refresh()
end

--@CHECK
UI:checkCompileError(UI_CrossPromotion)
