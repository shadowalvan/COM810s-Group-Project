### A Pluto.jl notebook ###
# v1.0.1

using Markdown
using InteractiveUtils

# ╔═╡ ccaf1620-1eaf-4742-ad20-fef6993629b9
begin
	using LinearAlgebra
	using TOML
end

# ╔═╡ 02b8b7f0-5554-11f1-0aa2-b74869b510cd
"""
INSTRUCTIONS

1. This assignment is to be completed by groups of at most three (3) students.

2. For each group, a repository should be created on GitHub (https: //github.com/)

3. All programs will be implemented in the Julia programming language.

4. The submission date is Friday, May 29 2026, at midnight. Please note that commits after
that deadline will not be accepted. Therefore, a submission will be assessed based on the
repository's clone at the deadline.

5. There will be a deduction of 5 marks (every two day delay) for groups that fail to submit on
time.

6. Each group is expected to present the project after the submission deadline.

7. In the case of plagiarism (groups copying from each other or submissions copied from the
Internet), all submissions involved will be awarded the mark 0, and each student will receive
a warning.

ASSESSMENT CRITERIA

. Modularity;

. Quality of game representation;

. Speed and quality of solution concept.

Problem 1
In this problem, you are tasked with the implementation (from scratch) in Julia of a pro-
gram/library that fulfils the following:

· capture a multi-player game in normal form;
. find pure strategy and mixed strategy Nash equilibria as solution concepts for the game.

Problem 2
Write a program/library (from scratch) in Julia that:

· captures a multi-player game in sequential form;
· identify all subgames;
. - when possible, find a subgame perfect Nash equilibrium;
- if not, find the pure strategy Nash equilibria.

Note that your game definition should allow for games with imperfect information.

.[40 points]

[60 points]
"""

# ╔═╡ 347bb298-5c8b-4d42-98d6-52de7ca26f35
# Problem 1: Normal Form Games

# ╔═╡ 3d0f4a54-3670-4f95-a5e6-3314f3fa31c4
# Players & Strategies
players = ["P1","P2"]

# ╔═╡ 4d4b5cbf-ea3d-4580-83d5-f0ecdc6579f0
strategies = Dict("P1" => ["a1", "a2"], "P2" => ["b1", "b2"])

# ╔═╡ 41eb6dbf-f9e2-4f2f-9646-0eb17c755b05
# Payoffs
payoffs = Dict(
	("a1","b1") => (3,2),
	("a1","b2") => (0,1),
	("a2","b1") => (1,0),
	("a2","b2") => (2,3)
)

# ╔═╡ 6cbf7e1a-8680-459b-98cc-8c8de1913a88
# Pure strategy Nash Equilibrium algorithm
function pure_nash(payoffs, strategies, players=["P1","P2"])
    equilibria = []
    for (profile, payoff) in payoffs
        stable = true
        for (i, player) in enumerate(players)
            for alt in strategies[player]
                alt_profile = ntuple(j -> j == i ? alt : profile[j], length(profile))
                if haskey(payoffs, alt_profile) && payoffs[alt_profile][i] > payoff[i]
                    stable = false
                    break
                end
            end
            if !stable
                break
            end
        end
        if stable
            push!(equilibria, (profile, payoff))
        end
    end
    return equilibria
end


# ╔═╡ 571fce3b-fbba-4fd3-ac57-12c434629024
println(pure_nash(payoffs, strategies))

# ╔═╡ 222d3f49-baa7-4b8e-8271-b9f15117762e
# Mixed Strategy Nash Equilibrium MSNE

# ╔═╡ 8cd72769-39ec-4cef-9d36-a6771225740f
function mixed_nash(payoffs, strategies=Dict("P1" => ["a1", "a2"], "P2" => ["b1", "b2"]), players=["P1","P2"])
    # Assume 2 players, 2 strategies each but names are generic
    p1, p2 = players[1], players[2]
    a1, a2 = strategies[p1][1], strategies[p1][2]
    b1, b2 = strategies[p2][1], strategies[p2][2]
    
    u11, v11 = payoffs[(a1, b1)]
    u12, v12 = payoffs[(a1, b2)]
    u21, v21 = payoffs[(a2, b1)]
    u22, v22 = payoffs[(a2, b2)]

    # Player 1 mixing probability p (prob of a1)
    # Player 2 mixing probability q (prob of b1)

    # Indifference equations
    denom_q = (u11 - u21) + (u22 - u12)
    q = denom_q == 0 ? 0.5 : (u22 - u12) / denom_q

    denom_p = (v11 - v12) + (v22 - v21)
    p = denom_p == 0 ? 0.5 : (v22 - v21) / denom_p

    return (p, q)
