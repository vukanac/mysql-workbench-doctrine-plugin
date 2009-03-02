--
-- MySQL Workbench Doctrine Plugin
-- Version: 0.1alpha9
-- Copyright 2008, 2009 Johannes Mueller
--
-- http://code.google.com/p/mysql-workbench-doctrine-plugin/
--
-- * The MySQL Workbench Doctrine plugin allows you to export a catalog
-- * as Doctrine YAML-schema.
-- * This plugin is build against MySQL Workbench 5.0.23 OSS
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
-- special thanks to:
--    Daniel Haas who develops the MySQL Workbench Propel export plugin
--    and kindly agreed to adopt pieces of his source
--    http://www.diloc.de/blog/
--
---------------------------------------------------------------------------------------------
--
-- * IMPORTANT:
-- * If you find BUGS in this plugin or have ideas for IMPROVEMENTS or PATCHES, dont hesitate
-- * to contact me at http://code.google.com/p/mysql-workbench-doctrine-plugin/
--
-- INSTALLATION:
-- 1. copy this file in the modules/ folder of your workbench installation
-- 2. open mysql workbench
-- 3. navigate to plugins->catalog->Doctrine export: ...
--    3a. the yaml-scheme is now on the clipboard
-- 4. open a new file
-- 5. click right mouse button and press insert or press Ctrl+V (on Windows)
-- 6. save the file and rename it to schema.yml
-- 7. finished, you can now use it with doctrine/symfony
--
---------------------------------------------------------------------------------------------
--
-- CHANGELOG:
-- 0.1alpha9
--    + [add] function to save a file (workaround)
--    + [add] print version name on execution in debug window
-- 0.1alpha8
--    + [fix] changed behaviour of table renaming (thanks to Francisco Ernesto Teixeira)
--         taBleNaMe -> Tablename ->[fix]-> TaBleNaMe
-- 0.1alpha7
--    + [other] changed the license from GPLv2 to LGPLv3
--    + [fix] removed plural correction of table names (deprecated in doctrine 1.0)
-- 0.1alpha6
--    + [fix] some convertion from workbench type to doctrine type
--         BIGINT   -> INTEGER
--         DATETIME -> TIMESTAMP
--    + [fix] decimal (precision + scale)
--    + [fix] enum handling
-- 0.1alpha5 by quocbao (qbao.nguyen@gmail.com)
--    + [fix] some convertion from workbench type to doctrine type
--    + [fix] removed generate_accessors [deprecated]
-- 0.1alpha4
--    + [add] tables_has_names -> TablesName ->[fix]-> TableName
--    + [add] rename columns "idtable | table_idtable" -> "id | table_id"
-- 0.1alpha3
--    + [add] convert underscores in tablenames to CamelCase
-- 0.1alpha2
--    + [add] nestedset support for tablenames ending with _ns
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
---------------------------------------------------------------------------------------------
-- standard plugin functions
--
-- this function is called first by MySQL Workbench core to determine number of
-- plugins in this module and basic plugin info
-- see the comments in the function body and adjust the parameters as appropriate
--
function getModuleInfo()
   return {
      name= "Doctrine export",
      author= "various",
      version= "0.1",
      implements= "PluginInterface",
      functions= {
            "getPluginInfo:l<o@app.Plugin>:",
            "exportYamlSchemaToClipboard:i:o@db.Catalog",
            "exportYamlSchemaToFile:i:o@db.Catalog",
      }
   }
end

function objectPluginInput(type)
   return grtV.newObj("app.PluginObjectInput", {objectStructName= type})
end

function getPluginInfo()
    local l
    local plugin

    l= grtV.newList("object", "app.Plugin")

    plugin= grtV.newObj("app.Plugin", {
      name= "wb.catalog.util.exportYamlSchemaToClipboard",
      caption= "Doctrine export: Copy Catalog as YAML-Schema to Clipboard",
      moduleName= "Doctrine export",
      pluginType= "normal",
      moduleFunctionName= "exportYamlSchemaToClipboard",
      inputValues= {objectPluginInput("db.Catalog")},
      rating= 100,
      showProgress= 0,
      groups= {"Catalog/Utilities", "Menu/Catalog"}
   })

    plugin.inputValues[1].owner= plugin
    grtV.insert(l, plugin)
    
    plugin= grtV.newObj("app.Plugin", {
      name= "wb.catalog.util.exportYamlSchemaToFile",
      caption= "Doctrine export: Copy Catalog as YAML-Schema to File",
      moduleName= "Doctrine export",
      pluginType= "normal",
      moduleFunctionName= "exportYamlSchemaToFile",
      inputValues= {objectPluginInput("db.Catalog")},
      rating= 100,
      showProgress= 0,
      groups= {"Catalog/Utilities", "Menu/Catalog"}
   })

    plugin.inputValues[1].owner= plugin
    grtV.insert(l, plugin)

    return l
