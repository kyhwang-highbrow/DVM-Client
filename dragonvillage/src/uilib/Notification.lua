-------------------------------------
-- class Notification
-------------------------------------
Notification = class{
        m_root = '',
        m_label = '',
        m_msg = '',
    }

-------------------------------------
-- function init
-------------------------------------
function Notification:init(msg, color)
    --local msg = self:getSampleMsg()

    local rect = cc.rect(0, 0, 0, 0)
    local node = cc.Scale9Sprite:create(rect, 'res/ui/temp/toast_notification.png')
    node:setAnchorPoint(cc.p(0.5, 0.5))
    node:setDockPoint(cc.p(0.5, 0.5))

    -- 문자열 길이(글자 단위, byte 아님)
    local msg_len = uc_len(msg)

    -- 글자 숫자에 따라 넓이 조절
    local width = 300
    if msg_len <= 25 then
        width = 300
    elseif msg_len <= 50 then
        width = 450
    else
        width = 600
    end
    node:setNormalSize(width, 40)

    local label = cc.Label:createWithTTF(msg or 'label', Translate:getFontPath(), 20, 0, cc.size(600, 50), 1, 1)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))

    if color then
        label:setColor(color)
        --label:setColor(cc.c3b(0,255,0))
    end
    node:addChild(label)

    self.m_root = node
    self.m_label = label
    self.m_msg = msg
end



-------------------------------------
-- 테스트 텍스트
-------------------------------------
local t_random = {}
table.insert(t_random, '다른 병사를 선택하세요.')
table.insert(t_random, '잘못된 위치입니다! 빈 영역에 병사를 투입하세요!')
table.insert(t_random, '모든 병사가 투입되었습니다.') 
table.insert(t_random, '오류.')

table.insert(t_random, 'Please choose another soldier.')
table.insert(t_random, 'The wrong location! Please put a soldier on an empty area!')
table.insert(t_random, 'All soldiers have been introduced.')
table.insert(t_random, 'error.')

table.insert(t_random, '他の兵士を選択してください。')
table.insert(t_random, '不適切な場所です！空の領域に兵士を投入してください！')
table.insert(t_random, 'すべての兵士が投入されました。')
table.insert(t_random, 'エラー。')

local idx = 0

-------------------------------------
-- function getSampleMsg
-------------------------------------
function Notification:getSampleMsg()
    idx = idx + 1
    if (idx == #t_random) then
        idx = 1
    end
    
    return t_random[idx]
end