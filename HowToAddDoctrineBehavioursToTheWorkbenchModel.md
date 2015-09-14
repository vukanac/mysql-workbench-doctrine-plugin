# Introduction #

Sometimes you want to add doctrine behaviours to your Workbench models - even this would result in a hack, because MySQL does not know about behaviours. Here is a simple way to do it with the plugin.

# Details #

To use doctrine behaviours in your table models just add this kind of code in the comment field of the table you want to add the behaviour.

```
{doctrine:actAs}
  actAs:
    Timestampable:
{/doctrine:actAs}
```

Please **keep an eye on the indention** - the first line "actAs:" has 2 leading spaces as this piece of code is attached directly below the table name in the Yaml file. If you use a wrong indention here this results in unusable yaml schemes.