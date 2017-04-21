package = "u-test"
version = "1.0.3-0"
source = {
    url = "git://github.com/iudalov/u-test"
}

description = {
    summary = "Sane and simple unit testing framework for Lua",
    detailed =
    [[
        **u-test** is a sane and simple unit testing framework for Lua. It has all essential features: defining test cases, test suites, set of build-in assertions, configurable tests output, lokkup tests by regexp, backtrace in assertions and etc.

        u-test compatible with lua 5.1 5.2 and 5.3.
    ]],
    homepage = "https://github.com/iudalov/u-test",
    license = "MIT"
}

dependencies = { "lua >= 5.1" }

build = {
    type = "builtin",
    modules = {}
}

build.modules["u-test"] = "u-test.lua"