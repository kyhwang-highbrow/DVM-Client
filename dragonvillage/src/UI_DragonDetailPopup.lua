local PARENT = UI

-------------------------------------
-- class UI_DragonDetailPopup
-------------------------------------
UI_DragonDetailPopup = class(PARENT, {
    m_tDragonData = 'table',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonDetailPopup:init(t_dragon_data)
    self.m_tDragonData = t_dragon_data

    local vars = self:load('dragon_manage_detail_info.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonDetailPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonDetailPopup:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonDetailPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonDetailPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-- @brief dragon_id로 드래곤의 상세 정보를 출력
-------------------------------------
function UI_DragonDetailPopup:refresh()
    local vars = self.vars

    -- 유저가 보유하고있는 드래곤의 정보
    local t_dragon_data = self.m_tDragonData
    local dragon_id = t_dragon_data['did']

    -- 테이블에 있는 드래곤의 정보
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    do -- 드래곤 이름    
        vars['nameLabel']:setString(Str(t_dragon['t_name']))
    end

    do -- 드래곤 등급
        vars['starNode']:removeAllChildren()
        local star_res = 'res/ui/icon/star030' .. t_dragon_data['grade'] .. '.png'
        local star_icon = cc.Sprite:create(star_res)
        star_icon:setDockPoint(cc.p(0.5, 0.5))
        star_icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['starNode']:addChild(star_icon)
    end

    do -- level
        local lv_str = Str('{1} / {2}', t_dragon_data['lv'], dragonMaxLevel(t_dragon_data['grade'], t_dragon_data['eclv']))
        vars['lvLabel']:setString(lv_str)
    end

    do -- 경혐치 exp
        local lv = t_dragon_data['lv']
        local table_exp = TABLE:get('exp_dragon')
        local t_exp = table_exp[lv] 
        local max_exp = t_exp['exp_d']
        if (max_exp > 0) then
            local percent = (t_dragon_data['exp'] / max_exp) * 100
            percent = math_floor(percent)
            vars['expLabel']:setString(Str('{1}%', percent))
        else
            vars['expLabel']:setString(Str('최대레벨'))
        end

        --vars['expGg']:setPercentage(percent)
    end

    do -- 진화도
        vars['evolutionLabel']:setString(evolutionName(t_dragon_data['evolution']))
    end

    do -- 희귀도
        local rarity_num = dragonRarityStrToNum(t_dragon['rarity'])
        vars['rarityLabel']:setString(getDragonRarityName(rarity_num))
    end

    do -- 속성
        local attr = t_dragon['attr']
        vars['attrLabel']:setString(dragonAttributeName(attr))
    end

    do -- 역할
        vars['roleLabel']:setString(dragonRoleName(t_dragon['role']))
    end

    do -- 공격유형
        vars['atkTypeLabel']:setString(dragonAttackTypeName(t_dragon['char_type']))
    end

    do -- 능력치 입력
        local doid = t_dragon_data['id']
        local status_calc
        if doid then
            status_calc = MakeOwnDragonStatusCalculator(doid)
        else
            status_calc = MakeDragonStatusCalculator(t_dragon_data['did'], t_dragon_data['lv'], t_dragon_data['grade'], t_dragon_data['evolution'])
        end
        vars['atk_p_label']:setString(status_calc:getFinalStatDisplay('atk'))
        vars['atk_spd_label']:setString(status_calc:getFinalStatDisplay('aspd'))
        vars['cri_chance_label']:setString(status_calc:getFinalStatDisplay('cri_chance'))
        vars['def_p_label']:setString(status_calc:getFinalStatDisplay('def'))
        vars['hp_label']:setString(status_calc:getFinalStatDisplay('hp'))
        vars['cri_avoid_label']:setString(status_calc:getFinalStatDisplay('cri_avoid'))
        vars['avoid_label']:setString(status_calc:getFinalStatDisplay('avoid'))
        vars['hit_rate_label']:setString(status_calc:getFinalStatDisplay('hit_rate'))
        vars['cri_dmg_label']:setString(status_calc:getFinalStatDisplay('cri_dmg'))

        vars['add_atk_p_label']:setString(status_calc:getFinalAddStatDisplay('atk'))
        vars['add_atk_spd_label']:setString(status_calc:getFinalAddStatDisplay('aspd'))
        vars['add_cri_chance_label']:setString(status_calc:getFinalAddStatDisplay('cri_chance'))
        vars['add_def_p_label']:setString(status_calc:getFinalAddStatDisplay('def'))
        vars['add_hp_label']:setString(status_calc:getFinalAddStatDisplay('hp'))
        vars['add_cri_avoid_label']:setString(status_calc:getFinalAddStatDisplay('cri_avoid'))
        vars['add_avoid_label']:setString(status_calc:getFinalAddStatDisplay('avoid'))
        vars['add_hit_rate_label']:setString(status_calc:getFinalAddStatDisplay('hit_rate'))
        vars['add_cri_dmg_label']:setString(status_calc:getFinalAddStatDisplay('cri_dmg'))
    end
end

--@CHECK
UI:checkCompileError(UI_DragonDetailPopup)
