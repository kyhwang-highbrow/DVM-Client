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
            if icon then
			    vars['iconNode']:addChild(icon.root)
            end
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
			content_str = Str('한정 드래곤 포함 알에서 획득')

		elseif (get_type == 'friend') then
			title_str = Str('[우정 알 부화]')
			content_str = Str('1~3★ 우정 부화에서 획득')

		elseif (get_type == 'relation') then
			title_str = Str('[인연 던전]')
			content_str = Str('인연 던전에서 획득')
        elseif (get_type == 'cardpack') then
			title_str = Str('토파즈 드래곤')
			content_str = Str('토파즈 상점에서 구매')

        elseif (get_type == 'dmgate') then
			title_str = Str('차원문')
			content_str = Str('차원문에서 획득')

        -- 슬라임
        elseif (get_type == 'slime_combine') then
            title_str = Str('슈퍼 슬라임 합성')
            content_str = Str('슈퍼 슬라임 합성에서 획득')

        -- 룬
        elseif (get_type == 'rune_gacha') then
            title_str = Str('룬 뽑기')
            content_str = Str('룬 뽑기에서 획득')
        elseif (get_type == 'rune_combine') then
            title_str = Str('룬 합성')
            content_str = Str('룬 합성에서 획득')

		elseif (get_type == 'empty') then
			title_str = Str('[획득 불가]')
			content_str = Str('이벤트에서 획득')
			vars['locationBtn']:setVisible(false)
        elseif (get_type == 'challenge_mode') then
			title_str = Str('그림자의 신전')
            content_str = ''
            local icon = IconHelper:getIcon('res/ui/icons/content/challenge_mode.png')
            if (icon) then
			    vars['iconNode']:addChild(icon)
            end
		elseif (get_type == 'arena_new') then
			title_str = Str('콜로세움')
            content_str = ''
            local icon = IconHelper:getIcon('res/ui/icons/content/arena.png')
            if (icon) then
			    vars['iconNode']:addChild(icon)
            end
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

	else
		local get_type = self.m_region
		if (get_type == 'combine') then
			UINavigator:goTo('hatchery', get_type)

		elseif (get_type == 'pick_low') then
			UINavigator:goTo('hatchery')

		elseif (get_type == 'pick_high') then
			UINavigator:goTo('hatchery')

		elseif (get_type == 'mileage') then
			UINavigator:goTo('hatchery')

		elseif (get_type == 'friend') then
			UINavigator:goTo('hatchery')

		elseif (get_type == 'relation') then
			UINavigator:goTo('hatchery', get_type)
        elseif (get_type == 'cardpack') then
			UINavigator:goTo('shop', 'topaz')

        elseif (get_type == 'dmgate') then
			UINavigator:goTo('dmgate')
        elseif (get_type == 'challenge_mode') then
            -- 그림자 신전이 열려있지 않다면 이동시키지 않음
            if (not g_challengeMode:isOpen_challengeMode()) then
                UIManager:toastNotificationRed(Str('오픈시간이 아닙니다.'))
                return
            end
			UINavigator:goTo('challenge_mode')
		elseif (get_type == 'arena_new') then
			if IS_ARENA_NEW_OPEN() and HAS_ARENA_NEW_SEASON() then
				UINavigator:goTo('colosseum')
			else -- 콜로세움이 열려있지 않으면
				UIManager:toastNotificationRed(Str('오픈시간이 아닙니다.'))
			end

        elseif (get_type == 'slime_combine') then
            -- 슈퍼 슬라임 합성으로 보내기
            UINavigator:goTo('slime_combine')

        elseif (get_type == 'rune_gacha') then
            --룬 가챠로 보내기
            UINavigator:goTo('rune_forge', 'gacha')

        elseif (get_type == 'rune_combine') then
            -- 룬 합성으로 보내기
            UINavigator:goTo('rune_forge', 'combine')

        elseif string.find(get_type, 'coupon') then
            ccdisplay('쿠폰 등록 팝업으로 이동!')

		end
	end
end