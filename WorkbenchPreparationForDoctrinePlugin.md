# How to prepare MySQL Workbench for use with the Doctrine plugin #

Please read the following section carefully, because this may be important for you.

## Recommendations on Table Naming ##

  1. Use **capitalized table names** (e.g. Persons not persons)
  1. Use **plural table names**. This is mainly because a relation (~table) in the relational model is a "mathematically defined set of tuples". As such, tables are better thought of as sets (entity sets in conceptual Entity Relationship Diagrams).
  1. **Avoid shuffling lower and uppercase characters in table names**, except it's a composition of different tables (e.g. Persons not PeRsOnS, but PersonsEmails as a result of a relation is OK)
  1. Be aware of critical table names like "Doctrine" or "Table". Don't use these.

## Plural Table Names Result in Singular ORM Classes ##

The plugin has built-in functionality to automatically detect and singularize table names. This means, if you declare a table "Persons" in Workbench it will result in a Doctrine/PHP class "Person". Note, the singularization process does not work for collective names ("Personnel", "Cast", ...) and certain special cases. You can read more in the plugin code.

## Changing the Default Primary Key and Associative Table Naming Conventions ##

MySQL Workbench comes with badly defaulted naming conventions, such as VARCHAR(45) for the default data type. The MySQL developers tried to be smart, assuming people would immediately be disturbed by these odd values and change them, but in effect, most people don't care at all. As a consequence, the chosen defaults enforce bad naming conventions and data type selection.

Thus, it is more than recommended to adjust the naming conventions to your own needs. To do so, go to **Tools -> Preferences...**, tab **Model** and change the default settings. An example is shown in the table below.

| **field** | **from** | **to** |
|:----------|:---------|:-------|
|PK name    |`id%table%`|`id`    |
|Associative table name|`%stable%_has_%dtable%`|`%stable%%dtable%`|