package main

import "sync"

type Instance struct {
	mu      sync.Mutex
	id      string
	clients map[string]*Client // key is userid
	table   Table
}

func joinInstance(c *Client, id string) *Instance {
	// server.mu.Lock()
	// defer server.mu.Unlock()
	if instance := server.instances[id]; instance != nil {
		instance.mu.Lock()
		defer instance.mu.Unlock()
		instance.clients[c.id] = c
		return instance
	}

	return newInstance(c, id)
}

func newInstance(c *Client, id string) *Instance {
	var newInstance = &Instance{
		id:      id,
		clients: map[string]*Client{c.id: c},
	}
	newInstance.table = newTable(newInstance)

	// server.mu.Lock()
	// defer server.mu.Unlock()
	server.instances[id] = newInstance

	return newInstance
}

func (i *Instance) Broadcast(msg map[string]string) {
	for _, c := range i.clients {
		if !c.isAuthed {
			continue
		}
		c.writeJson(msg)
	}
}
