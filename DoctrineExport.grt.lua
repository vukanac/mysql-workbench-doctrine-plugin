--
-- MySQL Workbench Doctrine Export Plugin
-- Version: 0.3
-- Authors: Johannes Müller, Karsten Wutzke
-- Copyright (c) 2008-2009
--
-- http://code.google.com/p/mysql-workbench-doctrine-plugin/
--
-- * The export plugin allows you to export a catalog as Doctrine YAML schema.
-- * This plugin was tested with MySQL Workbench 5.1.10 OSS (beta2)
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
--    5.1.9 up to 5.2.1alpha (other versions untested): http://bugs.mysql.com/bug.php?id=44461
-- 4. To change the schema character set and collation in Workbench 5.1.x you have to go to tab
--    "MySQL Model" -> "Physical Schemata", then double click that yellow DB image with the
--    schema name next to it.
-- 
-- CHANGELOG:
-- 0.3 (Karsten Wutzke)
--    + [fix] types BOOLEAN, BOOL, and INTEGER now working (aren't simpleType)
--    + [add] lowercasing for default TRUE and FALSE keywords
--    + [imp] default NULL, TRUE, and FALSE detected case-insensitively now (WB doesn't
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
--    + [improvement] replaced all string.len() calls with the length operator #s
--    + [add] function string.endswith()
--    + [improvement] eased the code of function exportYamlSchemaToFile (eliminated double if)
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
--      function buildTableName(), like this tables retain their original names and the
--      default Workbench naming convention "_has_" still gets handled correctly
--    + [imp] replaced "\r\n" line endings with "\n" only
--    + [imp] using lowercase for default null values
--    + [imp] restructured MySQL plugin init code for easier understanding
--    + [imp] changed the file name to "DoctrineExport-<major>.<minor>.grt.lua"
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
			version = "0.3",
			
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
-- ##	change from here	##
-- ############################

--
-- Print some version information and copyright to the output window
function printVersion()
	print("\n\n\nDoctrineExport v0.3\nCopyright (c) 2008 - 2009 Johannes Mueller, Karsten Wutzke - License: LGPLv3");
end

--
-- Convert workbench simple types to doctrine types
function wbSimpleType2DoctrineDatatype(column)
	
	--print("\n")
	--print(column)
	
	local doctrineType
	
	-- boolean, bool, and integer don't seem to be simple types, but rather user types...
	if ( column.simpleType ~= nil ) then
	
		doctrineType = column.simpleType.name
		
		--print("\n" .. column.name .. " type = " .. column.simpleType.name)
		
		-- convert VARCHAR and CHAR to string
		if ( column.simpleType.name == "VARCHAR" or column.simpleType.name == "CHAR" ) then
		  doctrineType = "string"
		end
		
		-- convert TINYINT to integer(1)
		if ( column.simpleType.name == "TINYINT" ) then
			doctrineType = "integer(1)"
		end
		
		-- convert SMALLINT to integer(2)
		if ( column.simpleType.name == "SMALLINT" ) then
			doctrineType = "integer(2)"
		end
		
		-- convert MEDIUMINT to integer(3)
		if ( column.simpleType.name == "MEDIUMINT" ) then
			doctrineType = "integer(3)"
		end
		
		if ( column.simpleType.name == "INT" ) then
			doctrineType = "int"
		end
		
		-- convert BIGINT to integer(8)
		if ( column.simpleType.name == "BIGINT" ) then
			doctrineType = "integer(8)"
		end
		
		-- decimal
		if ( column.simpleType.name == "DECIMAL" ) then
			doctrineType = "decimal"
			if ( column.precision ~= nil ) then
				doctrineType = doctrineType .. "(" .. column.precision .. "," .. column.scale .. ")"
			end
		end
		
		-- text
		if( column.simpleType.name == "TEXT" ) then
			doctrineType = "clob"
		end
		
		-- convert DATETIME to TIMESTAMP (DATETIME is not ISO/IEC standard SQL)
		if ( column.simpleType.name == "DATETIME" ) then
			doctrineType = "timestamp"
		end
		
		return string.lower(doctrineType)
		
	elseif ( column.userType ~= nil ) then
		
		--print("\n" .. column.name .. " type = " .. column.userType.name)
		
		if ( column.userType.name == "INTEGER" ) then
			doctrineType = "integer"
		end
		
		-- convert BOOLEAN and BOOL to boolean
		if ( column.userType.name == "BOOLEAN" or column.userType.name == "BOOL" ) then
			doctrineType = "boolean"
		end
		
		return string.lower(doctrineType)
		
	elseif ( column.structuredType ~= nil ) then
		--print("\n" .. column.name .. " type = " .. column.structuredType.name)
		return "structuredType (not implemented yet)"
	else
		return "unknown"
	end
end

--
-- handle enums for doctrine
function handleEnum(column)
	if ( column.datatypeExplicitParams ~= nil ) then
		local s = column.datatypeExplicitParams
		s = string.sub(s, 2, #s - 1)
		return s
	end
	return ""
end

--
-- converts first character of given string to uppercase
function ucfirst(s)
	-- only capitalize the very first char, leave all others untouched
	return string.upper(string.sub(s, 0, 1)) .. string.sub(s, 2, #s)
	
	-- old: lowers rest for whatever reason
	--return string.upper(string.sub(s, 0, 1)) .. string.lower(string.sub(s, 2, #s))
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
	-- don't call ucfirst, leave table names as they are
	--s = ucfirst(s)

	if ( isNestedTableModel(s) ) then
		s = string.sub(s, 1, #s - 3)
	end
	--
	-- converting User_has_Groups (default WB-Scheme) to UserGroups
	-- as used in the doctrine manual
	local patternStart, patternEnd = string.find(s, "_has_")
	if ( patternStart ~= nil and patternEnd ~= nil ) then
		local front = singularizeTableName(string.sub(s, 1, patternStart - 1))
		local back = string.sub(s, patternEnd + 1)
		s = ucfirst(front) .. ucfirst(back)
	end
	
	s = singularizeTableName(s)

	--
	-- make camel_case to CamelCase
	s = underscoresToCamelCase(s)

	return s
end

-- extend string functionality
function string.endswith(s, suffix)
	return s:sub(#s - #suffix + 1) == suffix
end

function isPlural(s)
	-- is plural if string ends with an "s" but not with "ss"
	return string.endswith(s, "s") and not string.endswith(s, "ss") and #s > 1
end

function isSingular(s)
	-- is singular if not plural
	return not isPlural(s)
end

--
-- remove plural of tableNames
-- Groups becomes Group
function singularizeTableName(s)
	
	-- is plural?
	if ( isPlural(s) ) then
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

function pluralizeTableName(s)
	
	-- is singular?
	if ( isSingular(s) ) then

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
function isNestedTableModel(s)
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
	local relations = "  relations:\n"
	
	for k = 1, grtV.getn(tbl.foreignKeys) do
		
		foreignKey = tbl.foreignKeys[k]
		
		relations = relations .. "    " .. buildTableName(foreignKey.referencedTable.name) .. ":\n"

		-- check zero length
		if ( #foreignKey.columns > 0 ) then
			relations = relations .. "      local: " .. renameIdColumns(foreignKey.columns[1].name) .. "\n"
		end
		
		-- check zero length
		if ( #foreignKey.referencedColumns > 0 ) then
			relations = relations .. "      foreign: " .. renameIdColumns(foreignKey.referencedColumns[1].name) .. "\n"
            relations = relations .. "      foreignAlias: " .. pluralizeTableName(buildTableName(tbl.name)) .. "\n"
        end
		
		if ( foreignKey.deleteRule ~= nil and foreignKey.deleteRule ~= "" and foreignKey.deleteRule ~= "NO ACTION" ) then
			relations = relations .. "      onDelete: " .. string.lower( foreignKey.deleteRule ) .. "\n"
		end
		
		if ( foreignKey.updateRule ~= nil and foreignKey.updateRule ~= "" and foreignKey.updateRule ~= "NO ACTION" ) then
			relations = relations .. "      onUpdate: " .. string.lower( foreignKey.updateRule ) .. "\n"
		end
		
		--if ( foreignKey.many == 1 ) then
		--	relations = relations .. "      type: many\n"
		--end
	end
	
	if ( foreignKey ~= nil ) then
		return relations
	end
	
	return ""
end

--
-- generates the yaml schema
function generateYamlSchema(cat)
	local i, j, k, l, m, schema, tbl, col, index, column
	local script = ""
	local separator = ""
	local yaml = "---\n"

	for i = 1, grtV.getn(cat.schemata) do
		schema = cat.schemata[i]

		--print(schema)

		-- automatically detect relations
		yaml = yaml .. "detect_relations: true\n"
		--
		-- set basic options
		yaml = yaml .. "options:\n"
		yaml = yaml .. "  collation: " .. schema.defaultCollationName .. "\n"
		yaml = yaml .. "  charset: " .. schema.defaultCharacterSetName .. "\n"
		--yaml = yaml .. "  type: " .. schema.defaultStorageEngineName .. "\n" --doesn't exist
		yaml = yaml .. "  type: " .. "InnoDB" .. "\n"

		yaml = yaml .. "\n"
		
		--print(schema)
		
		for j = 1, grtV.getn(schema.tables) do
			tbl = schema.tables[j]
			--
			-- start of adding a table
			yaml = yaml .. buildTableName(tbl.name) .. ":\n"
			
			-- test singularize and pluralize functions
			--print("\n" .. singularizeTableName(tbl.name))
			--print(" <-> ")
			--print(pluralizeTableName(tbl.name))
			
			-- check if table ends with _ns means
			-- NestedSet Model
			if( isNestedTableModel(tbl.name) ) then
				yaml = yaml .. "  actAs: [NestedSet]\n"
			end
			if ( buildTableName(tbl.name) ~= tbl.name ) then
				yaml = yaml .. "  tableName: " .. tbl.name .. "\n"
			end
			yaml = yaml .. "  columns:\n"
			for k = 1, grtV.getn(tbl.columns) do
				col = tbl.columns[k]
				doctrineType = wbSimpleType2DoctrineDatatype(col)
				--
				-- start of adding a column
				yaml = yaml.."    "..renameIdColumns(col.name)..":\n"
				yaml = yaml.."      type: " .. doctrineType
				if( doctrineType == "enum" ) then
					-- enum handling
					yaml = yaml.."\n"
					yaml = yaml.."      values: ["
					yaml = yaml.. handleEnum(col)
					yaml = yaml.."]"
				end
				if( col.length ~= -1 ) then
					yaml = yaml.. "(" ..col.length.. ")"
				end
				yaml = yaml.."\n"
				for m = 1, grtV.getn(tbl.indices) do
					index = tbl.indices[m]
					--
					-- checking for primary index
					if( index.indexType == "PRIMARY") then
						for l = 1, grtV.getn(index.columns) do
							column = index.columns[l]
							if(column.referencedColumn.name == col.name) then
								yaml = yaml .."      primary: true\n"
							end
						end
					end
					--
					-- checking for unique index
					if ( index.indexType == "UNIQUE" ) then
						for l = 1, grtV.getn(index.columns) do
							column = index.columns[l]
							if(column.referencedColumn.name == col.name) then
								yaml = yaml .. "      unique: true\n"
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
						indexes = indexes .. renameIdColumns(column.referencedColumn.name)
						if l < grtV.getn(index.columns) then
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
						indexes = indexes .. renameIdColumns(column.referencedColumn.name)
						if l < grtV.getn(index.columns) then
							indexes = indexes .. ", "
						end
					end
					indexes = indexes .. "]\n"
					indexes = indexes .. "      type: fulltext\n"
				end
			end
			if( indexes ~= "") then
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
			yaml = yaml .. "\n"
		end
	end
	
	--print(yaml)
	
	return yaml
end

---------------------------------------------------------------------------------------------------

-- export function #1
function exportYamlSchemaToClipboard(catalog)

	printVersion()
	local yaml = generateYamlSchema(catalog)
	
	Workbench:copyToClipboard(yaml)

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
