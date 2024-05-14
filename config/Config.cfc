component {

	public void function configure( required struct config ) {
		var conf     = arguments.config;
		var settings = conf.settings ?: {};

		ArrayAppend( conf.interceptors, { class="app.extensions.preside-ext-external-dbcolumn-storage.interceptors.ExternalDbColumnStorageInterceptors" } );
	}
}
