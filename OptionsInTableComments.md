# Introduction #

You possibly noticed our approach to add behaviours to the models with a very simple hack. Over the past few weeks we also implemented a few other things which makes your life easier using the plugin.

# Details #

## How to use ##
To bypass options to your yaml scheme, you have to select a table in your Workbench model and add some special formatted comments to the comment field.

See this example, which enables the timestampable behaviour:
```
{doctrine:actAs}
  actAs:
    Timestampable:
{/doctrine:actAs}
```

**Be aware of the 2 leading spaces in front of the actAs. These indentions are mandatory.**

## Available options ##
| **option** | **effect** | **intention** |
|:-----------|:-----------|:--------------|
| actAs      | bypasses yaml directly under the table name | add behaviours or other options to your table model |
| entityName | the table name will be exactly this name | prevent the plugin from do any special treatment to the table name |
| localAlias | none?      |               |
| foreignAlias | see foreignAliasMany and foreignAliasOne | fallback solution for foreignAliasMany and foreignAliasOne |
| foreignAliasOne | name of the table when referenced in a relation (representation of **one entity**) |               |
| foreignAliasMany | name of the table when referenced in a relation (representation of a **collection of entities**) |               |
| mnRelations | define a (proxy) reference table for m:n relations | you can use m:n relations like 1:n relations |
| externalRelations | bypass a relation | helps you to integrate relations to tables that are not related to your scheme, like integrating external plugins |

### Example 1: actAs ###

**be aware of the 2 leading spaces**
```
{doctrine:actAs}
  actAs:
    Timestampable:
{/doctrine:actAs}
```

### Example 2: entityName ###
```
{doctrine:entityName}
Status
{/doctrine:entityName}
```

### Example 3: localAlias ###
```
{doctrine:localAlias}
???
{/doctrine:localAlias}
```

### Example 7: mnRelations ###

**don't forget to replace each with the matching table names**
```
{doctrine:mnRelations}
localAlias=>ref_table=>foreign_table=>foreignAlias
{/doctrine:mnRelations}
```

Let's consider a real world example of students and courses - where each student visits many courses and each course consists of many studens (a classical many-to-many relationship). Then you would probably add the following piece of code to the comment in the Student table.
```
{doctrine:mnRelations}
Students=>students_courses=>courses=>Courses
{/doctrine:mnRelations}
```

### Example 8: externalRelations ###

**be aware of the 4 leading spaces**
```
{doctrine:externalRelations}
    Users:
      class: sfGuardUser
      local: project_id
      foreign: user_id
      refClass: UserProject
{/doctrine:externalRelations}
```