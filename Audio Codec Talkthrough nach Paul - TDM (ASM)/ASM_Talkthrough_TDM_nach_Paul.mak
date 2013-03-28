# Generated by the VisualDSP++ IDDE

# Note:  Any changes made to this Makefile will be lost the next time the
# matching project file is loaded into the IDDE.  If you wish to preserve
# changes, rename this file and run it externally to the IDDE.

# The syntax of this Makefile is such that GNU Make v3.77 or higher is
# required.

# The current working directory should be the directory in which this
# Makefile resides.

# Supported targets:
#     ASM_Talkthrough_TDM_nach_Paul_Debug
#     ASM_Talkthrough_TDM_nach_Paul_Debug_clean

# Define this variable if you wish to run this Makefile on a host
# other than the host that created it and VisualDSP++ may be installed
# in a different directory.

ADI_DSP=D:\Program Files (x86)\Analog Devices\VisualDSP 5.0


# $VDSP is a gmake-friendly version of ADI_DIR

empty:=
space:= $(empty) $(empty)
VDSP_INTERMEDIATE=$(subst \,/,$(ADI_DSP))
VDSP=$(subst $(space),\$(space),$(VDSP_INTERMEDIATE))

RM=cmd /C del /F /Q

#
# Begin "ASM_Talkthrough_TDM_nach_Paul_Debug" configuration
#

ifeq ($(MAKECMDGOALS),ASM_Talkthrough_TDM_nach_Paul_Debug)

ASM_Talkthrough_TDM_nach_Paul_Debug : ./Debug/ASM_Talkthrough_TDM_nach_Paul.dxe 

./Debug/initialization.doj :./Talkthrough.h ./initialization.asm $(VDSP)/Blackfin/include/defBF532.h $(VDSP)/Blackfin/include/defBF533.h $(VDSP)/Blackfin/include/def_LPBlackfin.h 
	@echo ".\initialization.asm"
	$(VDSP)/easmblkfn.exe .\initialization.asm -proc ADSP-BF533 -file-attr ProjectName=ASM_Talkthrough_TDM_nach_Paul -g -si-revision 0.5 -o .\Debug\initialization.doj -MM

./Debug/interrupts.doj :./Talkthrough.h ./consts.h ./interrupts.asm $(VDSP)/Blackfin/include/defBF532.h $(VDSP)/Blackfin/include/defBF533.h $(VDSP)/Blackfin/include/def_LPBlackfin.h 
	@echo ".\interrupts.asm"
	$(VDSP)/easmblkfn.exe .\interrupts.asm -proc ADSP-BF533 -file-attr ProjectName=ASM_Talkthrough_TDM_nach_Paul -g -si-revision 0.5 -o .\Debug\interrupts.doj -MM

./Debug/main.doj :./Talkthrough.h ./consts.h ./main.asm $(VDSP)/Blackfin/include/defBF532.h $(VDSP)/Blackfin/include/defBF533.h $(VDSP)/Blackfin/include/def_LPBlackfin.h 
	@echo ".\main.asm"
	$(VDSP)/easmblkfn.exe .\main.asm -proc ADSP-BF533 -file-attr ProjectName=ASM_Talkthrough_TDM_nach_Paul -g -si-revision 0.5 -o .\Debug\main.doj -MM

./Debug/Process_Data.doj :./Process_Data.asm ./Talkthrough.h $(VDSP)/Blackfin/include/defBF532.h $(VDSP)/Blackfin/include/defBF533.h $(VDSP)/Blackfin/include/def_LPBlackfin.h 
	@echo ".\Process_Data.asm"
	$(VDSP)/easmblkfn.exe .\Process_Data.asm -proc ADSP-BF533 -file-attr ProjectName=ASM_Talkthrough_TDM_nach_Paul -g -si-revision 0.5 -o .\Debug\Process_Data.doj -MM

./Debug/ASM_Talkthrough_TDM_nach_Paul.dxe :$(VDSP)/Blackfin/ldf/adsp-BF533.ldf $(VDSP)/Blackfin/lib/bf532_rev_0.5/crtsf532y.doj ./Debug/initialization.doj ./Debug/interrupts.doj ./Debug/main.doj ./Debug/Process_Data.doj $(VDSP)/Blackfin/lib/bf532_rev_0.5/__initsbsz532.doj $(VDSP)/Blackfin/lib/cplbtab533.doj $(VDSP)/Blackfin/lib/bf532_rev_0.5/crtn532y.doj $(VDSP)/Blackfin/lib/bf532_rev_0.5/libsmall532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/libio532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/libc532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/librt_fileio532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/libevent532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/libcpp532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/libf64ieee532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/libdsp532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/libsftflt532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/libetsi532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/Debug/libssl532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/Debug/libdrv532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/Debug/libusb532y.dlb $(VDSP)/Blackfin/lib/bf532_rev_0.5/libprofile532y.dlb 
	@echo "Linking..."
	$(VDSP)/ccblkfn.exe .\Debug\initialization.doj .\Debug\interrupts.doj .\Debug\main.doj .\Debug\Process_Data.doj -L .\Debug -add-debug-libpaths -flags-link -od,.\Debug -o .\Debug\ASM_Talkthrough_TDM_nach_Paul.dxe -proc ADSP-BF533 -si-revision 0.5 -MM

endif

ifeq ($(MAKECMDGOALS),ASM_Talkthrough_TDM_nach_Paul_Debug_clean)

ASM_Talkthrough_TDM_nach_Paul_Debug_clean:
	-$(RM) ".\Debug\initialization.doj"
	-$(RM) ".\Debug\interrupts.doj"
	-$(RM) ".\Debug\main.doj"
	-$(RM) ".\Debug\Process_Data.doj"
	-$(RM) ".\Debug\ASM_Talkthrough_TDM_nach_Paul.dxe"
	-$(RM) ".\Debug\*.ipa"
	-$(RM) ".\Debug\*.opa"
	-$(RM) ".\Debug\*.ti"
	-$(RM) ".\Debug\*.pgi"
	-$(RM) ".\*.rbld"

endif


