local PARENT = UI

-------------------------------------
-- class UI_GachaResult_Dragon
-------------------------------------
UI_GachaResult_Dragon = class(PARENT, {
        m_lGachaDragonList = 'list',
		m_lDragonCardList = 'list',

		m_currDragonAnimator = 'UIC_DragonAnimator',

		m_isDirecting = 'bool',
        m_hideUIList = '',

        m_eggID = 'number',
        m_eggRes = 'string',
        m_bSkip = 'bool',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GachaResult_Dragon:init(l_gacha_dragon_list, l_slime_list, egg_id, egg_res)

    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData_checkNumber()

    self.m_eggID = egg_id
    self.m_eggRes = egg_res
    self.m_bSkip = false

    -- 드래곤리스트, 슬라임 리스트 copy
    local copy_dragon_list = l_gacha_dragon_list and clone(l_gacha_dragon_list) or {}
    local copy_slime_list = l_slime_list and clone(l_slime_list) or {}

    -- 연출에 사용될 리스트 merge
    self.m_lGachaDragonList = {}
    for i,v in ipairs(copy_dragon_list) do
        local struct = StructDragonObject(v)
        table.insert(self.m_lGachaDragonList, struct)
    end
    for i,v in ipairs(copy_slime_list) do
        local struct = StructSlimeObject(v)
        table.insert(self.m_lGachaDragonList, struct)
    end

    -- 순서 셔플
    self.m_lGachaDragonList = table.sortRandom(self.m_lGachaDragonList)
    

    local vars = self:load('dragon_summon_result.ui')
    UIManager:open(self, UIManager.SCENE)

    -- @UI_ACTION
    self:doActionReset()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_GachaResult_Dragon')

	-- 멤버 변수
	self.m_lDragonCardList = {}
	self.m_isDirecting = false
    self.m_hideUIList = {}

	self:initUI()
	self:initButton()
    self:refresh()

    SoundMgr:stopBGM()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GachaResult_Dragon:initUI()
    self.vars['skipBtn']:setVisible(true)

	if (table.count(self.m_lGachaDragonList) > 1) then
		self:setDragonCardList()
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GachaResult_Dragon:initButton()
	local vars = self.vars
	vars['okBtn']:registerScriptTapHandler(function() self:refresh() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_skipBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GachaResult_Dragon:refresh()
    if (#self.m_lGachaDragonList <= 0) then
        self:close()
        return
    end

    local t_gacha_dragon = self.m_lGachaDragonList[1]
    table.remove(self.m_lGachaDragonList, 1)
    local is_last = (#self.m_lGachaDragonList <= 0)

    local vars = self.vars

	-- 연출을 위한 준비
	self.m_isDirecting = true
	vars['starVisual']:setVisible(false)
    vars['okBtn']:setEnabled(false)
	vars['bgNode']:removeAllChildren()
	local function start_directing_cb()
        -- 플래시 연출
		do
			vars['splashLayer']:setLocalZOrder(1)
			vars['splashLayer']:setVisible(true)
			vars['splashLayer']:stopAllActions()
			vars['splashLayer']:setOpacity(255)
			vars['splashLayer']:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.Hide:create()))
		end

		-- 드래곤 애니메이터 및 정보 갱신
		self:refresh_dragon(t_gacha_dragon)

		-- 해당 드래곤 카드 visible on
		local card = self.m_lDragonCardList[t_gacha_dragon]
		if (card) then
			card.root:setVisible(true)
		end
	end

    -- 마지막에만 보여야 하는 UI들을 관리
    for i,v in pairs(self.m_hideUIList) do
        v:setVisible(is_last)
    end

    if self.m_bSkip then
        start_directing_cb()
    else
        -- ui 다시 집어넣고 연출 시작
	    self:doActionReverse(start_directing_cb, 0.2)
    end
end

-------------------------------------
-- function refresh_dragon
-------------------------------------
function UI_GachaResult_Dragon:refresh_dragon(t_dragon_data)
	local vars = self.vars

    local did = t_dragon_data['did']
    local grade = t_dragon_data['grade']
    local evolution = t_dragon_data['evolution']

    -- 이름
    local name = t_dragon_data:getDragonNameWithEclv()
    vars['nameLabel']:setString(name .. '-' .. evolutionName(evolution))

    do -- 능력치
        self:refresh_status(t_dragon_data)
    end

    do -- 희귀도
        local rarity = t_dragon_data:getRarity()
        vars['rarityNode']:removeAllChildren()
        local icon = IconHelper:getRarityIcon(rarity)
        vars['rarityNode']:addChild(icon)

        vars['rarityLabel']:setString(dragonRarityName(rarity))
    end

    do -- 드래곤 속성
        local attr = t_dragon_data:getAttr()
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)

        vars['attrLabel']:setString(dragonAttributeName(attr))
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon_data:getRole()
        vars['roleNode']:removeAllChildren()
        local icon = IconHelper:getRoleIcon(role_type)
        vars['roleNode']:addChild(icon)

        vars['roleLabel']:setString(dragonRoleName(role_type))
    end

    do -- 드래곤 실리소스
        vars['dragonNode']:removeAllChildren()
		local dragon_animator = UIC_DragonAnimatorDirector_Summon()
		vars['dragonNode']:addChild(dragon_animator.m_node)
        
        -- 드래곤 등장 후의 연출
		local function cb()
			-- 등급
			vars['starVisual']:setVisible(true)
            local ani_name = TableDragon:getStarAniName(did, evolution)
            ani_name = ani_name .. grade
			vars['starVisual']:changeAni(ani_name)
			
			-- 배경
			local attr = TableDragon:getDragonAttr(did)
			if self:checkVarsKey('bgNode', attr) then
				local animator = ResHelper:getUIDragonBG(attr, 'idle')
				vars['bgNode']:addChild(animator.m_node)
			end

			-- ui 연출
			local function directing_done()
				self.m_isDirecting = false

                -- 중복 클릭을 방지하기 위해 막았던 버튼을 풀어줌
                vars['okBtn']:setEnabled(true)
			end
            self:doAction(directing_done, false)

            -- 마지막 드래곤이었을 경우 스킵 버튼 숨김
            if (table.count(self.m_lGachaDragonList) <= 0) then
                vars['skipBtn']:setVisible(false)
            end
        end

        dragon_animator:bindEgg(self.m_eggID, self.m_eggRes)
        dragon_animator:setDragonAppearCB(cb)
        dragon_animator:setDragonAnimator(t_dragon_data['did'], evolution, nil)
		dragon_animator:startDirecting()

        -- 자코 드래곤 크기 조절 (드래곤 중 태생이 1인 경우 자코)
        if (t_dragon_data.m_objectType == 'dragon') then
            if (TableDragon:isUnderling(t_dragon_data['did'])) then
                local dragon_node = dragon_animator.vars['dragonNode']
                local scale = dragon_node:getScale()
                scale = (scale * 0.7)
                dragon_node:setScale(scale)
            end
        end

		self.m_currDragonAnimator = dragon_animator

        if (self.m_bSkip == true) then
            dragon_animator:forceSkipDirecting()
        end
    end
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_GachaResult_Dragon:refresh_status(t_dragon_data)
    local vars = self.vars

    local is_slime_object = (t_dragon_data.m_objectType == 'slime')

    if is_slime_object then
        vars['atk_label']:setString('0')
        vars['def_label']:setString('0')
        vars['hp_label']:setString('0')
    else
        local dragon_id = t_dragon_data['did']
        local lv = t_dragon_data['lv'] or 1
        local grade = t_dragon_data['grade'] or 1
        local evolution = t_dragon_data['evolution'] or 1
        local eclv = eclv

        -- 능력치 계산기
        local status_calc = MakeDragonStatusCalculator(dragon_id, lv, grade, evolution, eclv)

        vars['atk_label']:setString(status_calc:getFinalStatDisplay('atk'))
        vars['def_label']:setString(status_calc:getFinalStatDisplay('def'))
        vars['hp_label']:setString(status_calc:getFinalStatDisplay('hp'))
    end
end

-------------------------------------
-- function setDragonCardList
-------------------------------------
function UI_GachaResult_Dragon:setDragonCardList()
	self.m_lDragonCardList = {}

	local card_node = self.vars['dragonIconNode']

	local gap = 10								-- 카드 간격
	local total_card = #self.m_lGachaDragonList	-- 총 카드 수
	local card_width = 150						-- 카드 넓이

	-- 시작 좌표
	local pos_x = - 720 - (total_card * gap / 2)

	for i, t_data in pairs(self.m_lGachaDragonList) do
		t_data['lv'] = nil

		-- 드래곤 카드 생성
		local card = UI_DragonCard(t_data)
		
		-- 카드..처리
		card.root:setPositionX(pos_x)
		card.root:setVisible(false)
		card_node:addChild(card.root)
		
		-- 카드 클릭시 드래곤을 보여준다.
		card.vars['clickBtn']:registerScriptTapHandler(function()
			if (self.m_isDirecting == false) then
				self:refresh_dragon(t_data)
				self.m_currDragonAnimator:forceSkipDirecting()
			end
		end)

		-- 리스트에 저장 (연출을 위해)
		self.m_lDragonCardList[t_data] = card

		-- 다음 좌표 계산
		pos_x = pos_x + (card_width + gap)
	end

	doAllChildren(card_node, function(node) node:setCascadeOpacityEnabled(true) end)
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UI_GachaResult_Dragon:click_skipBtn()
    self.m_bSkip = true

	if (table.count(self.m_lGachaDragonList) > 1) then
		-- 마지막 데이터만 남긴다.
		local t_last_data = self.m_lGachaDragonList[#self.m_lGachaDragonList]
		self.m_lGachaDragonList = {t_last_data}

		-- 남은 드래곤 카드들도 오픈한다.
		for _, card in pairs(self.m_lDragonCardList) do
			card.root:setVisible(true)
		end

        self:refresh()
	end

	-- 마지막 드래곤 animator를 띄우고 마지막 연출을 실행한다.
    if self.m_currDragonAnimator then
	    self.m_currDragonAnimator:forceSkipDirecting()
    end

	-- 스킵을 했다면 스킵 버튼을 가린다.
	self.vars['skipBtn']:setVisible(false)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_GachaResult_Dragon:click_closeBtn()
    local skip_btn = self.vars['skipBtn']
    if (skip_btn:isEnabled() and skip_btn:isVisible()) then
        self:click_skipBtn()
    else
        self:close()
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_GachaResult_Dragon:onClose()
    SoundMgr:playPrevBGM()
    PARENT.onClose(self)
end