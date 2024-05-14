# External Storage for DB Columns

## About

This _experimental_ extension allows you to use a Preside storage provider as private storage for a database column (on a Preside object). This could be useful in
situations where you have a table with a lot of rows and one large column that is read infrequently. Putting the storage of this column in an S3 bucket, for example,
could have a cost benefit, keeping database storage lower and utilising more cheap storage in its place.

## Howto

With this extension installed (`box install preside-ext-external-dbcolumn-storage`), you annotate your preside object property with a `externalStorageProvider` attribute
whose value is a configured storage provider in wirebox:

```cfc
// a preside object
component {
	property name="content" externalStorageProvider="myStorageProvider";
}
```

```cfc
// WireBox.cfc

// N.B. for illustrative purposes only - settings.mystorageprovider is fictional and would be up to you to configure
// here we are using the s3 storage provider, but could be another storage provider altogether
binder.map( "myStorageProvider" ).asSingleton().to( "app.extensions.preside-ext-s3-storage-provider.services.S3StorageProvider" ).noAutoWire().initWith(
	  s3bucket    = settings.mystorageprovider.bucket
	, s3accessKey = settings.mystorageprovider.accessKey
	, s3secretKey = settings.mystorageprovider.secretKey
	, s3region    = settings.mystorageprovider.region
	, s3subPath   = "/mystorageprovier"
);

```

## Known limitations

This extension is in an ALPHA state. it currently does not:

* Delete objects from the storage provider once their parent record is deleted
* Delete objects from the storage provider when the value of the column changes


## License

This project is licensed under the GPLv2 License - see the [LICENSE.txt](https://github.com/pixl8/preside-ext-external-dbcolumn-storage/blob/stable/LICENSE.txt) file for details.

## Authors

The project is maintained by [The Pixl8 Group](https://www.pixl8.co.uk).

## Code of conduct

We are a small, friendly and professional community. For the eradication of doubt, we publish a simple [code of conduct](https://github.com/pixl8/preside-ext-external-dbcolumn-storage/blob/stable/CODE_OF_CONDUCT.md) and expect all contributors, users and passers-by to observe it.