end

-- ############################
-- ##    change from here    ##
-- ############################

--
-- Print some version information and copyright to the output window
function printVersion()
	print("\n\n\nThis is DoctrineExport v. 0.1alpha8\nCopyright (c) 2008, 2009 Johannes Mueller - License: LGPLv3");
end

--
-- Convert workbench simple types to doctrine types
function wbSimpleType2DoctrineDatatype(column)
    if (column.simpleType ~= nil) then
        local doctrineType = column.simpleType.name

        -- convert VARCHAR to STRING
        if ( column.simpleType.name == "VARCHAR" ) then
          doctrineType = "string"
        end

        -- convert INT to INTEGER
        if ( column.simpleType.name == "INT" ) then
            doctrineType = "integer"
        end

        -- convert DATETIME to TIMESTAMP
        if ( column.simpleType.name == "DATETIME" ) then
            doctrineType = "timestamp"
        end

        -- convert BIGINT to INTEGER
        if ( column.simpleType.name == "BIGINT" ) then
            doctrineType = "integer"
        end

        -- decimal
        if( column.simpleType.name == "DECIMAL" ) then
            doctrineType = "decimal"
            if ( column.precision ~= nil ) then
                doctrineType = doctrineType .. "(" .. column.precision .. ",".. column.scale ..")"
            end
        end

        -- text
        if( column.simpleType.name == "TEXT") then
          doctrineType = "clob"
        end

        return string.lower(doctrineType)
    else
        return "unknown"
    end
end

--
-- handle enums for doctrine
function handleEnum(column)
    if( column.datatypeExplicitParams ~= nil ) then
        local s = column.datatypeExplicitParams
        s = string.sub(s, 2, string.len(s) - 1)
        return s
    end
    return ""
end

--
-- converts first character of given string to uppercase
function ucfirst(val)
    -- [fix] for 0.1alpha8
    -- return string.upper(string.sub(val, 0, 1))..""..string.lower(string.sub(val, 2, string.len(val)));
    return string.upper(string.sub(val, 0, 1))..""..string.sub(val, 2, string.len(val))
end

--
-- converts a table_name to tableName
function underscoresToCamelCase(s)
   s = string.gsub(s, "_(%w)", function(v)
         return string.upper(v)
       end)
   return s
end

--
-- rename idtable to id
-- rename table_idtable to table_id
function renameIdColumns(s)
   s = string.gsub(s, "(id%w+)", function(v)
         return "id"
       end)
   return s
end

--
-- changing tableNames of workbench into
-- doctrine friendly tableNames
function buildTableName(s)
    s = ucfirst( s )
    --
    -- delete _ns of tableNames
    if ( isNestedTableModel(s) ) then
        s = string.sub(s, 1, string.len(s)-3 )
    end

    --
    -- converting User_has_Groups (default WB-Scheme) to UserGroups
    -- as used in the doctrine manual
    local patternStart, patternEnd = string.find( s, "_has_" )
    if( patternStart ~= nil and patternEnd ~= nil ) then
        local front = pluralTablenamesToSingle(string.sub(s, 1, patternStart-1 ))
        local back = string.sub( s, patternEnd + 1 )
        s = ucfirst(front) .. ucfirst(back)
    end

    s = pluralTablenamesToSingle(s)

    --
    -- make camel_case to CamelCase
    s = underscoresToCamelCase(s)
    return s
end

--
-- remove plural of tableNames
-- Groups becomes Group
function pluralTablenamesToSingle(s)
    --
    -- removed in 0.1alpha7, instead throwing a notice
    -- if ( string.sub(s, string.len(s) ) == "s" ) then
    --    s = string.sub(s, 1, string.len(s) - 1)
    -- end
    if ( string.sub(s, string.len(s) ) == "s" ) then
        print('\n > [NOTICE] table name \"' .. s .. '\" is not singular');
    end
    return s
end

