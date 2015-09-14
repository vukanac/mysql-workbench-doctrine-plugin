# Introduction #

As you may noticed, the plugin changes table names by simple algorithms. This works quite ok for english table names and if you respect a few naming conventions.

In some cases you don't want this behaviour e.g. when you use non english table names or table names with special naming conventions.

# Details #

To disable table renaming you just have to:

  1. open the plugin code
  1. find the config section
  1. change the option "preventTableRenaming" to true
  1. (optional) change the "preventTableRenamingPrefix" to your preferred, otherwise relations start with "col_" which stands for collection_

You can read more about config options [here](http://code.google.com/p/mysql-workbench-doctrine-plugin/wiki/HowToUseConfigOptions).