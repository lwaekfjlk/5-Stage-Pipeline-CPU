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
        addi        r3   ,r0    ,0x9                                    # 20030009
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
        #disable interrupt
        addi       r1   ,r0    ,0x0                                     # 20010000
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # store
        # mfc must have nop because write at wb stage
        addi       r29  ,r29   ,-0x2                                    # 23BDFFFE
        mfc0       r1          ,EPC (sel=0)                             # 40017000
        nop                                                             # 00000000
        nop                                                             # 00000000
        sw         r1          ,0(r29)                                  # AFA10000
        mfc0       r2          ,Status (sel=0)                          # 40026000
        nop                                                             # 00000000
        nop                                                             # 00000000
        sw         r2          ,1(r29)                                  # AFA20001
        # keep the superviser mode and enable interrupt
        addi       r1   ,r0    ,0x1                                     # 20010001
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # record times of entering exception
        addi       r31  ,r31   ,0x1                                     # 23FF0001
        # keep the superviser mode and disable interrupt
        addi       r1   ,r0    ,0x0                                     # 20010000
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # load
        lw         r1          ,0(r29)                                  # 8FA10000
        mtc0       r1          ,EPC (sel=0)                             # 40817000
        lw         r2          ,1(r29)                                  # 8FA20001
        mtc0       r2          ,Status (sel=0)                          # 40826000
        addi       r29  ,r29   ,0x2                                     # 23BD0002
        eret                                                            # 42000018
# 0x40
Interrupt1_start:
        # change to superviser mode and disable interrupt
        addi       r1   ,r0    ,0x0                                     # 20010000
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # store
        # mfc must have nop because write at wb stage
        addi       r29  ,r29   ,-0x2                                    # 23BDFFFE
        mfc0       r1          ,EPC (sel=0)                             # 40017000
        nop                                                             # 00000000
        sw         r1          ,0(r29)                                  # AFA10000
        mfc0       r2          ,Status (sel=0)                          # 40026000
        nop                                                             # 00000000
        sw         r2          ,1(r29)                                  # AFA20001
        # keep the superviser mode and enable interrupt
        addi       r1   ,r0    ,0x1                                     # 20010001
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # record times of entering exception
        addi       r30  ,r30   ,0x1                                     # 23DE0001
        mfc0       r1          ,Cause (sel=0)                           # 40016800
        nop                                                             # 00000000
        nop                                                             # 00000000
        andi       r1   ,r1    ,0xfeff                                  # 3021FEFF
        mtc0       r1          ,Cause (sel=0)                           # 40816800
        # keep the superviser mode and disable interrupt
        addi       r1   ,r0    ,0x0                                     # 20010000
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # load
        lw         r1          ,0(r29)                                  # 8FA10000
        mtc0       r1          ,EPC (sel=0)                             # 40817000
        lw         r2          ,1(r29)                                  # 8FA20001
        mtc0       r2          ,Status (sel=0)                          # 40826000
        addi       r29  ,r29   ,0x2                                     # 23BD0002
        eret                                                            # 42000018
# 0x60
Interrupt2_start:
        # change to superviser mode and disable interrupt
        addi       r1   ,r0    ,0x0                                     # 20010000
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # store
        # mfc must have nop because write at wb stage
        addi       r29  ,r29   ,-0x2                                    # 23BDFFFE
        mfc0       r1          ,EPC (sel=0)                             # 40017000
        nop                                                             # 00000000
        sw         r1          ,0(r29)                                  # AFA10000
        mfc0       r2          ,Status (sel=0)                          # 40026000
        nop                                                             # 00000000
        sw         r2          ,1(r29)                                  # AFA20001
        # keep the superviser mode and enable interrupt
        addi       r1   ,r0    ,0x1                                     # 20010001
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # record times of entering exception
        addi       r30  ,r30   ,0x1                                     # 23DE0001
        mfc0       r1          ,Cause (sel=0)                           # 40016800
        nop                                                             # 00000000
        nop                                                             # 00000000
        andi       r1   ,r1    ,0xfdff                                  # 3021FDFF
        mtc0       r1          ,Cause (sel=0)                           # 40816800
        # keep the superviser mode and disable interrupt
        addi       r1   ,r0    ,0x0                                     # 20010000
        mtc0       r1          ,Status (sel=0)                          # 40816000
        # load
        lw         r1          ,0(r29)                                  # 8FA10000
        mtc0       r1          ,EPC (sel=0)                             # 40817000
        lw         r2          ,1(r29)                                  # 8FA20001
        mtc0       r2          ,Status (sel=0)                          # 40826000
        addi       r29  ,r29   ,0x2                                     # 23BD0002
        eret                                                            # 42000018
