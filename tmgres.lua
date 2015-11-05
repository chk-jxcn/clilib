#!/bin/env lua

cb = require "clilib"

function match(s, key)
	t = {}
	for line in string.gmatch (s, "([^\r\n]*)\r\n") do -- split to lines
		for _,v in pairs(key) do
			if string.match(line, v) then
				table.insert(t, line)
			end
		end
	end
	return  table.concat(t, "\r\n") 
end


tmgs = {
	{"tmg1" , cb.telnetcli("172.16.30.11", "9007"),},
	--{"tmg2" , cb.telnetcli("172.16.0.4", "9007"),},
	--{"tmg3" , cb.telnetcli("172.16.0.11", "9007"),},
	--{"tmg4" , cb.telnetcli("172.16.0.12", "9007"),},
}

for _, v in ipairs(tmgs) do
	cb.login(v[2], "admin", "admin")
end

function p(s)
	print(os.date(),":\n", s)
end

x=function ()
	repeat 
			p(tmgs[1][2].rr.showistchinf(1))
			p(tmgs[1][2].rr.showistchinf(2))
			spawn.usleep(1000000)
	until nil
end

ret,err = pcall(x)

if not ret then
	print("err: ", err)
end

