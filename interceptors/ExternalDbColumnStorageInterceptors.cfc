component extends="coldbox.system.Interceptor" {

	property name="externalDbColumnStorageService" inject="delayedInjector:externalDbColumnStorageService";

// PUBLIC
	public void function configure() {}

	public void function preUpdateObjectData( event, interceptData ) {
		var objectName                = interceptData.objectName ?: "";

		if ( !objectName.startsWith( "vrsn_" ) ) {
			externalDbColumnStorageService.get().externaliseData(
				  objectName = objectName
				, data       = interceptData.data ?: {}
			);
		}
	}

	public void function preInsertObjectData( event, interceptData ) {
		var objectName = interceptData.objectName ?: "";

		if ( !objectName.startsWith( "vrsn_" ) ) {
			externalDbColumnStorageService.get().externaliseData(
				  objectName = objectName
				, data       = interceptData.data ?: {}
			);
		}
	}

	public void function postSelectObjectData( event, interceptData ) {
		if ( IsQuery( interceptData.result ?: "" ) && interceptData.result.recordCount ) {
			externalDbColumnStorageService.get().readExternalColumns(
				  objectName   = interceptData.objectName   ?: ""
				, selectFields = interceptData.selectFields ?: []
				, recordSet    = interceptData.result
			);
		}
	}

	// TODO: preDeleteObjectData()... cleanup old files
}
