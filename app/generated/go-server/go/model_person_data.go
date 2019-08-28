/*
 * Titanic
 *
 * No description provided (generated by Swagger Codegen https://github.com/swagger-api/swagger-codegen)
 *
 * API version: 1.0
 * Generated by: Swagger Codegen (https://github.com/swagger-api/swagger-codegen.git)
 */

package swagger

type PersonData struct {

	Survived bool `json:"survived,omitempty"`

	PassengerClass int32 `json:"passengerClass,omitempty"`

	Name string `json:"name,omitempty"`

	Sex string `json:"sex,omitempty"`

	Age int32 `json:"age,omitempty"`

	SiblingsOrSpousesAboard int32 `json:"siblingsOrSpousesAboard,omitempty"`

	ParentsOrChildrenAboard int32 `json:"parentsOrChildrenAboard,omitempty"`

	Fare float32 `json:"fare,omitempty"`
}