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
      startIndex = 0
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
-- Co Compiler
CO_MAP={
  "echo"
}
CO_TYPE={
  TYPE_VARIABLE=0,
  TYPE_STRING=1,
  TYPE_NUMBER=2
}
CoCompiler = {}
CoStaticBlock = {}
CoCompiler.compile=function(codes)
  local result = {}
  if #codes>0 then
    local func=codes[1]
    if CoSyntax.codeType(func) ~= CO_TYPE.TYPE_VARIABLE then
      return {"!","SyntaxError: 第一个参数必须为函数。"}
    elseif table.find(CO_MAP,func)==nil then
      return {"!","SyntaxError: 尝试调用一个未定义的函数。"}
    else
      table.insert(result,table.find(CO_MAP,func))
    end
  end
  table.insert(result,#codes-1)
  for index = 2, #codes do
    local code = codes[index]
    local type = CoSyntax.codeType(code)
    if type == CO_TYPE.TYPE_VARIABLE then -- 如果表达式为变量类型
      table.insert(result, 0) -- 插入参数类型
      table.insert(CoStaticBlock,code) -- 插入参数到静态块
      table.insert(result,#CoStaticBlock) -- 插入参数索引
    elseif type == CO_TYPE.TYPE_STRING then -- 如果表达式为字符串类型
      table.insert(result, 1) -- 插入参数类型
      table.insert(CoStaticBlock,string.sub(code,2,#code-1)) -- 插入参数到静态块
      table.insert(result,#CoStaticBlock) -- 插入参数索引
    elseif type == CO_TYPE.TYPE_NUMBER then -- 如果表达式为数字类型
     table.insert(result, 2) -- 插入参数类型
     table.insert(CoStaticBlock,code) -- 插入参数到静态块
     table.insert(result,#CoStaticBlock) -- 插入参数索引
     else
      return {"!","SyntaxError: 未知的变量类型。"} -- 返回错误
    end
  end
  return result
end
local a = CoSyntax.codeSplit("echo aa")
local b =CoCompiler.compile(a)
-- print(dump(b))
-- print(dump(CoStaticBlock))
print("编译结果：")
local func=b[1]
print("调用的函数:"..func.."("..CO_MAP[func]..")");
local args=b[2]
print("参数数量:"..args);
for i=1,args do
  local type=b[2+i]
  local index=b[3+i]
  print("参数类型:"..type.." 参数索引:"..index.." 参数值:"..CoStaticBlock[index])
end
-- print('a'=="a")
-- print(string.sub("abc",1,2))
