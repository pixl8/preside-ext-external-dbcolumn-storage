/**
 * @presideService true
 * @singleton      true
 */
component {

	property name="relationshipGuidance"   inject="relationshipGuidance";
	property name="storageProviderService" inject="storageProviderService";

	variables._localCache = {};


// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public void function externaliseData( required string objectName, required struct data ) {
		var externalisedFields = _getExternalFieldStorageConfiguration( arguments.objectName );

		for( var field in externalisedFields ) {
			if ( StructKeyExists( arguments.data, field ) && Len( arguments.data[ field ] ) ) {
				arguments.data[ field ] = _storeFieldContent( storageProvider=externalisedFields[ field ], value=arguments.data[ field ], objectName=arguments.objectName, fieldName=field );
			}
		}
	}

	public void function readExternalColumns(
		  required string objectName
		, required array  selectFields
		, required query  recordSet
	) {
		var externalisedFields = _getExternalFieldConfigsFromSelectFields( arguments.objectName, arguments.selectFields );
		for( var field in externalisedFields ) {
			for( var i=1; i<=arguments.recordSet.recordCount; i++ ) {
				arguments.recordSet[ field ][ i ] = _fetchExternalFieldContent( storageProvider=externalisedFields[ field ], value=arguments.recordSet[ field ][ i ] );
			}
		}
	}

// PRIVATE HELPERS
	private struct function _getExternalFieldStorageConfiguration( required string objectName ) {
		var args = arguments;

		if ( !$getPresideObjectService().objectExists( args.objectName ) ) {
			return {};
		}

		return _simpleLocalCache( "getExternalFieldStorageConfiguration#arguments.objectName#", function(){
			var allProps = $getPresideObjectService().getObjectProperties( args.objectName );
			var config   = {};

			for( var propName in allProps ) {
				var prop = allProps[ propName ];

				if ( StructKeyExists( prop, "externalstorageprovider" ) && Len( prop.externalstorageprovider ) ) {
					config[ propName ] = prop.externalstorageprovider;
				}
			}

			return config;
		} );
	}


	public struct function _getExternalFieldConfigsFromSelectFields(
		  required string objectName
		, required array  selectFields
	) {
		var args = arguments;
		var cacheKey = "listExternalisedFieldsFromSelectFields" & arguments.objectName & ArrayToList( arguments.selectFields );

		return _simpleLocalCache( cacheKey, function(){
			var mappings             = {};
			var externalFieldConfigs = {};

			for( var field in args.selectFields ) {
				var minusEscapeChars = field.reReplace( "[\`\[\]]", "", "all" );
				var fieldName        = ListLast( ListLast( minusEscapeChars, "." ), " " );
				var withoutAlias     = ListFirst( minusEscapeChars, " " );
				var propName         = ListLast( withoutAlias, "." );

				if ( withoutAlias == propName || ListFirst( withoutAlias, "." ) == args.objectName ) {
					mappings[ args.objectName ] = mappings[ args.objectName ] ?: {};
					mappings[ args.objectName ][ propName ] = fieldname;
				} else {
					var relatedObject = relationshipGuidance.resolveRelationshipPathToTargetObject(
						  sourceObject     = args.objectName
						, relationshipPath = ListFirst( withoutAlias, "." )
					);

					if ( relatedObject.len() ) {
						mappings[ relatedObject ] = mappings[ relatedObject ] ?: {};
						mappings[ relatedObject ][ propName ] = fieldname;
					}
				}
			}

			for( var objName in mappings ) {
				var objConfigs = _getExternalFieldStorageConfiguration( objName );

				for( var propName in mappings[ objName ] ) {
					if ( StructKeyExists( objConfigs, propName ) ) {
						externalFieldConfigs[ mappings[ objName ][ propName ] ] = objConfigs[ propName ];
					}
				}
			}

			return externalFieldConfigs;
		} );
	}

	private function _storeFieldContent( storageProvider, value, objectName, fieldName ) {
		if ( Left( arguments.value, 6 ) == "esp://" ) {
			return arguments.value; // already stored
		}

		var path = LCase( "/#arguments.objectName#/#arguments.fieldName#/#CreateUUId()#.txt" );
		var esp  = _getStorageProvider( arguments.storageProvider );

		esp.putObject( object=ToBinary( ToBase64( arguments.value ) ), path=path, private=true );

		return "esp://#path#";
	}

	private function _fetchExternalFieldContent( storageProvider, value ) {
		if ( Left( arguments.value, 6 ) == "esp://" ) {
			var storagePath = Right( arguments.value, Len( arguments.value ) - 6 );
			var esp = _getStorageProvider( arguments.storageProvider );

			if ( storageProviderService.providerSupportsFileSystem( esp ) ) {
				return FileRead( esp.getObjectLocalPath( path=storagePath, private=true ) );
			}

			return ToString( esp.getObject( path=storagePath, private=true ) );
		}

		return arguments.value;
	}

	private any function _simpleLocalCache( cacheKey, processor ) {
		if ( !StructKeyExists( _localCache, arguments.cacheKey ) ) {
			_localCache[ arguments.cacheKey ] = arguments.processor();
		}

		return _localCache[ arguments.cacheKey ];
	}

	private any function _getStorageProvider( storageProvider ) {
		var args = arguments;
		return _simpleLocalCache( "storageprovider#arguments.storageProvider#", function(){
			return $getColdbox().getWirebox().getInstance( args.storageProvider );
		} );
	}
}