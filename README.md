# Game Theory Solvers in Julia

An elegant, modular library and interactive [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebook for capturing and solving multi-player games in both **Normal Form** and **Sequential Form**.

---

## Features

### 1. Normal Form Games (Problem 1)
*   Represent strategic multi-player games using players, strategies, and payoff mappings.
*   **Pure Strategy Nash Equilibria**: Computes all pure strategy Nash equilibria for arbitrary players and strategies.
*   **Mixed Strategy Nash Equilibria**: Resolves mixed strategy equilibria (indifference mixing probabilities) for any $2 \times 2$ strategic game.

### 2. Sequential Form Games (Problem 2)
*   Represent games in sequential (tree) form with arbitrary branches and game depth.
*   **Backward Induction**: Calculates the **Subgame Perfect Nash Equilibrium (SPNE)** payoff profile.
*   **N-Player Support**: Supports multi-player trees (2-player, 3-player, etc.) dynamically.

---

## Game Execution Modes

When you run the `Assignment.jl` Pluto notebook, **two sets of games** are executed:

1.  **Hardcoded Interactive Cells**: 
    A set of standard educational games is written directly within the notebook cells. These run automatically to demonstrate the core mathematical algorithms in a reactive environment.
2.  **Dynamic TOML Configurations**:
    The notebook dynamically imports the `TOML` standard library and loads all games defined in `games.toml`. It parses, solves, and renders their results in a beautiful Markdown summary at the **very bottom** of the notebook.

---

## How to Add Your Own Games to `games.toml`

You can add, edit, or delete games dynamically without modifying any Julia code by updating `games.toml`.

### 1. Normal Form Games
To add a normal form game, specify it under the `[normal_games.<game_id>]` table.

#### **Schema:**
*   `name`: A descriptive string name for the game.
*   `players`: An array of player identifier strings, e.g. `["P1", "P2"]`.
*   `strategies`: A dictionary mapping each player to their array of strategy names.
*   `payoffs`: A list of tables containing:
    *   `profile`: The chosen strategy for each player, ordered matching the `players` array.
    *   `payoff`: An array of payoff values awarded to each player for that strategy profile.

#### **Example:**
```toml
[normal_games.battle_of_the_sexes]
name = "Battle of the Sexes"
players = ["P1", "P2"]

[normal_games.battle_of_the_sexes.strategies]
P1 = ["Opera", "Football"]
P2 = ["Opera", "Football"]

[[normal_games.battle_of_the_sexes.payoffs]]
profile = ["Opera", "Opera"]
payoff = [3, 2]

[[normal_games.battle_of_the_sexes.payoffs]]
profile = ["Opera", "Football"]
payoff = [0, 0]

[[normal_games.battle_of_the_sexes.payoffs]]
profile = ["Football", "Opera"]
payoff = [0, 0]

[[normal_games.battle_of_the_sexes.payoffs]]
profile = ["Football", "Football"]
payoff = [2, 3]
```

---

### 2. Sequential Form Games
To add a sequential game, specify it under the `[sequential_games.<game_id>]` table. Sequential games are defined as nested tree nodes matching a recursive structure.

#### **Schema:**
*   `name`: A descriptive string name for the game.
*   `player`: The player whose turn it is at this node (e.g., `"P1"`, `"P2"`). If it is a leaf/terminal node, use `"Terminal"`.
*   `actions`: An array of available action strings at this node (use `[]` for terminal nodes).
*   `payoff`: An array of payoff values (only required for `"Terminal"` nodes).
*   `children`: (Optional) A dictionary mapping each action to its corresponding sub-tree node.

#### **Example (3-Player Sequential Game):**
```toml
[sequential_games.three_player_game]
name = "3-Player Sequential Game"
player = "P1"
actions = ["a1", "a2"]

[sequential_games.three_player_game.children.a1]
player = "P2"
actions = ["b1", "b2"]

[sequential_games.three_player_game.children.a1.children.b1]
player = "P3"
actions = ["c1", "c2"]

[sequential_games.three_player_game.children.a1.children.b1.children.c1]
player = "Terminal"
actions = []
payoff = [1, 2, 3]

[sequential_games.three_player_game.children.a1.children.b1.children.c2]
player = "Terminal"
actions = []
payoff = [3, 2, 1]

[sequential_games.three_player_game.children.a1.children.b2]
player = "Terminal"
actions = []
payoff = [2, 2, 2]

[sequential_games.three_player_game.children.a2]
player = "Terminal"
actions = []
payoff = [0, 0, 0]
```

---

## Run the Project

1.  Make sure you have [Julia](https://julialang.org/) installed.
2.  Start Julia in your terminal:
    ```bash
    julia
    ```
3.  Install and open Pluto:
    ```julia
    using Pkg
    Pkg.add("Pluto")
    using Pluto
    Pluto.run()
    ```
4.  Open `Assignment.jl` in the Pluto browser window. The notebook will automatically compile its packages (including `TOML` and `LinearAlgebra`) and compute solutions reactively!
