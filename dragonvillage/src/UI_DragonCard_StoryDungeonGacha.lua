local PARENT = UI_DragonCard_Gacha
-------------------------------------
-- class UI_DragonCard_Gacha
-------------------------------------
UI_DragonCard_StoryDungeonGacha = class(PARENT, {
})

-------------------------------------
-- function setOpenStartCB
-- @param open_start_cb : 카드 오픈 시작 때 호출되는 콜백
-------------------------------------
function UI_DragonCard_StoryDungeonGacha:setOpenStartCB(open_start_cb)
    self.m_openStartCB = open_start_cb
end


-------------------------------------
-- function makeDragonOpenAnimator
-------------------------------------
function UI_DragonCard_StoryDungeonGacha:makeDragonOpenAnimator()
    local vars = self.vars

    -- 카드 오픈 관련 애니메이션 설정
    local res_name = 'res/ui/spine/dragon_gacha/dragon_gacha.json'
    local animator = MakeAnimator(res_name)
    animator:setIgnoreLowEndMode(true)
    animator:changeAni('idle', true)
    animator:setMix('hold', 'flip_1', 0.2)
    animator:setMix('hold', 'flip_3', 0.2)
    animator:setMix('hold', 'flip_4', 0.2)
    self.m_animator = animator
    vars['skipBtn']:addChild(animator.m_node)

    local struct_dragon = self.m_tDragonData
    local rarity = struct_dragon:getRarity()
    if (isExistValue(rarity, 'hero', 'legend', 'myth')) then
        local effect_res_name = 'res/ui/a2d/card_summon/card_summon.vrp'
        local effect_animator = MakeAnimator(effect_res_name)

        effect_animator:setIgnoreLowEndMode(true)
        if (rarity == 'legend') then
			effect_animator:changeAni('summon_regend_2', true)
        elseif (rarity == 'myth') then
            effect_animator:changeAni('summon_mythical', true)
		else
			effect_animator:changeAni('summon_hero', true)
		end
        effect_animator.m_node:setScale(1.7)
        self.m_effectAnimator = effect_animator
        vars['runeNode']:addChild(effect_animator.m_node, 3)
    end
end

-------------------------------------
-- function openCard
-- @param b_do_open_cb : open CB를 동작시킬것인지
-------------------------------------
function UI_DragonCard_StoryDungeonGacha:openCard(b_do_open_cb)
    local vars = self.vars
    
    if (self.m_bIsOpen == true) then
        return
    end

    if (self.m_openConditionFunc) then
        if (self.m_openConditionFunc() == false) then
            return
        end
    end
   
    local animator = self.m_animator

    ---- 열리고 있는 도중인 경우 패스
    if (string.find(animator.m_currAnimation, 'flip')) then
        return
    end

    -- 카드를 뒤집는 애니메이션이 끝나면 드래곤 카드를 오픈 
    -- 전설 등급 이상의 드래곤 카드가 오픈된 이후에도 애니메이션이 이펙트 등으로 남아 있어
    -- 해당하는 경우에는 하드 코딩으로 self.m_openFinishCB을 실행한다.
    local function finish_cb(b_do_finish_cb)
        self.m_bIsOpen = true

        local duration = 0.2
        local fade_out = cc.EaseInOut:create(cc.FadeOut:create(duration), 1)
        animator.m_node:runAction(fade_out)
        animator:setAnimationPause(true)

        vars['runeNode']:setVisible(true)
        if (self.m_openFinishCB) and (b_do_open_cb == true) and (b_do_finish_cb == true) then
            self.m_openFinishCB() 
        end
    end

    local rarity = self.m_tDragonData:getRarity()
    
    if (self.m_openStartCB) and (b_do_open_cb == true) then
        self.m_openStartCB() 
    end

    if rarity == 'myth' then
        -- 1초동안 떨리다가 열리기
        animator:changeAni('hold', true)

        local function change_open_ani()
            local function play_gauging_sound()
                SoundMgr:playEffect('EFFECT', 'reward')
            end

            local function play_bomb_sound()
                SoundMgr:playEffect('UI', 'ui_summon')
            end

            local function card_open_finish_cb()
                if (self.m_openFinishCB) and (b_do_open_cb == true) then
                    self.m_openFinishCB()
                end
            end

            -- 한정 여부에 따른 애니메이션 및 사운드 분기 처리
            local summon_sequence
            if (self.m_tDragonData:isLimited() or (rarity == 'myth')) then
                animator:changeAni('flip_4', false)
                summon_sequence = cc.Sequence:create(cc.CallFunc:create(play_gauging_sound), cc.DelayTime:create(0.6), cc.CallFunc:create(play_bomb_sound),
                 cc.DelayTime:create(2.5), cc.CallFunc:create(play_gauging_sound), cc.DelayTime:create(0.6), cc.CallFunc:create(play_bomb_sound), 
                 cc.DelayTime:create(2.5), cc.CallFunc:create(card_open_finish_cb))
            else
                animator:changeAni('flip_3', false)
                summon_sequence = cc.Sequence:create(cc.CallFunc:create(play_gauging_sound), cc.DelayTime:create(0.6), cc.CallFunc:create(play_bomb_sound), 
                cc.DelayTime:create(1.9), cc.CallFunc:create(card_open_finish_cb))
            end

            self.root:runAction(summon_sequence)
            animator:addAniHandler(function() finish_cb(false) end)
        end

        local sequence = cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(change_open_ani))
        animator.m_node:runAction(sequence)

    else
        animator:changeAni('flip_1', false)
        animator:addAniHandler(function() finish_cb(true) end)
    end

    return self.m_bIsOpen
end