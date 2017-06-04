-- COMAND LINE ----------------------------------------------------------------
local function print_help()
    print "Usage: target.lua [options] [regex]"
    print "\t-h show this message"
    print "\t-q quiet mode"
    print "\t-s disable colours"
end

local quiet, grey, test_regex
if arg then
    for i = 1, #arg do
        if arg[i] == "-h" then
            print_help()
            os.exit(0)
        elseif arg[i] == "-q" then
            quiet = true
        elseif arg[i] == "-s" then
            grey = true
        elseif not test_regex then
            test_regex = arg[i]
        else
            print_help()
            os.exit(1)
        end
    end
end
-- UTILS -----------------------------------------------------------------------
local function red(str)    return grey and str or "\27[1;31m" .. str .. "\27[0m" end
local function blue(str)   return grey and str or "\27[1;34m" .. str .. "\27[0m" end
local function green(str)  return grey and str or "\27[1;32m" .. str .. "\27[0m" end
local function yellow(str) return grey and str or "\27[1;33m" .. str .. "\27[0m" end

local tab_tag      = blue   "[----------]"
local done_tag     = blue   "[==========]"
local run_tag      = blue   "[ RUN      ]"
local ok_tag       = green  "[       OK ]"
local fail_tag     = red    "[      FAIL]"
local disabled_tag = yellow "[ DISABLED ]"
local passed_tag   = green  "[  PASSED  ]"
local failed_tag   = red    "[  FAILED  ]"

local ntests = 0
local failed = false
local nfailed = 0

local function trace(start_frame)
    print "Trace:"
    local frame = start_frame
    while true do
        local info = debug.getinfo(frame, "Sl")
        if not info then break end
        if info.what == "C" then
            print(frame - start_frame, "??????")
        else
            print(frame - start_frame, info.short_src .. ":" .. info.currentline .. " ")
        end
        frame = frame + 1
    end
end

local function log(msg)
    if not quiet then
        print(msg)
    end
end

local function fail(msg, start_frame)
    failed = true
    print("Fail: " .. msg)
    trace(start_frame or 4)
end

-- PUBLIC API -----------------------------------------------------------------
local api = { test_suite_name = "__root", skip = false }
api.equal = function (l, r)
    if l ~= r then
        fail(tostring(l) .. " ~= " .. tostring(r))
    end
end

api.not_equal = function (l, r)
    if l == r then
        fail(tostring(l) .. " == " .. tostring(r))
    end
end

api.almost_equal = function (l, r, diff)
    if require("math").abs(l - r) > diff then
        fail("(" .. tostring(l) .. " - " .. tostring(r) ..") > " .. tostring(diff))
    end
end

api.is_false = function (maybe_false)
    if maybe_false or type(maybe_false) ~= "boolean" then
        fail("got " .. tostring(maybe_false) .. " instead of false")
    end
end

api.is_true = function (maybe_true)
    if not maybe_true or type(maybe_true) ~= "boolean" then
        fail("got " .. tostring(maybe_true) .. " instead of true")
    end
end

api.is_not_nil = function (maybe_not_nil)
    if type(maybe_not_nil) == "nil" then
        fail("got " .. tostring(maybe_not_nil) .. " instead of nil")
    end
end

local function make_type_checker(typename)
    api["is_" .. typename] = function (maybe_type)
        if type(maybe_type) ~= typename then
            fail("got " .. tostring(maybe_type) .. " instead of " .. typename, 5)
        end
    end
end

local supported_types = {"nil", "boolean", "string", "number", "userdata", "table", "function", "thread"}
for i, supported_type in ipairs(supported_types) do
    make_type_checker(supported_type)
end

local last_test_suite
local function run_test(test_suite, test_name, test_function)
    local test_suite_name = test_suite.test_suite_name
    local full_test_name = test_name
    if test_suite_name ~= "__root" then
        full_test_name = test_suite_name .. "." .. full_test_name
    end

    if test_regex and not string.match(full_test_name, test_regex) then
        return
    end

    if test_suite.skip then
        log(disabled_tag .. " " .. full_test_name)
        return
    end


    if test_suite_name ~= last_test_suite then
        log(tab_tag)
        last_test_suite = test_suite_name
    end

    ntests = ntests + 1
    failed = false

    log(run_tag .. " " .. full_test_name)

    local start = os.time()

    local status, err
    for _, f in ipairs({test_suite.start_up,  test_function, test_suite.tear_down}) do
        status, err = pcall(f)
        if not status then
            failed = true
            print(tostring(err))
        end
    end

    local stop = os.time()

    local is_test_failed = not status or failed
    log(string.format("%s %s %d sec",
                            is_test_failed and fail_tag or ok_tag,
                            full_test_name,
                            os.difftime(stop, start)))

    if is_test_failed then
        nfailed = nfailed + 1
    end
end

api.summary = function ()
    log(done_tag)
    if nfailed == 0 then
        print(passed_tag .. " " .. ntests .. " test(s)")
        os.exit(0)
    else
        print(failed_tag .. " " .. nfailed .. " out of " .. ntests)
        os.exit(1)
    end
end

api.result = function ( ... )
    return ntests, nfailed
end

local default_start_up = function () end
local default_tear_down = function () collectgarbage() end

api.start_up = default_start_up
api.tear_down = default_tear_down

local function new_test_suite(_, name)
    local test_suite = {
        test_suite_name = name,
        start_up = default_start_up,
        tear_down = default_tear_down,
        skip = false }
    setmetatable(test_suite, { __newindex = run_test })
    return test_suite
end

local all_cases = {}
setmetatable(api, {
    __index = function (tbl, name)
        if not all_cases[name] then
            all_cases[name] = new_test_suite(tbl, name)
        end
        return all_cases[name]
    end,
    __newindex = run_test
})

return api