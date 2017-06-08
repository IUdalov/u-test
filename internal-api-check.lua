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
end

t.all_assertions_failed = function ()
    fail_all()
end

t.param_root_test = function (a, b)
    t.equal(a,b)
end

t.param_root_test("Lua", "Lua")

t.case1.with_param = function (a, b, c)
    t.equal(a + b,  c)
end

t.case1.with_param(1,2,3)
t.case1.with_param(3,2,5)


t.case1.with_nil = function (i_am_nil)
    t.is_nil(i_am_nil)
end

t.case1.with_nil()

t.case1.fail_with_param = function (placeholder)
    fail_all()
end
t.case1.fail_with_param()

local ntests, nfailed = t.result()
print("All: " .. tostring(ntests) .. ", failed: " .. tostring(nfailed))
t.summary()