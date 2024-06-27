require "import"

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
    elseif stringMode2 then                        -- 如果为反义模式
      stringMode2 = false                          -- 取消反义模式
    elseif stringMode then                         -- 字符串模式
      if char == '\\' then                         -- 如果为反斜杠
        stringMode2 = true                         -- 开启反义模式
      elseif char == '\"' then                     --如果为双引号,结束字符串
        word = string.sub(code, startIndex, index) -- 截取字符串
        stringMode = false                         -- 更新字符串模式
        startIndex = 0
      end
    elseif char == ' ' then -- 如果为空格(普通模式)
      word = string.sub(code, startIndex, index - 1) -- 截取字符串
      startIndex = 0
    elseif char == '\"' then -- 如果为双引号(普通模式)
      word = string.sub(code, startIndex, index - 1) -- 截取字符串
      stringMode = true -- 更新字符串模式
      startIndex = index -- 更新开始位置
    elseif numberMode and table.contains({ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' }, char) == false then -- 如果为非法字符
      return { "!", "SyntaxError: 非法的字面量。" } -- 返回错误
    end
    if word ~= nil then -- 如果为回收状态
      table.insert(result, word)
      word = nil
    end
  end
  if stringMode then         -- 如果双引号未结束
    return { "!", "SyntaxError: 未闭合的双引号。" }
  elseif startIndex > 0 then -- 如果还有未回收的字符串
    word = string.sub(code, startIndex, #code)
    table.insert(result, word)
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

CoSyntax.codeFormat = function(lines)
  for i = 1, #lines do
    local line = lines[i]
        :gsub("\n", "") -- 删除换行符
        :gsub("\t", "") -- 删除制表符
        :gsub(" ", "") -- 删除空格
    if line=="" or line:sub(1, 2) == "//" then
      table.remove(lines, i)
      i = i - 1
    end
  end
  return lines
end

-- CoState
CoState = {}
CoNames = {}
CoValues = {}
CoTypes = {}
CoState.put = function(name, value, type)
  table.insert(CoNames, name)
  table.insert(CoValues, value)
  table.insert(CoTypes, type)
end

CoState.get = function(name)
  for i = 1, #CoNames do
    if CoNames[i] == name then
      return CoValues[i]
    end
  end
  return "null"
end

CoState.get2 = function(name)
  local value = CoState.get(name)
  local type = CoState.type(name)
  if type == "number" or type == "string" then
    return value
  elseif type == "function" then
    return "function: 0x"
  end
end

CoState.type = function(name)
  for i = 1, #CoNames do
    if CoNames[i] == name then
      return CoTypes[i]
    end
  end
  return "null"
end

-- CoFunction table
CoFunction = {}
CoFunctionTable = {}
CoFunction.new = function(name, args, body)
  local func = {}
  table.insert(func, name)  -- 插入函数名
  table.insert(func, #args) -- 插入参数长度
  -- 插入参数
  for i = 1, #args do
    table.insert(func, args[i])
  end
  -- 插入函数体
  for i = 1, #body do
    table.insert(func, body[i])
  end
  table.insert(CoFunctionTable, func)
end


CoState.load = function(lines)
  local CoLineCounter = 1 -- 行数
  local CoPreLines = {}   -- 预处理行
  local CoLines = CoSyntax.codeFormat(lines)   -- 处理行
  while true do           -- 通过两层循环实现 continue
    while true do
      local CoLine = nil
      local CoPreStatus = false
      if #CoPreLines > 0 then
        CoLine = CoPreLines[1] -- 获取预处理行
        CoPreStatus = true
        table.remove(CoPreLines, 1)
      else
        CoLine = CoLines[CoLineCounter] -- 获取当前行
      end
      -- 如果语法处理失败，丢出错误
      local Statements = CoSyntax.codeSplit(CoLine)
      local CoFunction = Statements[1]
      if CoFunction == "!" then
        error(Statements[2])
      end
      -- 执行函数
      table.remove(Statements, 1)
      if CoFunction == "invoke" then
        if #Statements == 0 then
          error("SyntaxError: 缺少函数名。")
        end
        if CoState.type(Statements[1]) == "function" then
          local func = CoState.get(Statements[1])
        end
      end
      -- 计数器自增
      if not CoPreStatus then
        CoLineCounter = CoLineCounter + 1 -- 行数加一
      end
      break                               -- 等效于 continue
    end
    if CoLineCounter > #CoLines then
      break
    end
  end
end

-- print(dump(CoSyntax.codeSplit("Hello World!")))
CoState.load({ "echo \"HelloWorld!" })
