local _M = {} 
function _M.match(s, key)
        local t = {}
        for line in string.gmatch (s, "([^\r\n]*)\r\n") do -- split to lines
                for _,v in pairs(key) do
                        if string.match(line, v) then
                                table.insert(t, line)
                        end
                end
        end
        return  table.concat(t, "\r\n")
end


function printall(t)
	for k,v in pairs(t) do
		print(k .. ": " .. tostring(v))
	end
end

return _M
