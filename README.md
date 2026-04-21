# marboota# Marboota Game Documentation

# [contribution guide](./documentation/contribution_guide.md)

# [backend docs](./backend/README.md)

## Project Overview

Marboota is a multiplayer board/card game developed with Godot 4.3. The game focuses on table-based gameplay where players can join, sit at a table, and indicate their readiness to play.

## Technical Architecture

### Directory Structure

```
game/
├── assets/          # Game assets (graphics, UI elements, fonts)
├── scenes/          # Scene files (.tscn)
├── scripts/         # GDScript files (.gd)
└── build/           # Export directory for web builds
```

### Core Systems

## 1. Network System

### NetworkManager (scripts/network_manager.gd)

The NetworkManager handles WebSocket connections to the backend server and authentication.

**Key Responsibilities:**
- Establishing WebSocket connection to the backend server
- Player authentication
- Sending/receiving JSON messages
- Basic message handling

**Important Properties:**
- `instance_id`: Game instance identifier
- `username`: Player name
- `user_id`: Unique player identifier
- `icon_url`: URL for player avatar
- `authenticated`: Authentication status

**Key Methods:**
- `_handle_auth()`: Handles authentication process
- `_write_json()`: Serializes and sends messages
- `_read_json()`: Receives and deserializes messages

### EventManager (scripts/event_manager.gd)

The EventManager handles game events and communication between the client and server.

**Key Responsibilities:**
- Managing request/response pattern
- Dispatching events to appropriate handlers
- Creating predefined message formats

**Signals:**
- `JOIN_received`: When a player joins
- `LEAVE_received`: When a player leaves
- `SIT_received`: When a player sits
- `UNSIT_received`: When a player stands up
- `READY_received`: When a player indicates readiness
- `UNREADY_received`: When a player cancels readiness

**Key Methods:**
- `send_request()`: Sends a request to the server with callbacks
- `_handle_message()`: Processes incoming messages
- `_dispatch()`: Routes messages to appropriate signal emissions
- Helper methods for creating request payloads (sit_request, ready_request, etc.)

## 2. Player System

### Player (scripts/player.gd)

The Player class represents individual players in the game.

**Key Properties:**
- `username`: Player name
- `state`: Current player state (idle, waiting, ready, etc.)
- `seat`: Reference to the seat the player occupies (if any)

**Key Methods:**
- `unseat()`: Removes player from seat and returns to idle state

### PlayerManager (scripts/player_manager.gd)

The PlayerManager handles player creation, tracking, and organization.

**Key Responsibilities:**
- Creating player objects
- Managing player states
- Handling player positioning
- Handling player joining/leaving events

**Player States:**
- `PLAYER_UNAVAILABLE`: Player not available
- `PLAYER_IDLE`: Player is in the lobby, not seated
- `PLAYER_WAITING`: Player is seated but not ready
- `PLAYER_READY`: Player is seated and ready
- `PLAYER_TRUMPING`: Player is in trump selection phase
- `PLAYER_PLAYING`: Player is actively playing

**Key Methods:**
- `_on_player_join()`: Creates a new player when someone joins
- `_on_player_leave()`: Removes a player when they leave
- `_on_player_sit()`: Handles seating a player
- `pin_player()`/`unpin_player()`: Manages the sidebar player list
- `move_player()`: Changes a player's position
- `_update_pinned_players()`: Reorganizes the sidebar player list

## 3. Table System

### Seat (scripts/seat_1.gd)

The Seat class represents a position at the game table.

**Key Properties:**
- `seat_num`: Seat identifier
- `sitter`: Reference to the player occupying the seat
- `is_taken`: Whether the seat is occupied

**Key Methods:**
- `seat_player()`: Assigns a player to the seat
- `unseat_player()`: Removes a player from the seat
- `_on_button_button_up()`: Handles the click event on the seat

### ReadyButton (scripts/ready_button.gd)

The ReadyButton manages player readiness state.

**Key Functionality:**
- Toggles player readiness state
- Sends ready/unready requests to the server
- Handles success/failure of readiness changes

## 4. Global State

### Globals (scripts/globals.gd)

Provides global access to key game objects.

**Key Properties:**
- `player_manager`: Reference to the PlayerManager instance
- `my_player`: Reference to the local player instance

## 5. Debug System

### DebugPanel (scripts/debug_panel.gd)

Provides debugging information and testing capabilities.

**Key Functionality:**
- Displays network status information
- Provides buttons for testing sit/unsit functionality

## Game Flow

1. **Game Initialization**
   - NetworkManager establishes connection to WebSocket server
   - Authentication process begins

2. **Authentication**
   - Client sends AUTH request to server
   - On successful authentication, LoadingUI is hidden
   - PlayerManager initializes the local player

3. **Player Interaction**
   - Players can choose to sit at available seats around the table
   - When seated, players can toggle their readiness status
   - The server validates all actions and broadcasts updates to all clients

4. **Player State Transitions**
   - IDLE → WAITING: When sitting at a table
   - WAITING → READY: When pressing the ready button
   - READY → WAITING: When canceling readiness
   - Any state → IDLE: When standing up from a seat

## Implementation Notes

### Event-Driven Architecture
The game uses an event-driven approach where:
1. User actions trigger requests to the server
2. Server validates and broadcasts events
3. Clients react to events through signal connections

### WebSocket Communication
All client-server communication happens via WebSocket using a simple JSON protocol:
- Requests include an ACTION field and a unique REQUESTID
- Responses reference the REQUESTID of the original request
- Events are broadcast to all clients with specific ACTION types

### Request-Response Pattern
The EventManager implements a request-response pattern with:
- Callback functions for success/failure handling
- Request queuing
- Response processing

## Expanding the Game

When adding new features:

1. **New Game States**:
   - Add new states to the PlayerManager enum
   - Update state transition logic

2. **New Network Messages**:
   - Add handling in EventManager._dispatch()
   - Create new signals for events
   - Add request helper methods

3. **New UI Elements**:
   - Create a new scene file (.tscn)
   - Attach appropriate scripts
   - Connect signals to handlers

4. **New Game Logic**:
   - Consider where the logic belongs (client vs. server)
   - For client-side validation, implement in appropriate script
   - For server-validated actions, use the request-response pattern
