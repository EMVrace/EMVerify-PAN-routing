TAMARIN = tamarin-prover
DECOMMENT = tools/decomment
PREFIXDIR = models-n-proofs
SEPARATOR = ==============================================================================

#configuration variables
generic = Contactless
brand = Visa
auth = EMV
CVM = OnlinePIN
value = Low
softfix = No
hardfix = No
paynet = AID

#other variables
decomment = Yes

#uncomment the code blocks that follow the selected configuration
left1 = if(\(|\(([a-zA-Z0-9]+\|)+)
left2 = endif(\(|\(([a-zA-Z0-9]+\|)+)
right = (\)|(\|[a-zA-Z0-9]+)+\))

brand_regex = \/\*$(left1)$(brand)$(right) *| *$(left2)$(brand)$(right)\*\/
auth_regex = \/\*$(left1)$(auth)$(right) *| *$(left2)$(auth)$(right)\*\/
CVM_regex = \/\*$(left1)$(CVM)$(right) *| *$(left2)$(CVM)$(right)\*\/
value_regex = \/\*$(left1)$(value)$(right) *| *$(left2)$(value)$(right)\*\/
authz_regex = \/\*$(left1)$(authz)$(right) *| *$(left2)$(authz)$(right)\*\/
soft_fix_regex = \/\*$(left1)SoftFix$(right) *| *$(left2)SoftFix$(right)\*\/
hard_fix_regex = \/\*$(left1)HardFix$(right) *| *$(left2)HardFix$(right)\*\/
paynet_regex = \/\*$(left1)$(paynet)$(right) *| *$(left2)$(paynet)$(right)\*\/

ifndef dir
	dir = $(PREFIXDIR)
endif

ifeq ($(brand), Mastercard)
	CVM_regex_ = |$(CVM_regex)
	CVM_ = _$(CVM)
endif

ifeq ($(paynet), PAN)
	paynet_ = _PaynetPAN
endif

regex = ($(brand_regex)|$(auth_regex)$(CVM_regex_)|$(value_regex)|$(paynet_regex))
theory = $(brand)_$(auth)$(CVM_)_$(value)$(paynet_)

ifeq ($(softfix), Yes)
	regex = $(soft_fix_regex)
	theory = Contactless_SoftFix
endif

ifeq ($(hardfix), Yes)
	regex = $(hard_fix_regex)
	theory = Contactless_HardFix
endif

#use oracle if indicated
ifndef oracle
	oracle = $(brand).oracle
endif
ifeq ($(oracle),$(wildcard $(oracle)))
  _oracle = --heuristic=O --oraclename=$(oracle)
endif

#prove only one lemma if indicated
ifdef lemma
  _lemma = =$(lemma)
endif

#the Tamarin command to be executed
cmd = $(TAMARIN) --prove$(_lemma) $(dir)/$(theory).spthy $(_oracle) $(TFLAGS) --output=$(dir)/$(theory).proof

proof:
	#Create directory for specific models and their proofs
	mkdir -p $(dir)
	
	#Generate theory file $(theory).spthy
	sed -E 's/$(regex)//g' $(generic).spthy > $(dir)/$(theory).tmp
	sed -E 's/theory .*/theory $(theory)/' $(dir)/$(theory).tmp > $(dir)/$(theory).spthy
	
	#Remove all comments
ifeq ($(decomment), Yes)
ifeq ($(DECOMMENT),$(wildcard $(DECOMMENT)))
	$(DECOMMENT) $(dir)/$(theory).spthy > $(dir)/$(theory).tmp
	cat $(dir)/$(theory).tmp > $(dir)/$(theory).spthy
endif	
endif	
	
	#Print date and time for monitoring
	date '+Analysis started on %Y-%m-%d at %H:%M:%S'
	
	#run Tamarin
	echo '$(cmd)'
	#(time $(cmd))> $(dir)/$(theory).tmp 2>&1
	$(cmd) > $(dir)/$(theory).tmp 2>&1
	
	#add breaklines
	echo >> $(dir)/$(theory).proof
	echo >> $(dir)/$(theory).proof
	
	#add summary of results to proof file
	(sed -n '/^$(SEPARATOR)/,$$p' $(dir)/$(theory).tmp) >> $(dir)/$(theory).proof
	
	#Clean up
	$(RM) $(dir)/$(theory).tmp
	echo 'Done.'

#for clarity, will use below some redundant variable assignments
####
mastercard:
	#SDA
	$(MAKE) brand=Mastercard auth=SDA CVM=NoPIN value=Low
	$(MAKE) brand=Mastercard auth=SDA CVM=NoPIN value=High
	$(MAKE) brand=Mastercard auth=SDA CVM=OnlinePIN value=Low
	$(MAKE) brand=Mastercard auth=SDA CVM=OnlinePIN value=High
	#DDA
	$(MAKE) brand=Mastercard auth=DDA CVM=NoPIN value=Low
	$(MAKE) brand=Mastercard auth=DDA CVM=NoPIN value=High
	$(MAKE) brand=Mastercard auth=DDA CVM=OnlinePIN value=Low
	$(MAKE) brand=Mastercard auth=DDA CVM=OnlinePIN value=High
	#CDA
	$(MAKE) brand=Mastercard auth=CDA CVM=NoPIN value=Low
	$(MAKE) brand=Mastercard auth=CDA CVM=NoPIN value=High
	$(MAKE) brand=Mastercard auth=CDA CVM=OnlinePIN value=Low
	$(MAKE) brand=Mastercard auth=CDA CVM=OnlinePIN value=High

	#SDA
	$(MAKE) brand=Mastercard auth=SDA CVM=NoPIN value=Low paynet=PAN
	$(MAKE) brand=Mastercard auth=SDA CVM=NoPIN value=High paynet=PAN
	$(MAKE) brand=Mastercard auth=SDA CVM=OnlinePIN value=Low paynet=PAN
	$(MAKE) brand=Mastercard auth=SDA CVM=OnlinePIN value=High paynet=PAN
	#DDA
	$(MAKE) brand=Mastercard auth=DDA CVM=NoPIN value=Low paynet=PAN
	$(MAKE) brand=Mastercard auth=DDA CVM=NoPIN value=High paynet=PAN
	$(MAKE) brand=Mastercard auth=DDA CVM=OnlinePIN value=Low paynet=PAN
	$(MAKE) brand=Mastercard auth=DDA CVM=OnlinePIN value=High paynet=PAN
	#CDA
	$(MAKE) brand=Mastercard auth=CDA CVM=NoPIN value=Low paynet=PAN
	$(MAKE) brand=Mastercard auth=CDA CVM=NoPIN value=High paynet=PAN
	$(MAKE) brand=Mastercard auth=CDA CVM=OnlinePIN value=Low paynet=PAN
	$(MAKE) brand=Mastercard auth=CDA CVM=OnlinePIN value=High paynet=PAN

visa:
	#EMV mode
	$(MAKE) brand=Visa auth=EMV value=Low
	$(MAKE) brand=Visa auth=EMV value=High
	#DDA mode
	$(MAKE) brand=Visa auth=DDA value=Low
	$(MAKE) brand=Visa auth=DDA value=High

	#EMV mode
	$(MAKE) brand=Visa auth=EMV value=Low paynet=PAN
	$(MAKE) brand=Visa auth=EMV value=High paynet=PAN
	#DDA mode
	$(MAKE) brand=Visa auth=DDA value=Low paynet=PAN
	$(MAKE) brand=Visa auth=DDA value=High paynet=PAN

fix:
	$(MAKE) paynet=PAN softfix=Yes
	$(MAKE) paynet=PAN hardfix=Yes

html: #write results in HTML format
	./tools/collect $(dir) #--columns=tools/columns.txt --tex-add=tools/tex-add.txt

.PHONY: clean

clean:
	$(RM) $(dir)/*.tmp
	$(RM) $(dir)/*.aes