--
-- checks if a given string ends with _ns
-- which means it is a NestedSet Table
function isNestedTableModel(s)
    if ( string.sub(s, string.len(s)-2 ) == '_ns' ) then
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
    local relations = "  relations:\r\n"
    for k = 1, grtV.getn(tbl.foreignKeys) do
        foreignKey = tbl.foreignKeys[k]
        relations = relations .. "    " .. buildTableName(foreignKey.referencedTable.name) .. ":\r\n"
        relations = relations .. "      local: " .. renameIdColumns(foreignKey.columns[1].name) .. "\r\n"
        relations = relations .. "      foreign: " .. renameIdColumns(foreignKey.referencedColumns[1].name) .. "\r\n"
        if ( foreignKey.deleteRule ~= nil and foreignKey.deleteRule ~= "" and foreignKey.deleteRule ~= "NO ACTION" ) then
            relations = relations .. "      onDelete: " .. string.lower( foreignKey.deleteRule ) .. "\r\n"
        end
        if ( foreignKey.updateRule ~= nil and foreignKey.updateRule ~= "" and foreignKey.updateRule ~= "NO ACTION" ) then
            relations = relations .. "      onUpdate: " .. string.lower( foreignKey.updateRule ) .. "\r\n"
        end
        --if ( foreignKey.many == 1 ) then
        --    relations = relations .. "      type: many\r\n"
        --end
    end
    if ( foreignKey ~= nil ) then
        return relations
    end
    return ""
end

--
-- outputs the whole yaml scheme to the clipboard
function generateYamlSchemeFromCatalog(cat)
    local i, j, k, l, m, schema, tbl, col, index, column
    local script = ""
    local separator = ""
    local yaml = "---\r\n"

    for i = 1, grtV.getn(cat.schemata) do
        schema = cat.schemata[i]

        -- 
        -- deprecated with doctrine 1.0
        -- yaml = yaml .. "generate_accessors: true\r\n"

        -- 
        -- detect automaticly the relations
        yaml = yaml .. "detect_relations: true\r\n"
        --
        -- set basic options
        yaml = yaml .. "options:\r\n"
        yaml = yaml .. "  collation: " .. schema.defaultCollationName .. "\r\n"
        yaml = yaml .. "  charset: " .. schema.defaultCharacterSetName .. "\r\n"
        yaml = yaml .. "  type: InnoDB\r\n\r\n"

        for j = 1, grtV.getn(schema.tables) do
            tbl = schema.tables[j]
            --
            -- start of adding a table
            yaml = yaml .. buildTableName(tbl.name) .. ":\r\n"
            --
            -- check if table ends with _ns means
            -- NestedSet Model
            if( isNestedTableModel(tbl.name) ) then
                yaml = yaml .. "  actAs: [NestedSet]\r\n"
            end
            if ( buildTableName(tbl.name) ~= tbl.name ) then
                yaml = yaml .. "  tableName: " .. tbl.name .. "\r\n"
            end
            yaml = yaml .. "  columns:\r\n"
            for k = 1, grtV.getn(tbl.columns) do
                col = tbl.columns[k]
                --
                -- start of adding a column
                yaml = yaml.."    "..renameIdColumns(col.name)..":\r\n"
                yaml = yaml.."      type: " .. wbSimpleType2DoctrineDatatype(col)
                if( wbSimpleType2DoctrineDatatype(col) == "enum" ) then
                    -- enum handling
                    yaml = yaml.."\r\n"
                    yaml = yaml.."      values: ["
                    yaml = yaml.. handleEnum(col)
                    yaml = yaml.."]"
                end
                if( col.length ~= -1 ) then
                    yaml = yaml.. "(" ..col.length.. ")"
                end
                yaml = yaml.."\r\n"
                for m = 1, grtV.getn(tbl.indices) do
                    index = tbl.indices[m]
                    --
                    -- checking for primary index
                    if( index.indexType == "PRIMARY") then
                        for l = 1, grtV.getn(index.columns) do
                            column = index.columns[l]
                            if(column.referencedColumn.name == col.name) then
                                yaml = yaml .."      primary: true\r\n"
                            end
                        end
                    end
                    --
                    -- checking for unique index
                    if ( index.indexType == "UNIQUE" ) then
                        for l = 1, grtV.getn(index.columns) do
                            column = index.columns[l]
                            if(column.referencedColumn.name == col.name) then
                                yaml = yaml .. "      unique: true\r\n"
                            end
                        end
                    end
                end
                --
                -- setting flags
                if( col.flags ~= nil ) then
                    local flag
                    for l = 1, grtV.getn(col.flags) do
                        flag = grtV.toLua(col.flags[l])
                        if( flag ~= nil ) then
                            if ( flag == "UNSIGNED" ) then
                                yaml = yaml .. "      unsigned: true\r\n"
                            end
                            if ( flag == "BINARY" ) then
                                yaml = yaml .. "      binary: true\r\n"
                            end
                            if ( flag == "ZEROFILL" ) then
                                yaml = yaml .. "      zerofill: true\r\n"
                            end
                        end
                    end
                end
                --
                -- checking for mysql column option not null
                if ( col.isNotNull == 1 ) then
                    yaml = yaml.."      notnull: true\r\n"
                end
                --
                -- checking for default value of a column
                if ( col.defaultValue ~= '' and col.defaultValue ~= 'CURRENT_TIMESTAMP' ) then
                    yaml = yaml.."      default: " ..col.defaultValue.. "\r\n"
                end
                --
                -- checking for autoincrement of a column
                if ( col.autoIncrement == 1 ) then
                    yaml = yaml.."      autoincrement: true\r\n"
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
                    indexes = indexes .. "    " .. index.name .. ":\r\n"
                    indexes = indexes .. "      fields: ["
                    for l = 1, grtV.getn(index.columns) do
                        column = index.columns[l]
                        indexes = indexes .. renameIdColumns(column.referencedColumn.name)
                        if l < grtV.getn(index.columns) then
                            indexes = indexes .. ", "
                        end
                    end
                    indexes = indexes .. "]\r\n"
                    if ( index.keyBlockSize ~= nil and index.keyBlockSize ~= 0 ) then
                        indexes = indexes .. "      length: " .. index.keyBlockSize .. "\r\n"
                    end
                end
                if ( index.indexType == "FULLTEXT" ) then
                    indexes = indexes .. "    " .. index.name .. ":\r\n"
                    indexes = indexes .. "      fields: ["
                    for l = 1, grtV.getn(index.columns) do
                        column = index.columns[l]
                        indexes = indexes .. renameIdColumns(column.referencedColumn.name)
                        if l < grtV.getn(index.columns) then
                            indexes = indexes .. ", "
                        end
                    end
                    indexes = indexes .. "]\r\n"
                    indexes = indexes .. "      type: fulltext\r\n"
                end
            end
            if( indexes ~= "") then
                yaml = yaml .. "  indexes:\r\n" .. indexes
            end
            --
            -- add the options
            local options = ""
            if ( tbl.tableEngine ~= nil and tbl.tableEngine ~= "" ) then
                options = options .. "    type: " .. tbl.tableEngine .. "\r\n"
            end
            if ( tbl.defaultCollationName ~= nil and tbl.defaultCollationName ~= "" ) then
                options = options .. "    collate: " .. tbl.defaultCollationName .. "\r\n"
            end
            if ( tbl.defaultCharacterSetName ~= nil and tbl.defaultCharacterSetName ~= "" ) then
                options = options .. "    charset: " .. tbl.defaultCharacterSetName .. "\r\n"
            end
            if ( options ~= "" ) then
                yaml = yaml .. "  options:\r\n" .. options
            end
            -- final line break
            yaml = yaml .. "\r\n"
        end
    end
    return yaml
