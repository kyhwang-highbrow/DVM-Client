local function check(lang)
    local file = 'lang_' .. lang    
    print('require start : ' .. file )
    local temp = require(file)
    print('require finish : ' .. file )
end

check( arg[1] )
