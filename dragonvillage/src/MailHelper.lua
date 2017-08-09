MailHelper = {}

-------------------------------------
-- function getMailText
-------------------------------------
function MailHelper:getMailText(struct_mail)
	local table_template = TABLE:get('mail_template')
	local mail_type = struct_mail:getMailType()
    local t_template

    -- 예외 처리 구간
    do
	    -- mail_type이 없다면 탈출
	    if (not mail_type) or (mail_type == '') then
		    return {title = '형식 없음', content = '내용 없음'}
	    end

        -- system인 경우 포함된 텍스트 반환
        if (mail_type == 'system') then
            return {title = '시스템', content = struct_mail:getMessage() or "시스템 메세지"}
        end

	    -- 테이블에 템플릿이 없다면 탈출
        t_template = table_template[mail_type]
	    if (not t_template) then
		    return {title = mail_type, content = '정의 되지 않은 mail_type 입니다.'}
	    end
    end

    -- 생성 시작

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
        
        end
    end

	local title = Str(t_template['t_title'])
	local content = Str(t_template['t_content'], t_value[1], t_value[2], t_value[3], t_value[4], t_value[5])

	return {title = title, content = content}
end
