INSTALL_DIR=~/.local/bin

all:
	@echo "Please run 'make install'"

install:
	@echo ""
	mkdir -p $(INSTALL_DIR)
	cp dynamicaliases.sh $(INSTALL_DIR)
	@echo ""
	@echo "Plase add 'source $(INSTALL_DIR)/dynamicaliases.sh' to your .bashrc file"
	@echo ""
	@echo "USAGE:"
	@echo "------"
	@echo 'cs   <alias_name> <command> - Saves the given command as "alias_name"'
	@echo 'c    <alias_name>           - Runs the command associated with "alias_name"'
	@echo 'ci   <alias_name>           - Prints the command associated with "alias_name"'
	@echo 'cdel <alias_name>           - Deletes the alias'
	@echo 'cl                          - Lists all available aliases'

.PHONY: all install
