---@diagnostic disable: lowercase-global
---@diagnostic disable: undefined-global

max_line_length = 125
max_cyclomatic_complexity = 20
std = "luajit+scopes"

-- ignore unused local, undefined globals and fields, it controller by "Lua Language Server" plugin
ignore = {"113", "143", "212"}

stds.scopes = {}
stds.scopes.globals = {
	"ENT"
}
