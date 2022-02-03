test:
	@$(MAKE) -sk test-all

test-all:	test-scripts test-exists

test-scripts:
	curl -sLO https://raw.githubusercontent.com/nd-cse-20289-sp22/cse-20289-sp22-assignments/master/reading05/test_exists.sh
	chmod +x test_*.sh

test-exists:
	./test_exists.sh
