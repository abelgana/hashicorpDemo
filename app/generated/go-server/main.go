/*
 * Titanic
 *
 * No description provided (generated by Swagger Codegen https://github.com/swagger-api/swagger-codegen)
 *
 * API version: 1.0
 * Generated by: Swagger Codegen (https://github.com/swagger-api/swagger-codegen.git)
 */

package main

import (
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"net/http"
	"strconv"
	"strings"

	sw "github.com/abelgana/hashicorpdemo/generated/go-server/go"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
)

func main() {
	log.Printf("Server started")

	router := sw.NewRouter()

	sw.InitDBConnection()
	defer sw.LocalDB.Close()

	sw.LocalDB.DropTable(&sw.Person{})
	sw.LocalDB.AutoMigrate(&sw.Person{})

	r := csv.NewReader(strings.NewReader(data))

	for {
		record, err := r.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
		}
		createNewRecord(sw.LocalDB, record)
	}

	log.Fatal(http.ListenAndServe(":80", router))
}

func createNewRecord(db *gorm.DB, record []string) {
	PersonData := sw.PersonData{
		Survived:                must(strconv.ParseBool(record[0])).(bool),
		PassengerClass:          int32(must(strconv.ParseInt(record[1], 10, 64)).(int64)),
		Name:                    record[2],
		Sex:                     record[3],
		Age:                     int32(must(strconv.ParseFloat(record[4], 32)).(float64)) + 1,
		SiblingsOrSpousesAboard: int32(must(strconv.ParseInt(record[5], 10, 32)).(int64)),
		ParentsOrChildrenAboard: int32(must(strconv.ParseInt(record[6], 10, 32)).(int64)),
		Fare:                    float32(must(strconv.ParseFloat(record[7], 32)).(float64)),
	}
	Person := sw.Person{
		PersonData: PersonData,
	}
	db.Create(&Person)
}

func must(v interface{}, err error) interface{} {
	if err != nil {
		fmt.Println(err.Error)
	}
	return v
}
