local GUIDE_MODE =
{
	['master_road'] = 1,
	['capsule_box'] = 2,
}
-------------------------------------
-- class UIC_LobbyGuide
-------------------------------------
UIC_LobbyGuide = class({
		m_titleLabel = 'UIC_Label',
		m_descLabel = 'UIC_Label',
		m_notiIcon = 'cc.Sprite',

		m_mode = 'enum',
     })

-------------------------------------
-- function init
-------------------------------------
function UIC_LobbyGuide:init(title_label, desc_label, noti_icon)
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
	local has_reward, _ = g_masterRoadData:hasRewardRoad()

	-- 마스터의 길 보상이 있는 경우
	if (has_reward) then
		is_show_master_road = true
	-- 마스터의 길을 전부 클리어한 경우
	elseif (g_masterRoadData:isClearAllRoad()) then
		is_show_master_road = false
	-- 랜덤
	else
		is_show_master_road = (math_random(2) == 1)
	end

	-- 마스터의 길
	if (is_show_master_road) then
		self.m_mode = GUIDE_MODE['master_road']

		local rid = g_masterRoadData:getFocusRoad()
        local t_road = TableMasterRoad():get(rid)

		title = Str('마스터의 길')
        desc = Str(t_road['t_desc'], t_road['desc_1'], t_road['desc_2'], t_road['desc_3'])

		self:setVisibleNotiIcon(has_reward)
		
	-- 드빌 도우미
	else
		self.m_mode = GUIDE_MODE['capsule_box']

		title = Str('캡슐 뽑기')
		desc = Str('1등급 보상 변경')

		self:setVisibleNotiIcon(true)

	end

	-- 텍스트 입력	
	self.m_titleLabel:setString(title)
    self.m_descLabel:setString(desc)
end

-------------------------------------
-- function onClick
-------------------------------------
function UIC_LobbyGuide:onClick()
    if (self.m_mode == GUIDE_MODE['master_road']) then
		local ui = UI_MasterRoadPopup()
		ui:setCloseCB(function()
			self:refresh()
		end)

	elseif (self.m_mode == GUIDE_MODE['capsule_box']) then
		g_capsuleBoxData:openCapsuleBoxUI(true) -- show_reward_list
		self:setVisibleNotiIcon(false)

	end
end

-------------------------------------
-- function setVisibleNotiIcon
-------------------------------------
function UIC_LobbyGuide:setVisibleNotiIcon(b)
	self.m_notiIcon:setVisible(b)
end

--@CHECK
UI:checkCompileError(UIC_LobbyGuide)