end

# ╔═╡ 0f4a20ca-9345-4554-a8ba-d0b193fce3c2
println(mixed_nash(payoffs))

# ╔═╡ 17c88aa6-1e9c-429d-bf89-35bbc1db2e2d
# Problem 2: Sequential Games
"""
Sequential Form Games tree
Solve SPNE using backward induction
"""

# ╔═╡ 126aee4c-6871-45b1-a5fe-05775a253c3c
# Define a simple game tree node
struct Node
    player::String
    actions::Vector{String}
    children::Dict{String, Node}
    payoff::Union{Nothing, Tuple}
end

# Example: Player 1 chooses a1 or a2, then Player 2 chooses b1 or b2

# ╔═╡ 4340ef32-53a4-47f9-8cca-dcce9498f8ee
leaf1 = Node("Terminal", [], Dict(), (3,2))

# ╔═╡ be6eea1d-54be-4e5e-b787-15550cb25177
leaf2 = Node("Terminal", [], Dict(), (0,1))

# ╔═╡ df3a7714-9203-4001-9bf4-29ed9288d9d7
leaf3 = Node("Terminal", [], Dict(), (1,0))

# ╔═╡ fe581fda-90a5-4241-9096-ca465ff0a2e4
leaf4 = Node("Terminal", [], Dict(), (2,3))

# ╔═╡ 5797ea53-d700-4bf5-9305-e539b47612e9
p2_after_a1 = Node("P2", ["b1","b2"], Dict("b1"=>leaf1,"b2"=>leaf2), nothing)

# ╔═╡ 91147cdc-8ce7-410b-a892-eb5e5c44dd6a
p2_after_a2 = Node("P2", ["b1","b2"], Dict("b1"=>leaf3,"b2"=>leaf4), nothing)

# ╔═╡ ac369ea6-46de-47a4-9b77-7668aa7e0963
root = Node("P1", ["a1","a2"], Dict("a1"=>p2_after_a1,"a2"=>p2_after_a2), nothing)

# ╔═╡ ffcee330-0de5-417b-b8c9-8e24ccf64b45
begin
    # Helper to map a player's name to their index in the payoff tuple (e.g. "P1" or "Player 1" -> 1)
    function get_player_index(player_name::String)
        m = match(r"\d+", player_name)
        if m !== nothing
            return parse(Int, m.match)
        end
        if player_name == "P1" || lowercase(player_name) == "player1"
            return 1
        elseif player_name == "P2" || lowercase(player_name) == "player2"
            return 2
        else
            return 1
        end
    end

    # Backward induction algorithm
    function backward_induction(node::Node)
        if node.payoff !== nothing
            return node.payoff
        end
        best_action, best_payoff = nothing, nothing
        player_idx = get_player_index(node.player)
        for action in node.actions
            payoff = backward_induction(node.children[action])
            if best_payoff === nothing || payoff[player_idx] > best_payoff[player_idx]
                best_action, best_payoff = action, payoff
            end
        end
        return best_payoff
    end
end

# ╔═╡ 1a3b2c36-bb44-4e42-b209-f44e87d5ecfb
println(backward_induction(root))

