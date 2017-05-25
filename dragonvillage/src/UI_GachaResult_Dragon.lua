local PARENT = UI

-------------------------------------
-- class UI_GachaResult_Dragon
-------------------------------------
UI_GachaResult_Dragon = class(PARENT, {
        m_lNumberLabel = 'list',
        m_lGachaDragonList = 'list',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GachaResult_Dragon:init(l_gacha_dragon_list)
    self.m_lGachaDragonList = clone(l_gacha_dragon_list)

    local vars = self:load('dragon_summon_result.ui')
    UIManager:open(self, UIManager.SCENE)

    -- @UI_ACTION
    self:doActionReset()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_GachaResult_Dragon')

	self:initUI()
	self:initButton()
    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_GachaResult_Dragon:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GachaResult_Dragon:initUI()
	if (table.count(self.m_lGachaDragonList) > 1) then
		self.vars['skipBtn']:setVisible(true)
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

    local vars = self.vars
    SoundMgr:playEffect('EFFECT', 'reward')


    do -- 챕터 전환 연출
        vars['splashLayer']:setLocalZOrder(1)
        vars['splashLayer']:setVisible(true)
        vars['splashLayer']:stopAllActions()
        vars['splashLayer']:setOpacity(255)
        vars['splashLayer']:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.Hide:create()))
    end

    local did = t_gacha_dragon['did']
    local grade = t_gacha_dragon['grade']
    local evolution = t_gacha_dragon['evolution']

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[did]

	-- 연출을 위한 준비
	vars['starVisual']:setVisible(false)
	vars['bgNode']:removeAllChildren()
	self:doActionReverse(nil, 0.1)

    -- 이름
    vars['nameLabel']:setString(Str(t_dragon['t_name']) .. '-' .. evolutionName(evolution))

    do -- 능력치
        self:refresh_status(t_gacha_dragon)
    end

    do -- 희귀도
        local rarity = t_dragon['rarity']
        vars['rarityNode']:removeAllChildren()
        local icon = IconHelper:getRarityIcon(rarity)
        vars['rarityNode']:addChild(icon)

        vars['rarityLabel']:setString(dragonRarityName(rarity))
    end

    do -- 드래곤 속성
        local attr = t_dragon['attr']
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)

        vars['attrLabel']:setString(dragonAttributeName(attr))
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon['role']
        vars['roleNode']:removeAllChildren()
        local icon = IconHelper:getRoleIcon(role_type)
        vars['roleNode']:addChild(icon)

        vars['roleLabel']:setString(dragonRoleName(role_type))
    end

    do -- 드래곤 공격 타입(char_type)
        local attack_type = t_dragon['char_type']
        vars['charTypeNode']:removeAllChildren()
        local icon = IconHelper:getAttackTypeIcon(attack_type)
        vars['charTypeNode']:addChild(icon)

        vars['charTypeLabel']:setString(dragonAttackTypeName(attack_type))
    end

    do -- 드래곤 실리소스
        vars['dragonNode']:removeAllChildren()
		local dragon_animator = UIC_DragonAnimatorDirector_Summon()
		vars['dragonNode']:addChild(dragon_animator.m_node)
        
		local function cb()
			-- 등급
			vars['starVisual']:setVisible(true)
			vars['starVisual']:changeAni('result' .. grade)
			
			-- 배경
			local attr = TableDragon:getDragonAttr(did)
			if self:checkVarsKey('bgNode', attr) then
				local animator = ResHelper:getUIDragonBG(attr, 'idle')
				vars['bgNode']:addChild(animator.m_node)
			end

			-- ui 연출
            self:doAction(nil, false)
        end

        dragon_animator:setDragonAppearCB(cb)
        dragon_animator:setDragonAnimator(t_dragon['did'], evolution, nil)
		dragon_animator:startDirecting()
    end
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_GachaResult_Dragon:refresh_status(t_dragon_data)
    local vars = self.vars
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

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UI_GachaResult_Dragon:click_skipBtn()
	ccdisplay('click')
end