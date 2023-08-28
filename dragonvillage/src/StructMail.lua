local PARENT = Structure

-------------------------------------
---@class StructMail
-------------------------------------
StructMail = class(PARENT, {
        -- 서버에서 받음
        id = 'string', -- mid
        uid = 'number',
        nick = 'string',
        mail_type = 'string',
        items_list = 'list',
        expired_at = 'time',
        custom = 'table',

        msg = 'string',

        -- 클라에서 편의를 위해 생성하는 데이터
        category = 'string',
        expire_remain_time = 'time',
    })

local THIS = StructMail

-------------------------------------
-- function init
-------------------------------------
function StructMail:init(data)
    if data then
        -- @TODO ret_fp를 마냥 기다릴 수 없어 클라에서 처리
        if (data.mail_type == 'fp') then
            if (data.nick == nil) then
                data.mail_type = 'ret_fp'
            end
        end

        self:applyTableData(data)
        
        self:setExpireRemainTime()
    end

end

-------------------------------------
-- function getClassName
-------------------------------------
function StructMail:getClassName()
    return 'StructMail'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructMail:getThis()
    return THIS
end

-------------------------------------
-- function setMid
-------------------------------------
function StructMail:setMid(mid)
    self.id = mid
end

-------------------------------------
-- function getMid
-------------------------------------
function StructMail:getMid()
    return self.id
end

-------------------------------------
-- function getItemList
-------------------------------------
function StructMail:getItemList()
    return self.items_list
end

-------------------------------------
-- function getMailType
-------------------------------------
function StructMail:getMailType()
    return self.mail_type
end

-------------------------------------
-- function getTitle
-------------------------------------
function StructMail:getTitle()
    if (self.custom) then
        return self.custom['title']
    else
        return ''
    end
end

-------------------------------------
-- function getMessage
-------------------------------------
function StructMail:getMessage()
    return self.msg
end

-------------------------------------
-- function getCustom
-------------------------------------
function StructMail:getCustom()
    return self.custom
end

-------------------------------------
-- function getNickName
-------------------------------------
function StructMail:getNickName()
    return self.nick
end

-------------------------------------
-- function getMailTitleAndContext
-- @brief mail의 제목과 내용 받아온다
-------------------------------------
function StructMail:getMailTitleAndContext()
    return MailHelper.getMailText(self)
end

-------------------------------------
-- function setExpireRemainTime
-- @brief 만료 기한 갱신
-------------------------------------
function StructMail:setExpireRemainTime()
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    -- 사용 시간을 millisecond에서 second로 변경
    local expired_at = (self['expired_at'] / 1000)

    self['expire_remain_time'] = (expired_at - server_time)
end

local YEAR_TO_SEC = 60 * 60 * 24 * 365
-------------------------------------
-- function getExpireRemainTimeStr
-- @brief 만료 기한 문자열 반환
-------------------------------------
function StructMail:getExpireRemainTimeStr()
    local expire_remain_time = self['expire_remain_time']
    
    -- 1년 이상은 무기한으로 처리
    if (expire_remain_time > YEAR_TO_SEC) then
        return Str('무기한')
    end

    return Str('{1} 남음', ServerTime:getInstance():makeTimeDescToSec(expire_remain_time))
end

-------------------------------------
-- function getFirstItemType
-- @brief 첫번째 아이템 타입 반환
-------------------------------------
function StructMail:getFirstItemType()
	local item_list = self['items_list']
	if (item_list[1]) then
		local item_type = TableItem():getValue(item_list[1]['item_id'], 'type')
		return item_type
	end
end

-------------------------------------
-- function isMailCanReadAll
-- @brief 모두 받기 가능한 메일인지 검사
-------------------------------------
function StructMail:isMailCanReadAll()
    -- 특정 타입의 메일 제외
    if (self['mail_type'] == 'notice') then
        return false
    end

    -- 쿠폰 제외
    if (self['mail_type'] == 'coupon_mail') then
        return false
    end

    -- 아이템 있는지 확인
	if (not self['items_list']) then
		return false
	end
	if (not self['items_list'][1]) then
		return false
	end
	
	local item_id = self['items_list'][1]['item_id']
	return TableItemType:isCanReadAll(item_id)	
end

