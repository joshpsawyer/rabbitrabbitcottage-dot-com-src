function Link(el)
  -- Match links ending with 'index.md' and strip it, leaving the trailing slash
  if el.target:match("index%.md") then
    el.target = el.target:gsub("index%.md", "")
  end
  return el
end