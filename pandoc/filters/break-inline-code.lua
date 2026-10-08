-- Add inexpensive discretionary line breaks to long inline-code spans.
-- Splitting into small Code nodes lets Pandoc keep handling LaTeX escaping.

local minimum_length = 12
local chunk_size = 3

function Code(code)
  if not FORMAT:match("latex") then
    return nil
  end

  local length = utf8.len(code.text)
  if not length or length < minimum_length then
    return nil
  end

  local chunks = {}
  local current = {}

  for _, point in utf8.codes(code.text) do
    current[#current + 1] = utf8.char(point)
    if #current == chunk_size then
      chunks[#chunks + 1] = table.concat(current)
      current = {}
    end
  end

  if #current > 0 then
    chunks[#chunks + 1] = table.concat(current)
  end

  local result = {}
  for index, chunk in ipairs(chunks) do
    result[#result + 1] = pandoc.Code(chunk, code.attr)
    if index < #chunks then
      result[#result + 1] = pandoc.RawInline("latex", "\\allowbreak{}")
    end
  end

  return result
end
