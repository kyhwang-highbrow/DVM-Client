local PARENT = UI

-------------------------------------
-- class UI_GameResult_ClanWar
-------------------------------------
UI_GameResult_ClanWar = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GameResult_ClanWar:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon, content_open, score_calc)
    local vars = self:load('event_illusion_result.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_homeBtn() end, 'UI_GameResult_ClanWar')
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_GameResult_ClanWar:click_homeBtn()
	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end

