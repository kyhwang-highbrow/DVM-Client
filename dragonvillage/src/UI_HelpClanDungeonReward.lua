local PARENT = UI_TabUI_AutoGeneration

-------------------------------------
-- class UI_HelpClanDungeonReward
-------------------------------------
UI_HelpClanDungeonReward = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HelpClanDungeonReward:init(ui_name, is_root, ui_depth, struct_tab_ui)
    self.m_uiName = 'UI_HelpClanDungeonReward'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HelpClanDungeonReward:initUI()

    local vars = self.vars

    -- 시즌 클랜 코인 보상 개수 
    local t_clan_coin_max = {
        2000,
        1800,
        1700,
        1600,
        1400,
        1200,
        1000,
        800
    }

    -- 개인 보상 최대 퍼센트
    local personal_max_percent = 0.08

    for i, cnt in ipairs(t_clan_coin_max) do
        if (vars['clancoinLabel'..i]) then
            vars['clancoinLabel'..i]:setString(Str('{1}개', comma_value(cnt)))
        end
        
        local personal_cnt = math_floor(cnt * personal_max_percent)
        if (vars['personalLabel'..i]) then
            vars['personalLabel'..i]:setString(Str('{1}개', comma_value(personal_cnt)))
        end
    end

    PARENT.initUI(self)
end