nvim --headless -u scripts/minimal_init.lua -c "PlenaryBustedDirectory lua/tests/ { minimal_init = 'scripts/minimal_init.lua', file_pattern = '*_spec.lua' }" -c "qa"

