local PARENT = UI

-------------------------------------
-- class UI_CapsuleBoxResultPopup
-------------------------------------
UI_CapsuleBoxResultPopup = class(PARENT,{
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBoxResultPopup:init(data)
    local vars = self:load('capsule_box_result.ui')
    self.m_uiName = 'UI_CapsuleBoxResultPopup'
    self.m_rewardInfo = data
    UIManager:open(self, UIManager.POPUP)
    -- 백키 블럭 해제
    UIManager:blockBackKey(false)
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_CapsuleBoxResultPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBoxResultPopup:initUI()
    local vars = self.vars
  
    local reward_info =  self.m_rewardInfo

	for idx, t_item in pairs(reward_info) do
		local item_id = t_item['item_id']
		local item_cnt = t_item['count']
        
		local card = UI_ItemCard(item_id, item_cnt)
		vars['dropRewardMenu']:addChild(card.root)

        -- 아이템 카드 설정
        local scale = 0.65
		local pos_x = UIHelper:getCardPosXWithScale(10, idx, scale)
		card.root:setPositionX(pos_x)
        card.root:setScale(scale)
        cca.uiReactionSlow(card.root, scale, scale, scale - 0.1)

        -- legend의 1,2 등급 아이템에 빛나는 이펙트 추가
        local grade = self:getRarity(item_id)
        self:setItemCardRarity(card, grade)
	end

    -- 캡슐 수량이 부족해서 10개 미만이 뽑혔을 경우 경고 문구
    if (#reward_info < 10) then
        vars['noticeLabel']:setString(Str('남아있는 캡슐 상품이 부족하여 획득한 상품의 개수만큼만 캡슐 코인이 사용되었습니다.'))
    else
        vars['noticeLabel']:setString('')
    end
end

-------------------------------------
-- function setItmeCardRarity()
-------------------------------------
function UI_CapsuleBoxResultPopup:setItemCardRarity(item_card, grade)
	if (not grade) then
        return
    end

	local rarity_effect = MakeAnimator('res/ui/a2d/card_summon/card_summon.vrp')
	if (grade == 1) then
		rarity_effect:changeAni('summon_regend', true)
	else
		rarity_effect:changeAni('summon_hero', true)
	end
	rarity_effect:setScale(1.7)
	rarity_effect:setAlpha(0)
	item_card.root:addChild(rarity_effect.m_node)
    rarity_effect.m_node:runAction(cc.FadeIn:create(0.2))

end

-------------------------------------
-- function getRarity()
-- @brief 1,2등급인지 판단
-------------------------------------
function UI_CapsuleBoxResultPopup:getRarity(item_id)
    local capsulebox_data = g_capsuleBoxData:getCapsuleBoxInfo()
    local struct_capsule_box = capsulebox_data['first']

    -- 1등급 판단
    local rank = 1
    local l_reward = struct_capsule_box:getRankRewardList(rank)
    for i, struct_reward in ipairs(l_reward) do
        if (struct_reward['item_id'] == item_id) then
            return rank
        end
    end

    --2등급 판단
    rank = 2
    l_reward = struct_capsule_box:getRankRewardList(rank)
    for i, struct_reward in ipairs(l_reward) do
        if (struct_reward['item_id'] == item_id) then
            return rank
        end
    end

    -- 1,2 등급이 아니라면 nil값 반환
    return nil 
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBoxResultPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBoxResultPopup:refresh()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_CapsuleBoxResultPopup:click_okBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_CapsuleBoxResultPopup)
