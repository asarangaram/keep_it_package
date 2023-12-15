# App Loader

In this approach, we create a app descriptor with available pages and other parameters. The App Loader internally implements the router, and few other basic providers to handle the application. 

You can provide the following:

1. title - title of the application.

2. appInitializer - a function that is called before the application is loaded. You may perform the boot time tasks, like loading preferences, trigger loading from the servers etc.

3. screenBuilders - builder functions that builds the requires pages. This is a map, that has route name as key and the page builder as value. The internal router generartes routes from this list. We may change this to have a internal key so that transitionBuilder and few other aspects can be customized per page.

4. transitionBuilder - For now, a single transitionBuilder is used. However, we may move this as part of screen builder.

5. redirector - a closure that is called before redirection. There is an internal redirector, that is called first, and then this redirector is invoked. It can redirect to any other path or return null to load the path.

## Widgets

## Providers

### AppLoader