-------------------------------------
-- function readMe
-- @brief 자기 자신을 읽자
-------------------------------------
function StructMail:readMe(cb_func)
	local mail_id_list = {
        self:getMid()
    }
    local mail_type_list = {
        self:getMailType()
    }
	local function finish_cb(ret)
		if (ret['status'] ~= 0) then
            return
        end

		local item_type = self:getFirstItemType()

		-- 확정권인 경우
		if (item_type == 'ticket') and (#ret['added_items']['dragons'] > 0) then
			local gacha_type = 'mail'
            UI_GachaResult_Dragon(gacha_type, ret['added_items']['dragons'])

        else
            ItemObtainResult_Mail(ret)

        end

        if (cb_func) then
            cb_func()
        end
	end

    -- 소환권 종류는 메일을 받으면 통신 후 결과물 출력
    if self:isSummonType() then
        local item_full_type = self:getItemFullType()
        -- 11연뽑 고급소환권
        if (string.find(item_full_type, 'summon_dragon')) then
            g_mailData:request_summonTicket(mail_id_list, finish_cb)
        
        elseif (string.find(item_full_type, 'summon_100')) then
            g_mailData:request_summon100Ticket(mail_id_list, finish_cb)

        -- 토파즈 드래곤 뽑기
        elseif (string.find(item_full_type, 'summon_draw')) then
            local draw_cb = function()
                g_mailData:request_summonDrawTicket(mail_id_list, finish_cb)
            end
            local ui_draw_info = UI_SummonDrawInfo(self:getItemId(), true)
            ui_draw_info:setDrawCb(draw_cb)
        end
    else
        g_mailData:request_mailRead(mail_id_list, mail_type_list, finish_cb)
    end
end

-------------------------------------
-- function isCouponCode
-- @brief 쿠폰 코드 확인 
-------------------------------------
function StructMail:isCouponCode()
    if (self['mail_type'] == 'coupon_mail') then
        return true
    end

    return false
end

-------------------------------------
-- function isChangeNick
-- @brief 닉네임 변경권 확인 
-------------------------------------
function StructMail:isChangeNick()
    if (not self:getItemList()[1]) then
        return false
    end
    local item_id = self:getItemList()[1]['item_id']
    local item_type = TableItem:getItemType(item_id)
    return (item_type == 'rename')
end

-------------------------------------
-- function isSummonTicket
-- @brief 고급소환권 확인 
-------------------------------------
function StructMail:isSummonTicket()
    if (not self:getItemList()[1]) then
        return false
    end
    local item_id = self:getItemList()[1]['item_id']
    return (item_id == ITEM_ID_SUMMON_TICKET)
end

-------------------------------------
-- function isSummonType
-- @brief 소환권 종류 확인
-- @brief 20210122 item_type == 'summon' : 10+1 고급소환권, 토파즈 드래곤 뽑기권, 100회 뽑기권(일반 or 한정)
-------------------------------------
function StructMail:isSummonType()
    if (not self:getItemList()[1]) then
        return false
    end
    local item_id = self:getItemList()[1]['item_id']
    local item_type = TableItem:getItemType(item_id)
    return (item_type == 'summon')
end

-------------------------------------
-- function getItemFullType
-- @brief 메일 아이템의 풀타입 반환 
-------------------------------------
function StructMail:getItemFullType()
    if (not self:getItemList()[1]) then
        return false
    end
    local item_id = self:getItemList()[1]['item_id']
    local item_full_type = TableItem:getItemFullType(item_id)
    return item_full_type
end

-------------------------------------
-- function getItemId
-- @brief 메일 아이템의 아이디 반환
-------------------------------------
function StructMail:getItemId()
    if (not self:getItemList()[1]) then
        return false
    end
    local item_id = self:getItemList()[1]['item_id']
    return item_id
end

-------------------------------------
-- function isBooster
-------------------------------------
function StructMail:isBooster()
    return (self:isExpBooster() or self:isGoldBooster())
end

-------------------------------------
-- function isExpBooster
-- @brief 경험치 부스터 확인 
-------------------------------------
function StructMail:isExpBooster()
    if (not self:getItemList()[1]) then
        return false
    end
    local item_id = self:getItemList()[1]['item_id']
    return (item_id == ITEM_ID_EXP_BOOSTER)
end

-------------------------------------
-- function isGoldBooster
-- @brief 골드 부스터 확인 
-------------------------------------
function StructMail:isGoldBooster()
    if (not self:getItemList()[1]) then
        return false
    end
    local item_id = self:getItemList()[1]['item_id']
    return (item_id == ITEM_ID_GOLD_BOOSTER)
end

-------------------------------------
-- function isEvolutionStone
-- @brief 진화석 확인
-------------------------------------
function StructMail:isEvolutionStone()
    if (not self:getItemList()[1]) then
        return false
    end
    local item_id = self:getItemList()[1]['item_id']
	local item_type = TableItem:getItemType(item_id)
    return (item_type == 'evolution_stone')
end

-------------------------------------
-- function isSlime
-- @brief 슬라임 확인
-------------------------------------
function StructMail:isSlime()
    if (not self:getItemList()[1]) then
        return false
    end
    local item_id = self:getItemList()[1]['item_id']
	local item_type = TableItem:getItemType(item_id)
    return (item_type == 'slime')
end

-------------------------------------
-- function readChangeNick
-- @brief 닉네임 변경권을 읽는다
-------------------------------------
function StructMail:readChangeNick(cb_func)
    UI_ChangeNickPopup(self:getMid(), cb_func)
end

-------------------------------------
-- function isPick
-- @brief 선택권 확인 
-------------------------------------
function StructMail:isPick()
    if (not self:getItemList()[1]) then
        return false
    end
    local item_id = self:getItemList()[1]['item_id']
    local item_type = TableItem:getItemType(item_id)
    return (item_type == 'pick')
end

-------------------------------------
-- function isInstantSkillSlime
-- @brief 사용 날짜 제한과 같은 이유로 즉시 사용하는 형식의 스킬 슬라임
---@return boolean
-------------------------------------
function StructMail:isInstantSkillSlime()
    if (not self:getItemList()[1]) then
        return false
    end
    local item_id = self:getItemList()[1]['item_id']
    local item_type = TableItem:getItemType(item_id)
    return (item_type == 'mail_slime')
end

-------------------------------------
-- function isPickItem
-- @brief 아이템 선택권 확인 
-------------------------------------
function StructMail:isPickItem()
    if (not self:getItemList()[1]) then
        return false
    end

	-- 2021.11.08 아이템 선택권을 쉽게 추가할 수 있도록 수정
	-- table_item의 full_type이 pick_item일 경우 아이템 선택권 UI 사용
	local item_id = self:getItemList()[1]['item_id']
	local full_type = self:getItemFullType(item_id)
	return (full_type == 'pick_item')

    -- 아이템 선택권 ID
    -- return (item_id == 700701 or item_id == 700702)
end

-------------------------------------
-- function readPickDragon
-- @brief 드래곤 선택권을 읽는다
-------------------------------------
function StructMail:readPickDragon(cb_func)
	local mid = self:getMid()
	local item_id = self['items_list'][1]['item_id']
	UI_PickDragon.makePickDragon(mid, item_id, cb_func)
end

-------------------------------------
-- function readPickItem
-- @brief 재료 선택권을 읽는다
-------------------------------------
function StructMail:readPickItem(cb_func)
	local mid = self:getMid()
	local item_id = self['items_list'][1]['item_id']
	UI_ItemPickPopup(mid, item_id, true, cb_func) -- mid, item_id, is_draw
end

-------------------------------------
-- function readBoosterItem
-- @brief 부스터 아이템을 읽는다
-------------------------------------
function StructMail:readBoosterItem(cb_func)
    local t_item = self:getItemList()[1]
	local item_name = UIHelper:makeItemName(t_item)

    local str_name = Str('{1}', item_name)
    local str_msg = Str('사용하시겠습니까?')
    local msg = str_name .. '\n{@default}' .. str_msg

    local str_msg_sub_1 = Str('사용 중인 부스터가 있으면 시간이 연장됩니다.')
    local str_msg_sub_2 = Str('부스터 사용 중 점검이 진행될 경우 점검시간만큼 시간이 연장됩니다')
    local msg_sub = str_msg_sub_1 .. '\n' .. str_msg_sub_2

    MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, msg_sub, function() self:readMe(cb_func) end)
