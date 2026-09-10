-- print("--> [DEBUG] Lua filter cache-bust.lua initialized!")

function Meta(meta)
  -- local timestamp = os.time()
  local raw_paths = {}

  local hash = meta.css_hash and pandoc.utils.stringify(meta.css_hash)

  -- 1. Read from YAML Metadata / -M flags
  if meta.css then
    -- print("--> [DEBUG] Found CSS in Meta AST")
    if meta.css.t == 'MetaList' then
      for _, item in ipairs(meta.css) do
        table.insert(raw_paths, pandoc.utils.stringify(item))
      end
    else
      table.insert(raw_paths, pandoc.utils.stringify(meta.css))
    end
  end

  -- 2. Read directly from Pandoc CLI writer options (--css flag)
  if PANDOC_WRITER_OPTIONS and PANDOC_WRITER_OPTIONS.css then
    -- print("--> [DEBUG] Found CSS in PANDOC_WRITER_OPTIONS (CLI)")
    for _, path in ipairs(PANDOC_WRITER_OPTIONS.css) do
      table.insert(raw_paths, path)
    end
  end

  -- Process paths if found
  if #raw_paths > 0 then
    local new_css_list = {}
    
    for _, path in ipairs(raw_paths) do
      -- Convert Windows backslashes to web forward slashes
      local clean_path = path:gsub("\\", "/")
      local cache_busted = clean_path .. "?v=" .. hash
      print("--> [DEBUG] Transformed CSS path: " .. cache_busted)
      table.insert(new_css_list, cache_busted)
    end

    -- Explicitly assign back to meta.css so the $for(css)$ template loop renders it
    meta.css = new_css_list
  else
    -- print("--> [WARNING] No CSS found in Meta or PANDOC_WRITER_OPTIONS!")
  end

  return meta
end