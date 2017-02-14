local PARENT = UI

-------------------------------------
-- class UI_GachaResult_Rune
-------------------------------------
UI_GachaResult_Rune = class(PARENT, ITopUserInfo_EventListener:getCloneTable(),{
        m_lNumberLabel = 'list',
        m_lGachaRuneList = 'list',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GachaResult_Rune:init(l_gacha_rune_list)
    self.m_lGachaRuneList = clone(l_gacha_rune_list)

    local vars = self:load('item_draw_result.ui')
    UIManager:open(self, UIManager.POPUP)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_GachaResult_Rune')

    vars['okBtn']:registerScriptTapHandler(function() self:refresh() end)

    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_GachaResult_Rune:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_GachaResult_Rune'
    self.m_bUseExitBtn = false
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_GachaResult_Rune:click_exitBtn()
    self:close()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GachaResult_Rune:refresh()
	-- 더이상 리스트가 남아있지 않으면 닫음
	if (#self.m_lGachaRuneList <= 0) then
        self:close()
        return
    end

    local vars = self.vars
    local t_rune_data = self.m_lGachaRuneList[1]
	table.remove(self.m_lGachaRuneList, 1)

	do-- 아이콘 표시
        vars['itemNode']:setVisible(true)
        local item = UI_RuneCard(t_rune_data)
        vars['itemNode']:addChild(item.root)

        -- UI 반응 액션
        cca.uiReactionSlow(item.root)
    end

    local t_rune_information = t_rune_data['information']

    do -- 아이템 이름
        local name = t_rune_information['full_name']
        vars['itemLabel']:setString(name)
        vars['itemLabel']:setVisible(true)
    end

    -- 주옵션 문자열
    local main_option_str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['mopt'])
    vars['runeMainOptionLabel']:setString(main_option_str)
    vars['runeMainOptionLabel']:setVisible(true)

    -- 부옵션 문자열
    local sub_option_str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['sopt'])
    vars['runeSubOptionLabel']:setString(sub_option_str)
    vars['runeSubOptionLabel']:setVisible(true)
end
