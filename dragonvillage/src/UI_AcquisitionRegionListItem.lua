local PARENT = class(UI, ITableViewCell:getCloneTable())


-------------------------------------
-- class UI_AcquisitionRegionListItem
-------------------------------------
UI_AcquisitionRegionListItem = class(PARENT, {
        m_region = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AcquisitionRegionListItem:init(region)
    self.m_region = region

    local vars = self:load('location_popup_list.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @TODO UI를 공유하기 위해서 임의로 작업, 차후에 수정할 예정
-------------------------------------
function UI_AcquisitionRegionListItem:initUI()
    local vars = self.vars
    
    local stage_id = tonumber(self.m_region)

	-- 넘어온 값이 숫자라면 룬 획득방법으로 간주
	if (stage_id) then
		do -- 스테이지 카테고리
			local category = g_stageData:getStageCategoryStr(stage_id)
			vars['locationLabel1']:setString(category)
		end

		do -- 스테이지 이름
			local name = g_stageData:getStageName(stage_id)
			vars['locationLabel2']:setString(name)
		end

		do -- 보스 썸네일 표시
			local table_stage_desc = TableStageDesc()
			local icon = table_stage_desc:getLastMonsterIcon(stage_id)
			vars['iconNode']:addChild(icon.root)
		end

	-- 드래곤 획득 방법
	else
		local get_type = self.m_region
		local title_str, content_str

		if (get_type == 'combine') then
			title_str = Str('[조합]')
			content_str = Str('조합에서 획득')

		elseif string.find(get_type, 'pick_low') then
			title_str = Str('[일반 알 부화]')
			content_str = Str('1~3★ 드래곤 알에서 획득')

		elseif string.find(get_type, 'pick_high') then
			title_str = Str('[고급 알 부화]')
			content_str = Str('3~5★ 드래곤 알에서 획득')

		elseif (get_type == 'mileage') then
			title_str = Str('[특수 알 부화]')
			content_str = Str('신화, 기적, 초월, 환상의 알에서 획득')

		elseif (get_type == 'friend') then
			title_str = Str('[우정 알 부화]')
			content_str = Str('1~3★ 우정 부화에서 획득')

		elseif (get_type == 'relation') then
			title_str = Str('[인연 던전]')
			content_str = Str('인연 던전에서 획득')

		elseif (get_type == 'empty') then
			title_str = Str('[획득 불가]')
			content_str = Str('이벤트에서 획득')
			vars['locationBtn']:setVisible(false)

        elseif string.find(get_type, 'coupon') then
            local n_time = string.gsub(get_type, 'coupon', '')
            title_str = Str('[오프라인 카드]')
            content_str = Str('드래곤 빌리지 카드 {1}탄 쿠폰에서 획득', n_time)

		end

		vars['locationLabel1']:setString(title_str)
		vars['locationLabel2']:setString(content_str)
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AcquisitionRegionListItem:initButton(t_user_info)
    local vars = self.vars
    vars['locationBtn']:registerScriptTapHandler(function() self:click_locationBtn() end)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_AcquisitionRegionListItem:refresh(t_user_info)
    local vars = self.vars
end

-------------------------------------
-- function click_locationBtn
-- @brief
-------------------------------------
function UI_AcquisitionRegionListItem:click_locationBtn()
    local stage_id = tonumber(self.m_region)
	-- 숫자라면 룬으로 간주
	if (stage_id) then
		g_stageData:goToStage(stage_id)

	-- 드래곤으로 간주
	else
		local get_type = self.m_region

		if (get_type == 'combine') then
			g_hatcheryData:openHatcheryUI(close_cb, get_type)

		elseif (get_type == 'pick_low') then
			g_hatcheryData:openHatcheryUI(close_cb)

		elseif (get_type == 'pick_high') then
			g_hatcheryData:openHatcheryUI(close_cb)

		elseif (get_type == 'mileage') then
			g_hatcheryData:openHatcheryUI(close_cb)

		elseif (get_type == 'friend') then
			g_hatcheryData:openHatcheryUI(close_cb)

		elseif (get_type == 'relation') then
			g_hatcheryData:openHatcheryUI(close_cb, get_type)

        elseif string.find(get_type, 'coupon') then
            ccdisplay('쿠폰 등록 팝업으로 이동!')

		end
	end
end