local PARENT = TableClass

-------------------------------------
-- class TableUserLevel
-------------------------------------
TableUserLevel = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableUserLevel:init()
    self.m_tableName = 'user_level'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getUserLevelExpPercentage
-- @breif
-------------------------------------
function TableUserLevel:getUserLevelExpPercentage(lv, exp)
    local t_user_level = self:get(lv)

    local req_exp = t_user_level['req_exp']
    local percentage = (exp / req_exp)

    -- @mskim 경험치 자릿수가 크기 때문에 formating 시 정확도가 떨어지는 경우가 있어 수정함
    percentage = math_floor(percentage * 10000) / 100

    return percentage
end

-------------------------------------
-- function getReqExp
-- @breif
-------------------------------------
function TableUserLevel:getReqExp(lv)
    local t_user_level = self:get(lv)
    return t_user_level['req_exp']
end

-------------------------------------
-- function getStaminaGift
-- @breif before_lv 에서 after_lv 도달 시 스태미나 수량
-------------------------------------
function TableUserLevel:getStaminaGift(before_lv, after_lv)
    local total_stamina = 0
    for lv = before_lv + 1, after_lv do
        t_user_level = self:get(lv)
        total_stamina = total_stamina + t_user_level['get_stamina']
    end

    return total_stamina
end

-------------------------------------
-- function getBetweenExp
-- @breif 두 레벨과 경험치 사이의 경험치를 리턴
-------------------------------------
function TableUserLevel:getBetweenExp(low_lv, low_lv_exp, high_lv, high_lv_exp)

    if (high_lv < low_lv) then
        --error()
        return 0
    end

    if (low_lv == high_lv) and (high_lv_exp < low_lv_exp) then
        --error()
        return 0
    end

    local between_exp = 0

    for i=low_lv, high_lv do
        local t_table = self:get(i)

        if (i == low_lv) then
            if (low_lv == high_lv) then
                between_exp = between_exp + (high_lv_exp - low_lv_exp)
            else
                between_exp = between_exp + (t_table['req_exp'] - low_lv_exp)
            end

        elseif (i < high_lv) then
            between_exp = between_exp + t_table['req_exp']

        elseif (i == high_lv) then
            between_exp = between_exp + high_lv_exp

        else
            error()
        end
    end

    return between_exp
end