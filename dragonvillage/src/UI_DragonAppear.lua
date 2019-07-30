local PARENT = UI

-------------------------------------
-- class UI_DragonAppear
-------------------------------------
UI_DragonAppear = class(PARENT, {
        m_structDragonObj = '',
		m_currDragonAnimator = 'UIC_DragonAnimator',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonAppear:init(struct_dragon_object)
    self.m_structDragonObj = struct_dragon_object

    self.m_uiName = 'UI_DragonAppear'
    local vars = self:load('dragon_summon_result.ui')
    UIManager:open(self, UIManager.SCENE)

    -- @UI_ACTION
    self:doActionReset()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonAppear')

	self:initUI()
	self:initButton()
    self:refresh()

    SoundMgr:stopBGM()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonAppear:initUI()
    self.vars['skipBtn']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonAppear:initButton()
	local vars = self.vars
	vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonAppear:refresh()
    local vars = self.vars

	-- 연출을 위한 준비
	vars['starVisual']:setVisible(false)
	vars['bgNode']:removeAllChildren()

	do -- 챕터 전환 연출
		vars['splashLayer']:setLocalZOrder(1)
		vars['splashLayer']:setVisible(true)
		vars['splashLayer']:stopAllActions()
		vars['splashLayer']:setOpacity(255)
		vars['splashLayer']:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.Hide:create()))
	end

	-- 드래곤 애니메이터 및 정보 갱신
	self:refresh_dragon(self.m_structDragonObj)
end

-------------------------------------
-- function refresh_dragon
-------------------------------------
function UI_DragonAppear:refresh_dragon(t_dragon_data)
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
        local icon = IconHelper:getRarityIconButton(rarity)
        vars['rarityNode']:addChild(icon)

        vars['rarityLabel']:setString(dragonRarityName(rarity))
    end

    do -- 드래곤 속성
        local attr = t_dragon_data:getAttr()
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIconButton(attr)
        vars['attrNode']:addChild(icon)

        vars['attrLabel']:setString(dragonAttributeName(attr))
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon_data:getRole()
        vars['roleNode']:removeAllChildren()
        local icon = IconHelper:getRoleIconButton(role_type)
        vars['roleNode']:addChild(icon)

        vars['roleLabel']:setString(dragonRoleTypeName(role_type))
    end

    do -- 드래곤 실리소스
        vars['dragonNode']:removeAllChildren()
		local dragon_animator = UIC_DragonAnimatorDirector_Summon()
		vars['dragonNode']:addChild(dragon_animator.m_node)
        
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
			end
            self:doAction(directing_done, false)
        end

        dragon_animator:setDragonAppearCB(cb)
        dragon_animator:setDragonAnimator(t_dragon_data['did'], evolution, nil)
		dragon_animator:startDirecting()

        -- 자코 드래곤 크기 조절
        if (t_dragon_data.m_objectType == 'dragon') then
            if (TableDragon:isUnderling(t_dragon_data['did'])) then
                local dragon_node = dragon_animator.vars['dragonNode']
                local scale = dragon_node:getScale()
                scale = (scale * 0.7)
                dragon_node:setScale(scale)
            end
        end

        -- 즉시 등장
        dragon_animator:forceSkipDirecting()

		self.m_currDragonAnimator = dragon_animator
    end
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonAppear:refresh_status(t_dragon_data)
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
-- function click_closeBtn
-------------------------------------
function UI_DragonAppear:click_closeBtn()
    self:close()
end

-------------------------------------
-- function onClose
-------------------------------------
function UI_DragonAppear:onClose()
    SoundMgr:playPrevBGM()
    PARENT.onClose(self)
end