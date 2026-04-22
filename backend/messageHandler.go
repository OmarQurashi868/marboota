package main

import (
	"encoding/json"

	"github.com/OmarQurashi868/marboota/backend/clog"
)

func msgHandler(c *Client, rawMsg []byte) {
	var msg map[string]string
	err := json.Unmarshal(rawMsg, &msg)
	if err != nil {
		c.writeError(err.Error())
		clog.Println(err)
	}

	c.requestId = msg["REQUESTID"]

	if msg["ACTION"] == "PING" {
		c.writeOk()
		return
	}

	if msg["ACTION"] == "AUTH" {
		err := authClient(c, msg["INSTANCEID"], msg["USERID"], msg["USERNAME"], msg["ICONURL"])
		if err != nil {
			c.writeError(err.Error())
			clog.Printf("(i:%s) (c:%s) AUTH request refused: %s\n", msg["INSTANCEID"], msg["USERID"], err)
			return
		}

		clog.Printf("(i:%s) (c:%s) AUTH request accepted\n", msg["INSTANCEID"], msg["USERID"])
		return
	}

	if !c.isAuthed {
		var err = "not authenticated"
		c.writeError(err)
		clog.Printf("Request refused: %s\n", err)
		return
	}

	switch msg["ACTION"] {

	case "SIT":
		err := seatClient(c, msg["SEAT"])
		if err != nil {
			c.writeError(err.Error())
			clog.Debugf("(i:%s) (c:%s) SIT request refused: %s\n", c.instance.id, c.id, err)
			return
		}
		c.writeOk()
		clog.Debugf("(i:%s) (c:%s) SIT request accepted", c.instance.id, c.id)

	case "UNSIT":
		err := unseatClient(c)
		if err != nil {
			c.writeError(err.Error())
			clog.Debugf("(i:%s) (c:%s) UNSIT request refused: %s\n", c.instance.id, c.id, err)
			return
		}
		c.writeOk()
		clog.Debugf("(i:%s) (c:%s) UNSIT request accepted", c.instance.id, c.id)

	case "READY":
		err := setReady(c)
		if err != nil {
			c.writeError(err.Error())
			clog.Debugf("(i:%s) (c:%s) READY request refused: %s\n", c.instance.id, c.id, err)
			return
		}
		c.writeOk()
		clog.Debugf("(i:%s) (c:%s) READY request accepted", c.instance.id, c.id)

	case "UNREADY":
		err := unsetReady(c)
		if err != nil {
			c.writeError(err.Error())
			clog.Debugf("(i:%s) (c:%s) UNREADY request refused: %s\n", c.instance.id, c.id, err)
			return
		}
		c.writeOk()
		clog.Debugf("(i:%s) (c:%s) UNREADY request accepted", c.instance.id, c.id)

	case "TRUMPCALL":
		err := advanceTrump(c, msg["SCORE"])
		if err != nil {
			c.writeError(err.Error())
			clog.Debugf("(i:%s) (c:%s) TRUMPCALL request refused: %s\n", c.instance.id, c.id, err)
			return
		}
		c.writeOk()
		clog.Debugf("(i:%s) (c:%s) TRUMPCALL request accepted", c.instance.id, c.id)

	case "PLAY":
		err := advancePlay(c, msg["CARD"])
		if err != nil {
			c.writeError(err.Error())
			clog.Debugf("(i:%s) (c:%s) PLAY request refused: %s\n", c.instance.id, c.id, err)
			return
		}
		c.writeOk()
		clog.Debugf("(i:%s) (c:%s) PLAY request accepted", c.instance.id, c.id)

	default:
		c.writeError("unknown or missing action")
		clog.Debugf("(i:%s) (c:%s) Unknown or missing action skipped: (%s)", c.instance.id, c.id, msg["ACTION"])
		return
	}
}
