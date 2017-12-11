local PARENT = Structure

-------------------------------------
-- class StructMail
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
    local server_time = Timer:getServerTime()

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

    return Str('{1} 남음', datetime.makeTimeDesc(expire_remain_time))
end

-------------------------------------
-- function checkTicket
-- @brief 확정권인지 검사한다.
-------------------------------------
function StructMail:checkTicket()
	local item_list = self['items_list']

	-- 확정권인지 체크
	local item_type = TableItem():getValue(item_list[1]['item_id'], 'type')
	if (item_type == 'ticket') then
		return true
	end

	return false
end

-------------------------------------
-- function isMailCanReadAll
-- @brief 모두 받기 가능한 메일인지 검사
-------------------------------------
function StructMail:isMailCanReadAll()
	local item_id = self['items_list'][1]['item_id']
	return (TableItem:getItemTypeFromItemID(item_id) ~= nil)
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

		-- 확정권인 경우
		if (self:checkTicket()) and (#ret['added_items']['dragons'] > 0) then
			local gacha_type = 'mail'
            UI_GachaResult_Dragon(gacha_type, ret['added_items']['dragons'])
        else
            ItemObtainResult_Mail(ret)
        end

        if (cb_func) then
            cb_func()
        end
	end
    
	g_mailData:request_mailRead(mail_id_list, mail_type_list, finish_cb)
end

-------------------------------------
-- function isChangeNick
-- @brief 닉네임 변경권 확인 
-------------------------------------
function StructMail:isChangeNick()
    local item_id = self:getItemList()[1]['item_id']
    local item_type = TableItem:getItemType(item_id)
    return (item_type == 'rename')
end

-------------------------------------
-- function readChangeNick
-- @brief 닉네임 변경권을 읽는다
-------------------------------------
function StructMail:readChangeNick(cb_func)
    UI_ChangeNickPopup(self:getMid(), cb_func)
end

-------------------------------------
-- function readSelection
-- @brief 선택권을 읽는다
-------------------------------------
function StructMail:readSelection(cb_func)

end