# ╔═╡ 06d386c3-662b-4880-9e3c-6efdb84021da
begin
    function parse_normal_game(game_data)
        players = convert(Vector{String}, game_data["players"])
        strategies = Dict{String, Vector{String}}()
        for (player, strats) in game_data["strategies"]
            strategies[player] = convert(Vector{String}, strats)
        end
        payoffs = Dict{Tuple, Tuple}()
        for entry in game_data["payoffs"]
            profile = Tuple(convert(Vector{String}, entry["profile"]))
            payoff = Tuple(entry["payoff"])
            payoffs[profile] = payoff
        end
        return players, strategies, payoffs
    end

    function dict_to_node(d::Dict{String, Any})
        player = d["player"]
        actions = haskey(d, "actions") ? convert(Vector{String}, d["actions"]) : String[]
        children = Dict{String, Node}()
        if haskey(d, "children")
            for (action, child_dict) in d["children"]
                children[action] = dict_to_node(convert(Dict{String, Any}, child_dict))
            end
        end
        payoff = haskey(d, "payoff") && !isnothing(d["payoff"]) ? Tuple(d["payoff"]) : nothing
        return Node(player, actions, children, payoff)
    end

    function run_all_games(filepath="games.toml")
        if !isfile(filepath)
            return Markdown.parse("### Error\nFile `$filepath` not found. Please ensure it is created.")
        end
        
        data = TOML.parsefile(filepath)
        output = "# TOML Game Solver Results\n\n"
        
        if haskey(data, "normal_games")
            output *= "## Problem 1: Normal Form Games\n\n"
            for (game_id, game_data) in data["normal_games"]
                name = get(game_data, "name", game_id)
                players, strategies, payoffs = parse_normal_game(game_data)
                
                output *= "### Game: $name\n"
                output *= "- **Players**: $(join(players, ", "))\n"
                output *= "- **Strategies**:\n"
                for p in players
                    output *= "  - $p: $(join(strategies[p], ", "))\n"
                end
                
                pure_eqs = pure_nash(payoffs, strategies, players)
                output *= "- **Pure Strategy Nash Equilibria**:\n"
                if isempty(pure_eqs)
                    output *= "  - None\n"
                else
                    for (profile, payoff) in pure_eqs
                        output *= "  - Profile: $profile => Payoff: $payoff\n"
                    end
                end
                
                is_2x2 = length(players) == 2 && all(length(strategies[p]) == 2 for p in players)
                if is_2x2
                    try
                        p, q = mixed_nash(payoffs, strategies, players)
                        output *= "- **Mixed Strategy Nash Equilibrium (Mixing Probabilities)**:\n"
                        output *= "  - Probability of $(strategies[players[1]][1]) (for $(players[1])): $(round(p, digits=4))\n"
                        output *= "  - Probability of $(strategies[players[2]][1]) (for $(players[2])): $(round(q, digits=4))\n"
                    catch e
                        output *= "- **Mixed Strategy Nash Equilibrium**: Calculation error: $e\n"
                    end
                end
                output *= "\n"
            end
        end
        
        if haskey(data, "sequential_games")
            output *= "## Problem 2: Sequential Games\n\n"
            for (game_id, game_data) in data["sequential_games"]
                name = get(game_data, "name", game_id)
                root_node = dict_to_node(game_data)
                
                output *= "### Game: $name\n"
                try
                    spne_payoff = backward_induction(root_node)
                    output *= "- **Subgame Perfect Nash Equilibrium Payoff**: $spne_payoff\n"
                catch e
                    output *= "- **Error running backward induction**: $e\n"
                end
                output *= "\n"
            end
        end
        
        return Markdown.parse(output)
    end

    run_all_games("games.toml")
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
TOML = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "dff273d8dcf8c92fa5415ce88e656d9e01c11e8b"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"
"""

# ╔═╡ Cell order:
# ╠═02b8b7f0-5554-11f1-0aa2-b74869b510cd
# ╠═347bb298-5c8b-4d42-98d6-52de7ca26f35
# ╠═3d0f4a54-3670-4f95-a5e6-3314f3fa31c4
# ╠═4d4b5cbf-ea3d-4580-83d5-f0ecdc6579f0
# ╠═41eb6dbf-f9e2-4f2f-9646-0eb17c755b05
# ╠═6cbf7e1a-8680-459b-98cc-8c8de1913a88
# ╠═571fce3b-fbba-4fd3-ac57-12c434629024
# ╠═222d3f49-baa7-4b8e-8271-b9f15117762e
# ╠═ccaf1620-1eaf-4742-ad20-fef6993629b9
# ╠═8cd72769-39ec-4cef-9d36-a6771225740f
# ╠═0f4a20ca-9345-4554-a8ba-d0b193fce3c2
# ╠═17c88aa6-1e9c-429d-bf89-35bbc1db2e2d
# ╠═126aee4c-6871-45b1-a5fe-05775a253c3c
# ╠═4340ef32-53a4-47f9-8cca-dcce9498f8ee
# ╠═be6eea1d-54be-4e5e-b787-15550cb25177
# ╠═df3a7714-9203-4001-9bf4-29ed9288d9d7
# ╠═fe581fda-90a5-4241-9096-ca465ff0a2e4
# ╠═5797ea53-d700-4bf5-9305-e539b47612e9
# ╠═91147cdc-8ce7-410b-a892-eb5e5c44dd6a
# ╠═ac369ea6-46de-47a4-9b77-7668aa7e0963
# ╠═ffcee330-0de5-417b-b8c9-8e24ccf64b45
# ╠═1a3b2c36-bb44-4e42-b209-f44e87d5ecfb
# ╠═06d386c3-662b-4880-9e3c-6efdb84021da
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
