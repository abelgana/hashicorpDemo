package swagger

import (
	"fmt"
	"os"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
)

var LocalDB *gorm.DB

func InitDBConnection() {
	dbString := "postgres://postgres:mysecretpassword@localhost:32771/hashicorptest?sslmode=disable"

	db, err := gorm.Open("postgres", dbString)
	LocalDB = db
	if err != nil {
		fmt.Fprintf(os.Stderr, "db connection failed: %s", err.Error())
		os.Exit(1)
	}
	LocalDB.LogMode(true)
}
