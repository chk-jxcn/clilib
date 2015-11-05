#!/bin/env lua


package.cpath="./lib/?.so"
require "spawn"
require "lpeg"

	
ssh=spawn.open"ssh -i id_rsa 172.16.0.2 -o UserKnownHostsFile=/dev/null"


p=function (s) io.write(s) end
function sshlogin(handle)
	p(handle:reads())
	handle:writes("yes\n")
	p(handle:reads())
	spawn.usleep(100000)
	handle:writes("tcnSUPERuser@xinwei\n")
	spawn.usleep(100000)
	p(handle:reads())
end

sshlogin(ssh)
