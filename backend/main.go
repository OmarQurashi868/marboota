package main

import (
	"net/http"
	"sync"

	"github.com/OmarQurashi868/marboota/backend/clog"
	"github.com/gorilla/websocket"
)

type Server struct {
	mu        sync.Mutex
	conns     map[*websocket.Conn]*Client
	instances map[string]*Instance // key is instanceid
}

func newServer() *Server {
	return &Server{
		conns:     make(map[*websocket.Conn]*Client),
		instances: make(map[string]*Instance),
	}
}

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		// return strings.Contains(r.URL.Host, "discordsays.com")
		// ! Change in prod
		return true
	},
} // use default options

func (s *Server) authHandler(w http.ResponseWriter, r *http.Request) {
	// ! Handled by frontend
	w.Write([]byte("Handled by fronten\n"))
}

func (s *Server) wsHandler(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		clog.Println(err)
		return
	}

	clog.Println("(server) New client connected")
	var newClient = newClient(c)

	s.mu.Lock()
	s.conns[c] = newClient
	s.mu.Unlock()

	go s.read(c)
}

func (s *Server) read(ws *websocket.Conn) {
	defer ws.Close()
	for {
		_, msg, err := ws.ReadMessage()
		if err != nil {
			var c = s.conns[ws]
			if c.isAuthed {
				c.broadcastToMates(map[string]string{"ACTION": "LEAVE", "USERID": s.conns[ws].id})
				if c.state == ClientSeated {
					c.instance.table.unseatPlayer(c)
				}
				c.instance.mu.Lock()
				delete(c.instance.clients, s.conns[ws].id)
				c.instance.mu.Unlock()

				if len(c.instance.clients) == 0 {
					s.mu.Lock()
					delete(s.instances, s.conns[ws].instance.id)
					s.mu.Unlock()
					clog.Printf("(c:%v) deleted empty instance", c.instance.id)
				}
			}

			s.mu.Lock()
			delete(s.conns, ws)
			s.mu.Unlock()
			clog.Printf("Connection closed: %s\n", err)
			break
		}

		msgHandler(s.conns[ws], msg)
	}
}

var server = newServer()

func main() {
	const PORT = "3000"

	http.HandleFunc("/auth", server.authHandler)
	http.HandleFunc("/ws", server.wsHandler)

	clog.Printf("Server is up and listening on port: %s\n", PORT)
	err := http.ListenAndServe(":"+PORT, nil)
	clog.Fatal(err)
}
