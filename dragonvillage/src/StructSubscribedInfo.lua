local PARENT = Structure

-------------------------------------
-- class StructSubscribedInfo
-------------------------------------
StructSubscribedInfo = class(PARENT, {
        category = '',
        cur_day = '',
        max_day = '',
        daily_items = '',
        login_items = '',
        reward_list = '',
        next_pid = '',
    })

--{
--        ['catetgory']='basic';
--        ['cur_day']=2;
--        ['max_day']=14;
--        ['daily_items']={
--        };
--        ['login_items']={
--                {
--                        ['oids']={
--                        };
--                        ['count']=100;
--                        ['item_id']=700001;
--                };
--                {
--                        ['oids']={
--                        };
--                        ['count']=100;
--                        ['item_id']=700101;
--                };
--        };
--        ['reward_list']={
--                {
--                        ['received']=false;
--                        ['day']=5;
--                };
--                {
--                        ['received']=false;
--                        ['day']=4;
--                };
--                {
--                        ['received']=false;
--                        ['day']=6;
--                };
--                {
--                        ['received']=false;
--                        ['day']=8;
--                };
--                {
--                        ['received']=false;
--                        ['day']=7;
--                };
--                {
--                        ['received']=true;
--                        ['day']=2;
--                };
--                {
--                        ['received']=false;
--                        ['day']=10;
--                };
--                {
--                        ['received']=true;
--                        ['day']=1;
--                };
--                {
--                        ['received']=false;
--                        ['day']=9;
--                };
--                {
--                        ['received']=false;
--                        ['day']=12;
--                };
--                {
--                        ['received']=false;
--                        ['day']=3;
--                };
--                {
--                        ['received']=false;
--                        ['day']=11;
--                };
--                {
--                        ['received']=false;
--                        ['day']=14;
--                };
--                {
--                        ['received']=false;
--                        ['day']=13;
--                };
--        };
--}

local THIS = StructSubscribedInfo

-------------------------------------
-- function init
-------------------------------------
function StructSubscribedInfo:init(data)

end

-------------------------------------
-- function getClassName
-------------------------------------
function StructSubscribedInfo:getClassName()
    return 'StructSubscribedInfo'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructSubscribedInfo:getThis()
    return THIS
end

-------------------------------------
-- function getDayRewardInfoList
-- @brief key가 day이고 해당 날짜의 보상 정보를 담은 테이블 리턴
-------------------------------------
function StructSubscribedInfo:getDayRewardInfoList()
    local l_ret = {}

    for i,v in pairs(self['reward_list']) do
        local day = v['day']
        local t_data = clone(v)
        t_data['login_items'] = clone(self['login_items'])
        t_data['daily_items'] = clone(self['daily_items'])
        l_ret[day] = t_data 
    end

    return l_ret
end

-------------------------------------
-- function getRemainDaysText
-- @brief 남은 기간 텍스트
-------------------------------------
function StructSubscribedInfo:getRemainDaysText()
    local remain_days = (self['max_day'] - self['cur_day'])
    local text = Str('남은 기간 {1}일', remain_days)
    return text
end

-------------------------------------
-- function getSubscriptionCategory
-- @brief
-------------------------------------
function StructSubscribedInfo:getSubscriptionCategory()
    return self['category']
end

-------------------------------------
-- function makePopupTitle
-- @brief
-------------------------------------
function StructSubscribedInfo:makePopupTitle()
    local category = self:getSubscriptionCategory()

    local res = ''

    if (category == 'basic') then
        res = 'res/ui/typo/kr/pakage/text_daily_dia_0101.png'

    elseif (category == 'premium') then
        res = 'res/ui/typo/kr/pakage/text_daily_dia_0102.png'

    else
        error('category : ' .. category)
    end

    local bg = cc.Sprite:create(res)
    if (not bg) then
        error('res : ' .. res)
    end

    bg:setDockPoint(cc.p(0.5, 0.5))
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    return bg
end

-------------------------------------
-- function makePopupBg
-- @brief
-------------------------------------
function StructSubscribedInfo:makePopupBg()
    local category = self:getSubscriptionCategory()

    local res = ''

    if (category == 'basic') then
        res = 'res/ui/package/bg_daily_dia_0101.png'

    elseif (category == 'premium') then
        res = 'res/ui/package/bg_daily_dia_0102.png'

    else
        error('category : ' .. category)
    end

    local bg = cc.Sprite:create(res)
    if (not bg) then
        error('res : ' .. res)
    end

    bg:setDockPoint(cc.p(0.5, 0.5))
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    return bg
end

-------------------------------------
-- function getNextProductID
-- @brief
-------------------------------------
function StructSubscribedInfo:getNextProductID()
    local next_pid = self['next_pid']
    return tonumber(next_pid)
end