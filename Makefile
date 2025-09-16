.PHONY: test

test:
	nvim --headless -c "PlenaryBustedDirectory lua/tests/ { minimal_init = './scripts/minimal_init.lua', file_pattern = '*_spec.lua' }" -c "qa"

