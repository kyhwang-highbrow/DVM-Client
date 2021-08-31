local PARENT = UI

-------------------------------------
-- class UI_CommunityPopup
-------------------------------------
UI_CommunityPopup = class(PARENT,{

    m_communityBtns = 'List[UIC_Button]',
    m_naverBtn = 'UIC_Button',
    m_facebookBtn = 'UIC_Button',
    m_instagramBtn = 'UIC_Button',
    m_discordBtn = 'UIC_Button',

    m_closeBtn = 'UIC_Button',

    m_rootUrl = 'string',
    m_link = 'table',

    m_gapBtwBtn = 'number',

    })

-------------------------------------
-- function init
-------------------------------------
function UI_CommunityPopup:init(t_notice)
    local vars = self:load('setting_popup_community.ui')

    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CommunityPopup')
    
    self.m_gapBtwBtn = 180
    self.m_rootUrl = 'https://bit.ly/'
    self.m_link = {
        ['instagram'] = '304r5YA',
        ['facebook'] = '2XYU1js',
        ['naver'] = '3cdMWCm',
        ['discord'] = '3kueg3m',
    }
    
    if (Translate:getGameLang() ~= 'ko') then
        self.m_link['naver'] = ''
    end

    self.m_communityBtns = {}

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CommunityPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CommunityPopup:initButton()
    local vars = self.vars

    -- x버튼
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    for key, url in pairs(self.m_link) do
        local button_name  = key .. 'Btn'

        if vars[button_name] then
            if (url ~= '') then
                vars[button_name]:registerScriptTapHandler(function() self:click_communityBtn(key) end)
                table.insert(self.m_communityBtns, vars[button_name])
            else
                vars[button_name]:setVisible(false)
            end
        end
    end
end

-------------------------------------
-- function click_communityBtn
-------------------------------------
function UI_CommunityPopup:click_communityBtn(key)
    if self.m_link[key] then
        SDKManager:goToWeb(self.m_rootUrl .. self.m_link[key])
    end
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_CommunityPopup:refresh()

    -- local button_number = #self.m_communityBtns
    -- local start_index
    -- -- 홀수
    -- local is_odd = (button_number % 2) == 1)
    -- if (is_odd) then
    --     start_index = button_num * 0.5 + 0.5
    -- else -- 짝수
    --     start_index = button_num * 0.5
    -- end

    -- for i = 1, math.floor(button_num * 0.5) do
    --     if (i == 1) then
    --         if is_odd then
    --         else
                
    --         end
    --     else
    --         self.m_communityBtns[start_index + i]
    --         self.m_communityBtns[start_index - i]
    --     end        
    -- end
end
