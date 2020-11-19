local PARENT = UI

-------------------------------------
-- class UI_DragonGoodbyeSelectInfoPopup
-------------------------------------
UI_DragonGoodbyeSelectInfoPopup = class(PARENT,{
        m_selectType = 'string',
    })

local INFO_TEXT = {}
INFO_TEXT['relation'] = {
                        Str('인연포인트는 드래곤의 강화 레벨을 올릴 때 사용합니다.'),
                        Str('강화 레벨이 증가하면 드래곤의 생명력, 방어력, 공격력이 증가합니다.'),
                        Str('작별을 통해 해당 드래곤의 인연포인트를 얻을 수 있습니다.'), 
                        Str('작별하려는 드래곤의 인연포인트가 보유 한도를 초과하면 인연포인트로 작별할 수 없습니다.'), 
                        }
INFO_TEXT['mastery'] = {
                        Str('특성 재료는 드래곤의 특성 레벨을 올릴 때 사용합니다.'),
                        Str('작별을 통해 해당 드래곤과 동일한 등급과 속성의 특성 재료를 얻을 수 있습니다.'), 
                        Str('일반 희귀도의 드래곤은 특성 재료로 작별할 수 없습니다.'), 
                       }
INFO_TEXT['exp'] = {
                Str('드래곤 경험치는 드래곤 레벨을 올릴 때 사용합니다.'),
                Str('작별을 통해 드래곤 경험치를 얻을 수 있습니다.'),
                }

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbyeSelectInfoPopup:init(type)
    local vars = self:load('dragon_goodbye_select_popup_new_info.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbyeSelectInfoPopup')

    self.m_selectType = type

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGoodbyeSelectInfoPopup:initUI()
	local vars = self.vars
    local type = self.m_selectType

    local text_list = INFO_TEXT[type]

    if (text_list == nil) then
        return
    end

    for idx, text in ipairs(text_list) do
        vars['infoNode' .. idx]:setVisible(true)
        vars['infoLabel' .. idx]:setString(text)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGoodbyeSelectInfoPopup:initButton()
    local vars = self.vars

	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbyeSelectInfoPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbyeSelectInfoPopup)
