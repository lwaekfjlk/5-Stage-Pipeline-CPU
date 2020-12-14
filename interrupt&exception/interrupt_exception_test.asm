根据中断或异常类型跳转至对应中断处理向量

关闭中断使能
设置中断类型优先级
设置系统优先级
打开中断使能

关闭中断使能
设置中断类型优先级
设置系统优先级
打开中断使能

# suppose exception priority = 0, interrupt1 priority = 1, interrupt2 priority = 2
# No.12 Status (sel=0)
        # bit 0 (1 for interrupt enable, 0 for interrupt disable)
        # bit 1 (1 for exception level , 0 for normal level)
        # bit 3-4 (00 for kernel mode     , 01 for supervisor mode , 10 for user mode)
        # bit 8-9 (interrupt mask 1 for interrupt requests enable , 0 for interrupt requests disable)
# No.13 Cause (sel=0)
        # bit 2-6 (0  for interrupt            , 4  for lw/IF address error,
        #          5  for sw address error     , 10 for undefined instruction,
        #          12 for overflow
        #         )
# No.14 EPC   (sel=0)
# No.15 EBase (sel=1)


#0x0
OS_start:
        # start at kernel mode
        # init stack
        addi        r29  ,r29   ,0x1f                                   # 23BD001F
        addi        r1   ,r0    ,0x7C                                   # 2001007C
        mtc0        r1          ,EBase (sel=1)                          # 40817801
        addi        r2   ,r0    ,0x3C                                   # 2002003C 
        mtc0        r2          ,EPC (sel=0)                            # 40827000 
        # set user mode (10) and enable interrupt (1)
        addi        r3   ,r0    ,0x11                                   # 20030011   
        mtc0        r3          ,Status (sel=0)                         # 40836000
        eret                                                            # 42000018
# 0x10
User_start:
        # undefined
        Undefined Instruction (0Xffff_ffff)                             # FFFFFFFF
        nop                                                             # 00000000
        # overflow
        lui        r1    ,       0x7fff                                 # 3C017FFF                     #
        lui        r2    ,       0x7fff                                 # 3C027FFF
        add        r3    ,r1    ,r2                                     # 00221820
        nop                                                             # 00000000
        # data_mem out of range
        lui        r4    ,       0xffff                                 # 3C04FFFF
        lw         r4    ,       4(r4)                                  # 8C840004
        nop
Loop:   # dead loop with a counter
        add        r5    ,zero  ,zero                                   # 00002820
        addi       r5    ,r5    ,0x1                                    # 20A50001
        j          Loop                                                 # 08000018
# 0x20
Exception_start:
        # change to superviser mode and disable interrupt
        addi       r1   ,r0    ,0x8                                     # 20010008
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # store epc
        # mfc must have nop because write at wb stage
        mfc0       r1          ,EPC (sel=0)                             # 40017000
        nop                                                             # 00000000
        addi       r29  ,r29   ,-0x1                                    # 23BDFFFF          
        sw         r1          ,0(r29)                                  # AFA10000
        # keep the superviser mode and enable interrupt
        addi       r1   ,r0    ,0x9                                     # 20010009
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # record times of entering exception
        addi       r31  ,r31   ,0x1                                     # 23FF0001
        # keep the superviser mode and disable interrupt
        addi       r1   ,r0    ,0x8                                     # 20010008
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # load epc
        lw         r1          ,0(r29)                                  # 8FA10000
        addi       r29  ,r29   ,0x1                                     # 23BD0001
        mtc0       r1          ,EPC (sel=0)                             # 40817000
        # return user mode
        addi       r1   ,r0    ,0x10                                    # 20010010
        mtc0       r1          ,Status (sel=0)                          # 40816000
        eret                                                            # 42000018
# 0x40
Interrupt_start:
        # change to superviser mode and disable interrupt
        addi       r1   ,r0    ,0x8                                     # 20010008
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # store epc
        # mfc must have nop because write at wb stage
        mfc0       r1          ,EPC (sel=0)                             # 40017000
        nop                                                             # 00000000
        addi       r29  ,r29   ,-0x1                                    # 23BDFFFF          
        sw         r1          ,0(r29)                                  # AFA10000
        # keep the superviser mode and enable interrupt
        addi       r1   ,r0    ,0x9                                     # 20010009
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # record times of entering interrupt
        addi       r30  ,r30   ,0x1                                     # 23DE0001
        # keep the superviser mode and disable interrupt
        addi       r1   ,r0    ,0x8                                     # 20010008
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # load epc
        lw         r1          ,0(r29)                                  # 8FA10000
        addi       r29  ,r29   ,0x1                                     # 23BD0001
        mtc0       r1          ,EPC (sel=0)                             # 40817000
        # return user mode 
        addi       r1   ,r0    ,0x10                                    # 20010010
        mtc        r1          ,Status (sel=0)                          # 40816000
        eret       
