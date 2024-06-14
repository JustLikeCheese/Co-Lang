function table.contains(_table, _value)
  for key, value in pairs(_table) do
    if value == _value then
      return true
    end
  end
  return false
end

CoSyntax = {}
CoSyntax.codeSplit = function(code)
  -- 语法分析
  local startIndex = 0
  local stringMode, stringMode2 = false, false
  local result, numberMode = {}, false
  local word = nil
  for index = 1, #code do
    -- 获取每个字符
    local char = string.sub(code, index, index)
    if startIndex == 0 then -- 如果开始
      if char ~= ' ' then   -- 如果不为空格
        startIndex = index
        stringMode = char == '\"'
        numberMode = table.contains({ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '-' }, char)
      end
    elseif stringMode then                         -- 字符串模式
      if stringMode2 then                          -- 如果为反义模式
        stringMode2 = false                        -- 取消反义模式
      elseif char == '\\' then                     -- 如果为反斜杠
        stringMode2 = true                         -- 开启反义模式
      elseif char == '\"' then                     --如果为双引号,结束字符串
        word = string.sub(code, startIndex, index) -- 截取字符串
        stringMode = false                         -- 更新字符串模式
        startIndex = 0
      end
    elseif numberMode then -- 数字模式
      if char == ' ' then -- 如果为空格
        word = string.sub(code, startIndex, index - 1) -- 截取字符串
        numberMode = false -- 更新数字模式
      elseif char == '\"' then -- 如果为双引号
        word = string.sub(code, startIndex, index - 1) -- 截取字符串
        stringMode = true -- 更新字符串模式
        startIndex = index
      elseif table.contains({ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' }, char) == false then -- 如果为非法字符
        return { "!", "SyntaxError: 非法的字面量。" } -- 返回错误
      end
    elseif char == ' ' then -- 如果为空格(普通模式)
      word = string.sub(code, startIndex, index - 1) -- 截取字符串
    elseif char == '\"' then -- 如果为双引号(普通模式)
      word = string.sub(code, startIndex, index - 1) -- 截取字符串
      stringMode = true -- 更新字符串模式
      startIndex = index -- 更新开始位置
    end
    if startIndex > 0 and index == #code then
      word = string.sub(code, startIndex, index)
    end
    if word ~= nil then -- 如果为回收状态
      table.insert(result, word)
      word = nil
    end
  end
  if stringMode then -- 如果双引号未结束
    return { "!", "SyntaxError: 未闭合的双引号。" }
  end
  return result
end

CoSyntax.codeType = function(code)
  local char = string.sub(code, 1, 1)
  if char == '\"' then
    return 2 -- string
  elseif table.contains({ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '-' }, char) then
    return 1 -- number
  else
    return 0 -- variable
  end
end

local function dump(_table)
  local result = ""
  for key, value in pairs(_table) do
    result = result .. key .. ":" .. value .. "\n"
  end
  return result
end

local a = CoSyntax.codeSplit("aa\"ad\"123456\"hi!\"")
print(dump(a))

-- print('a'=="a")
-- print(string.sub("abc",1,2))