end

-------------------------------------
-- function isInstantSkillSlime
-- @brief 사용 날짜 제한과 같은 이유로 즉시 사용하는 형식의 스킬 슬라임
---@return boolean
-------------------------------------
function StructMail:readInstantSkillSlime(cb_func)
	local mid = self:getMid()
	local item_id = self['items_list'][1]['item_id']
    require('UI_InstantSkillLevelUpPopup')
    local ui = UI_InstantSkillLevelUpPopup(mid, item_id, cb_func)
end

-------------------------------------
-- function readCouponCode
---@return boolean
-------------------------------------
function StructMail:readCouponCode(cb_func)
	local mail_id_list = {
        self:getMid()
    }

    local mail_type_list = {
        self:getMailType()
    }

    local text = self:getTitle()
    local ui = UI_CouponPopup('highbrow')
    ui.vars['editBox']:setText(text)
    ui.vars['editBox']:registerScriptEditBoxHandler(function() end)
    ui.vars['editBtn']:setEnabled(false)
    ui:setCloseCB(function() 
        if ui.m_couponCode == text then
            if ui.m_isSuccess == true then
                g_mailData:request_mailRead(mail_id_list, mail_type_list, cb_func)
            end
        end
    end)

    return true
end

-------------------------------------
-- function hasItem
-------------------------------------
function StructMail:hasItem()
    return (table.count(self['items_list']) > 0)
