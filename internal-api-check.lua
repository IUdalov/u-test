do
    local major, minor = _VERSION:match("Lua (%d).(%d)")
    LUA_VERSION = major * 10 + minor
end

local t = require "u-test"

t.all_assertions = function ()
    t.equal(1,1)
    t.not_equal(1,2)
    t.almost_equal(1,3,2)
    t.is_false(false)
    t.is_true(true)
    t.is_not_nil(false)
    t.is_nil(nil)
    t.is_boolean(false)
    t.is_string("string")
    t.is_number(8)
    -- t.is_userdata(???)
    t.is_table({})
    t.is_function(function() end)
    t.is_thread(coroutine.create(function () end))
    t.error_raised(function() error("") end)
end

local function fail_all()
    t.equal(1,2)
    t.not_equal(1,1)
    t.almost_equal(1,3,1.9)
    t.is_false(true)
    t.is_true({})
    t.is_not_nil()
    t.is_nil("nil")
    t.is_boolean("booo")
    t.is_string(1)
    t.is_number(true)
    t.is_userdata("no userdata")
    t.is_table()
    t.is_function(coroutine.create(function () end))
    t.is_thread(function() end)
    t.error_raised(function() end)
end

t.all_assertions_failed = function ()
    fail_all()
end

t.param_root_test_p = function (a, b)
    t.equal(a,b)
end

t.param_root_test_p("Lua", "Lua")

t.case1.with_param_p = function (a, b, c)
    t.equal(a + b,  c)
end

t.case1.with_param_p(1,2,3)
t.case1.with_param_p(3,2,5)

t.case1.with_nil_p = function (i_am_nil)
    t.is_nil(i_am_nil)
end

t.case1.with_nil_p()

t.case1.fail_with_param_p = function (placeholder)
    fail_all()
end

t.case1.fail_with_param_p()

if LUA_VERSION > 51 then

    t.param_test = function (a, b)
        t.equal(a,b)
    end

    t.param_test(2, 2)

end -- Lua > 5.1

local ntests, nfailed = t.result()

t.tests_result = function()
    if LUA_VERSION > 51 then
        t.equal(ntests, 8)
        t.equal(nfailed, 2)
    else
        t.equal(ntests, 7)
        t.equal(nfailed, 2)
    end
end

t.test_error_raised.when_error_is_raised = function()
    t.error_raised(function() error("a custom error") end)
end

t.test_error_raised.with_error_message = function()
    t.error_raised(function() error("a custom error") end,
        "custom error")
end

t.test_error_raised.with_wrong_error_message = function()
    t.error_raised(function() error("another error") end,
        "custom error")
end

t.test_error_raised.when_error_is_not_raised = function()
    t.error_raised(function() end)
end


local function has_key(tab, key)
    local msg
    if type(tab) ~= "table" then
        msg = "Expected first argument to be table"
        return false, msg
    end

    if tab[key] == nil then
        msg = "Expected table to have key '"..tostring(key).."'"
        return false, msg
    end

    return true
end

t.register_assert("has_key", has_key)

t.test_if_table_has_key = function(tab, key)
    t.has_key(tab, key)
end

t.test_if_table_has_key({ name = "John" }, "name")
t.test_if_table_has_key({ name = "John" }, "age")

t.summary()
