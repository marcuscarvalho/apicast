local TimerPoolExecutor = require('resty.concurrent.timer_pool_executor')

local function yield() ngx.sleep(0) end

local noop = function() end

describe('TimerPoolExecutor', function()
    describe('worker garbage collection', function()
        it('automatically checks in back old workers', function()
            local pool = TimerPoolExecutor.new({ max_timers = 1 })

            assert(pool:post(noop):wait(1))
            yield()
            assert.equal(0, #pool)
            assert(pool:post(noop):wait(1))
        end)

        it('puts back worker even when task crashes', function ()
            local pool = TimerPoolExecutor.new({ max_timers = 1 })

            assert(pool:post(error):wait(1))
            yield()
            assert.equal(0, #pool)
            assert(pool:post(error):wait(1))
        end)
    end)

    describe('fallback policies', function()
        it('can discard tasks', function()
            local pool = TimerPoolExecutor.new({ max_timers = 0, fallback_policy = 'discard' })

            assert.returns_error('rejected execution', pool:post(noop))
        end)

        it('can throw error', function()
            local pool = TimerPoolExecutor.new({ max_timers = 0, fallback_policy = 'abort' })

            assert.has_error(function() pool:post(noop) end, 'rejected execution')
        end)

        it('can run within the caller', function()
            local pool = TimerPoolExecutor.new({ max_timers = 0, fallback_policy = 'caller_runs' })
            local task = spy.new(function () return coroutine.running() end)

            assert(pool:post(task))

            assert.spy(task).was_called(1)
            assert.spy(task).was_returned_with(coroutine.running())
        end)
    end)
end)
