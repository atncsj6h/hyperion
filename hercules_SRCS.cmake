#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# housekeeping
if( USE_EXTPKGS_DYNAMIC_LIBRARIES  )
  set( extpkgs_LIBRARIES
    ${crypto_LINK_LIBRARIES}
    ${decnumber_LINK_LIBRARIES}
    ${softfloat_LINK_LIBRARIES}
    ${telnet_LINK_LIBRARIES}
  )
else()
  set( extpkgs_LIBRARIES
    ${crypto_STATIC_LINK_LIBRARIES}
    ${decnumber_STATIC_LINK_LIBRARIES}
    ${softfloat_STATIC_LINK_LIBRARIES}
    ${telnet_STATIC_LINK_LIBRARIES}
  )
endif()

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# common data areas
set( hercs_SRCS
  src/hsys.c
)
set( hercs_LIBS
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# utility functions
set( hercu_SRCS
  src/codepage.c
  src/hdl.c
  src/hexdumpe.c
  src/hostinfo.c
  src/hscutl.c
  src/hsocket.c
  src/hthreads.c
  src/logger.c
  src/logmsg.c
  src/machdep.c
  src/memrchr.c
  src/parser.c
  src/pttrace.c
  src/version.c
)
set( hercu_LIBS
  hercs
  ${extpkgs_LIBRARIES}
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# dasd support
set( hercd_SRCS
  src/cache.c
  src/cckddasd.c
  src/cckdutil.c
  src/ckddasd.c
  src/cckddasd64.c
  src/cckdutil64.c
  src/ckddasd64.c
  src/dasdtab.c
  src/dasdutil.c
  src/fbadasd.c
  src/dasdutil64.c
  src/fbadasd64.c
  src/shared.c
)
set( hercd_LIBS
  hercs hercu ${LIBZ} ${LIBBZ2} ${LIBZSTD}
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# tape support
set( herct_SRCS
  src/hetlib.c
  src/ftlib.c
  src/sllib.c
)
set( herct_LIBS
  hercs hercu ${LIBZ} ${LIBBZ2} ${LIBZSTD}
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# herc core engine
set( herc_SRCS
  src/archlvl.c
  src/assist.c
  src/bldcfg.c
  src/cgibin.c
  src/channel.c
  src/chsc.c
  src/clock.c
  src/cmdtab.c
  src/cmpsc_2012.c
  src/cmpscdbg.c
  src/cmpscdct.c
  src/cmpscget.c
  src/cmpscmem.c
  src/cmpscput.c
  src/config.c
  src/control.c
  src/cpu.c
  src/crypto.c
  src/dat.c
  src/decimal.c
  src/dfp.c
  src/diagmssf.c
  src/diagnose.c
  src/dyn76.c
  src/ecpsvm.c
  src/esame.c
  src/external.c
  src/facility.c
  src/fillfnam.c
  src/float.c
  src/general1.c
  src/general2.c
  src/general3.c
  src/hao.c
  src/hbyteswp.c
  src/hconsole.c
  src/hdiagf18.c
  src/history.c
  src/hRexx.c
  src/hRexx_o.c
  src/hRexx_r.c
  src/hsccmd.c
  src/hscemode.c
  src/hscloc.c
  src/hscmisc.c
  src/hscpufun.c
  src/httpserv.c
  src/ieee.c
  src/impl.c
  src/inline.c
  src/io.c
  src/ipl.c
  src/loadmem.c
  src/loadparm.c
  src/losc.c
  src/machchk.c
  src/machdep.c
  src/opcode.c
  src/panel.c
  src/pfpo.c
  src/plo.c
  src/qdio.c
  src/scedasd.c
  src/scescsi.c
  src/script.c
  src/service.c
  src/sie.c
  src/skey.c
  src/sr.c
  src/stack.c
  src/strsignal.c
  src/tcpip.c
  src/timer.c
  src/trace.c
  src/transact.c
  src/vector.c
  src/vm.c
  src/vmd250.c
  src/vstore.c
  src/x75.c
  src/xstore.c
)
set( herc_LIBS
  hercs hercu hercd
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# unit recorde devices
set( hdt1052c_SRCS
  src/con1052c.c
)
set( hdt1052c_LIBS
  hercs hercu herc
)

set( hdt1403_SRCS
  src/printer.c
  src/sockdev.c
)
set( hdt1403_LIBS
  hercs hercu herc
)

set( hdt3505_SRCS
  src/cardrdr.c
  src/sockdev.c
)
set( hdt3505_LIBS
  hercs hercu herc
)

set( hdt3525_SRCS
  src/cardpch.c
  src/sockdev.c
)
set( hdt3525_LIBS
  hercs hercu herc
)

set( hdt3270_SRCS
  src/console.c
)
set( hdt3270_LIBS
  hercs hercu herc
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# tape
set( hdt3420_SRCS
  src/tapedev.c
  src/tapeccws.c
  src/awstape.c
  src/faketape.c
  src/hettape.c
  src/omatape.c
  src/scsitape.c
  src/scsiutil.c
)
set( hdt3420_LIBS
  hercs hercu herc herct
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
set( hdt2880_SRCS
  src/hchan.c
)
set( hdt2880_LIBS
  hercs hercu herc
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
set( hdt2703_SRCS
  src/commadpt.c
)
set( hdt2703_LIBS
  hercs hercu herc
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
set( hdttcpnje_SRCS
  src/tcpnje.c
)
set( hdttcpnje_LIBS
  hercs hercu herc
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
set( hdt3705_SRCS
  src/comm3705.c
)
set( hdt3705_LIBS
  hercs hercu herc
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
set( hdt3088_SRCS
  src/ctc_lcs.c
  src/ctc_ctci.c
  src/ctcadpt.c
  src/netsupp.c
  src/tuntap.c
  src/utun.c
)
set( hdt3088_LIBS
  hercs hercu herc
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
set( hdtqeth_SRCS
  src/qeth.c
  src/mpc.c
  src/resolve.c
  src/tuntap.c
)
set( hdtqeth_LIBS
  hercs hercu herc
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
set( hdtzfcp_SRCS
  src/zfcp.c
)
set( hdtzfcp_LIBS
  hercs hercu herc
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
set( hdtptp_SRCS
  src/ctc_ptp.c
  src/mpc.c
  src/resolve.c
  src/tuntap.c
)
set( hdtptp_LIBS
  hercs hercu herc
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# misc
set( dyncrypt_SRCS
  src/dyncrypt.c
)
set( dyncrypt_LIBS
  hercs hercu herc
)

set( dyngui_SRCS
  src/dyngui.c
)
set( dyngui_LIBS
  hercs hercu herc
)

set( hdteq_SRCS
  src/hdteq.c
)
set( hdteq_LIBS
  hercs hercu herc
)

set( tfprint_SRCS
  src/tfprint.c
)
set( tfprint_LIBS
)

set( tfprint_SRCS
  src/tfswap.c
)
set( tfprint_LIBS
)

set( txt2card_SRCS
  src/txt2card.c
)
set( txt2card_LIBS
)


