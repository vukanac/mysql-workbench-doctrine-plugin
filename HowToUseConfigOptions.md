# Introduction #

With config options you can customize the plugin to fit your needs, for example to export always table names or to choose a special storage engine by default.

## Local vs Global Configuration ##

You can use the config options directly in the plugin file, which means whenever you update the plugin your personal settings will be lost **OR** you can store a global config file which overwrites the local settings with the global ones. You only need to add options you want to be overwritten, for the other options it falls back to the local ones.

A global config file is named **doctrinePluginConfig.lua** and (for Win) it's located in _%PROGRAMFILES%/MySQL/Workbench/modules_ instead of _%APPDATA%/MySQL/Workbench/modules_. It looks like the following:
```
local _G = _G

-- do not touch the three points, they are intended
module(...);

-- declare config and add it
-- to the global namespace
_G.extConfig = {
  defaultStorageEngine               = "InnoDB" -- default InnoDB|MyISAM (choose default storage engine)
  ,enableStorageEngineOverride        = true    -- default false|true (override individual table storage engine settings)
  ,enableOptionsHeader                = false     -- default true|false (enable header output)
}
```

This configuration would set the table engine to InnoDB for all your tables and will not output the headers in the yml file.

## Check which config is loaded ##

To check whether the plugin has access to a global config file or not you can check this by opening the output window (View -> Output or press Ctrl+F2) and run the export process. When no global configuration is found the plugin will show you two messages _"optional external config not found"_ and _"local config loaded"_ which is self explanatory. If a global configuration file is found you will see the message _"external config loaded"_. Keep in mind that this might get important when the output does not match your expectations.

# Details #

At the moment we implemented these options (an actual list is always included in the plugin code as the local options):

| **name** | **values** | **default** | **explanation** |
|:---------|:-----------|:------------|:----------------|
| enableCrossDatabaseJoins | false | true | false       | adds the database name to the table name, [blog post about cross database joins](http://www.doctrine-project.org/blog/cross-database-joins) |
| defaultStorageEngine | InnoDB, MyISAM, .. | InnoDB      | sets the default storage engine for your tables, this option will be overwritten if the table has own informations about it's storage engine |
| enableStorageEngineOverride | false | true | false       | tells the plugin to ignore the table specific storage engine and to use always the default one (see above) |
| enableOptionsHeader | true | false | true        | outputs the header for detect\_relations, options (collation, charset, type) |
| enableRenameUnderscoresToCamelcase | true | false | true        | if this option is true, underscores were filtered and the following character will be uppercase |
| enableRecapitalizeTableNames | first | none | first       | converts the first letter of the table name to uppercase |
| preventTableRenaming | false | true | false       | prevents the plugin from renaming your tables, which means switching between singular and plural |
| preventTableRenamingPrefix | _string_   | col|if preventTableRenaming is true, then your relations will not be distinguishable from the table names, therefor your relations get a prefix (here col_for collection)_|
| alwaysOutputTableNames | true | false | false       | if you always want to output the real table name as an option set this to true, normally it is only outputted if the table name and the real table name differs |
| sortTablesAlphabetical | false | true | false       | if you want to sort the tables alphabetical in the output, set this option to true |
| useReferencenamesAsRelationnames | false | true | false       | normally the name of the foreign table is used as the name of a relation, if you enable this option the name of the reference itself is taken by the plugin to name the relation (!! this is not synonymous to the caption of a reference !!) |