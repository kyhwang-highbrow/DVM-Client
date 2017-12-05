local PARENT = UI_Card

-------------------------------------
-- class UI_ReinforcePointCard
-------------------------------------
UI_ReinforcePointCard = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ReinforcePointCard:init(t_item, count)
    self.ui_res = 'card_relation.ui'
    self:getUIInfo()

    -- 버튼 생성과 배경 이미지 생성
    self:makeClickBtn()

    -- 카드 프레임
    self:makeFrame()

    -- 등급 아이콘 생성
    self:refresh_gradeIcon(t_item['grade'])

    -- 수량 표시
    self:makeNumberLabel(count)
end

-------------------------------------
-- function makeClickBtn
-------------------------------------
function UI_ReinforcePointCard:makeClickBtn()
    UI_CharacterCard.makeClickBtn(self)
end

-------------------------------------
-- function makeFrame
-- @brief 프레임 생성
-------------------------------------
function UI_ReinforcePointCard:makeFrame(res)
    local res = 'card_rp_frame.png'
    self:makeSprite('frameNode', res)

    local sprite = cc.Sprite:create('res/ui/icons/item/reinforce_point.png')
    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    self.vars['frameNode']:addChild(sprite)
end

-------------------------------------
-- function refresh_gradeIcon
-- @brief 등급 아이콘
-------------------------------------
function UI_ReinforcePointCard:refresh_gradeIcon(grade)
    local color = 'yellow'
    local res = string.format('card_star_%s_01%02d.png', color, grade)
    self:makeSprite('starNode', res)
end

-------------------------------------
-- function makeNumberLabel
-- @brief 수량 표시
-- @comment Label 과 같은 경우는 따로 만들어주고 setCardInfo만 해준다
-------------------------------------
function UI_ReinforcePointCard:makeNumberLabel(count)
    local vars = self.vars
    local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 40, 2, cc.size(100, 50), 2, 1)
    label:enableShadow(cc.c4b(0,0,0,255), cc.size(3, -3), 1)
    self:setCardInfo('numberNode', label)

    -- 인연 포인트 수치
    if (not count) or (count == 0) then
        label:setString('')
    else
        label:setString(Str('{1}', comma_value(count)))
    end

    vars['clickBtn']:addChild(label, 5)
    vars['numberNode'] = label
end