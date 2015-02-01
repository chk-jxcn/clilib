#本程序还在开发当中，暂时不可用！

```
1.0：
  Test version
  使用stdio测试
```

  
  
##设计用法：

  对于交换机或者路由器，命令行有不同的状态，例如：
```
  sys>
  vlan>
  user>
```

  clilib可以让调用类似的命令行更容易，例如：
```lua
  switch = new("telnet 192.168.1.1")
  switch.vlan100.ip("192.168.1.2")
  -- IN: vlan100
  -- OUT: switch>vlan100>
  -- IN: ip 192.168.1.1
  -- OUT: switch>vlan100>
  
  switch.vlan100.gateway("192.168.1.1")
  -- IN: gateway 192.168.1.1 对于进入的状态不会重复进入
  -- OUT: switch>vlan100>
  
  switch.vlan200.ip("192.168.2.2")
  -- IN: quit
  -- OUT: switch>
  -- IN: vlan200
  -- OUT: switch>vlan200>
  -- IN: ip 192.168.2.2
  -- OUT: switch>vlan200>
  
  switch.vlan200.gateway("192.168.2.1")
  -- IN: gateway 192.168。2.1
  -- OUT: switch>vlan200>
  
  switch.user.local.vty("1")
  -- IN: quit
  -- OUT: switch>
  -- IN: user
  -- OUT: switch>user>
  -- IN: local
  -- OUT: switch>user>local>
  -- IN: vty 1
  -- OUT: switch>user>local>
  
  switch.user.password("admin")
  -- IN: quit
  -- OUT: switch>user>
  -- IN: password admin
  -- OUT: switch>user>
```

类似上面的输入输出，使用clilib可以把层次的切换隐藏在表的调用层级中。

开发这个库的本意是为了简化我司核心网软件CLI的使用，进入不同的层级使用输入表名的方法，退出状态则写死在程序中，
如果需要在不同的产品中使用是需要修改的，同样的，每个层级退出的命令都是一样的，如果需要给定不同的命令，需要修改进入和退出函数，给出描述结构。


##idea：
  增加一个通过cli自省自动获取cli各层提供的命令的描述结构的库。
  例如可以通过输出？来遍历cli所有命令空间。
  
  
  

