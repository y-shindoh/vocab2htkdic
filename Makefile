# -*- coding: utf-8-unix -*-

VOCAB2HTKDIC	:= vocab2htkdic.rb
VOCAB2HTKDIC_IN	:= work/vocab2htkdic.rb.in
VOCAB_1		:= work/sample.1.vocab.xz
HTKDIC_1	:= work/sample.1.htkdic.gz
VOCAB_2		:= work/sample.2.vocab.xz
HTKDIC_2	:= work/sample.2.htkdic.gz
PHONES		:= japanese.k2p.gz

RUBY		:= ruby

all:	$(VOCAB2HTKDIC)

$(VOCAB2HTKDIC):	$(VOCAB2HTKDIC_IN)
	sed "s|@@RUBY@@|`which ruby`|" < $< > $@
	chmod +x $@

check:	$(HTKDIC_1) $(HTKDIC_2)

$(HTKDIC_1):	$(VOCAB2HTKDIC) $(VOCAB_1)
	xz -cd $(VOCAB_1) \
	| $(RUBY) -Ku $(VOCAB2HTKDIC) -t $(PHONES) -s ':' -p 2 \
	| gzip -c9 > $(HTKDIC_1)
	@echo 'ERROR CHECK'
	@zgrep -F 'ERROR' $(HTKDIC_1) || echo 'not found'

$(HTKDIC_2):	$(VOCAB2HTKDIC) $(VOCAB_2)
	xz -cd $(VOCAB_2) \
	| iconv -f 'EUC-JP' -t 'UTF-8' \
	| $(RUBY) -Ku $(VOCAB2HTKDIC) -t $(PHONES) -s '+' -p 3 \
	| iconv -f 'UTF-8' -t 'EUC-JP' \
	| gzip -c9 > $(HTKDIC_2)
	@echo 'ERROR CHECK'
	@gzip -cd $(HTKDIC_2) | iconv -f 'EUC-JP' -t 'UTF-8' | grep -F 'ERROR' || echo 'not found'

clean:
	rm -f $(VOCAB2HTKDIC) $(HTKDIC_1) $(HTKDIC_2)
	find . -name '*~' -print0 | xargs -0 rm -f

.PHONY: all check clean
