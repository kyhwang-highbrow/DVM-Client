local PARENT = LobbyGuideAbstract

-------------------------------------
-- class LobbyGuide_CapsuleBox
-------------------------------------
LobbyGuide_CapsuleBox = class(PARENT, {
        m_bActiveGuide = 'boolean',
        m_titleStr = 'string',
        m_subTitleStr = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyGuide_CapsuleBox:init(title_str, sub_title_str)
    self.m_bActiveGuide = false
    self.m_titleStr = title_str or 'title'
    self.m_subTitleStr = sub_title_str or 'sub title'
end

-------------------------------------
-- function checkCondition
-- @brief 조건 확인
-------------------------------------
function LobbyGuide_CapsuleBox:checkCondition()
    self.m_bActiveGuide = false

    -- 각종 조건들
	local wday = pl.Date():weekday_name()
	local lv = g_userData:get('lv')

	-- 캡슐 : 1일 1회 / 매주 화, 토 / 20렙 이상
	local seen_capsule = g_lobbyGuideData:getDailySeen('capsule_box')
	if (not seen_capsule) and (lv >= 20) then
		--if (wday == 'Tue') or (wday == 'Sat') then
			self.m_bActiveGuide = true
		--end
	end
end

-------------------------------------
-- function startGuide
-- @brief 안내 시작
-------------------------------------
function LobbyGuide_CapsuleBox:startGuide()
    g_capsuleBoxData:openCapsuleBoxUI(true) -- show_reward_list
    g_lobbyGuideData:setDailySeen('capsule_box')
end

return LobbyGuide_CapsuleBox