/*
 * Titanic
 *
 * No description provided (generated by Swagger Codegen https://github.com/swagger-api/swagger-codegen)
 *
 * API version: 1.0
 * Generated by: Swagger Codegen (https://github.com/swagger-api/swagger-codegen.git)
 */

package swagger

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/gorilla/mux"
)

type Route struct {
	Name        string
	Method      string
	Pattern     string
	HandlerFunc http.HandlerFunc
}

type Routes []Route

func NewRouter() *mux.Router {
	router := mux.NewRouter().StrictSlash(true)
	for _, route := range routes {
		var handler http.Handler
		handler = route.HandlerFunc
		handler = Logger(handler, route.Name)

		router.
			Methods(route.Method).
			Path(route.Pattern).
			Name(route.Name).
			Handler(handler)
	}

	return router
}

func Index(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello World!")
}

var routes = Routes{
	Route{
		"Index",
		"GET",
		"/",
		Index,
	},

	Route{
		"PeopleAdd",
		strings.ToUpper("Post"),
		"/people",
		PeopleAdd,
	},

	Route{
		"PeopleList",
		strings.ToUpper("Get"),
		"/people",
		PeopleList,
	},

	Route{
		"PersonDelete",
		strings.ToUpper("Delete"),
		"/people/{uuid}",
		PersonDelete,
	},

	Route{
		"PersonGet",
		strings.ToUpper("Get"),
		"/people/{uuid}",
		PersonGet,
	},

	Route{
		"PersonUpdate",
		strings.ToUpper("Put"),
		"/people/{uuid}",
		PersonUpdate,
	},
}
