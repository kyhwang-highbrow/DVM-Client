local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_GuidePopup_Rune
-------------------------------------
UI_GuidePopup_Rune = class(PARENT,{
    })

UI_GuidePopup_Rune.SUMMARY = 'summary' -- 론 개요
UI_GuidePopup_Rune.NUMBER = 'number' -- 룬 번호
UI_GuidePopup_Rune.TYPE = 'type' -- 룬 종류
UI_GuidePopup_Rune.ENHANCE = 'enhance' -- 룬 강화
UI_GuidePopup_Rune.NIGHTMARE = 'nightmare' -- 악몽 던전
UI_GuidePopup_Rune.ANCIENT_RUIN = 'ancient_ruin' -- 고대 유적 던전

-------------------------------------
-- function init
-------------------------------------
function UI_GuidePopup_Rune:init()
    local vars = self:load('rune_guide_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_GuidePopup_Rune')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GuidePopup_Rune:initUI()
    local vars = self.vars
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GuidePopup_Rune:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GuidePopup_Rune:refresh()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_GuidePopup_Rune:initTab()
    local vars = self.vars

    self:addTabAuto(UI_GuidePopup_Rune.SUMMARY, vars, vars['summaryMenu'])
    self:addTabAuto(UI_GuidePopup_Rune.NUMBER, vars, vars['numberMenu'])
    self:addTabAuto(UI_GuidePopup_Rune.TYPE, vars, vars['typeMenu'])
    self:addTabAuto(UI_GuidePopup_Rune.ENHANCE, vars, vars['enhanceMenu'])
    self:addTabAuto(UI_GuidePopup_Rune.NIGHTMARE, vars, vars['nightmareMenu'])
    self:addTabAuto(UI_GuidePopup_Rune.ANCIENT_RUIN, vars, vars['ancient_ruinMenu'])

    self:setTab(UI_GuidePopup_Rune.SUMMARY)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_GuidePopup_Rune:onChangeTab(tab, first)
    -- 탭할때마다 액션 
    self:doActionReset()
    self:doAction(nil, false)  

    local vars = self.vars
    if (tab == UI_GuidePopup_Rune.SUMMARY) then

        if first then
            local ui = UI()
            ui:load('rune_info_board.ui')
            vars['runeScNode']:removeAllChildren()
            vars['runeScNode']:addChild(ui.root)

            self:setRuneData(ui)
        end
    end
    
end

-------------------------------------
-- function setRuneData
-------------------------------------
function UI_GuidePopup_Rune:setRuneData(ui)
    local vars = ui.vars
    
    local t_rune_data = {}
    t_rune_data["lv"] = 15
    t_rune_data["id"] = "59b32f37476c0d2426b52139"
    t_rune_data["mopt"] = "atk_multi;46"
    t_rune_data["created_at"] = 1504915255534
    t_rune_data["sopt_2"] = "cri_dmg_add;6"
    t_rune_data["sopt_4"] = "cri_chance_add;8"
    t_rune_data["rid"] = 710646
    t_rune_data["rarity"] = 4
    t_rune_data["sopt_1"] = "hit_rate_add;6"
    t_rune_data["updated_at"] = 1514044721832
    t_rune_data["sopt_3"] = "hp_multi;7"
    t_rune_data["uopt"] = "avoid_add;4"
    t_rune_data["lock"] = false
    local rune_obj = StructRuneObject(t_rune_data)

    -- 룬 아이콘 삭제
    vars['runeNode']:removeAllChildren()
    vars['useRuneNameLabel']:setString('')
    vars['useMainOptionLabel']:setString('')
    vars['useSubOptionLabel']:setString('')
    vars['useRuneSetLabel']:setString('')

    -- 룬 명칭
    vars['useRuneNameLabel']:setString(rune_obj['name'])

    -- 룬 아이콘
    local rune_icon = UI_RuneCard(rune_obj)
    vars['runeNode']:addChild(rune_icon.root)

    -- 메인, 유니크 옵션
    vars['useMainOptionLabel']:setString(rune_obj:makeRuneDescRichText())

    -- 서브 옵션
    vars['useSubOptionLabel']:setString('')

    -- 세트 옵션
    vars['useRuneSetLabel']:setString(rune_obj:makeRuneSetDescRichText())

    do -- 레어도
        local color = rune_obj:getRarityColor()
        vars['useRuneNameLabel']:setColor(color)
        vars['useRarityNode']:setColor(color)

        local name = rune_obj:getRarityName()
        vars['useRarityLabel']:setString(name)
    end
end


--@CHECK
UI:checkCompileError(UI_GuidePopup_Rune)
