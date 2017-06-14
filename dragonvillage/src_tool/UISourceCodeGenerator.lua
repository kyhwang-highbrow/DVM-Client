
UISourceCodeGenerator = class({
    m_root = 'string',

    m_uiFilePath = 'string',
    m_uiFileName = 'string',
    m_luaFileName = 'string',
    m_luaClassName = 'string',

    m_uiFileNumOfLine = 'number',
                     
    })


-------------------------------------
-- function init
-------------------------------------
function UISourceCodeGenerator:init(path)
    self.m_root = '..\\res\\'
    self.m_uiFilePath = self.m_root 
    .. path
    self.m_uiFileNumOfLine = 0
    local split_name = pl.stringx.split(path, '\\')
    self.m_uiFileName = split_name[#split_name]
    self.m_luaClassName = self:snakeToPascal(self.m_uiFileName)
    self.m_luaFileName = self.m_luaClassName .. '.lua'

end


-------------------------------------
-- function snakeToPascal
-- @brief   snake case�� ui�����̸��� Pascal case�� lua���� �̸����� �ٲ۴�.
-- @param   file_name   : string,       snake_case ui���� �̸�
-- @return  str         : string,       PascalCase lua���� �̸�
-------------------------------------
function UISourceCodeGenerator:snakeToPascal(file_name)
    local offset = string.find(file_name, '.ui')
    local name_without_ext = file_name:sub(1, offset - 1)
    local name_without_underbar = pl.stringx.split(name_without_ext, '_')
    local str = 'UI_'
    for k, v in ipairs (name_without_underbar) do

        str = str .. v:sub(1, 1):upper() .. v:sub(2)
    end
    return str
end

-------------------------------------
-- function makeFile
-- @brief ui������ ����� ��ü���� ���μ����� �����ϴ� �Լ�.
-------------------------------------
function UISourceCodeGenerator:makeFile()
    local init_button_function_name = self.m_luaClassName .. ':initButton'
    local init_function_name        = self.m_luaClassName .. ':initUI'
    local file_contents             = self:readSourceCode()
    file_contents = self:renameInTable(file_contents, 'uiName.ui', self.m_uiFileName)
    file_contents = self:renameInTable(file_contents, 'UI_ClassForm', self.m_luaClassName)
   
    -- �̺�Ʈ binding�� function �ڵ� ����
    local initButton_function_start_line = self:findStr(file_contents, init_button_function_name, true)
    local line_to_write_new_function = self:findStr(file_contents, '--@CHECK')
    local init_function_start_line = self:findStr(file_contents, init_function_name, true)
    
    initButton_function_start_line = initButton_function_start_line + 1
    line_to_write_new_function = line_to_write_new_function - 1
    init_function_start_line = init_function_start_line + 1

    local function_code, event_code, comment_code = 
        self:makeComponentSourceCodeForm(file_contents, initButton_function_start_line, line_to_write_new_function, init_function_start_line)

    file_contents[initButton_function_start_line], file_contents[line_to_write_new_function], file_contents[init_function_start_line]
         = function_code, event_code, comment_code
    
    local new_file_contents = ''
    for _, v in ipairs(file_contents) do
        new_file_contents = new_file_contents .. v .. '\n'
    end
    print(pl.file.write(lfs.currentdir() .. '\\generatedUI\\'.. self.m_luaFileName, new_file_contents))

end

-------------------------------------
-- function readSourceCode
-- @brief   classForm lua������ �о, line ������ split
-- @return  contents_line : number,     line ������ �и��� UI_ClassForm.lua ������ ����
-------------------------------------
function UISourceCodeGenerator:readSourceCode()
    local contents = pl.file.read('..\\src\\UI_ClassForm.lua')
    local contents_line = pl.stringx.splitlines(contents)
    return contents_line
end

-------------------------------------
-- function findStr
-- @brief   contents���� name�� ã�Ƽ� �� line number�� ��ȯ
-- @param   contents        : string,               ���� ����
--          str             : string,               ã�� string
--          is_function     : boolean, optional,    �Լ����� �ƴ���. �Լ��̸� str �ڿ� '()'�� �߰�
-- @return  i               : number,               ã���� ��� �� line�� number ��ȯ
--          nil             : nil,                  ��ã���� ��� nil ��ȯ 
-------------------------------------
function UISourceCodeGenerator:findStr(contents, str, is_function)
    is_function = is_function or false
    if (is_function) then
        str = str .. '()'
    end

    for i, v in ipairs(contents) do
        if (v:find(str)) then
            return i
        end
    end    
    return nil
end



-------------------------------------
-- function makeComponentSourceCodeForm
-- @brief   Component�鿡 �ش�Ǵ� �ҽ��ڵ带 �־��� string �ڿ� append�Ѵ�.
-- @param   t                                 : table,    UI_ClassForm.lua ���� �������� ��� �ִ� ���̺�
--          initButton                        : number,   event handler�� append�� line number
--          newFunction                       : number,   event function�� append�� line number
--          commentComponents                 : number,   ��ư�� �ƴ� ������Ʈ���� �ּ� �ڵ尡 append �� line number
-- @return  string_to_append_button_event     : string,   event handler�� append �� string
--          string_to_write_button_function   : string,   event function�� append�� string
--          string_to_append_other_components : string,   ��ư�� �ƴ� ������Ʈ���� �ּ� �ڵ尡 append �� string
-------------------------------------
function UISourceCodeGenerator:makeComponentSourceCodeForm(t, initButton, newFunction, commentComponents)
    string_to_append_button_event, string_to_write_button_function, string_to_append_other_components = t[initButton], t[newFunction], t[commentComponents]
    local ui_file_contents = pl.file.read(self.m_uiFilePath)
    local vars = loadstring('return ' .. ui_file_contents)()

    -- button ���� �͵��� �ڵ忡 ����.
    local components = {}
    self:walkAndFindComponentInUITable(vars, components)
    for k, v in pairs(components) do

        -- button�� �ڵ忡 ����.
        if(k == 'Button') then
            for k2, v2 in pairs(v) do   
                    --button init �Լ� ���� �ۼ�
                string_to_append_button_event = self:appendEventCode(string_to_append_button_event, v2)

                --button click �̺�Ʈ �Լ� ���� �ۼ�
                string_to_write_button_function = self:appendEventFunctionCode(string_to_write_button_function, v2)
            end
        --button ���� components �ڵ忡 ����.
        else 
            for k2, v2 in pairs(v) do
                string_to_append_other_components = self:appendOtherComponentsCode(string_to_append_other_components, k, v2)
            end
        end

    end

    return string_to_append_button_event, string_to_write_button_function, string_to_append_other_components
end

-------------------------------------
-- function appendEventCode
-- @brief event handler �ҽ��ڵ带 string_to_append_button_event �ڿ� append�Ѵ�.
-- @param string_to_append_button_event : string,   event handler�� append�� string
--        component_name            : string,   event handler string�� ���Ե� ������Ʈ�� �̸�
-- @return                          : string
-------------------------------------
function UISourceCodeGenerator:appendEventCode(string_to_append_button_event, component_name)
    return string_to_append_button_event .. 
            '\n' ..
            '    self.vars[\'' .. component_name .. '\']:registerScriptTapHandler(function() ' ..
                'self:click_' .. component_name .. '() ' ..
                'end)'
end

-------------------------------------
-- function appendEventFunctionCode
-- @brief event function �ҽ��ڵ带 string_to_write_button_function �ڿ� append�Ѵ�.
-- @param string_to_write_button_function : string,   event function�� append�� string
--        component_name                    : string,   event function string�� ���Ե� ������Ʈ�� �̸� 
-- @return                                  : string
-------------------------------------
function UISourceCodeGenerator:appendEventFunctionCode(string_to_write_button_function, component_name) 
    local unicode = require 'unicode'
    local utf8 = unicode.utf8
    local comment_form =    '-------------------------------------\n' ..
                            '-- function FUNCTIONNAME\n'..
                            '-------------------------------------\n'

    local function_form =    'function CLASSNAME:FUNCTIONNAME()\n' ..
                            '    cclog(\'TODO FUNCTIONNAME event occurred!\')\n' ..
                            'end\n'

    local form = string_to_write_button_function .. '\n' .. comment_form .. function_form
    form = form:gsub('CLASSNAME', self.m_luaClassName)

    return form:gsub('FUNCTIONNAME', 'click_' .. component_name)

end

-------------------------------------
-- function appendOtherComponentsCode
-- @brief �ּ����ν� ������Ʈ�� ���縦 �˷��ִ� �ҽ��ڵ带 string_to_append_other_components �ڿ� append�Ѵ�.
-- @param string_to_append_other_components : string,   �ּ� �ڵ带 append�� string
--        component_type                    : string,   component type
--        component_name                    : string,   component name
-- @return                                  : string
-------------------------------------
function UISourceCodeGenerator:appendOtherComponentsCode(string_to_append_other_components, component_type, component_name)
    return string_to_append_other_components .. '\n' ..
            '\t--vars[\'' .. component_name .. '\'] -- ' .. component_type
end


-------------------------------------
-- function walkAndFindComponentInUITable
-- @brief �־��� ���̺��� ��������� Ž���ϰ�, t ���̺��� component type�� key�� �ϰ�, t ���̺��� value�� components�� value�� �ִ´�.
-- @param t                 : table,                key : attributes, value : value
--        components        : table,                key : type of components, value : value
-------------------------------------
function UISourceCodeGenerator:walkAndFindComponentInUITable(t, components)
    local component_type = t['type']
    for k, v in pairs(t) do
        if(type(v) == 'table') then
            self:walkAndFindComponentInUITable(v, components, component_type)
        else
            if ( k == 'lua_name') then
                if (v ~= '') then
                if(not components[component_type]) then
                    components[component_type] = {}
                end 
                table.insert(components[component_type], v)
                end
            end
        end
    end
end

-------------------------------------
-- function renameInTable
-- @brief ���̺� ���� �����ϴ� target�� ã�Ƽ� ���� str�� replace��Ų��.
-- @param   t                 : table,  search ���
--          target            : string, replace ���
--          str               : string, str�� replace��
-- @return  t                 : table,  replace �۾��� ���� t.
-------------------------------------
function UISourceCodeGenerator:renameInTable(t, target, str)
    for k, v in pairs(t) do
        t[k] = v:gsub(target, str)
    end
    return t
end