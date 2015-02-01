local spawn = require "spawn"


local function samefather(t1, t2)
	for i = #t2, 1, -1 do
		if t2[i] ~= t1[i] then
			return false
		end
	end
	return true
end


local function cmds()
	deep = 1
	function treewalk(t, path, args)
		--
		-- this function resume by meta __call,
		-- and nerver return.
		--
		-- compare path and go to the upper or return to lower
		-- if reach the last node, treat it as a cmd.
		--
		if deep == 1 then
			deep = deep + 1
			repeat 
				t, path, args = treewalk(t, path, args)		
			until false
			print "should never go here"
		end
		if #path == deep then  			
			output = t:__do_cmd(args)
			table.remove(path)		-- pop cmd node
			return coroutine.yield(t:__strip(output))
			
		else
			t:__enter(path, deep)	
			deep = deep + 1
			_, nextpath, nextargs = treewalk(t, path, args)
			while samefather(nextpath, path) do
				_, nextpath, nextargs = treewalk(t, nextpath, nextargs)
			end
			deep = deep - 1
			t:__exit(path, deep)	
			table.remove(path)		-- pop last path node
			return _, nextpath, nextargs    -- may return to root
			end
	end
	return coroutine.wrap(treewalk)
end


local tcf={
	__io = function (self, input) print(input .. "\r\n") return io.read() end,
	__cmds = cmds(),
	__do_cmd = function (self, args) return self:__io("do_cmd:" .. self.__path[#self.__path] .. " args: " ..  args) end,
	__path = {"root"},
	__promt = "xos>",
	__strip = function (self, input) print("strip: " .. input) return input end,
	__enter = function(self, path, deep) self:__updatestate(self:__io(path[deep])) end,
	__exit = function(self, path, deep) self:__updatestate(self:__io("q")) end,
	__updatestate = function (self, promt) end,
}


function tablecopy(src)
	dst = {}
	for k, v in ipairs(src) do
		dst[k] = src[k]
	end
	return dst
end




metatable={
	__index=function(t, index)
		table.insert(t.__path, index)
		return t
	end,
	__call=function(t, ...)
		out = t:__cmds(tablecopy(t.__path), table.concat({...}, " "))
		t.__path = {"root"}
		return out
	end
}

setmetatable(tcf, metatable)





print("tcf.bcp.list(): " .. tcf.bcp.list("qwe", "123"))
print("tcf.bcp.config(\"123\"): " .. tcf.bcp.config("123"))
print("tcf.vlr.config(\"123\"): " .. tcf.vlr.config("123"))
print("tcf.vlr.somenode1.config(\"123\"): " .. tcf.vlr.somenode1.config("123"))
print("tcf.vlr.somenode2.config(\"123\"): " .. tcf.vlr.somenode2.config("123"))
print("tcf.vlr.somenode3.config(\"123\"): " .. tcf.vlr.somenode3.config("123"))
print("tcf.vlr.somenode4.config(\"123\"): " .. tcf.vlr.somenode4.config("123"))
print("tcf.vlr.somenode5.config(\"123\"): " .. tcf.vlr.somenode5.config("123"))
print("tcf.sipua.config(\"123\"): " .. tcf.sipua.config("123"))


