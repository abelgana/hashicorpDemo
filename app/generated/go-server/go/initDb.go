package swagger

import (
	"fmt"
	"os"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
)

var LocalDB *gorm.DB

func InitDBConnection() {

	port := os.Getenv("DB_PORT")
	database := os.Getenv("DB_DATABASE")
	password := os.Getenv("DB_PASSWORD")
	host := os.Getenv("DB_HOST")
	username := os.Getenv("DB_USERNAME")

	dbString := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", username, password, host, port, database)

	db, err := gorm.Open("postgres", dbString)
	LocalDB = db
	if err != nil {
		fmt.Fprintf(os.Stderr, "db connection failed: %s", err.Error())
		os.Exit(1)
	}
	LocalDB.LogMode(true)
}