end

function exportYamlSchemaToClipboard(catalog)
    printVersion()
    local yamlSchema = generateYamlSchemeFromCatalog(catalog)
    Workbench:copyToClipboard(yamlSchema)
    print("\n > YAML-schema copied to clipboard")
    return 0
end

--
-- thanks to Daniel Haas for file export functionality
function exportYamlSchemaToFile(catalog)
    printVersion()
    local yamlSchema = generateYamlSchemeFromCatalog(catalog)
    
    if (catalog.customData["yamlExportPath"] ~= nil) then
        -- print("\nFilepath is: "..catalog.customData["yamlExportPath"]);
        if (Workbench:confirm("Proceed?","Do you want to overwrite previously exported file "..catalog.customData["yamlExportPath"].." ?") == 1) then
            yamlExportPath=catalog.customData["yamlExportPath"];
        else
            yamlExportPath=Workbench:input('Please enter filepath and name to export the yaml schema to');
            if (yamlExportPath~="") then
                -- Try to save the filepath for the next time:
                catalog.customData["yamlExportPath"]=yamlExportPath;
            end
        end
    else
        yamlExportPath=Workbench:input('Please enter filepath and name to export the yaml schema to');
        if (yamlExportPath~="") then
            -- Try to save the filepath for the next time:
            catalog.customData["yamlExportPath"]=yamlExportPath;
        end
    end
  
    if yamlExportPath~='' then
        f = io.open(yamlExportPath,"w");
        if (f~=nil) then
            yamlSchema = string.gsub(yamlSchema, "\r", "")
            f.write(f, yamlSchema);
            f.close(f);
            print('\n > Yaml-Scheme was exported to '..yamlExportPath);  
        else
            print('\n > Could not open file '..yamlExportPath..'!');
        end
    else
        print('\n > Yaml-Scheme was NOT exported as no path was given!');
    end
    return 0
end
