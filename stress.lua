#!/bin/env lua

package.path="./?.lua;./?"
package.cpath="./lib/?.so"
require "spawn"

oldprint=print


function print(s)
	oldprint(s)
end

count=0
function f()
repeat 
	require "hashowconfig"
	package.loaded["hashowconfig"] = nil
	count = count+1
	collectgarbage ("collect")
until nil
end

oldprint(pcall(f))


oldprint(count)
