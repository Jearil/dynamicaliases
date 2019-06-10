DynamicAliases is a shell script that allows you to save and run aliases quickly from the shell. The code is based on
the amazing [Bashmarks](https://github.com/huyng/bashmarks) project which I highly recommend.

Install
====
1. git clone git://github.com/jearil/dynamicaliases.git
2. cd dynamicaliases
3. make install
4. source ~/.local/bin/dynamicaliases.sh from within your ~/.bash_profile or ~/.bashrc file.

Usage
====

```
cs   <alias_name> <command> - Saves the given command as "alias_name"
c    <alias_name> [args]    - Runs the command associated with "alias_name", optionally appending given arguments
ci   <alias_name>           - Prints the command associated with "alias_name"
cdel <alias_name>           - Deletes the alias
cl                          - Lists all available aliases
```

The `c`, `ci`, and `cdel` commands all include tab completion. Aliases are stored in the `.saliases` file in your HOME
directory.
