local GUIDE_MODE =
{
	['capsule_box'] = 1,
	['ancient'] = 2,
	['colosseum'] = 3,
	['shop'] = 4,

	['master_road'] = 98,
	['off'] = 99,
}
-------------------------------------
-- class UIC_LobbyGuide
-------------------------------------
UIC_LobbyGuide = class({
		m_root = '',
		m_titleLabel = 'UIC_Label',
		m_descLabel = 'UIC_Label',
		m_notiIcon = 'cc.Sprite',

		m_mode = 'enum',
     })

-------------------------------------
-- function init
-- @comment 당초 예상보다 필요한게 많아서... 나중에 필요하면 UI로 만들자
-------------------------------------
function UIC_LobbyGuide:init(root, title_label, desc_label, noti_icon)
	self.m_root = root
	self.m_titleLabel = title_label
	self.m_descLabel = desc_label
	self.m_notiIcon = noti_icon
end

-------------------------------------
-- function refresh
-------------------------------------
function UIC_LobbyGuide:refresh()
	local title, desc
	local is_show_master_road
	
	-- 안내 모드
	local mode = self:getModeByCondition()
	self.m_mode = mode

    -- NPC 버튼 visible을 켜두고 아래 조건들에서 off를 설정
    self.m_root:setVisible(true)

	-- 마스터의 길
	if (mode == GUIDE_MODE['master_road']) then
		local rid = g_masterRoadData:getFocusRoad()
        local t_road = TableMasterRoad():get(rid)

		title = Str('마스터의 길')
        desc = Str(t_road['t_desc'], t_road['desc_1'], t_road['desc_2'], t_road['desc_3'])

		local has_reward, _ = g_masterRoadData:hasRewardRoad()
		self:setVisibleNotiIcon(has_reward)

	-- 캡슐
	elseif (mode == GUIDE_MODE['capsule_box']) then
		title = Str('캡슐 뽑기')
		desc = Str('1등급 보상 변경')

		self:setVisibleNotiIcon(true)

	-- off
	elseif (mode == GUIDE_MODE['off']) then
		self.m_root:setVisible(false)
		return

	end

	-- 텍스트 입력	
	self.m_titleLabel:setString(title)
    self.m_descLabel:setString(desc)
end

-------------------------------------
-- function getModeByCondition
-- @brief 조건에 맞춰 도우미 모드를 선택한다.
-------------------------------------
function UIC_LobbyGuide:getModeByCondition()
	-- 마스터의 길 보상 (최우선)
	local has_reward, _ = g_masterRoadData:hasRewardRoad()
	if (has_reward) then
		return GUIDE_MODE['master_road']
	end

	-- 각종 조건들
	local wday = pl.Date():weekday_name()
	local lv = g_userData:get('lv')

	-- 캡슐 : 1일 1회 / 매주 화, 토 / 20렙 이상
	local seen_capsule = g_settingData:getLobbyGuideSeen(GUIDE_MODE['capsule_box'])
	if (not seen_capsule) and (lv >= 20) then
		if (wday == 'Tue') or (wday == 'Sat') then
			return GUIDE_MODE['capsule_box']
		end
	end

	
	-- 그외 여러 컨텐츠 안내 추가 예정
	

	-- 다른 조건에 안걸리고 마스터의 길도 전부 클리어
	if (g_masterRoadData:isClearAllRoad()) then
		return GUIDE_MODE['off']
	else
		return GUIDE_MODE['master_road']
	end
end

-------------------------------------
-- function onClick
-------------------------------------
function UIC_LobbyGuide:onClick()
	-- 마스터의 길
    if (self.m_mode == GUIDE_MODE['master_road']) then
		local ui = UI_MasterRoadPopup()
		ui:setCloseCB(function()
			self:refresh()
		end)

	-- 캡슐
	elseif (self.m_mode == GUIDE_MODE['capsule_box']) then
		g_capsuleBoxData:openCapsuleBoxUI(true) -- show_reward_list

		g_settingData:setLobbyGuideSeen(GUIDE_MODE['capsule_box'])
		self:refresh()

	end
end

-------------------------------------
-- function setVisibleNotiIcon
-------------------------------------
function UIC_LobbyGuide:setVisibleNotiIcon(b)
	self.m_notiIcon:setVisible(b)
end

-------------------------------------
-- function isOffMode
-------------------------------------
function UIC_LobbyGuide:isOffMode()
	return (self.m_mode == GUIDE_MODE['off'])
end

--@CHECK
UI:checkCompileError(UIC_LobbyGuide)
