
cb = require "clilib"

function login(handle)
	handle.admin()
	handle.admin()
end

tcf1 = cb.telnetcli("168.0.70.6", "9006")
--tcf.__debug = true
login(tcf1)
print(tcf1.ha.showconfig())

tcf2 = cb.telnetcli("168.0.70.9", "9006")
login(tcf2)
print(tcf2.ha.showconfig())
