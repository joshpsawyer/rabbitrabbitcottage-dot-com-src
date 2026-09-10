function Meta(meta)
  if meta.jdid then
    local val = tonumber(pandoc.utils.stringify(meta.jdid))
    
    if val then
      -- %05.2f pads to a minimum width of 5 total characters with leading zeros
      meta.formatted_id = pandoc.MetaString(string.format("%05.2f", val))
    end
  end
  return meta
end