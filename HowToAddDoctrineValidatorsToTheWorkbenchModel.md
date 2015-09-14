# Introduction #

read more about validators here:
http://www.doctrine-project.org/documentation/manual/1_2/en/data-validation


# Details #

You can add validators for columns by adding a special comment to the corresponding column. You have to **take care of the indention** as the comment is just bypassed by the plugin.

Example:
```
{doctrine:validators}
      email: true
{/doctrine:validators}
```