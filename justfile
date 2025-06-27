test: test-plenary test-checkhealth 

test-checkhealth:
	nix run  . -- --headless "+checkhealth" +qa

test-plenary:
	nix run  . -- --headless "+PlenaryBustedDirectory nvim/tests/" +qa
