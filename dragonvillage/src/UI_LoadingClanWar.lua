local PARENT = UI_LoadingArena
local WAITING_TIME = 10

-------------------------------------
-- class UI_LoadingClanWar
-------------------------------------
UI_LoadingClanWar = class(PARENT,{

    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoadingClanWar:init(curr_scene)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoadingClanWar:initUI()
    local vars = self.vars
    local is_friend_match = self.m_bFriendMatch

	vars['arenaVisual']:setVisible(true)
	vars['challengeModeVisual']:setVisible(false)

	-- 플레이어
    do
		local struct_user_info = g_clanWarData:getPlayerUserInfo()
		if (struct_user_info) then
			-- 덱
			local l_dragon_obj = struct_user_info:getDeck_dragonList()
			local leader = struct_user_info.m_pvpDeck['leader']
			local formation = struct_user_info.m_pvpDeck['formation']
			self:initDeckUI('left', l_dragon_obj, leader, formation)

			-- 유저 정보
			self:initUserInfo('left', struct_user_info)
		end
    end

	 -- 상대방
    do
		local struct_user_info = g_clanWarData:getEnemyUserInfo()
		if (struct_user_info) then
			-- 덱
			local l_dragon_obj = struct_user_info:getDeck_dragonList()
			local leader = struct_user_info.m_pvpDeck['leader']
			local formation = struct_user_info.m_pvpDeck['formation']
			self:initDeckUI('right', l_dragon_obj, leader, formation)

			-- 유저 정보
			self:initUserInfo('right', struct_user_info)
		end
    end

    -- 연속 전투 상태 여부에 따라 버튼이나 로딩 게이지 표시
    do
        local is_autoplay = g_autoPlaySetting:isAutoPlay()
    
        vars['btnNode']:setVisible(not is_autoplay)
        vars['loadingNode']:setVisible(is_autoplay)
    end
end
