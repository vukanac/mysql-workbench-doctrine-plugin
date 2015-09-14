# Introduction #

The plugin has a build in singualrize and pluralize functionality to implement one-to-many relations in a handy way. The underlying algorithm for this is based on english grammar and for most cases it works properly. But sometimes it doesn't - for this kind of "bug" we implemented a special markup inside table comments.

# Details #

Let's assume we have a table "user" and we want to call it "customer" in singular and "customers" in plural. Add the following markup as a comment in the table "user":

### foreignAliasOne ###

foreignAliasOne is used, when the user is represented as a single user object
```
{doctrine:foreignAliasOne}
customer
{/doctrine:foreignAliasOne}
```

the Yaml result
```
xy:
  columns:
    ...
  relations:
    customer:
      class: user
      ...
```

the PHP result in doctrine model definition
```
$this->hasOne('user as customer', .. );
```

### foreignAliasMany ###

foreignAliasMany is used, when the user represents a collection of user objects
```
{doctrine:foreignAliasMany}
customers
{/doctrine:foreignAliasMany
```

the Yaml result
```
user:
  columns:
    ...
  relations:
    xy:
      class: xy
      ...
      foreignAlias: customers
```

the PHP result in doctrine model definition
```
$this->hasMany('user as customers', .. );
```

### foreignAlias ###

and here is an additional fallback solution if you want to use the _same for singular and plural_, e.g. "staff" but this saves only some chars and real world examples are rare
```
{doctrine:foreignAlias}
staff
{/doctrine:foreignAlias}
```

in PHP
```
$this->hasOne('user as staff', .. );
..
$this->hasMany('user as staff', .. );
```

### Annotation ###

Keep in mind, that this is optional - you can of course rely on the built in transformation algorithm.

If you use this feature, keep also in mind, that we use some kind of hierarchy in chosing the right alias. In the first place we check for foreignAliasOne and foreignAliasMany, afterwards for foreignAlias and at least for built in transformation.