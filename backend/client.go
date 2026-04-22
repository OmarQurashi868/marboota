package main

import (
	"errors"
	"sync"

	"github.com/gorilla/websocket"
)

type ClientState int

const (
	ClientUnavailable ClientState = iota
	ClientIdle
	ClientSeated
)

type Client struct {
	mu        sync.Mutex
	conn      *websocket.Conn
	isAuthed  bool
	instance  *Instance
	id        string
	name      string
	iconUrl   string
	state     ClientState
	player    *Player
	requestId string
}

func newClient(conn *websocket.Conn) *Client {
	return &Client{
		conn: conn,
	}
}

func (c *Client) writeJson(msg map[string]string) error {
	if c == nil {
		return errors.New("client not available")
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.conn.WriteJSON(msg)
}

func (c *Client) writeError(msg string) error {
	return c.writeJson(map[string]string{"ACTION": "ERROR", "REQUESTID": c.requestId, "MESSAGE": msg})
}

func (c *Client) writeOk() error {
	return c.writeJson(map[string]string{"ACTION": "OK", "REQUESTID": c.requestId})
}

func (c *Client) broadcastToMates(msg map[string]string) error {
	if c.instance == nil {
		return errors.New("Client not authenticated")
	}

	c.instance.mu.Lock()
	for _, client := range c.instance.clients {
		if !client.isAuthed || client == c {
			continue
		}
		client.writeJson(msg)
	}
	c.instance.mu.Unlock()

	return nil
}
