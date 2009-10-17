--
-- MySQL Workbench Doctrine Export Plugin
-- Version: 0.5.0pre
-- Authors: Johannes Mueller, Karsten Wutzke
-- Copyright (c) 2008-2009
--
-- http://code.google.com/p/mysql-workbench-doctrine-plugin/
--
-- * The export plugin allows you to export a catalog as Doctrine YAML schema.
-- * This plugin was tested with MySQL Workbench 5.1.17 OSS
--
-- This file is free software: you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation, either
-- version 3 of the License, or (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.  If not, see <http://www.gnu.org/licenses/>.
--
---------------------------------------------------------------------------------------------
--
-- Special thanks to:
--    Daniel Haas who develops the MySQL Workbench Propel export plugin
--    and kindly agreed to adopt pieces of his source
--    http://www.diloc.de/blog/
--
---------------------------------------------------------------------------------------------
--
-- * IMPORTANT:
-- * If you find BUGS in this plugin or have ideas for IMPROVEMENTS or PATCHES, don't hesitate
-- * to contact us at http://code.google.com/p/mysql-workbench-doctrine-plugin/
--
-- INSTALLATION:
-- Just copy this file into the \modules folder of your
--  a. up until Workbench version 5.0.x installation directory or
--  b. starting with Workbench 5.1.x local user MySQL appdata directory
--
-- USAGE:
-- 1. Open MySQL Workbench
-- 2. Open the database schema
-- 3. Go to "Plugins" -> "Catalog"
--    3a. Select "Doctrine Export: Copy [...] to Clipboard" to save the YAML output to your
--        OS's clipboard, just open a new file and paste it there
--    3b. Select "Doctrine Export: Write [...] to File..." and save the YAML output to a text
--        file as specified in the dialog
--
-- NOTES:
-- 1. The YAML file extension usually is ".yml"
-- 2. The plugin locations from MySQL Workbench changed from version 5.0.x to 5.1.x.
-- 3. On Windows XP the Workbench:copyToClipboard function seems to have a defect in version
--    5.1.9 up to 5.2.16 (other versions untested): http://bugs.mysql.com/bug.php?id=44461
-- 4. To change the schema character set and collation in Workbench 5.1.x you have to go to tab
--    "MySQL Model" -> "Physical Schemata", then double click that yellow DB image with the
--    schema name next to it.
--
-- CHANGELOG:
-- 0.5.0pre (JM)
--    + [oth] more OOP structured code
--    + [oth] new Config class
-- 0.3.4 (JM)
--    + [fix] multiple column unique indexes
--            see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=8
--    + [add] preparation for cross database joins (works with MySQL and PostgreSQL and maybe others)
--            please switch the function getCrossDatabaseJoinsFlag() return value to "on" and restart
--            MySQL Workbench (may cause problems with symfony)
--            see http://www.doctrine-project.org/blog/cross-database-joins
-- 0.3.3 (JM)
--    + [add] support for I18n schemes with *_translation tables
--            see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=7
-- 0.3.2 (Karsten Wutzke)
--    + [oth] small change in handling version information
-- 0.3.1 (JM)
--    + [fix] changed simple type "INT" to doctrine "integer"
--            see http://code.google.com/p/mysql-workbench-doctrine-plugin/issues/detail?id=6
-- 0.3 (Karsten Wutzke)
--    + [fix] types BOOLEAN, BOOL, and INTEGER now working (are no simpleTypes)
--    + [add] lowercasing for default TRUE and FALSE keywords
--    + [imp] default NULL, TRUE, and FALSE detected case-insensitively now (WB does not
--            uppercase default values as opposed to all data types - which are keywords, too)
--    + [add] added version info to module ID and menu items, like this plugins with different
--            versions can be used at the same time (starting with this version and one old)
--    + [imp] file export: added simple functionality to append ".yml" extension to file paths
--            not ending with ".yml"
--    + [imp] removed some unnecessary prints
--    + [imp] shortened changelog entry types [improvement] to [imp] and [other] to [oth]
-- 0.2 (Karsten Wutzke)
--    + [add] foreignAlias for relations
--    + [fix] exception thrown in relationBuilding on some tables with foreign keys where the
--      column and referenced columns list has zero length
--    + [imp] replaced all string.len() calls with the length operator #s
--    + [add] function string.endswith()
--    + [imp] eased the code of function exportYamlSchemaToFile (eliminated double if)
--    + [add] functions to test if a (table) name is plural or singular
--    + [fix] reanimated functionality for (English) plural table names
--    + [add] functionality to adjust special (English) table names ending with "ies" to
--      convert "ie" to "y" ("Countries" -> "Country") and more
--    + [add] data type conversion of integer types and CHAR, BOOLEAN, and BOOL:
--         TINYINT   -> integer(1)
--         SMALLINT  -> integer(2)
--         MEDIUMINT -> integer(3)
--         INT       -> integer
--         INTEGER   -> integer
--         BIGINT    -> integer(8)
--         BOOLEAN   -> boolean
--         BOOL      -> boolean
--         CHAR      -> string + fixed option
--    + [add] option for CHAR columns
--    + [imp] removed using the table name capitalization function (ucfirst) from
--      function Helper.buildTableName(), like this tables retain their original names and the
--      default Workbench naming convention "_has_" still gets handled correctly
--    + [imp] replaced "\r\n" line endings with "\n" only
--    + [imp] using lowercase for default null values
--    + [imp] restructured MySQL plugin init code for easier understanding
-- 0.1alpha9
--    + [add] function to save to file
--    + [add] print version name on execution in debug window
-- 0.1alpha8
--    + [fix] changed behavior of table renaming (thanks to Francisco Ernesto Teixeira)
--      taBleNaMe -> Tablename ->[fix]-> TaBleNaMe
-- 0.1alpha7
--    + [oth] changed the license from GPLv2 to LGPLv3
--    + [fix] removed plural correction of table names (deprecated in Doctrine 1.0)
-- 0.1alpha6
--    + [fix] some conversion from workbench type to Doctrine type
--         BIGINT   -> INTEGER
--         DATETIME -> TIMESTAMP
--    + [fix] decimal (precision + scale)
--    + [fix] enum handling
-- 0.1alpha5 by quocbao (qbao.nguyen@gmail.com)
--    + [fix] some conversion from workbench type to Doctrine type
--    + [fix] removed generate_accessors [deprecated]
-- 0.1alpha4
--    + [add] tables_has_names -> TablesName ->[fix]-> TableName
--    + [add] rename columns "idtable | table_idtable" -> "id | table_id"
-- 0.1alpha3
--    + [add] convert underscores in tablenames to CamelCase
-- 0.1alpha2
--    + [add] nested set support for tablenames ending with _ns
-- 0.1alpha1
--    supports:
--    + [add] indexes [fulltext, unique, index]
--    + [add] index length
--    + [add] collation
--    + [add] character set
--    + [add] engine [MySQL, InnoDB]
--    + [add] relations
--    + [add] foreign key constraints
--    + [add] table name fixing
--    + [add] column flags [binary, zerofill, unsigned]
--    + [add] autoincrement
--    + [add] not null
--    + [add] default values
--    + [add] decimal precision
--    + [add] column length [e.g. varchar(255)]
--
----------------------------------------------------------------------------------------------

-- standard plugin functions
--
-- this function is called first by MySQL Workbench core to determine number of
-- plugins in this module and basic plugin info
-- see the comments in the function body and adjust the parameters as appropriate
--
function getModuleInfo()

    -- module properties
    local props =
        {
            -- module name (ID)
            name = "DoctrineExport",

            -- module author(s)
            author = "various",

            --module version
            version = "0.5.0pre",

            -- interface implemented by this module
            implements = "PluginInterface",

            -- plugin functions exposed by this module
            -- l looks like a parameterized list, i instance, o object, @ fully qualified class name
            functions =
                {
                    "getPluginInfo:l<o@app.Plugin>:",
                    "exportYamlSchemaToClipboard:i:o@db.Catalog",
                    "exportYamlSchemaToFile:i:o@db.Catalog"
                }
        }

    -- can't assign inside declaration
    props.name = props.name .. props.version

    return props
end

function objectPluginInput(type)

    return grtV.newObj("app.PluginObjectInput", {objectStructName = type})

end

function getPluginInfo()

    -- list of plugins this module exposes (list object of type app.Plugin?)
    local l = grtV.newList("object", "app.Plugin")

    -- plugin instances
    local plugin

    local props = getModuleInfo()

    -- new plugin: export to clipboard
    plugin = createNewPlugin("wb.catalog.util.exportYamlSchemaToClipboard" .. props.version,
                             "Doctrine Export " .. props.version .. ": Copy Generated Doctrine Schema to Clipboard",
                             props.name,
                             "exportYamlSchemaToClipboard",
                             {objectPluginInput("db.Catalog")},
                             {"Catalog/Utilities", "Menu/Catalog"})

    -- append to list of plugins
    grtV.insert(l, plugin)

    -- new plugin: export to file
    plugin = createNewPlugin("wb.catalog.util.exportYamlSchemaToFile" .. props.version,
                             "Doctrine Export " .. props.version .. ": Write Generated Doctrine Schema to File...",
                             props.name,
                             "exportYamlSchemaToFile",
                             {objectPluginInput("db.Catalog")},
                             {"Catalog/Utilities", "Menu/Catalog"})

    -- append to list of plugins
    grtV.insert(l, plugin)

    return l
end

function createNewPlugin(name, caption, moduleName, moduleFunctionName, inputValues, groups)

    -- create dictionary, Lua seems to handle keys and values right...
    local props =
        {
            name = name,
            caption = caption,
            moduleName = moduleName,
            pluginType = "normal",
            moduleFunctionName = moduleFunctionName,
            inputValues = inputValues,
            rating = 100,
            showProgress = 0,
            groups = groups
        }

    local plugin = grtV.newObj("app.Plugin", props)

    -- set owner???
    plugin.inputValues[1].owner = plugin

    return plugin
end

-- ############################
-- ##    change from here    ##
-- ############################

-- declare Config class
Config = {
    enableCrossDatabaseJoins           = false,     -- default false| true (for further information see blog post on
                                                    -- http://www.doctrine-project.org/blog/cross-database-joins )
    defaultStorageEngine               = "InnoDB",  -- default InnoDB|MyISAM
    enableStorageEngineOverride        = false,     -- default false|true
    enableOptionsHeader                = true,      -- default true|false (enable header output)
    enableRenameIdColumns              = true,      -- default true|false (detect_relations feature of doctrine)
    enableRenameUnderscoresToCamelcase = true,      -- default true|false (enable table_name -> tableName)
    enableRecapitalizeTableNames       = "first",   -- default first|all|none
    enableSingularPluralization        = true,      -- default true|false
    enableDoctrine20support            = false      -- default true|false
}

--
-- Print some version information and copyright to the output window
function printVersion()
    print("\n\n\nDoctrine Export v" .. getModuleInfo().version .. "\nCopyright (c) 2008 - 2009 Johannes Mueller, Karsten Wutzke - License: LGPLv3");
end

--
-- Implementation of Registry Pattern
-- does Lua know about Singletons?
Registry    = {}
Registry_mt = {}
Registry_mt.__index = Registry

-- Registry class constructor
function Registry:init()
    registry = {
        register = {}
    }
    setmetatable(registry, Registry_mt)
	return registry
end

function Registry.set(self, key, value)
   self.register[key] = value 
end

function Registry.get(self, key)
    if ( self.register[key] ~= nil ) then
        return self.register[key]
    end
end

register = Registry:init()

-- declare Table class
Table    = {}
Table_mt = {}
Table_mt.__index = Table

-- Table class constructor
function Table:init()
    foo = {
        bar = ""
    }
    setmetatable(foo, Table_mt)
	return foo
end

function Table.setTable(self, stable)
    self.bar = stable
end

function Table.getName(self)
    s = Helper.buildTableName(self.bar.name)
    return s
end

function Table.isTranslationTable(self)
    return string.endswith(self.bar.name, "_translation")
end

function Table.getYaml(self)
    if ( self.isTranslationTable ) then
        return ""
    end
    
    
end

-- declare Schema class
Schema    = {}
Schema_mt = {}
Schema_mt.__index = Schema

-- Schema class constructor
function Schema:init()
    schema = {
        tables = {},
        schema = ""
    }
    setmetatable(schema, Schema_mt)
	return schema
end

function Schema.setSchema(self, schema)
    local tbl, i ,j, k
    self.schema = schema
    k = 1
    for i = 1, grtV.getn(schema) do
        for j = 1, grtV.getn(schema[i].tables) do
            tbl = Table:init()
            tbl:setTable(schema[i].tables[j])
            self.tables[(tbl.name)] = tbl
            k = k + 1
            --
            -- do not export *_translation tables
            --if ( string.endswith(tbl.name, "_translation") == false ) then
            --    yaml = buildYamlForSingleTable(tbl, schema, yaml)
            --end
        end
    end
end

function Schema.getTables(self)
    return self.tables
end

function Schema.getYaml(self)
    return "schema"
end

function Schema.getName(self)
    return self.schema.name
end

-- declare Convert class
Convert = {}

-- declare Helper class
Helper = {}
function Helper.getSpacesByLevel(indentLevel)
    return string.rep(" ", indentLevel * 2)
end

-- declare Yml class
Yml    = {}
Yml_mt = {}
Yml_mt.__index = Yml

-- Yml class constructor
function Yml:init()
    yml = {
        yaml = ""
    }
    setmetatable(yml, Yml_mt)
	return yml
end

function Yml.writeHeaderSection(self)
	  self:appendLine(0, "---")
    self:appendLine(0, "")

    -- adds a header of copyright and other informations
    -- to the top of the yaml text
    self:appendComment("build with MySQL Workbench Doctrine Plugin " .. getModuleInfo().version )
    self:appendComment("for more information visit")
    self:appendComment("http://code.google.com/p/mysql-workbench-doctrine-plugin/")
    self:appendComment("")
    
    -- adds the date of workbench export
    self:appendComment("generated on: " .. os.date("%x"))
    
    -- adds an empty line after header
    self:appendLine(0, "")

    -- adds a header to the yaml
    if ( Config.enableOptionsHeader ) then

        -- enable automatic detection of relations by doctrine
        self:appendLine(0, "detect_relations: true")

        -- set basic options
        self:appendLine(0, "options:")

        -- adds the default collation
        if ( self.scheme.defaultCollationName ~= nil and self.scheme.defaultCollationName ~= "" ) then
            self:appendLine(1, "collation: " .. self.scheme.defaultCollationName)
        end

        -- adds the default character set
        if ( self.scheme.defaultCharacterSetName ~= nil and self.scheme.defaultCharacterSetName ~= "" ) then
            self:appendLine(1, "charset: " .. self.scheme.defaultCharacterSetName)
        end

        -- adds the default storage engine specified in config object in head of yaml file
        self:appendLine(1, "type: " .. Config.defaultStorageEngine)

        -- adds an empty line after header
        self:appendLine(0, "")
    end
end

function Yml.setSchema(self, schema)
    self.scheme = schema
end

-- appends a given text to the yaml text
function Yml.append(self, text)
    self.yaml = self.yaml .. text
end

-- appends a given line to yaml text
function Yml.appendLine(self, indentLevel, text)
    self.yaml = self.yaml .. Helper.getSpacesByLevel(indentLevel) .. text .. "\n"
end

-- appends comment to yaml text
function Yml.appendComment(self, comment)
    self:appendLine(0, "# " .. comment)
end

-- returns yaml text
function Yml.getYaml(self)
    return self.yaml
end

-- appends yaml of a given yaml object
function Yml.embedYml(self, yamlObject)
    self:append(yamlObject:getYaml())
end

--
-- Convert workbench simple types to doctrine types
function wbSimpleType2DoctrineDatatype(column)
    local conversionTable = {
        ["VARCHAR"]      = "string",
        ["CHAR"]         = "string",
        ["CHARACTER"]    = "string",
        ["INT1"]         = "integer(1)",
        ["TINYINT"]      = "integer(1)",
        ["INT2"]         = "integer(2)",
        ["SMALLINT"]     = "integer(2)",
        ["INT3"]         = "integer(3)",
        ["MEDIUMINT"]    = "integer(3)",
        ["INT4"]         = "integer(4)",
        ["INT"]          = "integer(4)",
        ["INTEGER"]      = "integer(4)",
        ["INT8"]         = "integer(8)",
        ["BIGINT"]       = "integer(8)",
        ["DEC"]          = "decimal",
        ["DECIMAL"]      = "decimal",
        ["NUMERIC"]      = "decimal",
        ["FLOAT"]        = "float",
        ["DOUBLE"]       = "double",
        ["DATE"]         = "date",
        ["TIME"]         = "time",
        ["DATETIME"]     = "timestamp",
        ["TIMESTAMP"]    = "timestamp",
        ["YEAR"]         = "integer(2)",
        ["BOOL"]         = "boolean",
        ["BOOLEAN"]      = "boolean",
        ["BINARY"]       = "binary",      -- internally Doctrine seems to map binary to blob, which is wrong
        ["VARBINARY"]    = "varbinary",   -- internally Doctrine seems to map varbinary to blob, which is OK
        ["TINYTEXT"]     = "clob(255)",
        ["TEXT"]         = "clob(65535)",
        ["MEDIUMTEXT"]   = "clob(16777215)",
        ["LONG"]         = "clob(16777215)",
        ["LONG VARCHAR"] = "clob(16777215)",
        ["LONGTEXT"]     = "clob",
        ["TINYBLOB"]     = "blob(255)",
        ["BLOB"]         = "blob(65535)",
        ["MEDIUMBLOB"]   = "blob(16777215)",
        ["LONGBLOB"]     = "blob",
        ["ENUM"]         = "enum",
        ["SET"]          = "enum"
    }
    
    local typeName = nil
    local doctrineType = "unknown"

    -- assign typeName with simpleType or userType (structuredType will not be supported anytime soon)
    if ( column.simpleType ~= nil ) then
        typeName = column.simpleType.name
    elseif ( column.userType ~= nil ) then
        typeName = column.userType.name
    elseif ( column.structuredType ~= nil ) then
        -- print("\n" .. column.name .. " type = " .. column.structuredType.name)
        return "structuredType (not implemented)"
    end

    -- print("\n" .. column.name .. " type = " .. typeName)

    -- grab conversion type
    doctrineType = conversionTable[(typeName)]

    if ( doctrineType == nil ) then
        -- expr and a or b is LUA ternary operator fake
        return "unsupported " .. (column.simpleType == nil and "simpleType" or "userType" ) .. " " .. typeName
    end
    
    -- in case of a decimal type try to add precision and scale
    if ( doctrineType == "decimal" ) then
        if ( column.precision ~= nil and column.precision ~= -1 ) then
            -- append precision in any case
            doctrineType = doctrineType .. "(" .. column.precision
            -- append optional scale (only possible if precision is valid)
            if ( column.scale ~= nil and column.scale ~= -1 ) then
                doctrineType = doctrineType .. "," .. column.scale 
            end
            -- close parentheses
            doctrineType = doctrineType .. ")"
        end
    end

    return string.lower(doctrineType)
end

--
-- handle enums for doctrine
function Helper.handleEnum(column)
    if ( column.datatypeExplicitParams ~= nil ) then
        local s = column.datatypeExplicitParams
        s = string.sub(s, 2, #s - 1)
        return s
    end
    return ""
end

--
-- converts first character of given string to uppercase
function string.ucfirst(s)
    -- capitalize the very first char, leave all others untouched
    return string.upper(string.sub(s, 0, 1)) .. string.sub(s, 2, #s)
end

--
-- converts a table_name to tableName
function Convert.underscoresToCamelCase(s)
    if (Config.enableRenameUnderscoresToCamelcase == true) then
        s = string.gsub(s, "_(%w)", function(v)
                return string.upper(v)
            end)
    end
    return s
end

--
-- rename idtable to id
-- rename table_idtable to table_id
function Convert.renameIdColumns(s)
    if (Config.enableRenameIdColumns == true) then
        s = string.gsub(s, "(id%w+)", function(v)
                return "id"
            end)
    end
    return s
end

--
-- changing tableNames of workbench into
-- doctrine friendly tableNames
function Helper.buildTableName(s)
    -- don't call ucfirst, leave table names as they are
    if ( Config.enableRecapitalizeTableNames == "first" ) then
        s = string.ucfirst(s)
    end

    if ( Helper.isNestedTableModel(s) ) then
        s = string.sub(s, 1, #s - 3)
    end
    --
    -- converting User_has_Groups (default WB-Scheme) to UserGroups
    -- as used in the doctrine manual
    --s = string.gsub(s, "_has_(%w)", function(v)
    --        return string.upper(v)
    --    end)
    --return s
    
    local patternStart, patternEnd = string.find(s, "_has_")
    if ( patternStart ~= nil and patternEnd ~= nil ) then
        local front = Helper.singularizeTableName(string.sub(s, 1, patternStart - 1))
        local back = string.sub(s, patternEnd + 1)
        s = string.ucfirst(front) .. string.ucfirst(back)
    end
    
    --
    -- check for config option in helper method
    s = Helper.singularizeTableName(s)

    --
    -- make camel_case to CamelCase
    -- check for config option in helper method
    s = Convert.underscoresToCamelCase(s)
    
    if ( Config.enableRecapitalizeTableNames == "all" ) then
        s = string.upper(s)
    end

    return s
end

-- extend string functionality
function string.endswith(s, suffix)
    return s:sub(#s - #suffix + 1) == suffix
end

function Helper.isPlural(s)
    -- is plural if string ends with an "s" but not with "ss"
    return string.endswith(s, "s") and not string.endswith(s, "ss") and #s > 1
end

function Helper.isSingular(s)
    -- is singular if not plural
    return not Helper.isPlural(s)
end

--
-- remove plural of tableNames
-- Groups becomes Group
function Helper.singularizeTableName(s)
    if (Config.enableSingularPluralization == false) then
        return s
    end
    -- is plural?
    if ( Helper.isPlural(s) ) then
        -- strip "s"
        s = string.sub(s, 1, #s - 1)

        -- we can't just strip the s without looking at the remaining English plural endings
        -- see http://en.wikipedia.org/wiki/English_plural

        -- if the table name ends with "e" ("coache", "hashe", "addresse", "buzze", "heroe", ...)
        if (    string.endswith(s, "che")
             or string.endswith(s, "she")
             or string.endswith(s, "sse")
             or string.endswith(s, "zze")
             or string.endswith(s, "oe") ) then

            -- strip an "e", too
            s = string.sub(s, 1, #s - 1)

        -- if table name ends with "ie"
        elseif ( string.endswith(s, "ie") ) then
            -- replace "ie" by a "y" ("countrie" -> "country", "hobbie" -> "hobby", ...)
            s = string.sub(s, 1, #s - 2) .. "y"

        elseif ( string.endswith(s, "ve") ) then
            -- replace "ve" by an "f" ("calve" -> "calf", "leave" -> "leaf", ...)
            s = string.sub(s, 1, #s - 2) .. "f"

            -- does *not* work for certain words ("knive" -> "knif", "stave" -> "staf", ...): TODO (hard)
        else
            -- do nothing ("game", "referee", "monkey", ...)

            -- note: table names like "Caches" can't be handled correctly because of the "che" rule above,
            -- that word however basically stems from French and might be considered a special case anyway
            -- also collective names like "Personnel", "Cast" (caution: SQL keyword!) can't be singularized
        end
    end

    return s
end

function Helper.pluralizeTableName(s)
    if (Config.enableSingularPluralization == true) then
        return s
    end
    -- is singular?
    if ( Helper.isSingular(s) ) then

        -- we can't just append the s without looking at the English singular endings
        -- see http://en.wikipedia.org/wiki/English_plural

        -- if the table name ends with "ch", "sh", "ss" or "zz" ("coach", "hash", "address", "buzz", "hero", ...)
        if (    string.endswith(s, "ch")
             or string.endswith(s, "sh")
             or string.endswith(s, "ss")
             or string.endswith(s, "zz")
             or string.endswith(s, "o") ) then

            -- append "es"
            s = s .. "es"

        -- if table name ends with "y"
        elseif ( string.endswith(s, "y") ) then
            -- replace "y" with "ies" ("country" -> "countries", "hobby" -> "hobbies", ...)
            s = string.sub(s, 1, #s - 1) .. "ies"

        elseif ( string.endswith(s, "f") ) then
            -- replace "f" by an "ves" ("leaf" -> "leaves", "half" -> "halves", ...)
            s = string.sub(s, 1, #s - 1) .. "ves"
        else
            -- append "s" ("games", "referees", "monkeys", ...)
            s = s .. "s"
        end
    end

    return s
end

--
-- checks if a given string ends with _ns
-- which means it is a NestedSet Table
function Helper.isNestedTableModel(s)
    if ( string.sub(s, #s - 2 ) == '_ns' ) then
        return true
    end
    return false
end

--
-- building yaml for relations of a given
-- foreignKey
function relationBuilding(tbl, tables)

    local i, k
    local foreignKey = nil
    local relations = Yml:init()
    relations:appendLine(1, "relations:")

    for k = 1, grtV.getn(tbl.foreignKeys) do

        foreignKey = tbl.foreignKeys[k]

		relations:appendLine(2, Helper.buildTableName(foreignKey.referencedTable.name) .. ":")
        -- check zero length
        if ( #foreignKey.columns > 0 ) then
        	relations:appendLine(3, "local: " .. Convert.renameIdColumns(foreignKey.columns[1].name))
        end

        -- check zero length
        if ( #foreignKey.referencedColumns > 0 ) then
        	relations:appendLine(3, "foreign: " .. Convert.renameIdColumns(foreignKey.referencedColumns[1].name))
        	relations:appendLine(3, "foreignAlias: " .. Helper.pluralizeTableName(Helper.buildTableName(tbl.name)))
        end

        if (     foreignKey.deleteRule ~= nil
             and foreignKey.deleteRule ~= ""
             and foreignKey.deleteRule ~= "NO ACTION" ) then
             
        	relations:appendLine(3, "onDelete: " .. string.lower( foreignKey.deleteRule ))
        end

        if (     foreignKey.updateRule ~= nil
             and foreignKey.updateRule ~= ""
             and foreignKey.updateRule ~= "NO ACTION" ) then
             
        	relations:appendLine(3, "onUpdate: " .. string.lower( foreignKey.updateRule ))
        end

        --if ( foreignKey.many == 1 ) then
        --    relations:appendLine(3, "type: many")
        --end
    end

    if ( foreignKey ~= nil ) then
        return relations:getYaml()
    end

    return ""
end

--
-- check for *_translation table
-- related to I18n Support in doctrine
function hasTranslationTableModel(tblname, tables)
    local k
    tblname = tblname .. "_translation"
    for k = 1, grtV.getn(tables) do
        if ( tblname == tables[k].name ) then
            return true
        end
    end
    return false
end

--
-- returns a reference of the translation table
-- by given table name
function getTranslationTableModel(tblname, tables)
    local k
    tblname = tblname .. "_translation"
    for k = 1, grtV.getn(tables) do
        if ( tblname == tables[k].name ) then
            return tables[k]
        end
    end
end

--
-- build a list of the I18n fields by a given
-- table name works only if *_translation table of
-- given tblname exist
function buildActAsI18nFieldsList(tblname, tables)
    local i, j, tbl, columns, col
    local returnText = Yml:init()
    returnText:append(3, "fields: [")
    -- convert given table name to *_translation
    tblname = tblname .. "_translation"
    -- iterate on all tables to look for
    -- correspondent *_translation table
    for i = 1, grtV.getn(tables) do
        tbl = tables[i]
        -- if *_translation table exist
        if ( tblname == tbl.name ) then
            cols = tbl.columns
            -- iterate on *_translation table columns
            for j = 1, grtV.getn(columns) do
                col = cols[j]
                -- ignore "id" and "lang" column
                -- of *_translation table for I18n
                -- field list
                if (     col.name ~= "id"
                     and col.name ~= "lang" ) then
                     
                    returnText:append(col.name)
                    -- prevent ", " on last item of list
                    if ( l < grtV.getn(columns) ) then
                        returnText:append(", ")
                    end
                end
            end
        end
    end
    --returnText = string.sub(returnText:getYaml(), 1, #returnText:getYaml() - 2)
    -- close I18n column list
    returnText:appendLine("]\n")
    return returnText:getYaml()
end

--
-- generates the yaml schema
function generateYamlSchema(cat)
    local yml = Yml:init()
    yml:writeHeaderSection()

    local schema = Schema:init();
    schema:setSchema(cat.schemata)
    
    yml:append(schema:getYaml())
    --print(yaml)

    return yml:getYaml()
end

function buildYamlForSingleColumn(tbl, col, yaml)
    local l, m

    doctrineType = Convert.WorkbenchTypeToDoctrine(col)
    --
    -- start of adding a column
    yaml = yaml.."    "..Convert.renameIdColumns(col.name)..":\n"
    yaml = yaml.."      type: " .. doctrineType
    if ( doctrineType == "enum" ) then
        -- enum handling
        yaml = yaml.."\n"
        yaml = yaml.."      values: ["
        yaml = yaml.. Helper.handleEnum(col)
        yaml = yaml.."]"
    end
    if ( col.length ~= -1 ) then
        yaml = yaml.. "(" ..col.length.. ")"
    end
    yaml = yaml.."\n"
    for m = 1, grtV.getn(tbl.indices) do
        index = tbl.indices[m]
        --
        -- checking for primary index
        if ( index.indexType == "PRIMARY" ) then
            for l = 1, grtV.getn(index.columns) do
                column = index.columns[l]
                if ( column.referencedColumn.name == col.name ) then
                    yaml = yaml .."      primary: true\n"
                end
            end
        end
        --
        -- checking for unique index
        if ( index.indexType == "UNIQUE" ) then
            -- check if just one column in index
            if ( grtV.getn(index.columns) == 1 ) then
                for l = 1, grtV.getn(index.columns) do
                    column = index.columns[l]
                    if ( column.referencedColumn.name == col.name ) then
                        yaml = yaml .. "      unique: true\n"
                    end
                end
            end
        end
    end
    --
    -- setting flags
    if ( col.flags ~= nil ) then
        local flag
        for l = 1, grtV.getn(col.flags) do
            flag = grtV.toLua(col.flags[l])
            if ( flag ~= nil ) then
                if ( flag == "UNSIGNED" ) then
                    yaml = yaml .. "      unsigned: true\n"
                end
                if ( flag == "BINARY" ) then
                    yaml = yaml .. "      binary: true\n"
                end
                if ( flag == "ZEROFILL" ) then
                    yaml = yaml .. "      zerofill: true\n"
                end
            end
        end
    end
    --
    -- checking for mysql column option not null
    if ( col.isNotNull == 1 ) then
        yaml = yaml.."      notnull: true\n"
    end
    --
    -- checking for default value of a column
    if ( col.defaultValue ~= '' and string.upper(col.defaultValue) ~= 'CURRENT_TIMESTAMP' ) then
        yaml = yaml .. "      default: "

        -- Lua has no switch...
        -- switch ( string.upper(col.defaultValue) )

        -- if null, true, or false then lowercase
        if (    string.upper(col.defaultValue) == "NULL"
             or string.upper(col.defaultValue) == "TRUE"
             or string.upper(col.defaultValue) == "FALSE" ) then
            yaml = yaml .. string.lower(col.defaultValue)
        else
            yaml = yaml .. col.defaultValue
        end
        yaml = yaml .. "\n"
    end
    --
    -- checking for autoincrement of a column
    if ( col.autoIncrement == 1 ) then
        yaml = yaml.."      autoincrement: true\n"
    end

    -- if CHAR type, set fixed flag
    if ( col.simpleType ~= nil and col.simpleType.name == "CHAR" ) then
        yaml = yaml.."      fixed: true\n"
    end

    return yaml
end

function buildYamlForSingleTable(tbl, schema, yaml)
    local k, l, col, index, column
    local actAsPart = ""

    --
    -- start of adding a table
    yaml = yaml .. Helper.buildTableName(tbl.name) .. ":\n"

    -- test singularize and pluralize functions
    --print("\n" .. Helper.singularizeTableName(tbl.name))
    --print(" <-> ")
    --print(Helper.pluralizeTableName(tbl.name))

    --
    -- add the real table name to the model
    if ( Helper.buildTableName(tbl.name) ~= tbl.name and Config.enableCrossDatabaseJoins ~= true ) then
        yaml = yaml .. "  tableName: " .. tbl.name .. "\n"
    end

    if ( Config.enableCrossDatabaseJoins ) then
        yaml = yaml .. "  tableName: " .. schema.name .. "." .. tbl.name .. "\n"
        yaml = yaml .. "  connection: " .. schema.name .. "\n"
    end

    -- check if table ends with _ns means
    -- NestedSet Model
    if ( Helper.isNestedTableModel(tbl.name) ) then
        actAsPart = actAsPart .. "    NestedSet:\n"
    end

    --
    -- check for I18n tables
    if ( hasTranslationTableModel(tbl.name, schema.tables) ) then
        actAsPart = actAsPart .. "    I18n:\n"
        actAsPart = actAsPart .. buildActAsI18nFieldsList(tbl.name, schema.tables)
    end

    --
    -- add ActAs: part to the table model
    if ( string.len(actAsPart) > 0 ) then
        yaml = yaml .. "  actAs:\n"
        yaml = yaml .. actAsPart
    end

    --
    -- iterate through the table columns
    yaml = yaml .. "  columns:\n"
    for k = 1, grtV.getn(tbl.columns) do
        col = tbl.columns[k]
        yaml = buildYamlForSingleColumn(tbl, col, yaml)
    end

    --
    -- hack for adding columns outsourced
    -- to a *_translation table
    if ( hasTranslationTableModel(tbl.name, schema.tables) ) then
        local translationTable
        translationTable = getTranslationTableModel(tbl.name, schema.tables)
        for k = 1, grtV.getn(translationTable.columns) do
            col = translationTable.columns[k]
            if ( col.name ~= "id" and col.name ~= "lang" ) then
                yaml = buildYamlForSingleColumn(tbl, col, yaml)
            end
        end
    end

    --
    -- add foreign keys
    yaml = yaml .. relationBuilding(tbl, schema.tables)
    --
    -- add missing indices
    local indexes = ""
    for k = 1, grtV.getn(tbl.indices) do
        index = tbl.indices[k]
        if ( index.indexType == "INDEX" ) then
            indexes = indexes .. "    " .. index.name .. ":\n"
            indexes = indexes .. "      fields: ["
            for l = 1, grtV.getn(index.columns) do
                column = index.columns[l]
                indexes = indexes .. Convert.renameIdColumns(column.referencedColumn.name)
                if ( l < grtV.getn(index.columns) ) then
                    indexes = indexes .. ", "
                end
            end
            indexes = indexes .. "]\n"
            if ( index.keyBlockSize ~= nil and index.keyBlockSize ~= 0 ) then
                indexes = indexes .. "      length: " .. index.keyBlockSize .. "\n"
            end
        end
        if ( index.indexType == "FULLTEXT" ) then
            indexes = indexes .. "    " .. index.name .. ":\n"
            indexes = indexes .. "      fields: ["
            for l = 1, grtV.getn(index.columns) do
                column = index.columns[l]
                indexes = indexes .. Convert.renameIdColumns(column.referencedColumn.name)
                if ( l < grtV.getn(index.columns) ) then
                    indexes = indexes .. ", "
                end
            end
            indexes = indexes .. "]\n"
            indexes = indexes .. "      type: fulltext\n"
        end
        if ( index.indexType == "UNIQUE" ) then
            -- check if more than 1 column in index
            -- otherwise ignore
            if( grtV.getn(index.columns) > 1 ) then
                indexes = indexes .. "    " .. index.name .. ":\n"
                indexes = indexes .. "      fields:\n"
                for l = 1, grtV.getn(index.columns) do
                    column = index.columns[l]
                    indexes = indexes .. "        " .. Convert.renameIdColumns(column.referencedColumn.name) .. ":\n"
                    -- check if column in index is ASC or DESC
                    if ( column.descend ~= nil and column.descend ~= "" ) then
                        if ( column.descend == 0 ) then
                            indexes = indexes .. "          sorting: ASC\n"
                        else
                            indexes = indexes .. "          sorting: DESC\n"
                        end
                    end
                    -- check for column length in index
                    if ( column.columnLength ~= nil and column.columnLength ~= "" and column.columnLength ~= 0 ) then
                        indexes = indexes .. "          length: " .. column.columnLength .. "\n"
                    end
                end
                indexes = indexes .. "      type: unique\n"
            end
        end
    end
    if ( indexes ~= "" ) then
        yaml = yaml .. "  indexes:\n" .. indexes
    end
    --
    -- add the options
    local options = ""
    if ( tbl.defaultCharacterSetName ~= nil and tbl.defaultCharacterSetName ~= "" ) then
        options = options .. "    charset: " .. tbl.defaultCharacterSetName .. "\n"
    end
    if ( tbl.defaultCollationName ~= nil and tbl.defaultCollationName ~= "" ) then
        options = options .. "    collate: " .. tbl.defaultCollationName .. "\n"
    end
    if ( tbl.tableEngine ~= nil and tbl.tableEngine ~= "" ) then
        options = options .. "    type: " .. tbl.tableEngine .. "\n"
    end
    if ( options ~= "" ) then
        yaml = yaml .. "  options:\n" .. options
    end

    -- final line break
    return yaml .. "\n"
end

---------------------------------------------------------------------------------------------------

-- export function #1
function exportYamlSchemaToClipboard(catalog)

    printVersion()
    --local yaml = generateYamlSchema(catalog)
    local yml = Yml:init()
    yml:setSchema(catalog.schemata[1])
    yml:writeHeaderSection()

    local schema = Schema:init()
    schema:setSchema(catalog.schemata)
    
    Workbench:copyToClipboard(yml:getYaml())

    print('\n > YAML schema copied to clipboard')

    return 0
end

-- export function #2
function exportYamlSchemaToFile(catalog)

    printVersion()
    local yaml = generateYamlSchema(catalog)
    local file = catalog.customData["doctrineExportPath"]

    --print("\nFilepath is: " .. file)

    if ( file ~= nil and
         Workbench:confirm("Overwrite?", "Do you want to overwrite the previously exported file " .. file .. "?") == 1 ) then

        -- global
        doctrineExportPath = file

    else
        doctrineExportPath = Workbench:input("Please enter a path to the file to export the doctrine schema to.")

        if ( doctrineExportPath ~= "" ) then
            -- Try to save the filepath for the next time:

            -- if file path doesn't end with .yml, append that
            if ( not string.endswith(doctrineExportPath, ".yml") ) then

                if ( string.endswith(doctrineExportPath, ".") ) then
                    doctrineExportPath = doctrineExportPath .. "yml"
                else
                    doctrineExportPath = doctrineExportPath .. ".yml"
                end
            end

            catalog.customData["doctrineExportPath"] = doctrineExportPath
        end
    end

    if ( doctrineExportPath ~= '' ) then

        f = io.open(doctrineExportPath, "w")

        if ( f ~= nil ) then
            f.write(f, yaml)
            f.close(f)
            print('\n > Doctrine schema was written to file ' .. doctrineExportPath)
        else
            print('\n > Could not open file for writing ' .. doctrineExportPath .. '!')
        end
    else
        print('\n > Doctrine schema not exported as no path was given!')
    end

    return 0
end
