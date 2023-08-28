MailHelper = {}

-------------------------------------
-- function getMailText
-------------------------------------
function MailHelper.getMailText(struct_mail)
	local table_template = TABLE:get('mail_template')
	local mail_type = struct_mail:getMailType()
    local t_template

    -- 예외 처리 구간
    do
	    -- mail_type이 없다면 탈출
	    if (not mail_type) or (mail_type == '') then
		    return {title = '형식 없음', content = '내용 없음'}
	    end


        -- 순수하게 서버에서 주는 메세지만 사용
        if (mail_type == 'custom' ) then
            return MailHelper.makePureCustomMail(struct_mail)
        end

        -- 공지사항 메일 전용
        if (mail_type == 'notice' ) then
            return MailHelper.makeNoticeMail(struct_mail)
        end

	    -- 테이블에 템플릿이 없다면 탈출
        t_template = table_template[mail_type]
	    if (not t_template) then
		    return {title = mail_type, content = '정의 되지 않은 mail_type 입니다.'}
	    end

        -- system인 경우 포함된 텍스트 반환
        if (t_template['template_type'] == 'system') then
            
        end

        -- template_type이 custom인 경우 별도 로직 태움
        if (t_template['template_type'] == 'custom') then
            return MailHelper.makeCustomValueMail(struct_mail, t_template)
        end
    end

    -- 생성
    return MailHelper.makeFormalMail(struct_mail, t_template)
end

-------------------------------------
-- function makeFormalMail
-- @brief form 타입 메일 문구를 생성해준다.
-------------------------------------
function MailHelper.makeFormalMail(struct_mail, t_template)
    -- value key에 맞는 value값들을 만든다.
	local t_value = {}
	for i = 1, 5 do
        local value = t_template['value_' .. i]
        if (not value or value == '' or value == 'x') then break end
         
        -- 아이템 이름
        if (value == 'item') then
           	local t_item = struct_mail:getItemList()[1]
			t_value[i] = UIHelper:makeItemName(t_item)
                 
		-- 닉네임
        elseif (value == 'nick') then
            t_value[i] = struct_mail:getNickName()
        
        -- 메세지
        elseif (value == 'msg') then
            t_value[i] = struct_mail:getMessage()

        -- 타이틀
        elseif (value == 'title') then
            t_value[i] = struct_mail:getTitle()

        end
    end

    local title = Str(t_template['t_title'])
	local content = Str(t_template['t_content'], t_value[1], t_value[2], t_value[3], t_value[4], t_value[5])

	return {title = title, content = content}
end

-------------------------------------
-- function makePureCustomMail
-- @brief 순수하게 서버에서 준 메세지만 사용하는 메일
-------------------------------------
function MailHelper.makePureCustomMail(struct_mail)
    local t_custom = struct_mail:getCustom()
    local title = Str(t_custom['title'] or '')
	local content = ''
    
    if (t_custom['msg']) then
        content = Str(t_custom['msg'])

    -- msg가 없을 경우
    else
        local t_item = struct_mail:getItemList()[1]
        if (t_item) then
            local value = UIHelper:makeItemName(t_item)
            content = Str('{1}{@default}(을)를 받았습니다.', value)
        end
    end

	return {title = title, content = content}
end


-------------------------------------
-- function makeSystemMail
-------------------------------------
function MailHelper.makeSystemMail(struct_mail, t_template)
    local result = {title = Str(t_template['t_title']), content = struct_mail:getMessage() or Str(t_template['t_content'])}
    return result
end

-------------------------------------
-- function makeCustomValueMail
-- @brief custom 타입의 메일 문구를 생성해준다.
-------------------------------------
function MailHelper.makeCustomValueMail(struct_mail, t_template)
    local t_custom = struct_mail:getCustom()
    MailHelper.translateText(t_custom)

    local title = Str(t_template['t_title'])
	local content = Str(t_template['t_content'], t_custom['v1'], t_custom['v2'], t_custom['v3'], t_custom['v4'], t_custom['v5'])

	return {title = title, content = content}
end


-------------------------------------
-- function makeNoticeMail
-- @brief 공지 메일 제목을 찾아온다.
-------------------------------------
function MailHelper.makeNoticeMail(struct_mail)
    local t_custom = struct_mail:getCustom()
    local lang = Translate:getGameLang()

    local title = Str(t_custom['title_' .. lang])
    local content = ""
    
	return {title = title, content = content}
end

-------------------------------------
-- function translateText
-- @brief 필요한 경우에 특정 키가 치환되도록 한다.
-------------------------------------
local T_TRANSLATE = {
    ['dv1'] = '드빌1',
    ['dv2'] = '드빌2',
}
function MailHelper.translateText(t_custom)
    for i, v in pairs(t_custom) do
        if (T_TRANSLATE[v]) then
            t_custom[i] = T_TRANSLATE[v]
        end
    end
end