end

-------------------------------------
-- function isNotice
-------------------------------------
function StructMail:isNotice()
    return (self:getMailType() == 'notice')
end

-------------------------------------
-- function isNoticeRead
-------------------------------------
function StructMail:isNoticeRead()
    -- custom이 nil 데이터가 들어올 때도 있다?
    -- custom 자체가 없으면 리턴
    if (not self['custom']) then return true end

    return (self:isNotice() and (self['custom']['received'] == true))
end

-------------------------------------
-- function isNoticeHasReward
-------------------------------------
function StructMail:isNoticeHasReward()
    return (not self:isNoticeRead() and self:hasItem())
end

-------------------------------------
-- function getNoticeArticleID
-------------------------------------
function StructMail:getNoticeArticleID()
    if (not self['custom']) then
        return
    end
    local lang = g_localData:getLang()
    return self['custom']['article_id_' .. lang]
end

-------------------------------------
-- function hasValidNoticeMessage
-------------------------------------
function StructMail:hasValidNoticeMessage(t_mail)
    -- 게임내 공지 팝업 추가함에 따라
    -- 현 언어로 설정된 저목과 내용이 존재하는지로 유효한 공지인지 판단
    if (not t_mail['custom']) then
        return false
    end

    local lang = g_localData:getLang()
    local title = t_mail['custom']['title_' .. lang]
    local msg = t_mail['custom']['popup_msg_' .. lang]

    -- return false if title or msg string is numm or empty
    if (title == nil or msg == nil) then return false end

    if (title == '' or msg == '') then return false end

    return true
end

-------------------------------------
-- function readNotice
-- @brief 공지 읽기
-------------------------------------
function StructMail:readNotice(cb_func, isShowPopup)
    local isPopupShow = isShowPopup
    -- 팝업만 띄우고 보상은 팝업에서.
    if isPopupShow then
        UI_IngameNoticeFullPopup(self, cb_func)
        return
    end
    
    -- 공지 띄우기
    --local article_id = self:getNoticeArticleID()
    --if (article_id) then
    --    NaverCafeManager:naverCafeStartWithArticle(article_id)
    --end

    -- 공지 읽기
    if (not self:isNoticeRead()) then
        -- 받은 것으로 처리해준다
        self['custom']['received'] = true

        -- readMe와 분리되어 유지보수편의성이 떨어지지만 공지는 특이하게 동작하므로 분리
        local mail_id_list = {
            self:getMid()
        }
        local mail_type_list = {
            self:getMailType()
        }

        local function finish_cb(ret)
            local l_item = ret['added_items'] or {}
            l_item = l_item['items_list']

            -- 보상 팝업이 떠야 할 때
            -- 외부콜백을 받아서 보상팝업이 닫혀야
            -- 그 다음으로 넘어가는게 필요할 떄가 있다.
            -- ex. UI_IngameNoticeFullPopup
            local callback = nil
            if (cb_func) then
                callback = cb_func
            end

            -- 보상 있으면 보상 팝업
            if (l_item) and (table.count(l_item) > 0) then
                UI_ObtainPopup(l_item, Str('공지는 꼭 확인하라골!'), callback)
            else
                -- 보상이 없는데 들어왔을 때
                if callback then callback() end
            end
        end

        g_mailData:request_mailRead(mail_id_list, mail_type_list, finish_cb)
    end
end