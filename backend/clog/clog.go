package clog

import (
	"log"
)

const DEBUG = true

// ! Debug logging
func Debug(v ...any) {
	if DEBUG {
		log.Println(v...)
	}
}

func Debugf(format string, v ...any) {
	if DEBUG {
		log.Printf(format, v...)
	}
}

func Println(v ...any) {
	log.Println(v...)
}

func Printf(format string, v ...any) {
	log.Printf(format, v...)
}

func Fatal(v ...any) {
	log.Fatal(v...)
}
