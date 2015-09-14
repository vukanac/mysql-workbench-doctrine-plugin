# This plugin will be discarded in favour of the http://github.com/johmue/mysql-workbench-schema-exporter project #

There are plenty of reasons, why I will discard the LUA plugin.

1. I'm a PHP developer and LUA is a pain for me, as it retains me from implementing good ideas. The second effect is, that users dealing with Doctrine are PHP users and not LUA, which might help to find people to contribute.

2. My vision is a pluggable solution, where users can generate models for different tools (Symfony, Doctrine, Cake, Propel ..) with just one application.

3. migration from SVN to GIT will also help to find contributors and to ease the maintaining of the tool.

4. with the start of doctrine2 and annotations in mind the plugin would end up in a mess and maintaining two different doctrine plugins in LUA wouldn't work. As I don't know how to decouple logic from representation in LUA.

5. testing the application automatically against a set of predefined workbench files would be possible now, even for different tools like doctrine/propel/doctrine2

6. An online service to convert workbench files is also imaginable

## The only draw-back by now is that the github application is not as powerful as the plugin, because the whole stuff with comments is missing at the moment. ##

I hope you will respect my decision and follow the project to github.

Cheers
Johannes

# This software is not supported anymore by the maintainer #


---


## About ##

The MySQL Workbench Doctrine Plugin is a plugin developed for [MySQL Workbench](http://dev.mysql.com/workbench) which is a tool for developing [MySQL databases](http://www.mysql.com) with a graphical interface. Even developing MySQL databases with Workbench you can use the **.yml output for usage with every database supported by doctrine.**

The plugin helps you to generate database schemes for the [Doctrine](http://www.doctrine-project.org) framework which is e.g. used in the very famous PHP Framework [Symfony](http://www.symfony-project.org).


---


## Installation ##

Please read also the Wiki article [how to configure Workbench before using Doctrine Plugin](http://code.google.com/p/mysql-workbench-doctrine-plugin/wiki/WorkbenchPreparationForDoctrinePlugin).

### Download ###

You can download the latest _stable release_ of the plugin on the right box.

You can download the latest _development snapshot_ of the plugin [here](http://mysql-workbench-doctrine-plugin.googlecode.com/svn/trunk/DoctrineExport.grt.lua).

### Windows ###
To use the plugin with **Workbench 5.1.x** or **5.2.x** copy the Doctrine plugin file to
```
%APPDATA%/MySQL/Workbench 5.1/modules/
```

To use the plugin with **Workbench 5.0.x** copy the Doctrine plugin file to
```
%PROGRAMFILES%/MySQL/Workbench 5.0/modules/
```

### Mac ###
```
%YOUR HOME DIRECTORY%/Library/Application Support/MySQL/Workbench/modules/DoctrineExport.grt.lua
```
thanks to [http://cesaric.com/?p=549](http://cesaric.com/?p=549)

---


## Changelog ##

```
0.4.1 (JM)
   + [imp] export collation, charset and storage type on table level only if explicitly set
   + [fix] global setting of collation
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=23
   + [fix] fixed scale issue with decimal type
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=22
0.4.0 (JM)
   + [add] support for
             doctrine:foreignAliasOne,
             doctrine:foreignAliasMany and
             doctrine:foreignAlias fallback
           on table comments for custom relation naming
   + [add] support of doctrine behaviours via table comments
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/wiki/HowToAddDoctrineBehavioursToTheWorkbenchModel
   + [fix] charset and collate does not work with global options definition
           changed to work within table focus
   + [fix] changed export of foreign keys for doubled 1:n relations
           (e.g. Message -> Sender/Recipient) thanks to Mickael Kurmann for the code snippet
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=18
0.3.9 (KW)
   + [imp] foreignAliases now considering the cardinality one or many. if one is found,
           a singular foreignAlias is created, if many is found a pluralized foreignAlias
           is created
0.3.8 (JM, KW)
   + [add] added mapping of type YEAR -> integer(2)
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=12
   + [fix] removed the renameIdColumns function that worked with the (bad) Workbench default
           primary key and associative table naming conventions to be used with the Doctrine
           "detect_relations" option
           see the plugin Wiki page
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=11
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=15
   + [fix] removed binary flag for columns -> not supported by doctrine
0.3.7 (KW, JM)
   + [fix] changed conversion of INTEGER from integer to integer(4)
   + [fix] changed conversion of BLOB types from clob(n) to blob(n) see version 0.3.5 notes
   + [add] added DEC and NUMERIC to output decimal
   + [fix] now allowing DECIMAL, DEC, and NUMERIC to be specified with optional precision and scale
   + [imp] improved the save-to-file routine to work for previously saved files that do not exist anymore (file deleted, renamed, or moved)
   + [imp] restructured and simplified the supported types code
0.3.6 (JM)
   + [oth] changed conversion of INT from integer to integer(4)
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=10
0.3.5 (JM)
   + [fix] type mediumtext | mediumblob -> clob(16777215)
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=9
   + [add] type longtext   | longblob   -> clob
           type tinytext   | tinyblob   -> clob(255)
           type text       | blob       -> clob(65535)
0.3.4 (JM)
   + [fix] multiple column unique indexes
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=8
   + [add] preparation for cross database joins (works with MySQL and PostgreSQL
           and maybe others) please switch the function getCrossDatabaseJoinsFlag()
           return value to "on" and restart MySQL Workbench (may cause problems with
           symfony)
           see http://www.doctrine-project.org/blog/cross-database-joins
0.3.3 (JM)
   + [add] support for I18n schemes with *_translation tables
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=7
   + [oth] replaced code indent tabs with spaces
0.3.2 (Karsten Wutzke)
   + [oth] small change in handling version information
0.3.1 (JM)
   + [fix] changed simple type "INT" to doctrine "integer"
           see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=6
0.3 (Karsten Wutzke)
   + [fix] types BOOLEAN, BOOL, and INTEGER now working (aren't simpleType)
   + [add] lowercasing for default TRUE and FALSE keywords
   + [imp] default NULL, TRUE, and FALSE detected case-insensitively now (WB doesn't
           uppercase default values as opposed to all data types - which are keywords, too)
   + [add] added version info to module ID and menu items, like this plugins with different
           versions can be used at the same time (starting with this version and one old)
   + [imp] file export: added simple functionality to append ".yml" extension to file paths
           not ending with ".yml"
   + [imp] removed some unnecessary prints
   + [imp] shortened changelog entry types [improvement] to [imp] and [other] to [oth]
0.2 (Karsten Wutzke)
   + [add] foreignAlias for relations
   + [fix] exception thrown in relationBuilding on some tables with foreign keys where the
           column and referenced columns list has zero length
   + [imp] replaced all string.len() calls with the length operator #s
   + [add] function string.endswith()
   + [imp] eased the code of function exportYamlSchemaToFile (eliminated double if)
   + [add] functions to test if a (table) name is plural or singular
   + [fix] reanimated functionality for (English) plural table names
   + [add] functionality to adjust special (English) table names ending with "ies" to
           convert "ie" to "y" ("Countries" -> "Country") and more
   + [add] data type conversion of integer types and CHAR, BOOLEAN, and BOOL:
        TINYINT   -> integer(1)
        SMALLINT  -> integer(2)
        MEDIUMINT -> integer(3)
        INT       -> integer
        INTEGER   -> integer
        BIGINT    -> integer(8)
        BOOLEAN   -> boolean
        BOOL      -> boolean
        CHAR      -> string + fixed option
   + [add] option for CHAR columns
   + [imp] removed using the table name capitalization function (ucfirst) from
           function buildTableName(), like this tables retain their original names and the
           default Workbench naming convention "_has_" still gets handled correctly
   + [imp] replaced "\r\n" line endings with "\n" only
   + [imp] using lowercase for default null values
   + [imp] restructured MySQL plugin init code for easier understanding
0.1alpha9
   + [add] function to save to file
   + [add] print version name on execution in debug window
0.1alpha8
   + [fix] changed behavior of table renaming (thanks to Francisco Ernesto Teixeira)
     taBleNaMe -> Tablename ->[fix]-> TaBleNaMe
0.1alpha7
   + [oth] changed the license from GPLv2 to LGPLv3
   + [fix] removed plural correction of table names (deprecated in Doctrine 1.0)
0.1alpha6
   + [fix] some conversion from workbench type to Doctrine type
        BIGINT   -> INTEGER
        DATETIME -> TIMESTAMP
   + [fix] decimal (precision + scale)
   + [fix] enum handling
0.1alpha5 by quocbao (qbao.nguyen@gmail.com)
   + [fix] some conversion from workbench type to Doctrine type
   + [fix] removed generate_accessors [deprecated]
0.1alpha4
   + [add] tables_has_names -> TablesName ->[fix]-> TableName
   + [add] rename columns "idtable | table_idtable" -> "id | table_id"
0.1alpha3
   + [add] convert underscores in tablenames to CamelCase
0.1alpha2
   + [add] nested set support for tablenames ending with _ns
0.1alpha1
   supports:
   + [add] indexes [fulltext, unique, index]
   + [add] index length
   + [add] collation
   + [add] character set
   + [add] engine [MySQL, InnoDB]
   + [add] relations
   + [add] foreign key constraints
   + [add] table name fixing
   + [add] column flags [binary, zerofill, unsigned]
   + [add] autoincrement
   + [add] not null
   + [add] default values
   + [add] decimal precision
   + [add] column length [e.g. varchar(255)]
```