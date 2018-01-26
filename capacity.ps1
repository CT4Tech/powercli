# Looks at current usage stats fot all ESXi hosts

get-vmhost | ft networkinfo,model,memorytotalgb,memoryusagegb,cputotalmhz,cpuusagemhz,parent -autosize
