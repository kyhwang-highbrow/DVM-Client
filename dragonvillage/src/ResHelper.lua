ResHelper = {}

-------------------------------------
-- function getUIDragonBG
-- @brief UI에서 드래곤 속성별 배경 이미지 생성
-------------------------------------
function ResHelper:getUIDragonBG(attr)
    local res = string.format('res/bg/ui/dragon_bg_%s/dragon_bg_%s.vrp', attr, attr)
    local animator = MakeAnimator(res)

    return animator
end