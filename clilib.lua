package.cpath = "/root/clilib-master/lib/?.so"
local spawn = require "spawn"
local lpeg = require "lpeg"

local function samefather(t1, t2)
	for i = #t2, 1, -1 do
		if t2[i] ~= t1[i] then
			return false
		end
	end
	return true
end


local function cmds(self)
	function treewalk(t, path, args)
		--
		-- this function resume by meta __call,
		-- and nerver return.
		--
		-- compare path and go to the upper or return to lower
		-- if reach the last node, treat it as a cmd.
		--
		if t.__deep == 1 then
			t.__deep = t.__deep + 1
			repeat 
				t, path, args = treewalk(t, path, args)		
			until false
			print "should never go here"
		end
		if #path == t.__deep then  			
			output, len = t:__do_cmd(args)
			table.remove(path)		-- pop cmd node
			return coroutine.yield(output, len)
			
		else
			t:__enter(path, t.__deep)	
			t.__deep = t.__deep + 1
			_, nextpath, nextargs = treewalk(t, path, args)
			while samefather(nextpath, path) do
				_, nextpath, nextargs = treewalk(t, nextpath, nextargs)
			end
			t.__deep = t.__deep - 1
			t:__exit(path, t.__deep)	
			table.remove(path)		-- pop last path node
			return _, nextpath, nextargs    -- may return to root
			end
	end
	return coroutine.wrap(treewalk)
end


local _M={}

function _M.login(handle, user, pass)
        --handle.__stream:setnonblock(0)
        repeat
                handle[user]()
                loginret = handle[pass]() or ""
                if string.match(loginret, "Login") or  string.match(loginret, "Pass") then
                        if handle.__debug then
				print("Try lgoin again")
			end
                        handle["\r\n"]()
                else
                        break
                end
         until nil
         handle.__stream:setnonblock(1)
end


local fmt = string.format
function _M.telnetcli(host, port)
	spawn.setterm="keep"
	local telnet = spawn.open(fmt("telnet %s %s", host, port))
	telnet:setnonblock(true)
	telnet:setdelay(25000)
	local stream = {
		delay = 25000,
		readblock = 1024,
		nonblock = 1,
		pump = function (self, input)
			if telnet:isdead() then
				error"process has been exit"
			end
			telnet:writes(input)
			local t = {}
			repeat
				spawn.usleep(self.delay)		--sleep 25ms
				local slice = telnet:reads()			-- buffer?
				--[[if self.nonblock  then
					if slice == "" then
						break
					end
				else
					break
				end]]
				table.insert(t, slice)
				--print("slice :" .. slice)
			until (not self.nonblock) or slice == "" or slice == nil 
			return table.concat(t, "")
		end,
		set = function (k, v)
			telnet[k](telnet, v)
		end,
		setnonblock = function (self, bool)
			self.nonblock = bool
			if not telnet:setnonblock(bool) then
				error()
			end
		end
	}
	return _M.cli({}, stream)

end

-- stream = {
-- 	pump -- input string, stream args
--	close -- if stream has no gc, need call close
--
function _M.cli(t, stream)
	local function tablecopy(src)
		local dst = {}
		for k, v in ipairs(src) do
			dst[k] = src[k]
		end
		return dst
	end

	local metatable={
		__index = function(t, index) table.insert(t.__path, index) return t end,
		__call = function(t, ...)		 -- call actual function and reset path
			local out, len = t:__cmds(tablecopy(t.__path), {...}) 
			t.__path = {"root"} 
			return out, len			 
		end,
	}

	local captureprompt = function (s)  -- capture string after last \r \n if none return ""
		local m = lpeg
		local pat = m.P{ (m.C((1 - m.S"\r\n")^1 * -1) + 1 * m.V(1)) + m.Cc""}
		return pat:match(s or "")
	end

	local stripprompt = function(s, cmd, prompt)
		local m = lpeg
		if prompt == "" then 
			return s
		end
		local pat = m.P(cmd)^-1 * m.S"\r\n"^0  * m.C(m.P{#(m.P(prompt) * -1)  + 1 * m.V(1) + m.Cc""})
		local out = pat:match(s or "")
		return out
	end

	local instance = {
	       __io = function (self, input)  -- if input end with \r\n we didn't append \r\n ,if input is "" we just writes "" for reads
	       	       if string.match(input, ".*\r\n$") or input == "" then
		       else
			       input = input .. "\r\n"
		       end
		       if self.__debug then
			       --io.write(input)
		       end

		       local output =  stream:pump(input) 
		       if self.__debug then
			       io.write(output)
		       end
		       return output
	       end,
	        __debug = false,
		__stream = stream,
		__cmds = cmds(),
		__cmd_render = function (...) return table.concat({...}, " ") end,
		__do_cmd = function (self, args) 
			cmd = self.__cmd_render(self.__path[#self.__path], unpack(args)) 
			output = self:__io(cmd)
			return self:__strip(output, cmd), output and #output 
			end,
		__path = {"root"},
		__deep = 1,
		__prompt = "XOS>",
		__strip = function (self, input, cmd) return stripprompt(input, cmd, self.__prompt) end,
		__enter = function(self, path, deep) self:__updateprompt(self:__io(path[deep])) end,
		__exit = function(self, path, deep) self:__updateprompt(self:__io("q")) end,
		__updateprompt = function (self, prompt) self.__prompt = captureprompt(prompt) end,
	}
	
	if not t then				-- copy t to instance
		for k,v in pairs(t) do
			instance[k] = v
		end
	end

	setmetatable(instance, metatable)
	return instance
end

return _M
